"Support calls from MODULE.bazel to setup the toolchains"

load("//yq/toolchain:platforms.bzl", "YQ_PLATFORMS", "yq_platform_repo")
load("//yq/toolchain:toolchain.bzl", "yq_host_alias_repo", "yq_toolchains_repo")
load("//yq/toolchain:versions.bzl", "DEFAULT_YQ_VERSION")

def _toolchains_extension(_):
    name = "yq"
    version = DEFAULT_YQ_VERSION
    for [platform, _] in YQ_PLATFORMS.items():
        yq_platform_repo(
            name = "%s_%s" % (name, platform),
            platform = platform,
            version = version,
        )

    yq_host_alias_repo(name = name)

    yq_toolchains_repo(name = "%s_toolchains" % name, user_repository_name = name)

toolchains = module_extension(
    implementation = _toolchains_extension,
)
