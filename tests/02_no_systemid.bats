#!/usr/bin/env bats

@test "No systemid set should fail" {
  run ./beaconcli.sh ff00ff
  [ $status -eq 1 ]
  [ "${lines[0]}" = "Error: Systemid must be set." ]
}

@test "Empty systemid should fail" {
  echo "systemid = donaldduck" > .conf
  run ./beaconcli.sh -c .conf -i "" ff00ff
  rm .conf
  echo $output
  [ $status -eq 1 ]
  [ "${lines[0]}" = "Error: Systemid must be set." ]
}