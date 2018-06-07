#!/usr/bin/env bats
# -*- mode: sh -*-

INVALID_CHARS=": / + ; . Ã¤"   # [a-zA-Z0-9_-]+

@test "Invalid characters in systemid should fail" {
    for CHAR in ${INVALID_CHARS} ; do
        run ${BATS_SHELL} ./beaconcli.sh -i "${CHAR}" 00c01a
        [ $status -eq 1 ]
        EXPECTED="Error: Systemid contains invalid characters*"
        [[ "${lines[0]}" =~ $EXPECTED ]]
    done
}

@test "Invalid color should fail" {
    for CHAR in ${INVALID_CHARS} ; do
        run ${BATS_SHELL} ./beaconcli.sh -i 0xdeadbeef ff0${CHAR}ff
        [ $status -eq 1 ]
        [ "${lines[0]}" = "Error: color contains invalid characters." ]
    done
}
