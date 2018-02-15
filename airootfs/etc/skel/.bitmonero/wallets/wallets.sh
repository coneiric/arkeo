#!/bin/bash

# Globals
WALLET_DIR="${HOME}/.bitmonero/wallets"

PrintUsage()
{
  echo ""
  echo "Usage: $ $0 {create <wallet_name>|restore <wallet_name>|run <wallet_name>|help}" >&2
  echo ""
}

# Create testnet wallet
# $1 - wallet to create (e.g. new_wallet)
Create()
{
  local conf_file="${WALLET_DIR}/create.conf"
  local data_dir="${WALLET_DIR}/$1"
  local seed_file="${data_dir}/${1}.seed"
  local wallet_file="${data_dir}/${1}.wallet"

  # Create data directory if it does not exist
  if [[ ! -d $data_dir ]]; then
    mkdir $data_dir
  fi

  monero-wallet-cli --config-file "${conf_file}" \
                    --generate-new-wallet "${wallet_file}"


  echo ""
  echo "Wallet created successfully!"
  echo "To save and later restore from the electrum seed:"
  echo ""
  echo "Save seed:"
  echo "\t$ $0 run $1"
  echo "\tseed # prints wallet seed"
  echo "\t\t# Copy seed to ${seed_file}" 
  echo "\t\t# Ensure all seed words are space-separated on a single line"
  echo "\texit"
  echo ""
  echo "Restore from seed:"
  echo "\t$ $0 restore $1"
  echo ""
}

# Restore / create testnet wallet
# $1 - wallet to restore (i.e. node0, node1, node2)
Restore()
{
  local conf_file="${WALLET_DIR}/restore.conf"
  local data_dir="${WALLET_DIR}/$1"
  local seed_file="${data_dir}/${1}.seed"
  local wallet_file="${data_dir}/${1}.wallet"

  monero-wallet-cli --config-file "${conf_file}" \
                    --electrum-seed "${seed_file}" \
                    --generate-new-wallet "${wallet_file}"
}

# Run testnet wallet
# $1 - wallet to run (i.e. node0, node1, node2)
Run()
{
  local data_dir="${WALLET_DIR}/$1"
  local conf_file="${data_dir}/run.conf"
  local log_file="${data_dir}/wallet.log"
  local wallet_file="${data_dir}/${1}.wallet"

  monero-wallet-cli --config-file "$conf_file" \
                    --log-file "$log_file" \
                    --wallet-file "$wallet_file"
}

# Entrypoint for manipulating testnet wallets
# $1 - command to execute (e.g. restore, run)
# $2 - wallet to manipulate (e.g. node0, node1, node2...)
case "$1" in
  create)
    Create "$2"
    ;;
  restore)
    Restore "$2" 
    ;;
  run)
    Run "$2"
    ;;
  help | *)
    PrintUsage
    exit 1
esac
