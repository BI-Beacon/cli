#!/usr/bin/env bats

@test "No systemid set should fail" {
  run  ${BATS_SHELL} ./beaconcli.sh ff00ff
  [ $status -eq 1 ]
  [ "${lines[0]}" = "Error: Systemid must be set." ]
}

@test "Empty systemid should fail" {
  echo "systemid = donaldduck" > .conf
  run ${BATS_SHELL} ./beaconcli.sh -c .conf -i "" ff00ff
  rm .conf
  [ $status -eq 1 ]
  [ "${lines[0]}" = "Error: Systemid must be set." ]
}
