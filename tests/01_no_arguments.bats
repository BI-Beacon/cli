#!/usr/bin/env bats
# -*- mode: sh -*-

@test "No arguments should fail." {
  ! ${BATS_SHELL} ./beaconcli.sh
}

@test "No arguments should result in usage guide." {
    run ${BATS_SHELL} ./beaconcli.sh
    EXPECT="Usage:*"
    [[ "${lines[1]}" =~ ${EXPECT} ]]
}
