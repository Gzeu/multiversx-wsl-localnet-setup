#!/bin/bash

# MultiversX Localnet Configuration Manager
# Template-based configuration management for different development scenarios
# Author: George Pricop (Gzeu)
# Date: October 2025

set -e

# Configuration paths
CONFIG_DIR="./configs"
TEMPLATES_DIR="$CONFIG_DIR/templates"
ACTIVE_CONFIG="$CONFIG_DIR/active"
CUSTOM_CONFIG="$CONFIG_DIR/custom"
LOCALNET_DIR="$HOME/MultiversX/testnet"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

# Logging functions
log() { echo -e "${GREEN}[$(date +'%H:%M:%S')]${NC} $1"; }
warn() { echo -e "${YELLOW}[$(date +'%H:%M:%S')] WARN:${NC} $1"; }
error() { echo -e "${RED}[$(date +'%H:%M:%S')] ERROR:${NC} $1"; }
info() { echo -e "${BLUE}[$(date +'%H:%M:%S')] INFO:${NC} $1"; }
success() { echo -e "${GREEN}✓ $(date +'%H:%M:%S')${NC} $1"; }

# Initialize configuration environment
init_config_environment() {
    mkdir -p "$CONFIG_DIR"
    mkdir -p "$TEMPLATES_DIR"
    mkdir -p "$ACTIVE_CONFIG"
    mkdir -p "$CUSTOM_CONFIG"
    
    log "Configuration environment initialized"
}

# Create development template (fast iteration)
create_dev_template() {
    local template_dir="$TEMPLATES_DIR/dev"
    mkdir -p "$template_dir"
    
    # Development configuration - optimized for speed
    cat > "$template_dir/config.toml" << 'EOF'
# Development Configuration Template
# Optimized for fast iteration and debugging

[GeneralSettings]
    ChainID = "localnet"
    MinTransactionVersion = 1
    StartInEpochEnabled = true
    SCDeployEnableEpoch = 0
    BuiltInFunctionsEnableEpoch = 0
    RelayedTransactionsEnableEpoch = 0
    PenalizedTooMuchGasEnableEpoch = 0
    SwitchJailWaitingEnableEpoch = 0
    BelowSignedThresholdEnableEpoch = 0
    SwitchHysteresisForMinNodesEnableEpoch = 0
    TransactionSignedWithTxHashEnableEpoch = 0
    MetaProtectionEnableEpoch = 0
    AheadOfTimeGasUsageEnableEpoch = 0
    GasPriceModifierEnableEpoch = 0
    RepairCallbackEnableEpoch = 0
    BlockGasAndFeesReCheckEnableEpoch = 0
    BalanceWaitingListsEnableEpoch = 0
    ReturnDataToLastTransferEnableEpoch = 0
    SenderInOutTransferEnableEpoch = 0
    StakeEnableEpoch = 0
    StakingV2EnableEpoch = 0
    DoubleKeyProtectionEnableEpoch = 0
    ESDTEnableEpoch = 0
    GovernanceEnableEpoch = 0
    DelegationManagerEnableEpoch = 0
    DelegationSmartContractEnableEpoch = 0
    CorrectLastUnJailEpoch = 0
    SCProcessorV2EnableEpoch = 0

[EconomicsConfig]
    GlobalSettings = {
        GenesisTotalSupply = "20000000000000000000000000",
        MinimumInflation = 0.01,
        YearSettings = [
            { Year = 0, MaximumInflation = 0.1 }
        ]
    }
    RewardsSettings = {
        RewardsConfigByEpoch = [
            {
                LeaderPercentage = 0.1,
                DeveloperPercentage = 0.1,
                ProtocolSustainabilityPercentage = 0.1,
                ProtocolSustainabilityAddress = "erd1932eft30w753xyvme8d49qejgkjc09n5e49w4mwdjtm0neld797su0dlxp",
                TopUpGradientPoint = "300000000000000000000",
                TopUpFactor = 0.25,
                EpochEnable = 0,
            }
        ]
    }
    FeeSettings = {
        GasLimitSettings = [
            {
                MaxGasLimitPerBlock = "10000000",
                MaxGasLimitPerMiniBlock = "10000000",
                MaxGasLimitPerMetaBlock = "15000000",
                MaxGasLimitPerMetaMiniBlock = "15000000",
                MaxGasLimitPerTx = "600000000",
                MinGasPrice = "1000000000",
                GasPerDataByte = "1500",
                EpochEnable = 0,
            }
        ]
    }
EOF

    # Fast round configuration for development
    cat > "$template_dir/nodesSetup.json" << 'EOF'
{
    "startTime": 0,
    "roundDuration": 2000,
    "consensusGroupSize": 1,
    "minNodesPerShard": 1,
    "metaChainConsensusGroupSize": 1,
    "metaChainMinNodes": 1,
    "hysteresis": 0,
    "adaptivity": false,
    "chainID": "localnet",
    "minTransactionVersion": 1,
    "genesisMaxNumberOfShards": 3,
    "genesisShardConsensusGroupPreset": "normal"
}
EOF

    # Development-specific genesis
    cat > "$template_dir/genesis.json" << 'EOF'
{
    "alloc": {
        "erd1qyu5wthldzr8wx5c9ucg8kjagg0jfs53s8nr3zpz3hypefsdd8ssycr6th": {
            "balance": "1000000000000000000000000",
            "nonce": 0
        },
        "erd1spyavw0956vq68xj8y4tenjpq2wd5a9p2c6j8gsz7ztyrnpxrruqzu66jx": {
            "balance": "1000000000000000000000000",
            "nonce": 0
        }
    },
    "gasSchedule": {
        "BaseOpsAPICost": {
            "StorageStore": 200,
            "StorageLoad": 10,
            "GetCaller": 2,
            "CheckNoPayment": 1
        }
    }
}
EOF

    # Template metadata
    cat > "$template_dir/template.json" << 'EOF'
{
    "name": "Development",
    "description": "Fast development template with 2s rounds, minimal validators, optimized for quick iteration",
    "type": "dev",
    "features": [
        "Fast 2-second rounds",
        "Minimal validator setup (1 per shard)",
        "All features enabled from epoch 0",
        "Pre-funded development wallets",
        "Optimized gas settings"
    ],
    "use_cases": [
        "Smart contract development",
        "dApp frontend testing",
        "Quick prototyping",
        "Integration testing"
    ],
    "recommended_for": "Daily development work"
}
EOF

    success "Development template created"
}

