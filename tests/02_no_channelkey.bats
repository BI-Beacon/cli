#!/usr/bin/env bats
# -*- mode: sh -*-

@test "No channelkey set should fail" {
  run  ${BATS_SHELL} ./beaconcli.sh ff00ff
  [ $status -eq 1 ]
  [ "${lines[0]}" = "Error: Channelkey must be set." ]
}

@test "Empty channelkey should fail" {
  echo "channelkey = donaldduck" > .conf
  run ${BATS_SHELL} ./beaconcli.sh -c .conf -k "" ff00ff
  rm .conf
  [ $status -eq 1 ]
  [ "${lines[0]}" = "Error: Channelkey must be set." ]
}

