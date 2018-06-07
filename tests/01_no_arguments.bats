#!/usr/bin/env bats

@test "No arguments should fail." {
  !  ${BATS_SHELL} ./beaconcli.sh
}

@test "No arguments should result in correct error message." {
  run ${BATS_SHELL} ./beaconcli.sh
  [ "${lines[0]}" = "Error: Colour must be set on the command-line." ]
}