# Create testing template (similar to testnet)
create_test_template() {
    local template_dir="$TEMPLATES_DIR/test"
    mkdir -p "$template_dir"
    
    cat > "$template_dir/config.toml" << 'EOF'
# Testing Configuration Template
# Similar to testnet conditions for realistic testing

[GeneralSettings]
    ChainID = "localnet"
    MinTransactionVersion = 1
    
[EconomicsConfig]
    GlobalSettings = {
        GenesisTotalSupply = "20000000000000000000000000",
        MinimumInflation = 0.01,
        YearSettings = [
            { Year = 0, MaximumInflation = 0.1 }
        ]
    }
    FeeSettings = {
        GasLimitSettings = [
            {
                MaxGasLimitPerBlock = "1500000",
                MaxGasLimitPerMiniBlock = "1500000",
                MaxGasLimitPerMetaBlock = "15000000",
                MaxGasLimitPerMetaMiniBlock = "15000000",
                MaxGasLimitPerTx = "600000000",
                MinGasPrice = "1000000000",
                GasPerDataByte = "1500",
                EpochEnable = 0,
            }
        ]
    }
EOF

    cat > "$template_dir/nodesSetup.json" << 'EOF'
{
    "startTime": 0,
    "roundDuration": 6000,
    "consensusGroupSize": 2,
    "minNodesPerShard": 2,
    "metaChainConsensusGroupSize": 2,
    "metaChainMinNodes": 2,
    "hysteresis": 0.2,
    "adaptivity": true,
    "chainID": "localnet",
    "minTransactionVersion": 1,
    "genesisMaxNumberOfShards": 3,
    "genesisShardConsensusGroupPreset": "normal"
}
EOF

    cat > "$template_dir/template.json" << 'EOF'
{
    "name": "Testing",
    "description": "Testnet-like configuration for realistic testing with 6s rounds and multiple validators",
    "type": "test",
    "features": [
        "Testnet-like 6-second rounds",
        "Multiple validators per shard (2)",
        "Realistic gas limits",
        "Consensus group simulation",
        "Hysteresis and adaptivity enabled"
    ],
    "use_cases": [
        "Pre-deployment testing",
        "Performance benchmarking",
        "Stress testing",
        "Final validation"
    ],
    "recommended_for": "Testing before mainnet deployment"
}
EOF

    success "Testing template created"
}

