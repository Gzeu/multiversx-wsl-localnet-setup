#!/usr/bin/env bash
# MultiversX Enterprise Monitoring Stack
# Manages Prometheus, Grafana, and custom metrics collection

set -euo pipefail

# Configuration
MONITORING_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../monitoring" && pwd)"
COMPOSE_FILE="$MONITORING_DIR/docker-compose.yml"
CONFIG_DIR="$MONITORING_DIR/config"
DATA_DIR="$MONITORING_DIR/data"
LOG_FILE="$MONITORING_DIR/monitoring.log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a "$LOG_FILE"
}

warn() {
    echo -e "${YELLOW}[$(date '+%Y-%m-%d %H:%M:%S')] WARN:${NC} $1" | tee -a "$LOG_FILE"
}

error() {
    echo -e "${RED}[$(date '+%Y-%m-%d %H:%M:%S')] ERROR:${NC} $1" | tee -a "$LOG_FILE"
}

usage() {
    cat << EOF
MultiversX Enterprise Monitoring Stack

Usage: $0 [COMMAND]

Commands:
    setup       Initialize monitoring infrastructure
    start       Start monitoring stack
    stop        Stop monitoring stack  
    restart     Restart monitoring stack
    status      Show status of monitoring services
    logs        Show logs from monitoring services
    cleanup     Remove all monitoring data and containers
    dashboard   Open Grafana dashboard in browser
    metrics     Show current metrics summary
    backup      Backup monitoring configuration and data
    restore     Restore from backup
    update      Update monitoring stack images
    
Examples:
    $0 setup        # First time setup
    $0 start        # Start the monitoring stack
    $0 dashboard    # Open Grafana in browser
    $0 metrics      # Show current metrics
EOF
}

check_dependencies() {
    local missing_deps=()
    
    command -v docker >/dev/null 2>&1 || missing_deps+=("docker")
    command -v docker-compose >/dev/null 2>&1 || command -v "docker compose" >/dev/null 2>&1 || missing_deps+=("docker-compose")
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        error "Missing dependencies: ${missing_deps[*]}"
        echo "Please install the missing dependencies and try again."
        exit 1
    fi
}

setup_directories() {
    log "Setting up monitoring directories..."
    mkdir -p "$MONITORING_DIR" "$CONFIG_DIR" "$DATA_DIR"
    mkdir -p "$CONFIG_DIR/prometheus" "$CONFIG_DIR/grafana/dashboards" "$CONFIG_DIR/grafana/datasources"
    mkdir -p "$DATA_DIR/prometheus" "$DATA_DIR/grafana"
}

