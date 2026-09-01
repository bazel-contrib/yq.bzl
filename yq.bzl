"Re-export for syntax sugar load"

load("//yq:yq.bzl", _yq = "yq", _yq_test = "yq_test")

yq = _yq
yq_test = _yq_test
