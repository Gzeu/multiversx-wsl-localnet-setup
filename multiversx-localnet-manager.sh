#!/bin/bash

# MultiversX Localnet Manager - Master Control Script
# Unified interface for all MultiversX localnet operations
# Author: George Pricop (Gzeu)
# Date: October 2025

set -e

# Script version
VERSION="1.0.0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Configuration
LOCALNET_DIR="$HOME/MultiversX/testnet"
LOGS_DIR="./logs"
DATA_DIR="./data"
CONFIG_DIR="./configs"

# Colors for beautiful output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
NC='\033[0m'

# Unicode symbols
CHECKMARK="✓"
CROSS="✗"
WARNING="⚠"
INFO="ℹ"
ROCKET="🚀"
GEAR="⚙"
CHART="📈"
BACKUP="💾"
TEST="🧪"

# Logging functions
log() {
    echo -e "${GREEN}[$(date +'%H:%M:%S')] $CHECKMARK${NC} $1"
}

warn() {
    echo -e "${YELLOW}[$(date +'%H:%M:%S')] $WARNING${NC} $1"
}

error() {
    echo -e "${RED}[$(date +'%H:%M:%S')] $CROSS${NC} $1"
}

info() {
    echo -e "${BLUE}[$(date +'%H:%M:%S')] $INFO${NC} $1"
}

success() {
    echo -e "${GREEN}[$(date +'%H:%M:%S')] $ROCKET${NC} $1"
}

# Print banner
print_banner() {
    clear
    echo -e "${CYAN}"
    echo "  ╭──────────────────────────────────────────────────────────────────────╮"
    echo "  │                 $ROCKET MultiversX Localnet Manager v$VERSION $ROCKET                 │"
    echo "  │                     Complete Development Suite                      │"
    echo "  ╰──────────────────────────────────────────────────────────────────────╯"
    echo -e "${NC}"
    echo -e "  ${BLUE}Author:${NC} George Pricop (${CYAN}@Gzeu${NC})"
    echo -e "  ${BLUE}GitHub:${NC} https://github.com/Gzeu/multiversx-wsl-localnet-setup"
    echo ""
}

# Check dependencies
check_dependencies() {
    local missing_deps=()
    
    # Check for required tools
    local required_tools=("python3" "curl" "tar" "mxpy")
    
    for tool in "${required_tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            missing_deps+=("$tool")
        fi
    done
    
    # Check for optional tools
    local optional_tools=("jq" "bc")
    for tool in "${optional_tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            warn "Optional tool '$tool' not found (some features may be limited)"
        fi
    done
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        error "Missing required dependencies: ${missing_deps[*]}"
        echo ""
        echo "Please install the missing dependencies:"
        echo "  Ubuntu/Debian: sudo apt update && sudo apt install ${missing_deps[*]}"
        echo "  macOS: brew install ${missing_deps[*]}"
        echo ""
        return 1
    fi
    
    success "All required dependencies are installed"
}

