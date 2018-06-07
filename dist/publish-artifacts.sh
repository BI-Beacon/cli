#!/bin/sh

set -x

set

TMPDR="$(mktemp -d)"

./dist/make-install-sh.sh

git config --global user.email "travis@travis-ci.org"
git config --global user.name "Travis CI"

git clone -b artifacts https://${GH_TOKEN}@github.com/BI-Beacon/build-artifacts.git "${TMPDR}"

cp dist/install-sh "${TMPDR}/cli"

cd "${TMPDR}"
git add cli/install-sh
git commit -m 'Automated build' .
git push

