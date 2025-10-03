#!/bin/bash

# MultiversX Localnet Backup & Recovery System
# Automated backup and recovery for MultiversX localnet data
# Author: George Pricop (Gzeu)
# Date: October 2025

set -e

# Configuration
LOCALNET_DIR="$HOME/MultiversX/testnet"
BACKUP_DIR="./backups"
MAX_BACKUPS=10
COMPRESSION_LEVEL=6
ENCRYPTION_KEY="multiversx-localnet-backup-key"
LOG_FILE="./logs/backup-recovery.log"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Logging functions
log() {
    local msg="[$(date +'%Y-%m-%d %H:%M:%S')] $1"
    echo -e "${GREEN}$msg${NC}"
    echo "$msg" >> "$LOG_FILE"
}

warn() {
    local msg="[$(date +'%Y-%m-%d %H:%M:%S')] WARN: $1"
    echo -e "${YELLOW}$msg${NC}"
    echo "$msg" >> "$LOG_FILE"
}

error() {
    local msg="[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1"
    echo -e "${RED}$msg${NC}"
    echo "$msg" >> "$LOG_FILE"
}

info() {
    local msg="[$(date +'%Y-%m-%d %H:%M:%S')] INFO: $1"
    echo -e "${BLUE}$msg${NC}"
    echo "$msg" >> "$LOG_FILE"
}

success() {
    local msg="[$(date +'%Y-%m-%d %H:%M:%S')] SUCCESS: $1"
    echo -e "${GREEN}✓ $msg${NC}"
    echo "$msg" >> "$LOG_FILE"
}

# Setup backup environment
setup_backup_environment() {
    mkdir -p "$BACKUP_DIR"
    mkdir -p "$(dirname "$LOG_FILE")"
    mkdir -p "./recovery"
    
    # Create backup metadata directory
    mkdir -p "$BACKUP_DIR/metadata"
    
    log "Backup environment initialized"
}

# Check if localnet is running
check_localnet_status() {
    if pgrep -f "mxpy" > /dev/null || pgrep -f "node" > /dev/null; then
        return 0  # Running
    else
        return 1  # Not running
    fi
}

# Stop localnet safely
stop_localnet_safely() {
    if check_localnet_status; then
        warn "Localnet is running. Stopping it safely..."
        
        # Try to stop gracefully first
        if [ -f "./stop-localnet.sh" ]; then
            ./stop-localnet.sh
        else
            # Fallback to killing processes
            pkill -f "mxpy" 2>/dev/null || true
            pkill -f "node" 2>/dev/null || true
        fi
        
        # Wait for processes to stop
        local timeout=30
        while check_localnet_status && [ $timeout -gt 0 ]; do
            sleep 1
            ((timeout--))
        done
        
        if check_localnet_status; then
            error "Failed to stop localnet gracefully"
            return 1
        else
            success "Localnet stopped safely"
        fi
    else
        info "Localnet is not running"
    fi
}

# Create backup metadata
create_backup_metadata() {
    local backup_name="$1"
    local backup_path="$2"
    local metadata_file="$BACKUP_DIR/metadata/${backup_name}.json"
    
    cat > "$metadata_file" << EOF
{
    "backup_name": "$backup_name",
    "timestamp": "$(date -Iseconds)",
    "backup_path": "$backup_path",
    "size_bytes": $(stat -f%z "$backup_path" 2>/dev/null || stat -c%s "$backup_path" 2>/dev/null || echo 0),
    "compression": "gzip",
    "compression_level": $COMPRESSION_LEVEL,
    "encrypted": false,
    "localnet_dir": "$LOCALNET_DIR",
    "system_info": {
        "os": "$(uname -s)",
        "kernel": "$(uname -r)",
        "arch": "$(uname -m)"
    },
    "mxpy_version": "$(mxpy --version 2>/dev/null || echo 'unknown')",
    "backup_type": "full",
    "files_included": [
        "node configs",
        "validator keys",
        "genesis files",
        "blockchain data",
        "logs"
    ]
}
EOF

    log "Backup metadata created: $metadata_file"
}

# Create full backup
create_full_backup() {
    local backup_name="backup_$(date +%Y%m%d_%H%M%S)"
    local backup_file="$BACKUP_DIR/${backup_name}.tar.gz"
    
    log "Starting full backup: $backup_name"
    
    # Stop localnet if running
    local was_running=false
    if check_localnet_status; then
        was_running=true
        stop_localnet_safely || {
            error "Failed to stop localnet for backup"
            return 1
        }
    fi
    
    # Create the backup
    if [ -d "$LOCALNET_DIR" ]; then
        info "Compressing localnet data..."
        tar -czf "$backup_file" -C "$(dirname "$LOCALNET_DIR")" "$(basename "$LOCALNET_DIR")" 2>/dev/null || {
            error "Failed to create backup archive"
            return 1
        }
        
        # Create metadata
        create_backup_metadata "$backup_name" "$backup_file"
        
        # Get backup size
        local backup_size=$(stat -f%z "$backup_file" 2>/dev/null || stat -c%s "$backup_file" 2>/dev/null || echo 0)
        local backup_size_mb=$((backup_size / 1024 / 1024))
        
        success "Backup created: $backup_file (${backup_size_mb}MB)"
        
        # Clean up old backups
        cleanup_old_backups
        
    else
        error "Localnet directory not found: $LOCALNET_DIR"
        return 1
    fi
    
    # Restart localnet if it was running
    if [ "$was_running" = true ]; then
        info "Restarting localnet..."
        if [ -f "./start-localnet.sh" ]; then
            ./start-localnet.sh &
            success "Localnet restarted"
        else
            warn "start-localnet.sh not found, please restart manually"
        fi
    fi
}

