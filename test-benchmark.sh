#!/bin/bash

# MultiversX Localnet Testing & Benchmarking Suite
# Automated testing and performance benchmarking for MultiversX localnet
# Author: George Pricop (Gzeu)
# Date: October 2025

set -e

# Configuration
API_URL="http://localhost:7950"
TEST_RESULTS_DIR="./test-results"
WALLET_PEM="./testnet/wallets/users/alice.pem"
TEST_DURATION=60
MAX_TPS_TARGET=50
TEST_CONTRACT_DIR="./contracts/test"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Logging functions
log() { echo -e "${GREEN}[$(date +'%H:%M:%S')]${NC} $1"; }
warn() { echo -e "${YELLOW}[$(date +'%H:%M:%S')] WARN:${NC} $1"; }
error() { echo -e "${RED}[$(date +'%H:%M:%S')] ERROR:${NC} $1"; }
info() { echo -e "${BLUE}[$(date +'%H:%M:%S')] INFO:${NC} $1"; }
success() { echo -e "${GREEN}[$(date +'%H:%M:%S')] SUCCESS:${NC} $1"; }

# Create test directories
setup_test_environment() {
    mkdir -p "$TEST_RESULTS_DIR"
    mkdir -p "$TEST_CONTRACT_DIR"
    mkdir -p "./test-data/wallets"
    mkdir -p "./test-data/transactions"
}

# Check if localnet is running
check_localnet() {
    if ! curl -s "$API_URL/network/status" > /dev/null; then
        error "Localnet is not running or not accessible at $API_URL"
        exit 1
    fi
    success "Localnet is running and accessible"
}

# Generate test wallets
generate_test_wallets() {
    log "Generating test wallets..."
    
    for i in {1..10}; do
        local wallet_file="./test-data/wallets/test_wallet_$i.pem"
        if [ ! -f "$wallet_file" ]; then
            mxpy wallet new --format pem --outfile "$wallet_file" > /dev/null 2>&1
            log "Generated wallet: test_wallet_$i.pem"
        fi
    done
    
    success "Test wallets generated"
}

# Fund test wallets
fund_test_wallets() {
    log "Funding test wallets..."
    
    # Check if faucet script exists
    if [ ! -f "./faucet.sh" ]; then
        warn "Faucet script not found, attempting manual funding"
        return 1
    fi
    
    for i in {1..10}; do
        local wallet_file="./test-data/wallets/test_wallet_$i.pem"
        if [ -f "$wallet_file" ]; then
            local address=$(mxpy wallet pem-address "$wallet_file")
            ./faucet.sh "$address" > /dev/null 2>&1 || warn "Failed to fund wallet $i"
        fi
    done
    
    success "Test wallets funded"
}

# Basic connectivity test
test_api_connectivity() {
    log "Testing API connectivity..."
    
    local test_file="$TEST_RESULTS_DIR/connectivity_test.json"
    local start_time=$(date +%s.%N)
    
    # Test multiple endpoints
    local endpoints=("network/status" "network/config" "address/erd1qqqqqqqqqqqqqqqpqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqplllst77y4l/nonce")
    local results="{\"timestamp\": \"$(date -Iseconds)\", \"tests\": []}"
    
    for endpoint in "${endpoints[@]}"; do
        local test_start=$(date +%s.%N)
        if curl -s "$API_URL/$endpoint" > /dev/null; then
            local test_end=$(date +%s.%N)
            local duration=$(echo "$test_end - $test_start" | bc -l)
            info "✓ $endpoint - ${duration}s"
        else
            error "✗ $endpoint - Failed"
        fi
    done
    
    local end_time=$(date +%s.%N)
    local total_duration=$(echo "$end_time - $start_time" | bc -l)
    
    echo "{\"connectivity_test\": {\"duration\": \"$total_duration\", \"timestamp\": \"$(date -Iseconds)\"}}" > "$test_file"
    success "API connectivity test completed in ${total_duration}s"
}

