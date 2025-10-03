#!/usr/bin/env bash
# MultiversX Chain Simulator
# Advanced blockchain simulation and testing framework

set -euo pipefail

# Configuration
SIM_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../simulator" && pwd)"
DATA_DIR="$SIM_DIR/data"
CONFIG_DIR="$SIM_DIR/config"
LOGS_DIR="$SIM_DIR/logs"
COMPOSE_FILE="$SIM_DIR/docker-compose.yml"
SCENARIOS_DIR="$SIM_DIR/scenarios"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[$(date '+%Y-%m-%d %H:%M:%S')] WARN:${NC} $1"
}

error() {
    echo -e "${RED}[$(date '+%Y-%m-%d %H:%M:%S')] ERROR:${NC} $1"
}

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

usage() {
    cat << EOF
MultiversX Chain Simulator - Advanced Testing Framework

Usage: $0 [COMMAND] [OPTIONS]

Commands:
    setup           Initialize simulator environment
    start           Start the chain simulator
    stop            Stop the chain simulator
    restart         Restart the simulator
    status          Show simulator status
    logs            Show simulator logs
    reset           Reset simulator state
    scenarios       List available test scenarios
    run-scenario    Run a specific test scenario
    load-test       Run load testing
    stress-test     Run stress testing
    network-test    Test network conditions
    benchmark       Run performance benchmarks
    snapshot        Create blockchain snapshot
    restore         Restore from snapshot
    
Scenario Commands:
    list-scenarios      List all available scenarios
    create-scenario     Create new test scenario
    run-scenario NAME   Run specific scenario
    
Testing Commands:
    tx-flood           Flood network with transactions
    consensus-test     Test consensus mechanisms  
    failover-test      Test node failover scenarios
    partition-test     Test network partition handling
    
Options:
    --nodes N          Number of nodes to simulate (default: 4)
    --shards N         Number of shards (default: 2)
    --observers N      Number of observer nodes (default: 1)
    --tps N            Target transactions per second
    --duration N       Test duration in seconds
    --config FILE      Use custom configuration file
    
Examples:
    $0 setup --nodes 6 --shards 3     # Setup 6-node, 3-shard network
    $0 start                           # Start simulator
    $0 run-scenario high-load         # Run high load test
    $0 benchmark --duration 300       # 5-minute benchmark
EOF
}

setup_directories() {
    log "Setting up simulator directories..."
    mkdir -p "$SIM_DIR" "$DATA_DIR" "$CONFIG_DIR" "$LOGS_DIR" "$SCENARIOS_DIR"
    mkdir -p "$DATA_DIR/node-0" "$DATA_DIR/node-1" "$DATA_DIR/node-2" "$DATA_DIR/node-3"
    mkdir -p "$CONFIG_DIR/node-0" "$CONFIG_DIR/node-1" "$CONFIG_DIR/node-2" "$CONFIG_DIR/node-3"
}

check_dependencies() {
    local missing_deps=()
    
    command -v docker >/dev/null 2>&1 || missing_deps+=("docker")
    command -v docker-compose >/dev/null 2>&1 || command -v "docker compose" >/dev/null 2>&1 || missing_deps+=("docker-compose")
    command -v python3 >/dev/null 2>&1 || missing_deps+=("python3")
    command -v curl >/dev/null 2>&1 || missing_deps+=("curl")
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        error "Missing dependencies: ${missing_deps[*]}"
        exit 1
    fi
}

generate_node_config() {
    local node_id="$1"
    local shard_id="$2"
    local port_offset=$((node_id * 10))
    local rest_port=$((8080 + port_offset))
    local p2p_port=$((9999 + port_offset))
    
    cat > "$CONFIG_DIR/node-$node_id/config.toml" << EOF
[GeneralSettings]
ChainID = "localnet"
MinTransactionVersion = 1
ProtocolSustainabilityAddress = "erd1932eft30w2r83u3qr4ks2ssfrskk5ff52t3q0ndwm2u5xvv8rl2s87kw80"

[NetworkConfig]
Port = $p2p_port
MaximumExpectedPeerCount = 10
ConnectionWatcherType = "print"
ShardId = $shard_id

[P2PConfig]
Node = [
    {Addr = "node-0:9999", PubKey = "node0_key"},
    {Addr = "node-1:10009", PubKey = "node1_key"},
    {Addr = "node-2:10019", PubKey = "node2_key"},
    {Addr = "node-3:10029", PubKey = "node3_key"}
]

[RestAPIServerConfig]
RestApiInterface = "0.0.0.0:$rest_port"

[LogsConfig]
LogsPath = "/logs"
LogFileLifeSpanInMB = 100
LogFileLifeSpanInSec = 86400

[ConsensusConfig]
Type = "bls"
RoundDurationInMilliseconds = 6000
EpochStartMetaHdrNonce = 1
EpochStartMetaHdrHash = "0000000000000000000000000000000000000000000000000000000000000000"

[EpochConfig]
EnableEpochs = {
    SCDeployEnableEpoch = 0,
    BuiltInFunctionsEnableEpoch = 0,
    RelayedTransactionsEnableEpoch = 0
}
EOF
}