# Create incremental backup (only changed files)
create_incremental_backup() {
    local backup_name="incremental_$(date +%Y%m%d_%H%M%S)"
    local backup_file="$BACKUP_DIR/${backup_name}.tar.gz"
    local reference_file="$BACKUP_DIR/.last_backup_timestamp"
    
    log "Starting incremental backup: $backup_name"
    
    if [ ! -f "$reference_file" ]; then
        warn "No reference timestamp found, creating full backup instead"
        create_full_backup
        return
    fi
    
    local last_backup=$(cat "$reference_file")
    
    # Find files changed since last backup
    local temp_file="$(mktemp)"
    find "$LOCALNET_DIR" -newer "$reference_file" -type f > "$temp_file" 2>/dev/null || {
        warn "No changes detected since last backup"
        rm -f "$temp_file"
        return 0
    }
    
    if [ -s "$temp_file" ]; then
        info "Creating incremental backup with $(wc -l < "$temp_file") changed files..."
        tar -czf "$backup_file" -T "$temp_file" 2>/dev/null || {
            error "Failed to create incremental backup"
            rm -f "$temp_file"
            return 1
        }
        
        create_backup_metadata "$backup_name" "$backup_file"
        success "Incremental backup created: $backup_file"
    else
        info "No files changed since last backup"
    fi
    
    rm -f "$temp_file"
    date +%s > "$reference_file"
}

