#!/usr/bin/env bash

set -euo pipefail

dir="$( cd -- "${BASH_SOURCE[0]%/*}" &> /dev/null && pwd )"
cd $dir

PROJECT=$1
VERSION=$2

if [ "$CI" != "true" ]; then
    echo "This script is meant to be run on CI only."
fi

cd $PROJECT
sbt ci-release
