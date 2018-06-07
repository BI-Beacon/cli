#!/usr/bin/env bats
# -*- mode: sh -*-

@test "Invalid characters in systemid should fail" {
      run ${BATS_SHELL} ./beaconcli.sh -i "${CHAR}" 00c01a
      [ $status -eq 1 ]
      echo "[$output]"
      EXPECTED ="Error: Systemid contains invalid characters*"
      [[ "${lines[0]}" =~ $EXPECTED ]]
  done
}
