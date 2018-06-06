#!/bin/sh

## Usage: ${PROGNAME} [-h] | { [-c|--config-file <FILE>]
##        ${PROGNAME}          [-s|--state-server <URL>]
##        ${PROGPADD}          [-i|--systemid <ID>]
##        ${PROGPADD}          [-X|--extra <DATA>]
##        ${PROGPADD}          <colour>[,<period>] }
##
##  Tool for setting the state of a given beacon systemid.
##
##   -h, --help
##          Display this helpful usage information
##
##   -c, --config-file <FILE>
##          Use  this configuration  file.   The file  format for  the
##          configuration file  is a  simple flat file  with key-value
##          pairs, delimitered by the equals (=) sign.
##  
##          Currently, only two options can be set, "state_server" and
##          "systemid".
##
##          Example:
##          ----------------------------------------------------------
##          state_server = https://server.bi-beacon.se/api/v1/
##          systemid = 0xdeadbeef
##          ----------------------------------------------------------
##
##          If  this argument  is used,  no other  configuration files
##          will be read.
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
##   <colour>[,<period>]
##          The colour to set the given systemid to. If the additional
##          argument <period>  is given,  the beacon will  pulsate the
##          given   colour   with   the  specified   periodicity   (in
##          milliseconds).
##
##
##   Unless  a configuration  file  is specified  on the  command-line
##   (using the  -c option),  we will  read the  contents of  the file
##   /etc/bi-beacon.conf if it exists, as well as ~/.bi-beacon.conf.
##
## Blame (most) bugs on: Martin Kjellstrand <martin.kjellstrand@madworx.se>.

# Our default values:
SYSTEMID=""
CONFIG_FILE=""
STATE_SERVER="https://api.cilamp.se/v1"

#
# Print the usage  of this tool. Extracts this  documentation from the
# source code of the script itself.
#
program_path="$0"
usage() {
    export PROGNAME="${program_path##*/}"
    PROGPADD="$(echo "${PROGNAME}" | sed 's#.# #g')"
    export PROGPADD
    (echo "cat <<EOT"
     sed -n 's/^## \?//p' < "${program_path}"
     echo "EOT") > /tmp/.help.$$ ; . /tmp/.help.$$ ; rm /tmp/.help.$$
}

# Parse command line options:
while [ "$#" -gt 0 ] ; do
    case "$1" in
        -c|--config_file) CONFIG_FILE="$2" ; shift 2 ;;
        -i|--systemid) SYSTEMID="$2" ; shift 2 ;;
        -X|--extra) EXTRAS="${EXTRAS} $2" ; shift ;;
        -h|--help) usage ; exit 0 ;;
        -*) echo "Error: Unknown option '$1'." 1>&2 ; usage ; exit 1 ;;
        *) COLOUR="$1" ; shift ;;
    esac
done

# Sanity check that colour has been set:
if [ -z "${COLOUR}" ] ; then
    echo "Error: Colour must be set on the command-line." 1>&2
    usage
    exit 1
fi

COLOUR="${COLOUR},0"
PERIOD="${COLOUR#*,}"
PERIOD="${PERIOD%,*}"
COLOUR="${COLOUR%%,*}"
COLOURSTR="-F color=${COLOUR} -F period=${PERIOD}"

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
)

curl ${COLOURSTR} "${STATE_SERVER}/${SYSTEMID}/"
