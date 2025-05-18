<!-- Generated with Stardoc: http://skydoc.bazel.build -->

Public API for calling yq

<a id="yq_rule"></a>

## yq_rule

<pre>
load("@yq.bzl//yq:yq.bzl", "yq_rule")

yq_rule(<a href="#yq_rule-name">name</a>, <a href="#yq_rule-srcs">srcs</a>, <a href="#yq_rule-data">data</a>, <a href="#yq_rule-out">out</a>, <a href="#yq_rule-args">args</a>, <a href="#yq_rule-expand_args">expand_args</a>, <a href="#yq_rule-filter">filter</a>, <a href="#yq_rule-filter_file">filter_file</a>, <a href="#yq_rule-stamp">stamp</a>)
</pre>

Most users should use the `yq` macro instead.

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="yq_rule-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="yq_rule-srcs"></a>srcs |  -   | <a href="https://bazel.build/concepts/labels">List of labels</a> | required |  |
| <a id="yq_rule-data"></a>data |  -   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="yq_rule-out"></a>out |  -   | <a href="https://bazel.build/concepts/labels">Label</a>; <a href="https://bazel.build/reference/be/common-definitions#configurable-attributes">nonconfigurable</a> | optional |  `None`  |
| <a id="yq_rule-args"></a>args |  -   | List of strings | optional |  `[]`  |
| <a id="yq_rule-expand_args"></a>expand_args |  -   | Boolean | optional |  `False`  |
| <a id="yq_rule-filter"></a>filter |  -   | String | optional |  `""`  |
| <a id="yq_rule-filter_file"></a>filter_file |  -   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `None`  |
| <a id="yq_rule-stamp"></a>stamp |  Whether to encode build information into the output. Possible values:<br><br>- `stamp = 1`: Always stamp the build information into the output, even in     [--nostamp](https://docs.bazel.build/versions/main/user-manual.html#flag--stamp) builds.     This setting should be avoided, since it is non-deterministic.     It potentially causes remote cache misses for the target and     any downstream actions that depend on the result. - `stamp = 0`: Never stamp, instead replace build information by constant values.     This gives good build result caching. - `stamp = -1`: Embedding of build information is controlled by the     [--[no]stamp](https://docs.bazel.build/versions/main/user-manual.html#flag--stamp) flag.     Stamped targets are not rebuilt unless their dependencies change.   | Integer | optional |  `-1`  |


<a id="yq"></a>

## yq

<pre>
load("@yq.bzl//yq:yq.bzl", "yq")

yq(<a href="#yq-name">name</a>, <a href="#yq-srcs">srcs</a>, <a href="#yq-filter">filter</a>, <a href="#yq-filter_file">filter_file</a>, <a href="#yq-args">args</a>, <a href="#yq-out">out</a>, <a href="#yq-data">data</a>, <a href="#yq-expand_args">expand_args</a>, <a href="#yq-kwargs">**kwargs</a>)
</pre>

Invoke yq with a filter on a set of json input files.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="yq-name"></a>name |  Name of the rule   |  none |
| <a id="yq-srcs"></a>srcs |  List of input files. May be empty.   |  none |
| <a id="yq-filter"></a>filter |  Filter expression (https://stedolan.github.io/yq/manual/#Basicfilters). Subject to stamp variable replacements, see [Stamping](./stamping.md). When stamping is enabled, a variable named "STAMP" will be available in the filter.<br><br>Be careful to write the filter so that it handles unstamped builds, as in the example above.   |  `None` |
| <a id="yq-filter_file"></a>filter_file |  File containing filter expression (alternative to `filter`)   |  `None` |
| <a id="yq-args"></a>args |  Additional args to pass to yq   |  `[]` |
| <a id="yq-out"></a>out |  Name of the output json file; defaults to the rule name plus ".json"   |  `None` |
| <a id="yq-data"></a>data |  List of additional files. May be empty.   |  `[]` |
| <a id="yq-expand_args"></a>expand_args |  Run bazel's location and make variable expansion on the args.   |  `False` |
| <a id="yq-kwargs"></a>kwargs |  Other common named parameters such as `tags` or `visibility`   |  none |


