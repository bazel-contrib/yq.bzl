"Support calls from MODULE.bazel to setup the toolchains"

load("//yq/toolchain:platforms.bzl", "YQ_PLATFORMS", "yq_platform_repo")
load("//yq/toolchain:toolchain.bzl", "yq_toolchains_repo")
load("//yq/toolchain:versions.bzl", "DEFAULT_YQ_VERSION")

def _toolchain_extension(module_ctx):
    # Iterate over the global view of all `yq` extension calls
    for mod in module_ctx.modules:
        for toolchain in mod.tags.toolchain:
            if toolchain.name != "yq" and not mod.is_root:
                fail("""\
                Only the root module may override the default name for the yq toolchains.
                This prevents conflicting registrations in the global namespace of external repos.
                """)

            for [platform, _] in YQ_PLATFORMS.items():
                yq_platform_repo(
                    name = "%s_%s" % (toolchain.name, platform),
                    platform = platform,
                    version = toolchain.version,
                )

            yq_toolchains_repo(name = "%s_toolchains" % toolchain.name, user_repository_name = toolchain.name)

toolchain = tag_class(attrs = {
    "name": attr.string(doc = """\
Base name for generated repositories, allowing more than one set of toolchains to be registered.
Overriding the default is only permitted in the root module.
""", default = "yq"),
    "version": attr.string(doc = """\
Version of yq to use.
""", default = DEFAULT_YQ_VERSION),
})

yq = module_extension(
    implementation = _toolchain_extension,
    tag_classes = {
        "toolchain": toolchain,
    },
)
