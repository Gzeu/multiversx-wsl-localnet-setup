#!/bin/bash

################################################################################
# MultiversX Localnet Stop Script
# Description: Stops all running localnet blockchain nodes
# Usage: ./stop-localnet.sh
################################################################################

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Stopping MultiversX Localnet${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Find and kill all node processes
echo -e "${YELLOW}Searching for running node processes...${NC}"
NODE_PIDS=$(pgrep -f "node" || true)

if [ -z "$NODE_PIDS" ]; then
    echo -e "${YELLOW}No running nodes found.${NC}"
    echo -e "${GREEN}Localnet is already stopped.${NC}"
    exit 0
fi

echo -e "${BLUE}Found running nodes. Stopping...${NC}"
echo ""

# Stop each node process
for PID in $NODE_PIDS; do
    if ps -p $PID > /dev/null 2>&1; then
        echo -e "${BLUE}Stopping process $PID...${NC}"
        kill $PID 2>/dev/null || true
        
        # Wait for graceful shutdown
        for i in {1..5}; do
            if ! ps -p $PID > /dev/null 2>&1; then
                echo -e "${GREEN}✓ Process $PID stopped${NC}"
                break
            fi
            sleep 1
        done
        
        # Force kill if still running
        if ps -p $PID > /dev/null 2>&1; then
            echo -e "${YELLOW}Force killing process $PID...${NC}"
            kill -9 $PID 2>/dev/null || true
            echo -e "${GREEN}✓ Process $PID force stopped${NC}"
        fi
    fi
done

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Localnet Stopped Successfully!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${YELLOW}Start localnet again with:${NC} ./start-localnet.sh"
echo -e "${YELLOW}Reset localnet state with:${NC} ./reset-localnet.sh"
echo ""
