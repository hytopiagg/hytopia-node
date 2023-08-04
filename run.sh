#!/bin/bash

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

if [ "$(uname)" == "Darwin" ]; then
  EDGE_BIN_OS="darwin"
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
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

echo "Target bin path: $EDGE_BIN_PATH"

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
                      --seal false