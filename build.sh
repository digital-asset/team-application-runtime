#!/usr/bin/env bash

set -euo pipefail

dir="$( cd -- "${BASH_SOURCE[0]%/*}" &> /dev/null && pwd )"
cd $dir

for project in scalatest-utils; do (
    cd $project
    sbt test
) done
