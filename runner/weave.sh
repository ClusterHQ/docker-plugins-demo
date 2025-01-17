#!/bin/sh

set -xe

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

source $DIR/utils.sh

# run the weave plugin on a named node
# the peer IP addresses are passed as args
function start-weave() {
  local node="$1"; shift;
  local index="$1"; shift;
  local peers="$@";

  # make sure the plugins folder exists
  vagrant ssh $node -c "sudo bash /tmp/runweave.sh $index $peers"
}

# get the IP addresses of the nodes
masterip_private=$(get-node-ip master private_ip)
runner1ip_private=$(get-node-ip runner-1 private_ip)
runner2ip_private=$(get-node-ip runner-2 private_ip)

# tell head node about the other 2
## TODO: we can just do this once weaveworks/docker-plugin#8 is fixed
##vagrant ssh master -c "weave connect $runner1ip $runner2ip"

# kick off the weave plugin on each node
start-weave master 10 $runner1ip_private $runner2ip_private
start-weave runner-1 11 $masterip_private $runner2ip_private
start-weave runner-2 12 $masterip_private $runner1ip_private
