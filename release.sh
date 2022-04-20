#!/usr/bin/env bash

set -euo pipefail

dir="$( cd -- "${BASH_SOURCE[0]%/*}" &> /dev/null && pwd )"
cd $dir

log=$(mktemp)
trap "echo 'Build failed, logs:'; cat $log" EXIT

if [ "$CI" != "true" ]; then
    echo "This script is meant to be run on CI only."
fi

version_for_path() (
    set -euo pipefail
    folder=$1
    commit_sha_8=$(git log -n1 --format=%h --abbrev=8 -- $dir/$folder)
    commit_date=$(git log -n1 --format=%cd --date=format:%Y%m%d $commit_sha_8)
    commit_index=$(git rev-list --count $commit_sha_8)
    echo "0.0.0-$commit_date.$commit_index.sha$commit_sha_8"
)

project_on_maven() (
    set -euo pipefail
    curl -I --silent --fail "https://repo1.maven.org/maven2/com/daml/${1}_2.13/$2/" 1>$log 2>&1
)

gcs_bucket=daml-app-runtime-ci-state

project_on_gcs() (
    set -euo pipefail
    gsutil ls gs://$gcs_bucket/$1/$2 1>$log 2>&1
)

push_to_maven() (
    set -euo pipefail
    cd $1
    export VERSION=$2
    sbt ci-release 2>&1 | tee $log | grep '\[promote\] Finished successfully'
)

push_to_gcs() (
    set -euo pipefail
    tmp=$(mktemp)
    echo $2 > $tmp
    gsutil cp $tmp gs://$gcs_bucket/$1/$2
)

for project in scalatest-utils; do (
    version=$(version_for_path $project)
    if project_on_maven $project $version; then
        echo "[$project] $version available on Maven Central."
    elif project_on_gcs $project $version; then
        echo "[$project] $version pushed, but not yet available."
    else
        echo "[$project] publishing $version"
        push_to_maven $project $version
        push_to_gcs $project $version
        echo "[$project] Done."
    fi
) done

trap - EXIT

echo "Success."
