#!/bin/bash

MONEROD_DIR="${HOME}/.bitmonero"

# Start a monero testnet node
# $1 - node to start (i.e. node0, node1, node2)
Start()
{
  data_dir="${MONEROD_DIR}/${1}"
  conf_file="${data_dir}/bitmonero.conf"
  log_file="${data_dir}/bitmonero.log"

  monerod --config-file "${conf_file}" \
          --log-file "${log_file}" \
          --testnet-data-dir "${data_dir}" \
          --detach
}

# Start default monero testnet nodes
for node in "node0" "node1" "node2"; do
  Start ${node}
done
