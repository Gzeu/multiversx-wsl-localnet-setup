#!/bin/bash

################################################################################
# MultiversX Localnet Start Script
# Description: Starts all localnet blockchain nodes
# Usage: ./start-localnet.sh
################################################################################

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  MultiversX Localnet Startup${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check if localnet directory exists
if [ ! -d "$HOME/multiversx-localnet" ]; then
    echo -e "${RED}Error: Localnet directory not found!${NC}"
    echo -e "${YELLOW}Please run ./init-localnet.sh first${NC}"
    exit 1
fi

cd "$HOME/multiversx-localnet"

# Check if nodes are already running
if pgrep -f "node" > /dev/null; then
    echo -e "${YELLOW}Warning: Some nodes may already be running${NC}"
    echo -e "${YELLOW}Run ./stop-localnet.sh first if you want to restart${NC}"
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo -e "${GREEN}Starting localnet nodes...${NC}"
echo ""

# Start validator nodes
for i in {0..2}; do
    echo -e "${BLUE}Starting validator node $i...${NC}"
    cd "$HOME/multiversx-localnet/node-$i"
    nohup ./node > node.log 2>&1 &
    echo -e "${GREEN}✓ Node $i started (PID: $!)${NC}"
    sleep 2
done

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Localnet Started Successfully!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${BLUE}Proxy endpoint:${NC} http://localhost:7950"
echo -e "${BLUE}Observer endpoint:${NC} http://localhost:8080"
echo ""
echo -e "${YELLOW}Tip: Check node logs with:${NC}"
echo -e "  tail -f $HOME/multiversx-localnet/node-0/node.log"
echo ""
echo -e "${YELLOW}Stop localnet with:${NC} ./stop-localnet.sh"
echo ""