# Transaction throughput test
test_transaction_throughput() {
    log "Testing transaction throughput..."
    
    local test_file="$TEST_RESULTS_DIR/throughput_test.json"
    local start_time=$(date +%s)
    local tx_count=0
    local successful_tx=0
    local failed_tx=0
    
    # Use first test wallet as sender
    local sender_wallet="./test-data/wallets/test_wallet_1.pem"
    
    if [ ! -f "$sender_wallet" ]; then
        error "Sender wallet not found: $sender_wallet"
        return 1
    fi
    
    log "Starting throughput test for $TEST_DURATION seconds..."
    
    # Generate transactions
    while [ $(($(date +%s) - start_time)) -lt $TEST_DURATION ]; do
        local receiver_wallet="./test-data/wallets/test_wallet_$((RANDOM % 10 + 1)).pem"
        local receiver_address=$(mxpy wallet pem-address "$receiver_wallet" 2>/dev/null || echo "erd1qqqqqqqqqqqqqqqpqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqplllst77y4l")
        
        # Send a small transaction
        if mxpy tx new --pem="$sender_wallet" --receiver="$receiver_address" --value="1000000000000000" --gas-limit=50000 --send --outfile="./test-data/transactions/tx_$tx_count.json" > /dev/null 2>&1; then
            ((successful_tx++))
        else
            ((failed_tx++))
        fi
        
        ((tx_count++))
        
        # Small delay to prevent overwhelming
        sleep 0.1
    done
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    local tps=$(echo "scale=2; $successful_tx / $duration" | bc -l)
    
    # Save results
    cat > "$test_file" << EOF
{
    "throughput_test": {
        "duration": $duration,
        "total_transactions": $tx_count,
        "successful_transactions": $successful_tx,
        "failed_transactions": $failed_tx,
        "transactions_per_second": $tps,
        "timestamp": "$(date -Iseconds)"
    }
}
EOF
    
    success "Throughput test completed: $tps TPS (${successful_tx}/${tx_count} successful)"
}

# Smart contract deployment test
test_smart_contract_deployment() {
    log "Testing smart contract deployment..."
    
    local test_file="$TEST_RESULTS_DIR/contract_test.json"
    local start_time=$(date +%s.%N)
    
    # Create a simple test contract if it doesn't exist
    if [ ! -f "$TEST_CONTRACT_DIR/test.wasm" ]; then
        warn "No test contract found, creating simple ping-pong contract..."
        create_test_contract
    fi
    
    local contract_file="$TEST_CONTRACT_DIR/test.wasm"
    local wallet_file="./test-data/wallets/test_wallet_1.pem"
    
    if [ -f "$contract_file" ] && [ -f "$wallet_file" ]; then
        if mxpy contract deploy --bytecode="$contract_file" --pem="$wallet_file" --gas-limit=5000000 --send --outfile="$TEST_RESULTS_DIR/deploy_result.json" > /dev/null 2>&1; then
            local end_time=$(date +%s.%N)
            local duration=$(echo "$end_time - $start_time" | bc -l)
            
            echo "{\"contract_deployment\": {\"success\": true, \"duration\": \"$duration\", \"timestamp\": \"$(date -Iseconds)\"}}" > "$test_file"
            success "Smart contract deployed successfully in ${duration}s"
        else
            echo "{\"contract_deployment\": {\"success\": false, \"timestamp\": \"$(date -Iseconds)\"}}" > "$test_file"
            error "Smart contract deployment failed"
        fi
    else
        warn "Contract file or wallet not found, skipping deployment test"
    fi
}

# Create a simple test contract
create_test_contract() {
    mkdir -p "$TEST_CONTRACT_DIR"
    
    # Create a simple Rust smart contract
    cat > "$TEST_CONTRACT_DIR/lib.rs" << 'EOF'
#![no_std]

use multiversx_sc::derive::{ManagedVecItem, TopEncode, TopDecode, NestedEncode, NestedDecode, TypeAbi};
use multiversx_sc::imports::*;

#[multiversx_sc::contract]
pub trait TestContract {
    #[init]
    fn init(&self) {}
    
    #[endpoint]
    fn ping(&self) -> ManagedBuffer {
        ManagedBuffer::from(b"pong")
    }
    
    #[endpoint]
    fn sum(&self, a: BigUint, b: BigUint) -> BigUint {
        a + b
    }
}
EOF

    # Create Cargo.toml
    cat > "$TEST_CONTRACT_DIR/Cargo.toml" << 'EOF'
[package]
name = "test-contract"
version = "0.1.0"
edition = "2021"

[dependencies]
multiversx-sc = "0.50.0"

[lib]
name = "test_contract"
path = "lib.rs"
crate-type = ["cdylib"]
EOF

    log "Test contract template created"
}

