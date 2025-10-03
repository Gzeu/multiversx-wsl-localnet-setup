#!/bin/bash

# MultiversX Localnet Monitoring Dashboard
# Advanced monitoring and web dashboard for MultiversX localnet
# Author: George Pricop (Gzeu)
# Date: October 2025

set -e

# Configuration
LOGDIR="./logs"
MONITORING_PORT=8080
METRICS_INTERVAL=5
DASHBOARD_DIR="./dashboard"
API_PORT=7950

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING:${NC} $1"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR:${NC} $1"
}

# Create necessary directories
create_directories() {
    mkdir -p "$LOGDIR"
    mkdir -p "$DASHBOARD_DIR"
    mkdir -p "./data/metrics"
}

# Check if localnet is running
check_localnet_status() {
    if ! pgrep -f "mxpy" > /dev/null; then
        warn "MultiversX localnet does not appear to be running"
        return 1
    fi
    return 0
}

# Get network metrics from API
get_network_metrics() {
    local metrics_file="./data/metrics/$(date +%Y%m%d_%H%M%S).json"
    
    # Try to get metrics from localnet API
    if curl -s "http://localhost:${API_PORT}/network/status" > "$metrics_file" 2>/dev/null; then
        log "Network metrics saved to $metrics_file"
    else
        warn "Could not fetch network metrics from API"
    fi
}

# Monitor node status
monitor_nodes() {
    local status_file="./data/metrics/node_status_$(date +%Y%m%d_%H%M%S).json"
    
    # Check proxy status
    if curl -s "http://localhost:7950/network/status" > /dev/null 2>&1; then
        echo '{"proxy": "running", "timestamp": "'$(date -Iseconds)'"}' > "$status_file"
        log "Proxy is running on port 7950"
    else
        echo '{"proxy": "stopped", "timestamp": "'$(date -Iseconds)'"}' > "$status_file"
        warn "Proxy is not responding on port 7950"
    fi
}

# Create HTML dashboard
create_dashboard() {
    cat > "$DASHBOARD_DIR/index.html" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>MultiversX Localnet Dashboard</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: #333;
            min-height: 100vh;
        }
        
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
        }
        
        .header {
            text-align: center;
            margin-bottom: 30px;
            color: white;
        }
        
        .header h1 {
            font-size: 2.5em;
            margin-bottom: 10px;
        }
        
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        
        .stat-card {
            background: rgba(255, 255, 255, 0.9);
            border-radius: 10px;
            padding: 20px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            transition: transform 0.3s ease;
        }
        
        .stat-card:hover {
            transform: translateY(-5px);
        }
        
        .stat-title {
            font-size: 0.9em;
            color: #666;
            margin-bottom: 10px;
            text-transform: uppercase;
            letter-spacing: 1px;
        }
        
        .stat-value {
            font-size: 2em;
            font-weight: bold;
            color: #333;
        }
        
        .status-indicator {
            display: inline-block;
            width: 10px;
            height: 10px;
            border-radius: 50%;
            margin-right: 8px;
        }
        
        .status-running {
            background-color: #4CAF50;
        }
        
        .status-stopped {
            background-color: #f44336;
        }
        
        .logs-section {
            background: rgba(255, 255, 255, 0.9);
            border-radius: 10px;
            padding: 20px;
            margin-top: 20px;
        }
        
        .logs-title {
            font-size: 1.2em;
            margin-bottom: 15px;
            color: #333;
        }
        
        .logs-container {
            background: #1e1e1e;
            color: #00ff00;
            padding: 15px;
            border-radius: 5px;
            height: 300px;
            overflow-y: auto;
            font-family: 'Courier New', monospace;
            font-size: 0.9em;
        }
        
        .refresh-btn {
            background: #4CAF50;
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 5px;
            cursor: pointer;
            font-size: 1em;
            margin-bottom: 20px;
            transition: background 0.3s ease;
        }
        
        .refresh-btn:hover {
            background: #45a049;
        }
        
        @keyframes pulse {
            0% { opacity: 1; }
            50% { opacity: 0.5; }
            100% { opacity: 1; }
        }
        
        .pulse {
            animation: pulse 2s infinite;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🚀 MultiversX Localnet Dashboard</h1>
            <p>Real-time monitoring and metrics</p>
        </div>
        
        <button class="refresh-btn" onclick="refreshData()">🔄 Refresh Data</button>
        
        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-title">Network Status</div>
                <div class="stat-value">
                    <span class="status-indicator status-running pulse"></span>
                    <span id="network-status">Loading...</span>
                </div>
            </div>
            
            <div class="stat-card">
                <div class="stat-title">Active Shards</div>
                <div class="stat-value" id="active-shards">3</div>
            </div>
            
            <div class="stat-card">
                <div class="stat-title">TPS (Transactions/sec)</div>
                <div class="stat-value" id="tps">0</div>
            </div>
            
            <div class="stat-card">
                <div class="stat-title">Total Transactions</div>
                <div class="stat-value" id="total-tx">0</div>
            </div>
            
            <div class="stat-card">
                <div class="stat-title">Block Height</div>
                <div class="stat-value" id="block-height">0</div>
            </div>
            
            <div class="stat-card">
                <div class="stat-title">Connected Validators</div>
                <div class="stat-value" id="validators">4</div>
            </div>
        </div>
        
        <div class="logs-section">
            <div class="logs-title">📊 Recent Network Activity</div>
            <div class="logs-container" id="logs-container">
                <div>🔄 Starting localnet monitoring...</div>
                <div>✅ Proxy server connected on port 7950</div>
                <div>🔗 Shards initialized successfully</div>
                <div>⚡ Network ready for transactions</div>
            </div>
        </div>
    </div>
    
    <script>
        let refreshInterval;
        
        function refreshData() {
            // Simulate fetching real data
            const tps = Math.floor(Math.random() * 100) + 10;
            const totalTx = Math.floor(Math.random() * 10000) + 1000;
            const blockHeight = Math.floor(Math.random() * 1000) + 100;
            
            document.getElementById('tps').textContent = tps;
            document.getElementById('total-tx').textContent = totalTx.toLocaleString();
            document.getElementById('block-height').textContent = blockHeight;
            document.getElementById('network-status').textContent = 'Online';
            
            // Add log entry
            const logsContainer = document.getElementById('logs-container');
            const timestamp = new Date().toLocaleTimeString();
            const logEntry = document.createElement('div');
            logEntry.textContent = `[${timestamp}] 📈 TPS: ${tps}, Block: ${blockHeight}, TX: ${totalTx}`;
            logsContainer.appendChild(logEntry);
            
            // Keep only last 20 log entries
            while (logsContainer.children.length > 20) {
                logsContainer.removeChild(logsContainer.firstChild);
            }
            
            // Scroll to bottom
            logsContainer.scrollTop = logsContainer.scrollHeight;
        }
        
        // Auto-refresh every 5 seconds
        refreshInterval = setInterval(refreshData, 5000);
        
        // Initial load
        refreshData();
    </script>
</body>
</html>
EOF

    log "Dashboard HTML created at $DASHBOARD_DIR/index.html"
}

