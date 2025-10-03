#!/bin/bash

################################################################################
# MultiversX Testnet Faucet Script
# Description: Requests test tokens from MultiversX Testnet faucet
# Usage: ./faucet.sh <your_address>
################################################################################

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Testnet faucet URL
FAUCET_URL="https://r3d4.fr/faucet"

echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}  💧 MultiversX Testnet Faucet${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

# Check if address is provided
if [ -z "$1" ]; then
    echo -e "${RED}Error: No address provided!${NC}"
    echo ""
    echo -e "${YELLOW}Usage:${NC}"
    echo -e "  ./faucet.sh <your_erd_address>"
    echo ""
    echo -e "${YELLOW}Example:${NC}"
    echo -e "  ./faucet.sh erd1qqqqqqqqqqqqqpgqxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    echo ""
    echo -e "${BLUE}Tip:${NC} Get your address with: ${CYAN}mxpy wallet derive <your_wallet.pem>${NC}"
    exit 1
fi

ADDRESS=$1

# Basic validation - MultiversX addresses start with 'erd1'
if [[ ! "$ADDRESS" =~ ^erd1 ]]; then
    echo -e "${RED}Error: Invalid address format!${NC}"
    echo -e "${YELLOW}MultiversX addresses must start with 'erd1'${NC}"
    exit 1
fi

echo -e "${BLUE}Address:${NC} ${ADDRESS}"
echo -e "${BLUE}Faucet:${NC} ${FAUCET_URL}"
echo ""
echo -e "${YELLOW}Requesting test EGLD from faucet...${NC}"
echo ""

# Check if curl is installed
if ! command -v curl &> /dev/null; then
    echo -e "${RED}Error: curl is not installed!${NC}"
    echo -e "${YELLOW}Install with: sudo apt install curl${NC}"
    exit 1
fi

# Request tokens from faucet
RESPONSE=$(curl -s -X POST "${FAUCET_URL}" \
    -H "Content-Type: application/json" \
    -d "{\"address\":\"${ADDRESS}\"}" || echo "ERROR")

if [ "$RESPONSE" = "ERROR" ] || [ -z "$RESPONSE" ]; then
    echo -e "${RED}Failed to connect to faucet!${NC}"
    echo ""
    echo -e "${YELLOW}Possible issues:${NC}"
    echo -e "  • No internet connection"
    echo -e "  • Faucet service is down"
    echo -e "  • Rate limit exceeded (try again later)"
    echo ""
    echo -e "${BLUE}Alternative faucets:${NC}"
    echo -e "  • https://r3d4.fr/faucet"
    echo -e "  • https://testnet-wallet.multiversx.com (use web interface)"
    exit 1
fi

# Check response for success
if echo "$RESPONSE" | grep -q "success" || echo "$RESPONSE" | grep -q "sent"; then
    echo -e "${GREEN}✓ Success! Test EGLD sent to your address${NC}"
    echo ""
    echo -e "${BLUE}Transaction should appear in a few seconds.${NC}"
    echo -e "${BLUE}Check your balance with:${NC}"
    echo -e "  ${CYAN}mxpy account get --address=${ADDRESS} --proxy=https://testnet-api.multiversx.com${NC}"
    echo ""
    echo -e "${YELLOW}Note: Faucet typically sends 1-10 xEGLD per request${NC}"
    echo -e "${YELLOW}Rate limits may apply (usually 1 request per 24 hours per address)${NC}"
else
    echo -e "${YELLOW}Response from faucet:${NC}"
    echo "$RESPONSE"
    echo ""
    echo -e "${YELLOW}The request may have been rate-limited or failed.${NC}"
    echo -e "${YELLOW}Please try again later or use the web faucet.${NC}"
fi

echo ""
