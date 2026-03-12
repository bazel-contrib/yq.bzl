#!/usr/bin/env bash
set -euo pipefail

output=$("$YQ" --version)
if [[ ! "$output" =~ "yq" ]]; then
  echo "ERROR: Expected 'yq' in version output, got: $output"
  exit 1
fi
