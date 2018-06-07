#!/usr/bin/env bats
# -*- mode: sh -*-

@test "Examples should produce output" {
    run ${BATS_SHELL} ./beaconcli.sh --examples
    [ $status -eq 0 ]
    EXPECTED="Usage examples:*"
    [[ "${lines[0]}" =~ ${EXPECTED} ]]
}