generate_prometheus_config() {
    log "Generating Prometheus configuration..."
    cat > "$CONFIG_DIR/prometheus/prometheus.yml" << 'EOF'
global:
  scrape_interval: 15s
  evaluation_interval: 15s
  external_labels:
    monitor: 'multiversx-monitor'
    environment: 'localnet'

rule_files:
  - "alert.rules.yml"

alerting:
  alertmanagers:
    - static_configs:
        - targets:
          - alertmanager:9093

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
    scrape_interval: 5s

  - job_name: 'multiversx-proxy'
    static_configs:
      - targets: ['host.docker.internal:7950']
    scrape_interval: 10s
    metrics_path: /metrics
    
  - job_name: 'multiversx-node-0'
    static_configs:
      - targets: ['host.docker.internal:8080']
    scrape_interval: 10s
    metrics_path: /metrics
    
  - job_name: 'multiversx-node-1' 
    static_configs:
      - targets: ['host.docker.internal:8081']
    scrape_interval: 10s
    metrics_path: /metrics

  - job_name: 'system-metrics'
    static_configs:
      - targets: ['node-exporter:9100']
    scrape_interval: 15s
EOF

    # Generate alert rules
    cat > "$CONFIG_DIR/prometheus/alert.rules.yml" << 'EOF'
groups:
  - name: multiversx.rules
    rules:
    - alert: MultiversXNodeDown
      expr: up{job=~"multiversx-.*"} == 0
      for: 1m
      labels:
        severity: critical
      annotations:
        summary: "MultiversX node {{ $labels.instance }} is down"
        description: "MultiversX node {{ $labels.instance }} has been down for more than 1 minute."
        
    - alert: HighCPUUsage
      expr: 100 - (avg by(instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
      for: 2m
      labels:
        severity: warning
      annotations:
        summary: "High CPU usage on {{ $labels.instance }}"
        description: "CPU usage is above 80% for more than 2 minutes."
EOF
}

generate_grafana_config() {
    log "Generating Grafana configuration..."
    
    # Datasource configuration
    cat > "$CONFIG_DIR/grafana/datasources/prometheus.yml" << 'EOF'
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
    editable: true
EOF

    # Dashboard provisioning
    cat > "$CONFIG_DIR/grafana/dashboards/dashboard.yml" << 'EOF'
apiVersion: 1

providers:
  - name: 'MultiversX Dashboards'
    orgId: 1
    folder: 'MultiversX'
    type: file
    disableDeletion: false
    updateIntervalSeconds: 10
    allowUiUpdates: true
    options:
      path: /var/lib/grafana/dashboards
EOF

    # Generate MultiversX dashboard
    generate_multiversx_dashboard
}

generate_multiversx_dashboard() {
    cat > "$CONFIG_DIR/grafana/dashboards/multiversx-overview.json" << 'EOF'
{
  "annotations": {
    "list": [
      {
        "builtIn": 1,
        "datasource": "-- Grafana --",
        "enable": true,
        "hide": true,
        "iconColor": "rgba(0, 211, 255, 1)",
        "name": "Annotations & Alerts",
        "type": "dashboard"
      }
    ]
  },
  "editable": true,
  "gnetId": null,
  "graphTooltip": 0,
  "id": null,
  "links": [],
  "panels": [
    {
      "datasource": "Prometheus",
      "fieldConfig": {
        "defaults": {
          "color": {
            "mode": "palette-classic"
          },
          "custom": {
            "axisLabel": "",
            "axisPlacement": "auto",
            "barAlignment": 0,
            "drawStyle": "line",
            "fillOpacity": 10,
            "gradientMode": "none",
            "hideFrom": {
              "legend": false,
              "tooltip": false,
              "vis": false
            },
            "lineInterpolation": "linear",
            "lineWidth": 1,
            "pointSize": 5,
            "scaleDistribution": {
              "type": "linear"
            },
            "showPoints": "never",
            "spanNulls": true,
            "stacking": {
              "group": "A",
              "mode": "none"
            },
            "thresholdsStyle": {
              "mode": "off"
            }
          },
          "mappings": [],
          "thresholds": {
            "mode": "absolute",
            "steps": [
              {
                "color": "green",
                "value": null
              },
              {
                "color": "red",
                "value": 80
              }
            ]
          },
          "unit": "short"
        },
        "overrides": []
      },
      "gridPos": {
        "h": 8,
        "w": 12,
        "x": 0,
        "y": 0
      },
      "id": 2,
      "options": {
        "legend": {
          "calcs": [],
          "displayMode": "list",
          "placement": "bottom"
        },
        "tooltip": {
          "mode": "single"
        }
      },
      "targets": [
        {
          "expr": "up{job=~\"multiversx-.*\"}",
          "interval": "",
          "legendFormat": "{{job}}",
          "refId": "A"
        }
      ],
      "title": "MultiversX Nodes Status",
      "type": "timeseries"
    },
    {
      "datasource": "Prometheus",
      "fieldConfig": {
        "defaults": {
          "color": {
            "mode": "thresholds"
          },
          "mappings": [],
          "max": 1,
          "min": 0,
          "thresholds": {
            "mode": "absolute",
            "steps": [
              {
                "color": "red",
                "value": null
              },
              {
                "color": "green",
                "value": 1
              }
            ]
          },
          "unit": "short"
        },
        "overrides": []
      },
      "gridPos": {
        "h": 8,
        "w": 12,
        "x": 12,
        "y": 0
      },
      "id": 4,
      "options": {
        "orientation": "auto",
        "reduceOptions": {
          "calcs": [
            "lastNotNull"
          ],
          "fields": "",
          "values": false
        },
        "showThresholdLabels": false,
        "showThresholdMarkers": true,
        "text": {}
      },
      "pluginVersion": "8.0.0",
      "targets": [
        {
          "expr": "up{job=\"multiversx-proxy\"}",
          "interval": "",
          "legendFormat": "Proxy",
          "refId": "A"
        }
      ],
      "title": "Proxy Status",
      "type": "gauge"
    }
  ],
  "schemaVersion": 27,
  "style": "dark",
  "tags": [
    "multiversx",
    "blockchain"
  ],
  "templating": {
    "list": []
  },
  "time": {
    "from": "now-1h",
    "to": "now"
  },
  "timepicker": {},
  "timezone": "",
  "title": "MultiversX Overview",
  "uid": "multiversx-overview",
  "version": 1
}
EOF
}

generate_docker_compose() {
    log "Generating Docker Compose configuration..."
    cat > "$COMPOSE_FILE" << 'EOF'
version: '3.8'

services:
  prometheus:
    image: prom/prometheus:latest
    container_name: mvx-prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./config/prometheus:/etc/prometheus:ro
      - ./data/prometheus:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.console.libraries=/etc/prometheus/console_libraries'
      - '--web.console.templates=/etc/prometheus/consoles'
      - '--storage.tsdb.retention.time=200h'
      - '--web.enable-lifecycle'
      - '--web.enable-admin-api'
    restart: unless-stopped
    networks:
      - monitoring

  grafana:
    image: grafana/grafana:latest
    container_name: mvx-grafana
    ports:
      - "3000:3000"
    volumes:
      - ./data/grafana:/var/lib/grafana
      - ./config/grafana/datasources:/etc/grafana/provisioning/datasources:ro
      - ./config/grafana/dashboards/dashboard.yml:/etc/grafana/provisioning/dashboards/dashboard.yml:ro
      - ./config/grafana/dashboards:/var/lib/grafana/dashboards:ro
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
      - GF_USERS_ALLOW_SIGN_UP=false
      - GF_INSTALL_PLUGINS=grafana-piechart-panel
    restart: unless-stopped
    networks:
      - monitoring
    depends_on:
      - prometheus

  node-exporter:
    image: prom/node-exporter:latest
    container_name: mvx-node-exporter
    ports:
      - "9100:9100"
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /:/rootfs:ro
    command:
      - '--path.procfs=/host/proc'
      - '--path.sysfs=/host/sys'
      - '--collector.filesystem.ignored-mount-points=^/(sys|proc|dev|host|etc)($$|/)'
    restart: unless-stopped
    networks:
      - monitoring

  alertmanager:
    image: prom/alertmanager:latest
    container_name: mvx-alertmanager
    ports:
      - "9093:9093"
    volumes:
      - ./config/alertmanager:/etc/alertmanager:ro
    restart: unless-stopped
    networks:
      - monitoring

networks:
  monitoring:
    driver: bridge

volumes:
  prometheus_data:
  grafana_data:
EOF
}

setup_monitoring() {
    log "Setting up MultiversX monitoring infrastructure..."
    
    check_dependencies
    setup_directories
    generate_prometheus_config
    generate_grafana_config
    generate_docker_compose
    
    # Set correct permissions
    sudo chown -R 472:472 "$DATA_DIR/grafana" 2>/dev/null || true
    
    log "Monitoring infrastructure setup completed!"
    log "Next steps:"
    log "  1. Run: $0 start"
    log "  2. Open Grafana: http://localhost:3000 (admin/admin)"
    log "  3. Open Prometheus: http://localhost:9090"
}

start_monitoring() {
    log "Starting monitoring stack..."
    
    if [ ! -f "$COMPOSE_FILE" ]; then
        warn "Docker compose file not found. Running setup first..."
        setup_monitoring
    fi
    
    cd "$MONITORING_DIR"
    docker-compose up -d
    
    # Wait for services to be ready
    log "Waiting for services to start..."
    sleep 10
    
    if docker-compose ps | grep -q "Up"; then
        log "Monitoring stack started successfully!"
        log "Services available at:"
        log "  - Grafana: http://localhost:3000"
        log "  - Prometheus: http://localhost:9090"
        log "  - Node Exporter: http://localhost:9100"
        log "  - Alert Manager: http://localhost:9093"
    else
        error "Failed to start monitoring stack"
        docker-compose logs
        exit 1
    fi
}

stop_monitoring() {
    log "Stopping monitoring stack..."
    cd "$MONITORING_DIR"
    docker-compose down
    log "Monitoring stack stopped."
}

restart_monitoring() {
    log "Restarting monitoring stack..."
    stop_monitoring
    sleep 3
    start_monitoring
}

show_status() {
    log "Monitoring stack status:"
    cd "$MONITORING_DIR"
    
    if [ -f "$COMPOSE_FILE" ]; then
        docker-compose ps
    else
        warn "Monitoring stack not initialized. Run 'setup' first."
    fi
}

show_logs() {
    log "Showing monitoring stack logs:"
    cd "$MONITORING_DIR"
    docker-compose logs -f --tail=100
}

cleanup_monitoring() {
    log "Cleaning up monitoring stack..."
    cd "$MONITORING_DIR"
    docker-compose down -v --remove-orphans
    docker system prune -f
    log "Cleanup completed."
}

open_dashboard() {
    log "Opening Grafana dashboard..."
    if command -v xdg-open >/dev/null 2>&1; then
        xdg-open "http://localhost:3000"
    elif command -v open >/dev/null 2>&1; then
        open "http://localhost:3000"
    else
        log "Please open http://localhost:3000 in your browser"
        log "Default credentials: admin/admin"
    fi
}

show_metrics() {
    log "Current metrics summary:"
    
    # Check if Prometheus is accessible
    if curl -s "http://localhost:9090/api/v1/query?query=up" >/dev/null 2>&1; then
        echo "=== MultiversX Nodes ==="
        curl -s "http://localhost:9090/api/v1/query?query=up{job=~'multiversx-.*'}" | \
            python3 -c "import sys, json; data=json.load(sys.stdin); [print(f\"{r['metric']['job']}: {'UP' if r['value'][1] == '1' else 'DOWN'}\") for r in data['data']['result']]"
        
        echo "\n=== System Resources ==="
        echo "CPU Usage:"
        curl -s "http://localhost:9090/api/v1/query?query=100-avg(rate(node_cpu_seconds_total{mode='idle'}[5m]))*100" | \
            python3 -c "import sys, json; data=json.load(sys.stdin); print(f\"{float(data['data']['result'][0]['value'][1]):.1f}%\" if data['data']['result'] else 'N/A')"
    else
        warn "Prometheus is not accessible. Is the monitoring stack running?"
    fi
}

backup_monitoring() {
    local backup_file="monitoring_backup_$(date +%Y%m%d_%H%M%S).tar.gz"
    log "Creating backup: $backup_file"
    
    tar -czf "$backup_file" -C "$MONITORING_DIR" config data
    log "Backup created: $backup_file"
}

update_monitoring() {
    log "Updating monitoring stack images..."
    cd "$MONITORING_DIR"
    docker-compose pull
    restart_monitoring
    log "Update completed."
}

# Main script logic
case "${1:-}" in
    setup)
        setup_monitoring
        ;;
    start)
        start_monitoring
        ;;
    stop)
        stop_monitoring
        ;;
    restart)
        restart_monitoring
        ;;
    status)
        show_status
        ;;
    logs)
        show_logs
        ;;
    cleanup)
        cleanup_monitoring
        ;;
    dashboard)
        open_dashboard
        ;;
    metrics)
        show_metrics
        ;;
    backup)
        backup_monitoring
        ;;
    update)
        update_monitoring
        ;;
    *)
        usage
        exit 1
        ;;
esac
