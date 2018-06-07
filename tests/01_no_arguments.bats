#!/usr/bin/env bats
# -*- mode: sh -*-

@test "No arguments should fail." {
  ! ${BATS_SHELL} ./beaconcli.sh
}

@test "No arguments should result in correct error message." {
    run ${BATS_SHELL} ./beaconcli.sh
    EXPECT="Usage:*"
    [[ "${lines[0]}" =~ ${EXPECT} ]]
}