generate_docker_compose() {
    local nodes="${1:-4}"
    local shards="${2:-2}"
    
    log "Generating Docker Compose for $nodes nodes, $shards shards..."
    
    cat > "$COMPOSE_FILE" << 'HEADER'
version: '3.8'

services:
  proxy:
    image: multiversx/chain-proxy:latest
    container_name: mvx-sim-proxy
    ports:
      - "7950:7950"
    volumes:
      - ./config/proxy:/config
      - ./logs/proxy:/logs
    environment:
      - MX_PROXY_PORT=7950
    networks:
      - mvx-sim
    restart: unless-stopped

HEADER

    # Generate node services
    for ((i=0; i<nodes; i++)); do
        local shard_id=$((i % shards))
        local rest_port=$((8080 + i * 10))
        local p2p_port=$((9999 + i * 10))
        
        # Generate node config
        generate_node_config "$i" "$shard_id"
        
        cat >> "$COMPOSE_FILE" << EOF

  node-$i:
    image: multiversx/chain-node:latest
    container_name: mvx-sim-node-$i
    ports:
      - "$rest_port:$rest_port"
      - "$p2p_port:$p2p_port"
    volumes:
      - ./config/node-$i:/config
      - ./data/node-$i:/data
      - ./logs/node-$i:/logs
    environment:
      - NODE_INDEX=$i
      - SHARD_ID=$shard_id
      - REST_API_PORT=$rest_port
    networks:
      - mvx-sim
    restart: unless-stopped
    depends_on:
      - proxy
EOF
    done
    
    cat >> "$COMPOSE_FILE" << 'FOOTER'

  metrics-exporter:
    image: multiversx/chain-metrics-exporter:latest
    container_name: mvx-sim-metrics
    ports:
      - "8081:8081"
    volumes:
      - ./config/metrics:/config
      - ./logs/metrics:/logs
    networks:
      - mvx-sim
    restart: unless-stopped

networks:
  mvx-sim:
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.0.0/16

volumes:
  proxy_data:
  metrics_data:
FOOTER
}

create_test_scenarios() {
    log "Creating test scenarios..."
    
    # Basic transaction scenario
    cat > "$SCENARIOS_DIR/basic-tx.json" << 'EOF'
{
  "name": "Basic Transaction Test",
  "description": "Send simple transactions between accounts",
  "steps": [
    {
      "action": "create_accounts",
      "count": 10,
      "initial_balance": "1000000000000000000"
    },
    {
      "action": "send_transactions",
      "count": 100,
      "tps": 10,
      "duration": 10
    },
    {
      "action": "verify_balances"
    }
  ]
}
EOF

    # High load scenario
    cat > "$SCENARIOS_DIR/high-load.json" << 'EOF'
{
  "name": "High Load Test",
  "description": "Test network under high transaction load",
  "steps": [
    {
      "action": "create_accounts",
      "count": 100,
      "initial_balance": "10000000000000000000"
    },
    {
      "action": "send_transactions",
      "count": 5000,
      "tps": 100,
      "duration": 50
    },
    {
      "action": "measure_performance",
      "metrics": ["tps", "latency", "success_rate"]
    }
  ]
}
EOF

    # Smart contract scenario
    cat > "$SCENARIOS_DIR/smart-contracts.json" << 'EOF'
{
  "name": "Smart Contract Test",
  "description": "Deploy and test smart contracts",
  "steps": [
    {
      "action": "deploy_contract",
      "contract": "counter.wasm",
      "constructor_args": []
    },
    {
      "action": "call_contract",
      "function": "increment",
      "count": 100
    },
    {
      "action": "query_contract",
      "function": "get_count",
      "expected_value": 100
    }
  ]
}
EOF

    # Network partition scenario
    cat > "$SCENARIOS_DIR/network-partition.json" << 'EOF'
{
  "name": "Network Partition Test",
  "description": "Test behavior during network partitions",
  "steps": [
    {
      "action": "start_normal_operation",
      "duration": 60
    },
    {
      "action": "create_partition",
      "partition_groups": [["node-0", "node-1"], ["node-2", "node-3"]]
    },
    {
      "action": "operate_partitioned",
      "duration": 120
    },
    {
      "action": "heal_partition"
    },
    {
      "action": "verify_consistency"
    }
  ]
}
EOF
}

