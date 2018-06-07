#!/bin/bash

if [ "${TRAVIS_BRANCH}" == "master" ] ; then
    TMPDR="$(mktemp -d)"

    sed -e "s%###VERSION###$(date +%Y%m%d)-$(git rev-parse master | cut -c1-7)##%" \
        -i dist/beaconcli.sh

    ./dist/make-install-sh.sh

    git config --global user.email "travis@travis-ci.org"
    git config --global user.name  "Travis CI"
    
    git clone -b artifacts https://${GH_TOKEN}@github.com/BI-Beacon/build-artifacts.git "${TMPDR}"

    install -m 755 dist/install-sh "${TMPDR}/cli"
    install -m 755 beaconcli.sh    "${TMPDR}/cli/beaconcli"

    cd "${TMPDR}"
    find . -type f -not -path "*/.git*" -not -name SHA1SUMS | xargs sha1sum | sort -k+2 > SHA1SUMS
    git add cli/install-sh cli/beaconcli SHA1SUMS
    git commit -m 'Automated build' .
    git push
fi

