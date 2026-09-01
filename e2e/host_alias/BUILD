"""Exercises the @yq host alias repo without resolving the yq toolchain.

Do not add yq() targets here; that would defeat the purpose of this workspace.
"""

load("@rules_shell//shell:sh_test.bzl", "sh_test")

sh_test(
    name = "yq_host_alias_test",
    srcs = ["tests/yq_host_alias.sh"],
    data = ["@yq"],
    env = {"YQ": "$(rootpath @yq)"},
)