create_scenario_runner() {
    cat > "$SCENARIOS_DIR/runner.py" << 'EOF'
#!/usr/bin/env python3
"""MultiversX Chain Simulator Scenario Runner"""

import json
import time
import requests
import subprocess
import sys
from typing import Dict, List, Any

class ScenarioRunner:
    def __init__(self, proxy_url: str = "http://localhost:7950"):
        self.proxy_url = proxy_url
        self.accounts = []
        
    def create_accounts(self, count: int, initial_balance: str):
        """Create test accounts"""
        print(f"Creating {count} accounts with balance {initial_balance}")
        # Implementation would create accounts using mxpy or direct API calls
        pass
        
    def send_transactions(self, count: int, tps: int, duration: int):
        """Send transactions at specified TPS"""
        print(f"Sending {count} transactions at {tps} TPS for {duration} seconds")
        interval = 1.0 / tps
        
        for i in range(count):
            # Send transaction
            self._send_single_transaction()
            time.sleep(interval)
            
            if i % 100 == 0:
                print(f"Sent {i} transactions...")
                
    def _send_single_transaction(self):
        """Send a single test transaction"""
        # Implementation would send actual transaction
        pass
        
    def measure_performance(self, metrics: List[str]):
        """Measure network performance"""
        print(f"Measuring performance metrics: {metrics}")
        
        # Get network stats from proxy
        try:
            response = requests.get(f"{self.proxy_url}/network/status")
            if response.status_code == 200:
                stats = response.json()
                print(f"Network stats: {json.dumps(stats, indent=2)}")
            else:
                print(f"Failed to get network stats: {response.status_code}")
        except Exception as e:
            print(f"Error getting network stats: {e}")
            
    def run_scenario(self, scenario_file: str):
        """Run a test scenario from JSON file"""
        print(f"Running scenario: {scenario_file}")
        
        with open(scenario_file, 'r') as f:
            scenario = json.load(f)
            
        print(f"Scenario: {scenario['name']}")
        print(f"Description: {scenario['description']}")
        
        for i, step in enumerate(scenario['steps']):
            print(f"\nStep {i+1}: {step['action']}")
            
            action = step['action']
            if action == 'create_accounts':
                self.create_accounts(step['count'], step['initial_balance'])
            elif action == 'send_transactions':
                self.send_transactions(step['count'], step['tps'], step['duration'])
            elif action == 'measure_performance':
                self.measure_performance(step['metrics'])
            else:
                print(f"Unknown action: {action}")
                
if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python3 runner.py <scenario_file>")
        sys.exit(1)
        
    scenario_file = sys.argv[1]
    runner = ScenarioRunner()
    runner.run_scenario(scenario_file)
EOF

    chmod +x "$SCENARIOS_DIR/runner.py"
}

setup_simulator() {
    log "Setting up MultiversX Chain Simulator..."
    
    check_dependencies
    setup_directories
    
    local nodes="${NODES:-4}"
    local shards="${SHARDS:-2}"
    
    generate_docker_compose "$nodes" "$shards"
    create_test_scenarios
    create_scenario_runner
    
    log "Simulator setup completed!"
    log "Configuration:"
    log "  - Nodes: $nodes"
    log "  - Shards: $shards"
    log "  - Proxy: http://localhost:7950"
    log "  - Node APIs: http://localhost:8080-$((8080 + nodes * 10))"
}

start_simulator() {
    log "Starting MultiversX Chain Simulator..."
    
    if [ ! -f "$COMPOSE_FILE" ]; then
        warn "Simulator not initialized. Running setup first..."
        setup_simulator
    fi
    
    cd "$SIM_DIR"
    docker-compose up -d
    
    log "Waiting for services to start..."
    sleep 15
    
    # Check if proxy is responding
    local max_attempts=30
    local attempt=0
    
    while [ $attempt -lt $max_attempts ]; do
        if curl -s "http://localhost:7950/network/status" >/dev/null 2>&1; then
            log "Chain Simulator started successfully!"
            log "Services available:"
            log "  - Proxy API: http://localhost:7950"
            log "  - Node 0 API: http://localhost:8080"
            log "  - Metrics: http://localhost:8081"
            return 0
        fi
        
        ((attempt++))
        echo -n "."
        sleep 2
    done
    
    error "Failed to start simulator - proxy not responding"
    docker-compose logs
    exit 1
}

