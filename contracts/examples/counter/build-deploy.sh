#!/bin/bash

# Build and Deploy Script for Counter Contract
# This script automates building and deploying the counter smart contract to MultiversX Localnet

set -e

CONTRACT_NAME="counter"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

PROXY="http://localhost:7950"
CHAIN_ID="localnet"
WALLET_PEM="$PROJECT_ROOT/wallets/wallet-owner.pem"

echo "================================"
echo "Building $CONTRACT_NAME contract..."
echo "================================"

cd "$SCRIPT_DIR"

# Build the contract
if [ ! -f "Cargo.toml" ]; then
    echo "Error: Cargo.toml not found. Please ensure contract source exists."
    exit 1
fi

sc-meta all build

if [ $? -ne 0 ]; then
    echo "Build failed!"
    exit 1
fi

echo ""
echo "Build successful!"
echo ""

# Check if wallet exists
if [ ! -f "$WALLET_PEM" ]; then
    echo "Warning: Wallet file not found at $WALLET_PEM"
    echo "Please ensure you have a wallet configured."
    exit 1
fi

echo "================================"
echo "Deploying $CONTRACT_NAME to Localnet..."
echo "================================"

# Find the WASM file
WASM_FILE=$(find output -name "*.wasm" | head -n 1)

if [ -z "$WASM_FILE" ]; then
    echo "Error: WASM file not found in output directory"
    exit 1
fi

echo "Deploying: $WASM_FILE"

# Deploy contract
mxpy contract deploy \
    --bytecode="$WASM_FILE" \
    --pem="$WALLET_PEM" \
    --proxy="$PROXY" \
    --chain="$CHAIN_ID" \
    --recall-nonce \
    --gas-limit=5000000 \
    --send

if [ $? -eq 0 ]; then
    echo ""
    echo "================================"
    echo "Deployment successful!"
    echo "================================"
else
    echo ""
    echo "Deployment failed!"
    exit 1
fi
