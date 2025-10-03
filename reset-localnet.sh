#!/bin/bash

################################################################################
# MultiversX Localnet Reset Script
# Description: Resets localnet to clean state (stops nodes and clears data)
# Usage: ./reset-localnet.sh
################################################################################

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${RED}========================================${NC}"
echo -e "${RED}  ⚠️  MultiversX Localnet Reset${NC}"
echo -e "${RED}========================================${NC}"
echo ""
echo -e "${YELLOW}WARNING: This will:${NC}"
echo -e "${YELLOW}  • Stop all running nodes${NC}"
echo -e "${YELLOW}  • Delete all blockchain data${NC}"
echo -e "${YELLOW}  • Clear all transaction history${NC}"
echo -e "${YELLOW}  • Reset to genesis state${NC}"
echo ""

# Ask for confirmation
read -p "Are you sure you want to reset the localnet? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo -e "${GREEN}Reset cancelled.${NC}"
    exit 0
fi

echo ""
echo -e "${BLUE}Starting reset process...${NC}"
echo ""

# Stop all running nodes first
echo -e "${BLUE}Step 1/3: Stopping all nodes...${NC}"
NODE_PIDS=$(pgrep -f "node" || true)

if [ -n "$NODE_PIDS" ]; then
    for PID in $NODE_PIDS; do
        if ps -p $PID > /dev/null 2>&1; then
            kill -9 $PID 2>/dev/null || true
            echo -e "${GREEN}✓ Stopped process $PID${NC}"
        fi
    done
else
    echo -e "${YELLOW}No running nodes found${NC}"
fi

echo ""

# Remove localnet data directory
echo -e "${BLUE}Step 2/3: Removing blockchain data...${NC}"
if [ -d "$HOME/multiversx-localnet" ]; then
    rm -rf "$HOME/multiversx-localnet"
    echo -e "${GREEN}✓ Removed localnet directory${NC}"
else
    echo -e "${YELLOW}Localnet directory not found${NC}"
fi

echo ""

# Clean up any remaining artifacts
echo -e "${BLUE}Step 3/3: Cleaning up artifacts...${NC}"
rm -f /tmp/multiversx-*.log 2>/dev/null || true
rm -f nohup.out 2>/dev/null || true
echo -e "${GREEN}✓ Cleaned up temporary files${NC}"

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Localnet Reset Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo -e "  1. Run ${BLUE}./init-localnet.sh${NC} to recreate the localnet"
echo -e "  2. Run ${BLUE}./start-localnet.sh${NC} to start fresh nodes"
echo ""