# Create production-like template
create_production_template() {
    local template_dir="$TEMPLATES_DIR/production"
    mkdir -p "$template_dir"
    
    cat > "$template_dir/config.toml" << 'EOF'
# Production-like Configuration Template
# Mainnet-like settings for final testing

[GeneralSettings]
    ChainID = "localnet"
    MinTransactionVersion = 1
    
[EconomicsConfig]
    GlobalSettings = {
        GenesisTotalSupply = "31415926535898462843383279502884197169399375105820974944592307816406286208998628034825342117067",
        MinimumInflation = 0.01,
        YearSettings = [
            { Year = 0, MaximumInflation = 0.1 }
        ]
    }
    FeeSettings = {
        GasLimitSettings = [
            {
                MaxGasLimitPerBlock = "1500000",
                MaxGasLimitPerMiniBlock = "1500000",
                MaxGasLimitPerMetaBlock = "15000000",
                MaxGasLimitPerMetaMiniBlock = "15000000",
                MaxGasLimitPerTx = "600000000",
                MinGasPrice = "1000000000",
                GasPerDataByte = "1500",
                EpochEnable = 0,
            }
        ]
    }
EOF

    cat > "$template_dir/nodesSetup.json" << 'EOF'
{
    "startTime": 0,
    "roundDuration": 6000,
    "consensusGroupSize": 63,
    "minNodesPerShard": 400,
    "metaChainConsensusGroupSize": 400,
    "metaChainMinNodes": 400,
    "hysteresis": 0.2,
    "adaptivity": true,
    "chainID": "localnet",
    "minTransactionVersion": 1,
    "genesisMaxNumberOfShards": 3,
    "genesisShardConsensusGroupPreset": "normal"
}
EOF

    cat > "$template_dir/template.json" << 'EOF'
{
    "name": "Production",
    "description": "Mainnet-like configuration with realistic parameters for final testing",
    "type": "production",
    "features": [
        "Mainnet-like parameters",
        "Large consensus groups",
        "Production token supply",
        "Realistic network conditions",
        "Full security features"
    ],
    "use_cases": [
        "Final pre-mainnet testing",
        "Security auditing",
        "Performance validation",
        "Load testing"
    ],
    "recommended_for": "Final validation before mainnet"
}
EOF

    success "Production template created"
}

# Create CI/CD template (minimal resources)
create_ci_template() {
    local template_dir="$TEMPLATES_DIR/ci"
    mkdir -p "$template_dir"
    
    cat > "$template_dir/config.toml" << 'EOF'
# CI/CD Configuration Template
# Minimal resource usage for automated testing pipelines

[GeneralSettings]
    ChainID = "localnet"
    MinTransactionVersion = 1
    
[EconomicsConfig]
    GlobalSettings = {
        GenesisTotalSupply = "20000000000000000000000000",
        MinimumInflation = 0.01,
        YearSettings = [
            { Year = 0, MaximumInflation = 0.1 }
        ]
    }
    FeeSettings = {
        GasLimitSettings = [
            {
                MaxGasLimitPerBlock = "10000000",
                MaxGasLimitPerMiniBlock = "10000000",
                MaxGasLimitPerMetaBlock = "15000000",
                MaxGasLimitPerMetaMiniBlock = "15000000",
                MaxGasLimitPerTx = "600000000",
                MinGasPrice = "1000000000",
                GasPerDataByte = "1500",
                EpochEnable = 0,
            }
        ]
    }
EOF

    cat > "$template_dir/nodesSetup.json" << 'EOF'
{
    "startTime": 0,
    "roundDuration": 1000,
    "consensusGroupSize": 1,
    "minNodesPerShard": 1,
    "metaChainConsensusGroupSize": 1,
    "metaChainMinNodes": 1,
    "hysteresis": 0,
    "adaptivity": false,
    "chainID": "localnet",
    "minTransactionVersion": 1,
    "genesisMaxNumberOfShards": 2,
    "genesisShardConsensusGroupPreset": "normal"
}
EOF

    cat > "$template_dir/template.json" << 'EOF'
{
    "name": "CI/CD",
    "description": "Minimal configuration optimized for CI/CD pipelines with fastest startup and low resource usage",
    "type": "ci",
    "features": [
        "Ultra-fast 1-second rounds",
        "Minimal validators (1 per shard)",
        "Only 2 shards",
        "Fastest startup time",
        "Low memory footprint"
    ],
    "use_cases": [
        "GitHub Actions",
        "GitLab CI/CD",
        "Automated testing",
        "Quick validation"
    ],
    "recommended_for": "Automated CI/CD pipelines"
}
EOF

    success "CI/CD template created"
}

