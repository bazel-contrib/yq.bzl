# host alias test

This e2e covers `@yq//:yq`, the host alias repo, _in isolation_.

`@yq//:yq` is a symlink into the sibling `@yq_{platform}` repository. Nothing
in this workspace resolves the yq toolchain, so if creating that symlink ever
stopped registering a dependency on the platform repository, the platform repo
would go unfetched and `@yq//:yq` would be a dangling symlink.

That is why this is a separate workspace from `e2e/smoke`: `bazel test //...`
there also builds `yq()` targets, which resolve the yq toolchain and materialize
`@yq_{platform}` as a side effect, so it cannot tell the two cases apart.