# Create directory structure
setup_directories() {
    local dirs=("$LOGS_DIR" "$DATA_DIR" "$CONFIG_DIR" "./backups" "./test-results" "./reports" "./dashboard")
    
    for dir in "${dirs[@]}"; do
        mkdir -p "$dir"
    done
    
    # Make all scripts executable
    chmod +x "$SCRIPT_DIR"/*.sh 2>/dev/null || true
    
    log "Directory structure created"
}

# Check localnet status
check_localnet_status() {
    if pgrep -f "mxpy" > /dev/null || curl -s "http://localhost:7950/network/status" > /dev/null 2>&1; then
        return 0  # Running
    else
        return 1  # Not running
    fi
}

# Interactive menu system
show_main_menu() {
    while true; do
        print_banner
        
        # Show status
        if check_localnet_status; then
            echo -e "  ${GREEN}$CHECKMARK Localnet Status: ${BOLD}RUNNING${NC} ${GREEN}(http://localhost:7950)${NC}"
        else
            echo -e "  ${RED}$CROSS Localnet Status: ${BOLD}STOPPED${NC}"
        fi
        
        echo ""
        echo -e "  ${CYAN}${BOLD}Main Operations:${NC}"
        echo -e "    ${WHITE}1.${NC} $ROCKET  Setup & Start Localnet"
        echo -e "    ${WHITE}2.${NC} $GEAR   Stop Localnet"
        echo -e "    ${WHITE}3.${NC} $GEAR   Reset Localnet"
        echo -e "    ${WHITE}4.${NC} $CHART  Launch Monitoring Dashboard"
        echo -e "    ${WHITE}5.${NC} $TEST   Run Tests & Benchmarks"
        echo ""
        echo -e "  ${CYAN}${BOLD}Configuration:${NC}"
        echo -e "    ${WHITE}6.${NC} $GEAR   Configuration Manager"
        echo -e "    ${WHITE}7.${NC} $BACKUP  Backup & Recovery"
        echo -e "    ${WHITE}8.${NC} $INFO   View Current Status"
        echo ""
        echo -e "  ${CYAN}${BOLD}Utilities:${NC}"
        echo -e "    ${WHITE}9.${NC} 💰  Fund Wallet (Faucet)"
        echo -e "    ${WHITE}10.${NC} 📁 View Logs"
        echo -e "    ${WHITE}11.${NC} 🧩 Cleanup All Data"
        echo ""
        echo -e "    ${WHITE}0.${NC} 🚪  Exit"
        echo ""
        
        read -p "  $(echo -e "${YELLOW}Select option [0-11]:${NC}") " choice
        
        case $choice in
            1) handle_setup_start ;;
            2) handle_stop ;;
            3) handle_reset ;;
            4) handle_dashboard ;;
            5) handle_testing ;;
            6) handle_config ;;
            7) handle_backup ;;
            8) handle_status ;;
            9) handle_faucet ;;
            10) handle_logs ;;
            11) handle_cleanup ;;
            0) exit 0 ;;
            *) 
                error "Invalid option: $choice"
                sleep 2
                ;;
        esac
    done
}

# Handle setup and start
handle_setup_start() {
    clear
    echo -e "${CYAN}${BOLD}Setup & Start Localnet${NC}\n"
    
    if check_localnet_status; then
        warn "Localnet is already running"
        read -p "Do you want to restart it? [y/N]: " restart
        if [[ $restart =~ ^[Yy]$ ]]; then
            "$SCRIPT_DIR/stop-localnet.sh"
            sleep 3
        else
            return
        fi
    fi
    
    # Run setup if not done
    if [ ! -d "$LOCALNET_DIR" ]; then
        log "Running initial setup..."
        "$SCRIPT_DIR/setup.sh"
    fi
    
    # Start localnet
    log "Starting localnet..."
    "$SCRIPT_DIR/start-localnet.sh"
    
    success "Localnet started successfully!"
    echo ""
    info "Access points:"
    echo "  • API: http://localhost:7950"
    echo "  • Dashboard: Run option 4 to launch monitoring"
    echo ""
    read -p "Press Enter to continue..."
}

# Handle stop
handle_stop() {
    clear
    echo -e "${CYAN}${BOLD}Stop Localnet${NC}\n"
    
    if ! check_localnet_status; then
        warn "Localnet is not running"
        read -p "Press Enter to continue..."
        return
    fi
    
    log "Stopping localnet..."
    "$SCRIPT_DIR/stop-localnet.sh"
    
    success "Localnet stopped successfully!"
    read -p "Press Enter to continue..."
}

# Handle reset
handle_reset() {
    clear
    echo -e "${CYAN}${BOLD}Reset Localnet${NC}\n"
    
    warn "This will completely reset the localnet (all data will be lost)"
    read -p "Are you sure? [y/N]: " confirm
    
    if [[ $confirm =~ ^[Yy]$ ]]; then
        log "Resetting localnet..."
        "$SCRIPT_DIR/reset-localnet.sh"
        success "Localnet reset completed!"
    else
        info "Reset cancelled"
    fi
    
    read -p "Press Enter to continue..."
}

# Handle dashboard
handle_dashboard() {
    clear
    echo -e "${CYAN}${BOLD}Monitoring Dashboard${NC}\n"
    
    if ! check_localnet_status; then
        warn "Localnet is not running. Start it first."
        read -p "Press Enter to continue..."
        return
    fi
    
    echo "Choose dashboard option:"
    echo "  1. Launch web dashboard"
    echo "  2. Start monitoring only"
    echo "  3. View metrics report"
    echo ""
    read -p "Select [1-3]: " dash_choice
    
    case $dash_choice in
        1)
            log "Starting web dashboard..."
            "$SCRIPT_DIR/monitor-dashboard.sh" dashboard &
            sleep 3
            info "Dashboard started at http://localhost:8080"
            ;;
        2)
            log "Starting monitoring..."
            "$SCRIPT_DIR/monitor-dashboard.sh" start
            ;;
        3)
            "$SCRIPT_DIR/monitor-dashboard.sh" report
            ;;
        *)
            error "Invalid option"
            ;;
    esac
    
    read -p "Press Enter to continue..."
}

# Handle testing
handle_testing() {
    clear
    echo -e "${CYAN}${BOLD}Testing & Benchmarks${NC}\n"
    
    if ! check_localnet_status; then
        warn "Localnet is not running. Start it first."
        read -p "Press Enter to continue..."
        return
    fi
    
    echo "Choose test type:"
    echo "  1. Full test suite"
    echo "  2. Connectivity test only"
    echo "  3. Throughput benchmark"
    echo "  4. Smart contract deployment test"
    echo "  5. Network stress test"
    echo ""
    read -p "Select [1-5]: " test_choice
    
    case $test_choice in
        1) "$SCRIPT_DIR/test-benchmark.sh" all ;;
        2) "$SCRIPT_DIR/test-benchmark.sh" connectivity ;;
        3) "$SCRIPT_DIR/test-benchmark.sh" throughput ;;
        4) "$SCRIPT_DIR/test-benchmark.sh" contract ;;
        5) "$SCRIPT_DIR/test-benchmark.sh" stress ;;
        *) error "Invalid option" ;;
    esac
    
    read -p "Press Enter to continue..."
}

# Handle configuration
handle_config() {
    clear
    echo -e "${CYAN}${BOLD}Configuration Manager${NC}\n"
    
    echo "Configuration options:"
    echo "  1. Initialize default templates"
    echo "  2. List available templates"
    echo "  3. Apply template"
    echo "  4. View current configuration"
    echo ""
    read -p "Select [1-4]: " config_choice
    
    case $config_choice in
        1) "$SCRIPT_DIR/config-manager.sh" init ;;
        2) "$SCRIPT_DIR/config-manager.sh" list ;;
        3)
            "$SCRIPT_DIR/config-manager.sh" list
            echo ""
            read -p "Enter template name: " template_name
            "$SCRIPT_DIR/config-manager.sh" apply "$template_name"
            ;;
        4) "$SCRIPT_DIR/config-manager.sh" current ;;
        *) error "Invalid option" ;;
    esac
    
    read -p "Press Enter to continue..."
}

# Handle backup
handle_backup() {
    clear
    echo -e "${CYAN}${BOLD}Backup & Recovery${NC}\n"
    
    echo "Backup options:"
    echo "  1. Create full backup"
    echo "  2. Create incremental backup"
    echo "  3. List backups"
    echo "  4. Restore from backup"
    echo "  5. Verify backup"
    echo "  6. Schedule automatic backups"
    echo ""
    read -p "Select [1-6]: " backup_choice
    
    case $backup_choice in
        1) "$SCRIPT_DIR/backup-recovery.sh" create ;;
        2) "$SCRIPT_DIR/backup-recovery.sh" incremental ;;
        3) "$SCRIPT_DIR/backup-recovery.sh" list ;;
        4)
            "$SCRIPT_DIR/backup-recovery.sh" list
            echo ""
            read -p "Enter backup name: " backup_name
            "$SCRIPT_DIR/backup-recovery.sh" restore "$backup_name"
            ;;
        5)
            "$SCRIPT_DIR/backup-recovery.sh" list
            echo ""
            read -p "Enter backup name to verify: " backup_name
            "$SCRIPT_DIR/backup-recovery.sh" verify "$backup_name"
            ;;
        6)
            read -p "Enter backup interval in hours [24]: " interval
            interval=${interval:-24}
            "$SCRIPT_DIR/backup-recovery.sh" schedule "$interval"
            ;;
        *) error "Invalid option" ;;
    esac
    
    read -p "Press Enter to continue..."
}

# Handle status
handle_status() {
    clear
    echo -e "${CYAN}${BOLD}System Status${NC}\n"
    
    # Localnet status
    if check_localnet_status; then
        echo -e "${GREEN}$CHECKMARK Localnet: RUNNING${NC}"
        
        # Try to get detailed status
        if curl -s "http://localhost:7950/network/status" > /tmp/network_status.json 2>/dev/null; then
            if command -v jq &> /dev/null; then
                local epoch=$(jq -r '.status.erd_epoch_number // "N/A"' /tmp/network_status.json 2>/dev/null)
                local round=$(jq -r '.status.erd_round_number // "N/A"' /tmp/network_status.json 2>/dev/null)
                local nonce=$(jq -r '.status.erd_nonce // "N/A"' /tmp/network_status.json 2>/dev/null)
                
                echo "  Epoch: $epoch | Round: $round | Nonce: $nonce"
            fi
        fi
    else
        echo -e "${RED}$CROSS Localnet: STOPPED${NC}"
    fi
    
    echo ""
    
    # Process status
    local mxpy_processes=$(pgrep -f "mxpy" | wc -l)
    echo -e "${BLUE}Processes:${NC}"
    echo "  mxpy processes: $mxpy_processes"
    
    # Dashboard status
    if [ -f "dashboard.pid" ]; then
        local dash_pid=$(cat dashboard.pid)
        if ps -p "$dash_pid" > /dev/null 2>&1; then
            echo -e "  ${GREEN}Dashboard: RUNNING (PID: $dash_pid)${NC}"
        else
            echo -e "  ${RED}Dashboard: STOPPED${NC}"
        fi
    else
        echo -e "  ${YELLOW}Dashboard: NOT STARTED${NC}"
    fi
    
    # Disk usage
    echo ""
    echo -e "${BLUE}Disk Usage:${NC}"
    if [ -d "$LOCALNET_DIR" ]; then
        local localnet_size=$(du -sh "$LOCALNET_DIR" 2>/dev/null | cut -f1 || echo "N/A")
        echo "  Localnet data: $localnet_size"
    fi
    
    local logs_size=$(du -sh "$LOGS_DIR" 2>/dev/null | cut -f1 || echo "N/A")
    local backups_size=$(du -sh "./backups" 2>/dev/null | cut -f1 || echo "N/A")
    echo "  Logs: $logs_size"
    echo "  Backups: $backups_size"
    
    read -p "Press Enter to continue..."
}

# Handle faucet
handle_faucet() {
    clear
    echo -e "${CYAN}${BOLD}Wallet Faucet${NC}\n"
    
    if ! check_localnet_status; then
        warn "Localnet is not running. Start it first."
        read -p "Press Enter to continue..."
        return
    fi
    
    read -p "Enter wallet address to fund: " wallet_address
    
    if [ -n "$wallet_address" ]; then
        "$SCRIPT_DIR/faucet.sh" "$wallet_address"
    else
        error "No wallet address provided"
    fi
    
    read -p "Press Enter to continue..."
}

# Handle logs
handle_logs() {
    clear
    echo -e "${CYAN}${BOLD}View Logs${NC}\n"
    
    echo "Available logs:"
    echo "  1. Localnet logs"
    echo "  2. Monitoring logs"
    echo "  3. Backup logs"
    echo "  4. Test results"
    echo ""
    read -p "Select [1-4]: " log_choice
    
    case $log_choice in
        1)
            if [ -d "$LOCALNET_DIR/logs" ]; then
                tail -f "$LOCALNET_DIR/logs"/*.log 2>/dev/null || echo "No localnet logs found"
            else
                echo "No localnet logs directory found"
            fi
            ;;
        2)
            tail -f "$LOGS_DIR"/*.log 2>/dev/null || echo "No monitoring logs found"
            ;;
        3)
            if [ -f "$LOGS_DIR/backup-recovery.log" ]; then
                tail -f "$LOGS_DIR/backup-recovery.log"
            else
                echo "No backup logs found"
            fi
            ;;
        4)
            if [ -d "./test-results" ]; then
                ls -la ./test-results/
                echo ""
                read -p "Enter file name to view: " filename
                if [ -f "./test-results/$filename" ]; then
                    cat "./test-results/$filename"
                fi
            else
                echo "No test results found"
            fi
            ;;
        *) error "Invalid option" ;;
    esac
    
    echo ""
    read -p "Press Enter to continue..."
}

# Handle cleanup
handle_cleanup() {
    clear
    echo -e "${CYAN}${BOLD}Cleanup All Data${NC}\n"
    
    warn "This will remove ALL localnet data, logs, backups, and configurations"
    warn "This action cannot be undone!"
    echo ""
    read -p "Type 'DELETE' to confirm: " confirm
    
    if [ "$confirm" = "DELETE" ]; then
        # Stop everything first
        if check_localnet_status; then
            "$SCRIPT_DIR/stop-localnet.sh"
        fi
        
        "$SCRIPT_DIR/monitor-dashboard.sh" stop 2>/dev/null || true
        "$SCRIPT_DIR/backup-recovery.sh" stop-schedule 2>/dev/null || true
        
        # Remove directories
        rm -rf "$LOCALNET_DIR" "$LOGS_DIR" "./backups" "./test-results" "./data" "./configs" "./dashboard"
        
        success "All data cleaned up successfully!"
    else
        info "Cleanup cancelled"
    fi
    
    read -p "Press Enter to continue..."
}

# Initialize environment
init_environment() {
    check_dependencies || exit 1
    setup_directories
}

# Main execution
if [ "${1:-}" = "--cli" ]; then
    # CLI mode for direct command execution
    shift
    case "${1:-help}" in
        "setup") "$SCRIPT_DIR/setup.sh" ;;
        "start") "$SCRIPT_DIR/start-localnet.sh" ;;
        "stop") "$SCRIPT_DIR/stop-localnet.sh" ;;
        "reset") "$SCRIPT_DIR/reset-localnet.sh" ;;
        "dashboard") "$SCRIPT_DIR/monitor-dashboard.sh" "${2:-start}" ;;
        "test") "$SCRIPT_DIR/test-benchmark.sh" "${2:-all}" ;;
        "config") "$SCRIPT_DIR/config-manager.sh" "${2:-list}" ;;
        "backup") "$SCRIPT_DIR/backup-recovery.sh" "${2:-list}" ;;
        "status") check_localnet_status && echo "RUNNING" || echo "STOPPED" ;;
        *)
            echo "Usage: $0 --cli <command>"
            echo "Commands: setup, start, stop, reset, dashboard, test, config, backup, status"
            ;;
    esac
else
    # Interactive mode
    init_environment
    show_main_menu
fi