# List available templates
list_templates() {
    echo -e "\n${CYAN}Available Configuration Templates:${NC}\n"
    
    if [ ! -d "$TEMPLATES_DIR" ] || [ -z "$(ls -A "$TEMPLATES_DIR" 2>/dev/null)" ]; then
        warn "No templates found. Run 'init' to create default templates."
        return 1
    fi
    
    for template in "$TEMPLATES_DIR"/*; do
        if [ -d "$template" ] && [ -f "$template/template.json" ]; then
            local name=$(jq -r '.name // "Unknown"' "$template/template.json" 2>/dev/null || echo "Unknown")
            local desc=$(jq -r '.description // "No description"' "$template/template.json" 2>/dev/null || echo "No description")
            local type=$(jq -r '.type // "unknown"' "$template/template.json" 2>/dev/null || echo "unknown")
            
            echo -e "${WHITE}$(basename "$template")${NC} (${type})"
            echo -e "  ${BLUE}Name:${NC} $name"
            echo -e "  ${BLUE}Description:${NC} $desc"
            
            # Show features if available
            local features=$(jq -r '.features[]? // empty' "$template/template.json" 2>/dev/null)
            if [ -n "$features" ]; then
                echo -e "  ${BLUE}Features:${NC}"
                echo "$features" | sed 's/^/    • /'
            fi
            
            echo ""
        fi
    done
}

# Apply a configuration template
apply_template() {
    local template_name="$1"
    
    if [ -z "$template_name" ]; then
        error "Template name required"
        list_templates
        return 1
    fi
    
    local template_dir="$TEMPLATES_DIR/$template_name"
    
    if [ ! -d "$template_dir" ]; then
        error "Template not found: $template_name"
        list_templates
        return 1
    fi
    
    log "Applying template: $template_name"
    
    # Backup current configuration if it exists
    if [ -d "$ACTIVE_CONFIG" ] && [ "$(ls -A "$ACTIVE_CONFIG" 2>/dev/null)" ]; then
        local backup_dir="$CONFIG_DIR/backup_$(date +%Y%m%d_%H%M%S)"
        cp -r "$ACTIVE_CONFIG" "$backup_dir"
        info "Current configuration backed up to: $backup_dir"
    fi
    
    # Clear active config
    rm -rf "$ACTIVE_CONFIG"/*
    
    # Copy template to active config
    cp -r "$template_dir"/* "$ACTIVE_CONFIG"/
    
    # Create symlinks for localnet if directory exists
    if [ -d "$LOCALNET_DIR" ]; then
        info "Creating configuration symlinks..."
        
        # Backup original configs
        for config_file in config.toml nodesSetup.json genesis.json; do
            if [ -f "$LOCALNET_DIR/$config_file" ]; then
                mv "$LOCALNET_DIR/$config_file" "$LOCALNET_DIR/${config_file}.backup.$(date +%s)" 2>/dev/null || true
            fi
        done
        
        # Create symlinks
        ln -sf "$(realpath "$ACTIVE_CONFIG/config.toml")" "$LOCALNET_DIR/config.toml" 2>/dev/null || true
        ln -sf "$(realpath "$ACTIVE_CONFIG/nodesSetup.json")" "$LOCALNET_DIR/nodesSetup.json" 2>/dev/null || true
        ln -sf "$(realpath "$ACTIVE_CONFIG/genesis.json")" "$LOCALNET_DIR/genesis.json" 2>/dev/null || true
    fi
    
    success "Template '$template_name' applied successfully"
    
    # Show applied configuration summary
    if [ -f "$ACTIVE_CONFIG/template.json" ]; then
        local name=$(jq -r '.name // "Unknown"' "$ACTIVE_CONFIG/template.json" 2>/dev/null)
        echo -e "\n${CYAN}Applied Configuration:${NC} $name"
        
        local features=$(jq -r '.features[]? // empty' "$ACTIVE_CONFIG/template.json" 2>/dev/null)
        if [ -n "$features" ]; then
            echo -e "${BLUE}Active Features:${NC}"
            echo "$features" | sed 's/^/  • /'
        fi
    fi
    
    warn "Restart localnet to apply new configuration"
}

# Show current configuration
show_current_config() {
    if [ ! -f "$ACTIVE_CONFIG/template.json" ]; then
        warn "No active configuration found"
        return 1
    fi
    
    echo -e "\n${CYAN}Current Active Configuration:${NC}\n"
    
    local name=$(jq -r '.name // "Unknown"' "$ACTIVE_CONFIG/template.json" 2>/dev/null)
    local desc=$(jq -r '.description // "No description"' "$ACTIVE_CONFIG/template.json" 2>/dev/null)
    local type=$(jq -r '.type // "unknown"' "$ACTIVE_CONFIG/template.json" 2>/dev/null)
    
    echo -e "${WHITE}Name:${NC} $name"
    echo -e "${WHITE}Type:${NC} $type"
    echo -e "${WHITE}Description:${NC} $desc"
    
    local features=$(jq -r '.features[]? // empty' "$ACTIVE_CONFIG/template.json" 2>/dev/null)
    if [ -n "$features" ]; then
        echo -e "\n${WHITE}Features:${NC}"
        echo "$features" | sed 's/^/  • /'
    fi
    
    local use_cases=$(jq -r '.use_cases[]? // empty' "$ACTIVE_CONFIG/template.json" 2>/dev/null)
    if [ -n "$use_cases" ]; then
        echo -e "\n${WHITE}Use Cases:${NC}"
        echo "$use_cases" | sed 's/^/  • /'
    fi
    
    echo ""
}

# Initialize default templates
init_default_templates() {
    init_config_environment
    
    log "Creating default configuration templates..."
    
    create_dev_template
    create_test_template
    create_production_template
    create_ci_template
    
    success "Default templates created successfully"
    
    echo -e "\n${CYAN}Available templates:${NC}"
    echo "  • dev        - Fast development (2s rounds)"
    echo "  • test       - Testnet-like (6s rounds)"
    echo "  • production - Mainnet-like settings"
    echo "  • ci         - CI/CD optimized (1s rounds)"
    echo ""
    echo -e "Use: ${WHITE}$0 apply <template_name>${NC} to apply a template"
}

# Main CLI interface
case "${1:-help}" in
    "init")
        init_default_templates
        ;;
    "list")
        list_templates
        ;;
    "apply")
        init_config_environment
        apply_template "$2"
        ;;
    "current")
        show_current_config
        ;;
    "help")
        echo -e "${CYAN}MultiversX Localnet Configuration Manager${NC}"
        echo ""
        echo "Usage: $0 <command> [options]"
        echo ""
        echo "Commands:"
        echo "  init                Initialize default configuration templates"
        echo "  list                List all available templates"
        echo "  apply <template>    Apply a configuration template"
        echo "  current             Show current active configuration"
        echo "  help                Show this help message"
        echo ""
        echo "Default Templates:"
        echo "  dev                 Development template (2s rounds, fast iteration)"
        echo "  test                Testing template (6s rounds, testnet-like)"
        echo "  production          Production template (mainnet-like settings)"
        echo "  ci                  CI/CD template (1s rounds, minimal resources)"
        echo ""
        echo "Examples:"
        echo "  $0 init             # Create default templates"
        echo "  $0 apply dev        # Apply development template"
        echo "  $0 list             # Show all available templates"
        echo ""
        ;;
    *)
        error "Unknown command: $1"
        echo "Use '$0 help' for usage information"
        exit 1
        ;;
esac