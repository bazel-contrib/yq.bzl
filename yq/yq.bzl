"""
Load in your `BUILD` file:

```starlark
load("@yq.bzl", "yq")
```

Examples
--------

Remove fields:
```starlark
yq(
    name = "safe-config",
    srcs = ["config.yaml"],
    expression = "del(.credentials)",
)
```

Merge two yaml documents:
```starlark
yq(
    name = "ab",
    srcs = [
        "a.yaml",
        "b.yaml",
    ],
    expression = ". as $item ireduce ({}; . * $item )",
)
```

Split a yaml file into several files:
```starlark
yq(
    name = "split",
    srcs = ["multidoc.yaml"],
    outs = [
        "first.yml",
        "second.yml",
    ],
    args = [
        "-s '.a'",  # Split expression
        "--no-doc", # Exclude document separator --
    ],
)
```

Convert a yaml file to json:
```starlark
yq(
    name = "convert-to-json",
    srcs = ["foo.yaml"],
    args = ["-o=json"],
    outs = ["foo.json"],
)
```

Convert a json file to yaml:
```starlark
yq(
    name = "convert-to-yaml",
    srcs = ["bar.json"],
    args = ["-P"],
    outs = ["bar.yaml"],
)
```

Call yq in a genrule:
```starlark
genrule(
    name = "generate",
    srcs = ["farm.yaml"],
    outs = ["genrule_output.yaml"],
    cmd = "$(YQ_BIN) '.moo = \"cow\"' $(location farm.yaml) > $@",
    toolchains = ["@yq_toolchains//:resolved_toolchain"],
)
```

With --stamp, causes properties to be replaced by version control info.
```starlark
yq(
    name = "stamped",
    srcs = ["package.yaml"],
    expression = "|".join([
        "load(strenv(STAMP)) as $stamp",
        # Provide a default using the "alternative operator" in case $stamp is empty dict.
        ".version = ($stamp.BUILD_EMBED_LABEL // "<unstamped>")",
    ]),
)
```
"""

load("@bazel_lib//lib:diff_test.bzl", "diff_test")
load("//yq/private:yq.bzl", _is_split_operation = "is_split_operation", _yq_lib = "yq_lib")

_yq_rule = rule(
    attrs = _yq_lib.attrs,
    implementation = _yq_lib.implementation,
    toolchains = ["@yq.bzl//yq/toolchain:type"],
)

def yq_test(name, file1, file2, filter1 = ".", filter2 = ".", **kwargs):
    """Assert that the given YAML files have the same semantic content.

    Uses yq to filter each file, recursively sort mapping keys, and serialize
    the results as compact JSON before comparing them. The default filter of
    `"."` compares each whole file.

    Args:
        name: Name of the resulting diff_test target.
        file1: A YAML file.
        file2: Another YAML file.
        filter1: A yq expression to apply to file1.
        filter2: A yq expression to apply to file2.
        **kwargs: Additional named arguments for the resulting diff_test.
    """
    name1 = "{}_yq1".format(name)
    name2 = "{}_yq2".format(name)
    normalize_args = [
        "--output-format=json",
        "--indent=0",
    ]
    _yq_rule(
        name = name1,
        srcs = [file1],
        expression = "({}) | sort_keys(..)".format(filter1),
        args = normalize_args,
        outs = [name1 + ".json"],
    )
    _yq_rule(
        name = name2,
        srcs = [file2],
        expression = "({}) | sort_keys(..)".format(filter2),
        args = normalize_args,
        outs = [name2 + ".json"],
    )

    diff_test(
        name = name,
        file1 = name1,
        file2 = name2,
        failure_message = "'{}' from {} doesn't match '{}' from {}".format(
            filter1,
            file1,
            filter2,
            file2,
        ),
        **kwargs
    )

def yq(name, srcs, expression = ".", args = [], outs = None, **kwargs):
    """Invoke yq with an expression on a set of input files.

    yq is capable of parsing and outputting to other formats. See their [docs](https://mikefarah.gitbook.io/yq) for more examples.

    Args:
        name: Name of the rule
        srcs: List of input file labels
        expression: yq expression (https://mikefarah.gitbook.io/yq/commands/evaluate).

            Defaults to the identity expression ".".
            Subject to stamp variable replacements, see [Stamping](./stamping.md).
            When stamping is enabled, an environment variable named "STAMP" will be available in the expression.

            Be careful to write the filter so that it handles unstamped builds, as in the example above.

        args: Additional args to pass to yq.

            Note that you do not need to pass _eval_ or _eval-all_ as this is handled automatically based on the number `srcs`.
            Passing the output format or the parse format is optional as these can be guessed based on the file extensions in `srcs` and `outs`.

        outs: Name of the output files.

            Defaults to a single output with the name plus a ".yaml" extension, or the extension corresponding to a passed output argument such as `"-o=json"`.
            For split operations you must declare all outputs, as the name of the output files depends on the expression.

        **kwargs: Other common named parameters such as `tags` or `visibility`
    """
    args = args[:]

    if not _is_split_operation(args):
        # For split operations we can't predeclare outs because the name of the resulting files
        # depends on the expression. For non-split operations, set a default output file name
        # based on the name and the output format passed, defaulting to yaml.
        if not outs:
            outs = [name + ".yaml"]
            if "-o=json" in args or "--outputformat=json" in args:
                outs = [name + ".json"]
            if "-o=xml" in args or "--outputformat=xml" in args:
                outs = [name + ".xml"]
            elif "-o=props" in args or "--outputformat=props" in args:
                outs = [name + ".properties"]
            elif "-o=c" in args or "--outputformat=csv" in args:
                outs = [name + ".csv"]
            elif "-o=t" in args or "--outputformat=tsv" in args:
                outs = [name + ".tsv"]

        elif outs and len(outs) == 1:
            # If an output file with an extension was provided, try to set the corresponding output
            # argument if it wasn't already passed.
            if outs[0].endswith(".json") and "-o=json" not in args and "--outputformat=json" not in args:
                args.append("-o=json")
            elif outs[0].endswith(".xml") and "-o=xml" not in args and "--outputformat=xml" not in args:
                args.append("-o=xml")
            elif outs[0].endswith(".properties") and "-o=props" not in args and "--outputformat=props" not in args:
                args.append("-o=props")
            elif outs[0].endswith(".csv") and "-o=c" not in args and "--outputformat=csv" not in args:
                args.append("-o=c")
            elif outs[0].endswith(".tsv") and "-o=t" not in args and "--outputformat=tsv" not in args:
                args.append("-o=t")

    # If the input files are json or xml, set the parse flag if it isn't already set.
    # Select statements can't be inspected by macros, so if you're using configurable
    # attributes, you'll need to add the -P or -p=xml arguments yourself as needed.
    if type(srcs) != "select" and len(srcs) > 0:
        first_label = native.package_relative_label(srcs[0])
        if first_label.name.endswith(".json") and "-P" not in args:
            args.append("-P")
        elif first_label.name.endswith(".xml") and "-p=xml" not in args:
            args.append("-p=xml")

    _yq_rule(
        name = name,
        srcs = srcs,
        expression = expression,
        args = args,
        outs = outs,
        **kwargs
    )
