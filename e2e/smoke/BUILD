"""Provides a simple way to test your rules as an external workspace.
Add a basic smoke-test target below.
"""

load("@aspect_bazel_lib//lib:testing.bzl", "assert_contains")
load("@yq.bzl", "yq")

yq(
    name = "no_srcs",
    srcs = [],
    expression = ".name = \"Alice\"",
)

assert_contains(
    name = "smoke_test",
    actual = "no_srcs.yaml",
    expected = "name: Alice",
)