# List available backups
list_backups() {
    log "Available backups:"
    
    if [ ! -d "$BACKUP_DIR" ] || [ -z "$(ls -A "$BACKUP_DIR"/*.tar.gz 2>/dev/null)" ]; then
        warn "No backups found in $BACKUP_DIR"
        return 1
    fi
    
    echo -e "\n${CYAN}Backup Name${NC}\t\t${CYAN}Date${NC}\t\t\t${CYAN}Size${NC}\t${CYAN}Type${NC}"
    echo "--------------------------------------------------------------------------------"
    
    for backup in "$BACKUP_DIR"/*.tar.gz; do
        if [ -f "$backup" ]; then
            local basename=$(basename "$backup" .tar.gz)
            local size=$(stat -f%z "$backup" 2>/dev/null || stat -c%s "$backup" 2>/dev/null || echo 0)
            local size_mb=$((size / 1024 / 1024))
            local date_str=$(echo "$basename" | grep -o '[0-9]\{8\}_[0-9]\{6\}' | sed 's/_/ /' | sed 's/\(.\{4\}\)\(.\{2\}\)\(.\{2\}\) \(.\{2\}\)\(.\{2\}\)\(.\{2\}\)/\1-\2-\3 \4:\5:\6/')
            local type=$(echo "$basename" | grep -q "incremental" && echo "Incremental" || echo "Full")
            
            printf "%-24s\t%s\t%dMB\t%s\n" "$basename" "$date_str" "$size_mb" "$type"
        fi
    done
    
    echo ""
}

# Restore from backup
restore_from_backup() {
    local backup_name="$1"
    
    if [ -z "$backup_name" ]; then
        error "Backup name required"
        echo "Usage: $0 restore <backup_name>"
        list_backups
        return 1
    fi
    
    local backup_file="$BACKUP_DIR/${backup_name}.tar.gz"
    
    if [ ! -f "$backup_file" ]; then
        error "Backup file not found: $backup_file"
        list_backups
        return 1
    fi
    
    log "Starting restore from backup: $backup_name"
    
    # Stop localnet if running
    local was_running=false
    if check_localnet_status; then
        was_running=true
        stop_localnet_safely || {
            error "Failed to stop localnet for restore"
            return 1
        }
    fi
    
    # Create backup of current state before restore
    if [ -d "$LOCALNET_DIR" ]; then
        local current_backup="pre_restore_$(date +%Y%m%d_%H%M%S)"
        warn "Creating backup of current state: $current_backup"
        tar -czf "$BACKUP_DIR/${current_backup}.tar.gz" -C "$(dirname "$LOCALNET_DIR")" "$(basename "$LOCALNET_DIR")" 2>/dev/null || {
            warn "Failed to backup current state"
        }
    fi
    
    # Remove current localnet directory
    if [ -d "$LOCALNET_DIR" ]; then
        info "Removing current localnet directory..."
        rm -rf "$LOCALNET_DIR"
    fi
    
    # Extract backup
    info "Extracting backup..."
    tar -xzf "$backup_file" -C "$(dirname "$LOCALNET_DIR")" 2>/dev/null || {
        error "Failed to extract backup"
        return 1
    }
    
    success "Backup restored successfully"
    
    # Restart localnet if it was running
    if [ "$was_running" = true ]; then
        info "Restarting localnet..."
        if [ -f "./start-localnet.sh" ]; then
            ./start-localnet.sh &
            success "Localnet restarted"
        else
            warn "start-localnet.sh not found, please restart manually"
        fi
    fi
    
    info "Restore completed. You may need to wait for the network to synchronize."
}

# Cleanup old backups
cleanup_old_backups() {
    local backup_count=$(ls -1 "$BACKUP_DIR"/*.tar.gz 2>/dev/null | wc -l)
    
    if [ "$backup_count" -gt "$MAX_BACKUPS" ]; then
        local excess=$((backup_count - MAX_BACKUPS))
        info "Cleaning up $excess old backup(s)..."
        
        # Remove oldest backups
        ls -t "$BACKUP_DIR"/*.tar.gz | tail -n "$excess" | while read -r old_backup; do
            local basename=$(basename "$old_backup" .tar.gz)
            rm -f "$old_backup"
            rm -f "$BACKUP_DIR/metadata/${basename}.json"
            log "Removed old backup: $basename"
        done
    fi
}

# Verify backup integrity
verify_backup() {
    local backup_name="$1"
    
    if [ -z "$backup_name" ]; then
        error "Backup name required"
        return 1
    fi
    
    local backup_file="$BACKUP_DIR/${backup_name}.tar.gz"
    
    if [ ! -f "$backup_file" ]; then
        error "Backup file not found: $backup_file"
        return 1
    fi
    
    log "Verifying backup integrity: $backup_name"
    
    # Test archive integrity
    if tar -tzf "$backup_file" > /dev/null 2>&1; then
        success "Backup archive is valid"
        
        # Show archive contents summary
        local file_count=$(tar -tzf "$backup_file" | wc -l)
        info "Archive contains $file_count files/directories"
        
        return 0
    else
        error "Backup archive is corrupted"
        return 1
    fi
}

# Auto backup scheduler
schedule_auto_backup() {
    local interval="$1"  # in hours
    
    if [ -z "$interval" ]; then
        interval=24  # Default to daily backups
    fi
    
    log "Setting up automatic backups every $interval hours"
    
    # Create a simple cron-like scheduler
    cat > "./auto-backup.sh" << EOF
#!/bin/bash

# Auto backup script
while true; do
    sleep $((interval * 3600))
    $(realpath "$0") create
done
EOF
    
    chmod +x "./auto-backup.sh"
    
    # Start scheduler in background
    nohup ./auto-backup.sh > "./logs/auto-backup.log" 2>&1 &
    echo $! > "./auto-backup.pid"
    
    success "Auto backup scheduler started (PID: $(cat ./auto-backup.pid))"
    info "Backups will be created every $interval hours"
}

# Stop auto backup scheduler
stop_auto_backup() {
    if [ -f "./auto-backup.pid" ]; then
        local pid=$(cat "./auto-backup.pid")
        if kill "$pid" 2>/dev/null; then
            success "Auto backup scheduler stopped"
        else
            warn "Auto backup scheduler was not running"
        fi
        rm -f "./auto-backup.pid"
    else
        warn "Auto backup scheduler PID file not found"
    fi
}

# Main CLI interface
case "${1:-help}" in
    "create")
        setup_backup_environment
        create_full_backup
        ;;
    "incremental")
        setup_backup_environment
        create_incremental_backup
        ;;
    "list")
        list_backups
        ;;
    "restore")
        setup_backup_environment
        restore_from_backup "$2"
        ;;
    "verify")
        verify_backup "$2"
        ;;
    "cleanup")
        cleanup_old_backups
        ;;
    "schedule")
        setup_backup_environment
        schedule_auto_backup "$2"
        ;;
    "stop-schedule")
        stop_auto_backup
        ;;
    "help")
        echo -e "${CYAN}MultiversX Localnet Backup & Recovery System${NC}"
        echo ""
        echo "Usage: $0 <command> [options]"
        echo ""
        echo "Commands:"
        echo "  create              Create a full backup"
        echo "  incremental         Create an incremental backup"
        echo "  list                List all available backups"
        echo "  restore <name>      Restore from a specific backup"
        echo "  verify <name>       Verify backup integrity"
        echo "  cleanup             Remove old backups (keeps $MAX_BACKUPS)"
        echo "  schedule [hours]    Start automatic backup scheduler (default: 24h)"
        echo "  stop-schedule       Stop automatic backup scheduler"
        echo "  help                Show this help message"
        echo ""
        echo "Examples:"
        echo "  $0 create                    # Create full backup"
        echo "  $0 restore backup_20251003_120000  # Restore specific backup"
        echo "  $0 schedule 12               # Auto backup every 12 hours"
        echo ""
        ;;
    *)
        error "Unknown command: $1"
        echo "Use '$0 help' for usage information"
        exit 1
        ;;
esac