#!/usr/bin/env bats

@test "No arguments should fail." {
  ! ./beaconcli.sh
}

@test "No arguments should result in correct error message." {
  run ./beaconcli.sh
  [ "${lines[0]}" = "Error: Colour must be set on the command-line." ]
}
