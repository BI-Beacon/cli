#!/bin/bash

WD="$(dirname "$0")"

(
    echo "#!/bin/sh"
    echo "base64 -d | gzip -cd | install -m 755 -o root /dev/stdin /usr/local/bin/beaconcli' <<EOT"
    gzip -c9 < ${WD}/../beaconcli.sh | base64
    echo "EOT"
) > ${WD}/install-sh

