#!/bin/bash

# Create testnet directory
if [[ ! -L /tmp/kovri ]]; then
  ln -sf /usr/src/kovri /tmp/kovri
fi

# Start sway if not already running
pidof sway >> /dev/null
if [[ $? -ne 0 ]]; then
  sway
fi
