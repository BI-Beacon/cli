#!/bin/sh

TMPDR="$(mktemp -d)"

git config --global user.email "travis@travis-ci.org"
git config --global user.name "Travis CI"

git checkout -b artifacts https://${GH_TOKEN}github.com/BI-Beacon/build-artifacts.git "${TMPDR}"

./dist/make-install-sh.sh
cp dist/install-sh "${TMPDR}"

cd "${TMPDR}"
git add install-sh
git commit -m 'Automated build' .
git push

