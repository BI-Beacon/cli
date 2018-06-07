#!/bin/sh

## ${PROGNAME} version ###VERSION###
## Usage: ${PROGNAME} [-h] | { [-c|--config-file <FILE>]
##        ${PROGPADD}          [-s|--state-server <URL>]
##        ${PROGPADD}          [-i|--systemid <ID>]
##        ${PROGPADD}          [-X|--extra <DATA>]
##        ${PROGPADD}          <color>[,<period>] }
##        ${PROGNAME} [--examples]
## 
##  Tool for setting the state of a given beacon systemid.
##
##   -h, --help
##          Display this helpful usage information
##
##   -c, --config-file <FILE>
##          Read additional  configuration from  this file.   The file
##          format for  the configuration file  is a simple  flat file
##          with key-value pairs, delimitered by the equals (=) sign.
##  
##          Currently, only two options can be set, "state_server" and
##          "systemid".
##
##          Example:
##          ----------------------------------------------------------
##          state_server = https://server.bi-beacon.se/api/v1/
##          systemid = 0xdeadbeef
##          ----------------------------------------------------------
##          (Default value: '${CONFIG_FILE}'.)
## 
##   -s, --state-server <URL>
##          The URL of the state server.
##          (Default value: '${STATE_SERVER}'.)
##
##   -i, --systemid <ID>
##          Chooses which systemid to set  the state for. The systemid
##          must  be set,  either  via configuration  file  or on  the
##          command line.
##          (Default value: '${SYSTEMID}'.)
##
##   -X, --extra <DATA>
##          Send additional data to the server.
##
##   <color>[,<period>]
##          The color to set the  given systemid to. If the additional
##          argument <period>  is given,  the beacon will  pulsate the
##          given   color   with   the   specified   periodicity   (in
##          milliseconds).
##
##          The format of <color> is [#]<RR><GG><BB>.
##
##   Unless  a configuration  file  is specified  on the  command-line
##   (using the  -c option),  we will  read the  contents of  the file
##   ${CONFIG_FILE_SYSTEM} if it exists, as well as ${CONFIG_FILE_USER}.
##
## Blame (most) bugs on: Martin Kjellstrand <martin.kjellstrand@madworx.se>.

attempt_read_config() {
    if [ -r "$1" ] ; then
        # shellcheck disable=SC1117
        READ_SYSTEMID=$(awk -F"[\t ]*=[\t ]*" '$1 = /systemid/ { print $2 }' "$1")
        # shellcheck disable=SC1117
        READ_STATESRV=$(awk -F"[\t ]*=[\t ]*" '$1 = /state_server/ { print $2 }' "$1")
        
        CONF_SYSTEMID="${READ_SYSTEMID:=$CONF_SYSTEMID}"
        CONF_STATESRV="${READ_STATESRV:=$CONF_STATESRV}"
    fi
}

# Non-user configurable defaults:
CONFIG_FILE_SYSTEM="/etc/bi-beacon.conf"
CONFIG_FILE_USER="${HOME}/.bi-beacon.conf"

attempt_read_config "${CONFIG_FILE_SYSTEM}"
attempt_read_config "${CONFIG_FILE_USER}"


# Our default values:
: "${STATE_SERVER:=https://api.cilamp.se/v1}"

#
# Print the usage  of this tool. Extracts this  documentation from the
# source code of the script itself.
#
program_path="$0"
usage() {
    export PROGNAME="${program_path##*/}"
    # shellcheck disable=SC2001
    PROGPADD="$(echo "${PROGNAME}" | sed 's#.# #g')"
    export PROGPADD
    (echo "cat <<EOT"
     sed -n 's/^## \?//p' < "${program_path}"
     echo "EOT") > /tmp/.help.$$
    # shellcheck disable=SC1090
    . /tmp/.help.$$ ; rm /tmp/.help.$$
}

if [ "$#" -lt 1 ] ; then
    usage
    exit 1
fi

usage_examples() {
    PROGNAME="${program_path##*/}"
    cat <<EOF
Usage examples:

     \$ ${PROGNAME} -i my.system.id 550055
     \$ ${PROGNAME} -s https://we.corp.eu/cilamp/api/v1 \\
                    -i my.system.id FF0000,3000


Blame (most) bugs on: Martin Kjellstrand <martin.kjellstrand@madworx.se>.
EOF
}

# Parse command line options:
while [ "$#" -gt 0 ] ; do
    case "$1" in
        -c|--config-file) CONFIG_FILE="$2" ; shift 2 ;;
        -i|--systemid) SYSTEMID="$2" ; shift 2 ;;
        -X|--extra) EXTRAS="${EXTRAS} $2" ; shift ;;
        --examples) usage_examples ; exit 0 ;;
        -h|--help) usage ; exit 0 ;;
        -*) echo "Error: Unknown option '$1'." 1>&2 ; exit 1 ;;
        *) COLOR="$1" ; shift ;;
    esac
done

# If config-file is set, it must be readable:
if [ ! -z "${CONFIG_FILE}" ] ; then
    if [ ! -r "${CONFIG_FILE}" ] ; then
        echo "Error: Given configuration file \`${CONFIG_FILE}' isn't readable." 1>&2
        exit 1
    fi
    attempt_read_config "${CONFIG_FILE}"
fi

SYSTEMID="${SYSTEMID-${CONF_SYSTEMID}}"
STATE_SERVER="${STATE_SERVER-${CONF_STATESRV}}"

# Sanity check on systemid:
if [ -z "${SYSTEMID}" ] ; then
    echo "Error: Systemid must be set." 1>&2
    exit 1
else
    # shellcheck disable=SC2001
    REST="$(echo "${SYSTEMID}" | sed 's#[a-zA-Z0-9_-]##g')"
    if [ ! -z "${REST}" ] ; then
        echo "Error: Systemid contains invalid characters. \`${REST}'" 1>&2
        exit 1
    fi
fi

SYSTEMID="${SYSTEMID-${CONF_SYSTEMID}}"
STATE_SERVER="${STATE_SERVER-${CONF_STATESRV}}"

# Sanity check on systemid:
if [ -z "${SYSTEMID}" ] ; then
    echo "Error: Systemid must be set."
    usage
    exit 1
fi

# Sanity check for 'curl' binary.
which curl >/dev/null 2>&1 || (
    cat 1>&2 <<EOF
Error: This utility requires the 'curl' program to be installed.

Depending on your operating system  distribution, you might be able to
install it by typing:

  # DEB (Ubuntu/Debian etc)
  $ sudo apt-get install curl

  # RPM (RedHat/CentOS/Fedora etc)
  $ sudo yum install curl

EOF
    exit 1
)

# Sanity check on the color and period argument(s).
if [ -z "${COLOR}" ] ; then
    echo "Error: Color must be set on the command-line." 1>&2
    exit 1
fi

COLOR="${COLOR},0"
PERIOD="${COLOR#*,}"
PERIOD="${PERIOD%,*}"
COLOR="${COLOR%%,*}"

# shellcheck disable=SC2001
if [ ! -z "$(echo "${COLOR}" | sed 's#[a-zA-Z0-9_-]##g')" ] ; then
    echo "Error: color contains invalid characters." 1>&2
    usage
    exit 1
fi


curl -F "color=${COLOR}" -F "period=${PERIOD}" "${STATE_SERVER}/${SYSTEMID}/"
