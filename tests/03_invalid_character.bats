#!/usr/bin/env bats
# -*- mode: sh -*-

INVALID_CHARS=": / + ; . Ã¤"   # [a-zA-Z0-9_-]+

@test "Invalid characters in channelkey should fail" {
    for CHAR in ${INVALID_CHARS} ; do
        run ${BATS_SHELL} ./beaconcli.sh -k "${CHAR}" 00c01a
        [ $status -eq 1 ]
        EXPECTED="Error: Channelkey contains invalid characters*"
        [[ "${lines[0]}" =~ $EXPECTED ]]
    done
}

@test "Invalid color should fail" {
    for CHAR in ${INVALID_CHARS} ; do
        run ${BATS_SHELL} ./beaconcli.sh -k 0xdeadbeef ff0${CHAR}ff
       echo "[[[${lines[0]}]]]"
        [ $status -eq 1 ]
        [ "${lines[0]}" = "Error: Color contains invalid characters." ]
    done
}
