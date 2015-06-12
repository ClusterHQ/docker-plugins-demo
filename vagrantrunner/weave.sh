#!/bin/sh

set -ex

weave_release='0.11.2'

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

# run the weave plugin on a named node
# the peer IP addresses are passed as args
function start-weave() {
  local node="$1"; shift;
  local index="$1"; shift;
  local peers="$@";
  vagrant ssh $node -c "sudo bash /tmp/runweave.sh $index $peers"
}

master="172.16.70.250"
runner1="172.16.70.251"
runner2="172.16.70.252"

# kick off the weave plugin on each node
start-weave master 10 $runner1 $runner1
start-weave runner-1 11 $runner2 $master
start-weave runner-2 12 $runner1 $master