# Network stress test
stress_test_network() {
    log "Starting network stress test..."
    
    local test_file="$TEST_RESULTS_DIR/stress_test.json"
    local start_time=$(date +%s)
    local max_concurrent=10
    
    # Run multiple transaction streams in parallel
    for i in $(seq 1 $max_concurrent); do
        (
            local wallet="./test-data/wallets/test_wallet_$i.pem"
            if [ -f "$wallet" ]; then
                for j in $(seq 1 20); do
                    local receiver="./test-data/wallets/test_wallet_$(((i % 10) + 1)).pem"
                    local receiver_addr=$(mxpy wallet pem-address "$receiver" 2>/dev/null || echo "erd1qqqqqqqqqqqqqqqpqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqplllst77y4l")
                    
                    mxpy tx new --pem="$wallet" --receiver="$receiver_addr" --value="100000000000000" --gas-limit=50000 --send > /dev/null 2>&1 &
                    sleep 0.5
                done
            fi
        ) &
    done
    
    wait
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    echo "{\"stress_test\": {\"duration\": $duration, \"concurrent_streams\": $max_concurrent, \"timestamp\": \"$(date -Iseconds)\"}}" > "$test_file"
    success "Stress test completed in ${duration}s"
}

# Generate comprehensive report
generate_test_report() {
    log "Generating test report..."
    
    local report_file="$TEST_RESULTS_DIR/test_report_$(date +%Y%m%d_%H%M%S).md"
    
    cat > "$report_file" << EOF
# MultiversX Localnet Test Report

**Generated:** $(date)
**Test Suite Version:** 1.0
**Localnet API:** $API_URL

## Test Summary

### Environment
- **OS:** $(uname -s) $(uname -r)
- **Python:** $(python3 --version 2>/dev/null || echo "Not available")
- **mxpy:** $(mxpy --version 2>/dev/null || echo "Not available")
- **Test Duration:** ${TEST_DURATION}s
- **Target TPS:** $MAX_TPS_TARGET

### Test Results

EOF

    # Add individual test results
    for test_file in "$TEST_RESULTS_DIR"/*.json; do
        if [ -f "$test_file" ]; then
            echo "#### $(basename "$test_file" .json)" >> "$report_file"
            echo '```json' >> "$report_file"
            cat "$test_file" >> "$report_file"
            echo '```' >> "$report_file"
            echo "" >> "$report_file"
        fi
    done
    
    cat >> "$report_file" << EOF

## Recommendations

1. **Performance Optimization:**
   - Monitor memory usage during high TPS periods
   - Consider adjusting round duration for better throughput
   - Optimize gas limits for smart contract calls

2. **Network Stability:**
   - Implement proper error handling for failed transactions
   - Monitor validator synchronization
   - Set up alerting for network issues

3. **Development Workflow:**
   - Use automated testing before mainnet deployment
   - Implement CI/CD pipelines with localnet testing
   - Regular performance benchmarking

## Next Steps

- [ ] Optimize network configuration based on test results
- [ ] Implement automated regression testing
- [ ] Set up continuous monitoring
- [ ] Create performance baseline metrics

EOF

    success "Test report generated: $report_file"
    echo -e "${BLUE}View report: cat $report_file${NC}"
}

# Run all tests
run_all_tests() {
    log "Running complete test suite..."
    
    setup_test_environment
    check_localnet
    generate_test_wallets
    fund_test_wallets
    
    sleep 5  # Wait for funding to complete
    
    test_api_connectivity
    test_transaction_throughput
    test_smart_contract_deployment
    stress_test_network
    
    generate_test_report
    
    success "All tests completed! Check $TEST_RESULTS_DIR for detailed results."
}

# Cleanup function
cleanup() {
    log "Cleaning up test environment..."
    pkill -f "mxpy tx" 2>/dev/null || true
    success "Cleanup completed"
}

trap cleanup EXIT

# Main CLI
case "${1:-all}" in
    "all")
        run_all_tests
        ;;
    "connectivity")
        setup_test_environment
        check_localnet
        test_api_connectivity
        ;;
    "throughput")
        setup_test_environment
        check_localnet
        generate_test_wallets
        fund_test_wallets
        test_transaction_throughput
        ;;
    "contract")
        setup_test_environment
        check_localnet
        generate_test_wallets
        fund_test_wallets
        test_smart_contract_deployment
        ;;
    "stress")
        setup_test_environment
        check_localnet
        generate_test_wallets
        fund_test_wallets
        stress_test_network
        ;;
    "report")
        generate_test_report
        ;;
    "setup")
        setup_test_environment
        generate_test_wallets
        success "Test environment setup completed"
        ;;
    *)
        echo "Usage: $0 {all|connectivity|throughput|contract|stress|report|setup}"
        echo "  all          - Run complete test suite"
        echo "  connectivity - Test API connectivity"
        echo "  throughput   - Test transaction throughput"
        echo "  contract     - Test smart contract deployment"
        echo "  stress       - Run network stress test"
        echo "  report       - Generate test report from existing results"
        echo "  setup        - Setup test environment only"
        exit 1
        ;;
esac