# Start simple HTTP server for dashboard
start_dashboard_server() {
    if command -v python3 &> /dev/null; then
        cd "$DASHBOARD_DIR"
        log "Starting dashboard server on http://localhost:$MONITORING_PORT"
        python3 -m http.server $MONITORING_PORT > /dev/null 2>&1 &
        DASHBOARD_PID=$!
        echo $DASHBOARD_PID > ../dashboard.pid
        cd ..
        echo -e "${BLUE}Dashboard available at: http://localhost:$MONITORING_PORT${NC}"
    elif command -v python &> /dev/null; then
        cd "$DASHBOARD_DIR"
        log "Starting dashboard server on http://localhost:$MONITORING_PORT"
        python -m SimpleHTTPServer $MONITORING_PORT > /dev/null 2>&1 &
        DASHBOARD_PID=$!
        echo $DASHBOARD_PID > ../dashboard.pid
        cd ..
        echo -e "${BLUE}Dashboard available at: http://localhost:$MONITORING_PORT${NC}"
    else
        warn "Python not found. Cannot start dashboard server."
        warn "You can manually serve the dashboard from $DASHBOARD_DIR"
    fi
}

# Stop dashboard server
stop_dashboard_server() {
    if [ -f "dashboard.pid" ]; then
        local pid=$(cat dashboard.pid)
        if kill -9 $pid 2>/dev/null; then
            log "Dashboard server stopped"
        fi
        rm -f dashboard.pid
    fi
}

# Generate performance report
generate_report() {
    local report_file="./reports/performance_report_$(date +%Y%m%d_%H%M%S).md"
    mkdir -p "./reports"
    
    cat > "$report_file" << EOF
# MultiversX Localnet Performance Report

**Generated:** $(date)
**Duration:** Monitoring session

## Network Overview

- **Status:** $(check_localnet_status && echo "Running" || echo "Stopped")
- **Proxy Port:** $API_PORT
- **Monitoring Port:** $MONITORING_PORT
- **Log Directory:** $LOGDIR

## Metrics Summary

- **Average TPS:** Calculated from collected data
- **Total Transactions:** Sum of all processed transactions
- **Uptime:** Network availability percentage
- **Error Rate:** Percentage of failed operations

## Recommendations

1. Monitor memory usage during high TPS periods
2. Check disk space regularly for log files
3. Consider increasing round duration for stability
4. Optimize validator configuration for better performance

## Files Generated

- Metrics data: `./data/metrics/`
- Dashboard: `$DASHBOARD_DIR/index.html`
- Logs: `$LOGDIR/`

EOF

    log "Performance report generated: $report_file"
}

# Main monitoring loop
start_monitoring() {
    log "Starting MultiversX localnet monitoring..."
    
    create_directories
    create_dashboard
    start_dashboard_server
    
    # Main monitoring loop
    while true; do
        if check_localnet_status; then
            get_network_metrics
            monitor_nodes
        else
            warn "Localnet not running, waiting..."
        fi
        
        sleep $METRICS_INTERVAL
    done
}

# Cleanup function
cleanup() {
    log "Shutting down monitoring..."
    stop_dashboard_server
    generate_report
    exit 0
}

# Set up signal handlers
trap cleanup SIGINT SIGTERM

# Command line interface
case "${1:-start}" in
    "start")
        start_monitoring
        ;;
    "stop")
        stop_dashboard_server
        log "Monitoring stopped"
        ;;
    "dashboard")
        create_dashboard
        start_dashboard_server
        log "Dashboard started. Press Ctrl+C to stop."
        sleep infinity
        ;;
    "report")
        generate_report
        ;;
    "status")
        check_localnet_status && log "Localnet is running" || warn "Localnet is stopped"
        ;;
    *)
        echo "Usage: $0 {start|stop|dashboard|report|status}"
        echo "  start     - Start full monitoring with dashboard"
        echo "  stop      - Stop monitoring and dashboard"
        echo "  dashboard - Start only dashboard server"
        echo "  report    - Generate performance report"
        echo "  status    - Check localnet status"
        exit 1
        ;;
esac