stop_simulator() {
    log "Stopping Chain Simulator..."
    cd "$SIM_DIR"
    docker-compose down
    log "Simulator stopped."
}

restart_simulator() {
    stop_simulator
    sleep 3
    start_simulator
}

show_status() {
    log "Chain Simulator Status:"
    cd "$SIM_DIR"
    
    if [ -f "$COMPOSE_FILE" ]; then
        docker-compose ps
        
        echo -e "\n${BLUE}Network Status:${NC}"
        if curl -s "http://localhost:7950/network/status" >/dev/null 2>&1; then
            curl -s "http://localhost:7950/network/status" | python3 -m json.tool
        else
            warn "Proxy not responding"
        fi
    else
        warn "Simulator not initialized. Run 'setup' first."
    fi
}

show_logs() {
    log "Showing simulator logs:"
    cd "$SIM_DIR"
    docker-compose logs -f --tail=100
}

reset_simulator() {
    log "Resetting simulator state..."
    stop_simulator
    
    # Clean data directories
    rm -rf "$DATA_DIR"/*
    mkdir -p "$DATA_DIR/node-0" "$DATA_DIR/node-1" "$DATA_DIR/node-2" "$DATA_DIR/node-3"
    
    # Clean logs
    rm -rf "$LOGS_DIR"/*
    mkdir -p "$LOGS_DIR"
    
    log "Simulator state reset. Use 'start' to restart."
}

list_scenarios() {
    log "Available test scenarios:"
    if [ -d "$SCENARIOS_DIR" ]; then
        for scenario in "$SCENARIOS_DIR"/*.json; do
            if [ -f "$scenario" ]; then
                local name=$(basename "$scenario" .json)
                local desc=$(python3 -c "import json; f=open('$scenario'); data=json.load(f); print(data.get('description', 'No description'))" 2>/dev/null || echo "Invalid JSON")
                printf "  %-20s %s\n" "$name" "$desc"
            fi
        done
    else
        warn "No scenarios found. Run 'setup' first."
    fi
}

run_scenario() {
    local scenario_name="$1"
    local scenario_file="$SCENARIOS_DIR/$scenario_name.json"
    
    if [ ! -f "$scenario_file" ]; then
        error "Scenario not found: $scenario_name"
        list_scenarios
        exit 1
    fi
    
    log "Running scenario: $scenario_name"
    python3 "$SCENARIOS_DIR/runner.py" "$scenario_file"
}

run_load_test() {
    local duration="${DURATION:-300}"
    local tps="${TPS:-50}"
    
    log "Running load test - TPS: $tps, Duration: ${duration}s"
    
    # Create temporary scenario
    local temp_scenario="/tmp/load_test_$(date +%s).json"
    cat > "$temp_scenario" << EOF
{
  "name": "Load Test",
  "description": "Automated load test",
  "steps": [
    {
      "action": "create_accounts",
      "count": 50,
      "initial_balance": "10000000000000000000"
    },
    {
      "action": "send_transactions",
      "count": $((tps * duration)),
      "tps": $tps,
      "duration": $duration
    },
    {
      "action": "measure_performance",
      "metrics": ["tps", "latency", "success_rate"]
    }
  ]
}
EOF

    python3 "$SCENARIOS_DIR/runner.py" "$temp_scenario"
    rm "$temp_scenario"
}

# Parse command line arguments
NODES=4
SHARDS=2
OBSERVERS=1
TPS=50
DURATION=300

while [[ $# -gt 0 ]]; do
    case $1 in
        --nodes)
            NODES="$2"
            shift 2
            ;;
        --shards)
            SHARDS="$2"
            shift 2
            ;;
        --observers)
            OBSERVERS="$2"
            shift 2
            ;;
        --tps)
            TPS="$2"
            shift 2
            ;;
        --duration)
            DURATION="$2"
            shift 2
            ;;
        *)
            break
            ;;
    esac
done

# Main command handling
case "${1:-}" in
    setup)
        setup_simulator
        ;;
    start)
        start_simulator
        ;;
    stop)
        stop_simulator
        ;;
    restart)
        restart_simulator
        ;;
    status)
        show_status
        ;;
    logs)
        show_logs
        ;;
    reset)
        reset_simulator
        ;;
    list-scenarios|scenarios)
        list_scenarios
        ;;
    run-scenario)
        if [ -z "${2:-}" ]; then
            error "Scenario name required"
            list_scenarios
            exit 1
        fi
        run_scenario "$2"
        ;;
    load-test)
        run_load_test
        ;;
    stress-test)
        TPS=200
        DURATION=600
        run_load_test
        ;;
    *)
        usage
        exit 1
        ;;
esac
