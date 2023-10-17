#!/bin/bash

echo "!!!!!   !!!!!  !!!!!    !!!!!  !!!!!!!!!!!!!  !!!!!!!!!!!!!  !!!!!!!!!!!!!!  !!!!!  !!!!!!!!!!!!!!"
echo "!!!!!   !!!!!  !!!!!    !!!!!  !!!!!!!!!!!!!  !!!!!!!!!!!!!  !!!!!!!!!!!!!!  !!!!!  !!!!!!!!!!!!!!"
echo "!!!!!   !!!!!  !!!!!    !!!!!  !!!!!!!!!!!!!  !!!!!!!!!!!!!  !!!!!!!!!!!!!!  !!!!!  !!!!!!!!!!!!!!"
echo "!!!!!!!!!!!!!  !!!!!!!!!!!!!!  !!!!!!!!!!!!!  !!!!!!!!!!!!!  !!!!!!!!!!!!!!  !!!!!  !!!!!!!!!!!!!!"
echo "!!!!!!!!!!!!!      !!!!!           !!!!!      !!!!!!!!!!!!!  !!!!!           !!!!!  !!!!!    !!!!!"
echo "!!!!!   !!!!!      !!!!!           !!!!!      !!!!!!!!!!!!!  !!!!!           !!!!!  !!!!!    !!!!!"
echo "!!!!!   !!!!!      !!!!!           !!!!!      !!!!!!!!!!!!!  !!!!!           !!!!!  !!!!!    !!!!!"
echo "--------------------------------------------------------------------------------------------------"
echo "Website: https://hytopia.com"
echo "Twitter: https://twitter.com/hytopiagg"
echo "Discord: https://discord.gg/hytopiagg"
echo ""
echo "If this is the first time running your full node, it can take a while to sync and get up to date "
echo "with the current state of the HYTOPIA chain. Please be patient while your node syncs. Should the "
echo "syncing process be interrupted, it will resume from its last checkpoint the next time you run "
echo "your node."
echo "--------------------------------------------------------------------------------------------------"

echo "Starting HYTOPIA fullnode..."

#
# Determine target network
#

HYTOPIA_NETWORK=$1

if [[ "${HYTOPIA_NETWORK}" != "mainnet" && "${HYTOPIA_NETWORK}" != "testnet" ]]; then
  echo "Target network for fullnode not provided as argument. For example: sh ./run.sh testnet" >&2
  exit 1
fi

echo "Target network: ${HYTOPIA_NETWORK}"

#
# Determine edge binary path
#

if [[ "$(uname)" == "Darwin" ]]; then
  EDGE_BIN_OS="darwin"
elif [[ "$(expr substr $(uname -s) 1 5)" == "Linux" ]]; then
  EDGE_BIN_OS="linux"
else
  echo "Only Mac (Darwin) and Linux operating systems are currently supported for running a fullnode. Found: ${uname}" >&2
  exit 1
fi

if [[ "$(uname -m)" == "x86_64" ]]; then
    EDGE_BIN_ARCH="amd64"
elif [[ "$(uname -m)" == "aarch64" || "$(uname -m)" == "arm64" ]]; then
    EDGE_BIN_ARCH="arm64"
else
    echo "Unsupported architecture found, must be arm64 or amd64: $(uname -m)" >&2
    exit 1
fi

EDGE_BIN_PATH="./bin/polygon-edge/${EDGE_BIN_OS}_${EDGE_BIN_ARCH}/polygon-edge"

#
# Generate secrets if necessary
#

if [[ ! -d "${HYTOPIA_NETWORK}/data/consensus" ]]; then
    echo "Generating consensus secrets to ${HYTOPIA_NETWORK}/data/consensus..."
    $EDGE_BIN_PATH polybft-secrets --data-dir "${HYTOPIA_NETWORK}/data" \
                                   --insecure
else
    echo "Found existing ${HYTOPIA_NETWORK}/data/consensus directory..."
fi

#
# Start
#

$EDGE_BIN_PATH server --data-dir "${HYTOPIA_NETWORK}/data" \
                      --chain "${HYTOPIA_NETWORK}/genesis.json" \
                      --json-rpc-batch-request-limit 500 \
                      --grpc-address "0.0.0.0:10000" \
                      --libp2p "0.0.0.0:10001" \
                      --jsonrpc "0.0.0.0:10002" \
                      2>&1 | sed -e 's/polygon/hytopia/g' -e 's/polybft/hytopiabft/g'
