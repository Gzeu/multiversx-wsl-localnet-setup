#!/usr/bin/env bash
# MultiversX SDK Manager 2025
# Comprehensive SDK and toolchain management for MultiversX development

set -euo pipefail

# Configuration
SDK_DIR="$HOME/.multiversx-sdk"
BACKUP_DIR="$SDK_DIR/backups"
LOG_FILE="$SDK_DIR/sdk-manager.log"
VERSIONS_FILE="$SDK_DIR/versions.json"

# Colors
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

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

usage() {
    cat << EOF
MultiversX SDK Manager 2025

Usage: $0 [COMMAND] [OPTIONS]

Commands:
    install         Install/update all SDK components
    update          Update existing SDK components to latest
    status          Show current SDK versions and status
    backup          Backup current SDK configuration
    restore         Restore SDK from backup
    clean           Clean SDK cache and temporary files
    doctor          Diagnose SDK installation issues
    benchmark       Run SDK performance benchmarks
    configure       Configure SDK settings
    
Specific SDK Commands:
    install-mxpy        Install/update mxpy CLI
    install-rust        Install/update Rust toolchain
    install-node        Install/update Node.js SDK
    install-go          Install/update Go SDK
    install-python      Install/update Python SDK
    install-snippets    Install code snippets for IDEs
    
Options:
    --force         Force reinstallation
    --version VER   Install specific version
    --beta          Install beta/nightly versions
    --offline       Use offline installation if available
    
Examples:
    $0 install              # Install all SDK components
    $0 update --beta        # Update to beta versions
    $0 status               # Show current versions
    $0 doctor               # Check for issues
EOF
}

setup_directories() {
    mkdir -p "$SDK_DIR" "$BACKUP_DIR"
    touch "$LOG_FILE" "$VERSIONS_FILE"
}

check_system_requirements() {
    log "Checking system requirements..."
    
    # Check OS
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
    elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
        OS="windows"
    else
        error "Unsupported operating system: $OSTYPE"
        exit 1
    fi
    
    # Check architecture
    ARCH=$(uname -m)
    case $ARCH in
        x86_64|amd64) ARCH="amd64" ;;
        aarch64|arm64) ARCH="arm64" ;;
        *) error "Unsupported architecture: $ARCH"; exit 1 ;;
    esac
    
    log "System: $OS ($ARCH)"
    
    # Check required tools
    local required_tools=("curl" "git" "make")
    local missing_tools=()
    
    for tool in "${required_tools[@]}"; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            missing_tools+=("$tool")
        fi
    done
    
    if [ ${#missing_tools[@]} -ne 0 ]; then
        error "Missing required tools: ${missing_tools[*]}"
        exit 1
    fi
}

get_latest_version() {
    local repo="$1"
    local api_url="https://api.github.com/repos/$repo/releases/latest"
    curl -s "$api_url" | grep '"tag_name":' | sed -E 's/.*"v?([^"]+)".*/\1/'
}

save_version() {
    local component="$1"
    local version="$2"
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    
    # Create or update versions file
    if [ ! -f "$VERSIONS_FILE" ] || [ ! -s "$VERSIONS_FILE" ]; then
        echo '{}' > "$VERSIONS_FILE"
    fi
    
    # Update version info using Python (more reliable than jq for this)
    python3 -c "
import json
import sys

try:
    with open('$VERSIONS_FILE', 'r') as f:
        data = json.load(f)
except (FileNotFoundError, json.JSONDecodeError):
    data = {}

data['$component'] = {
    'version': '$version',
    'installed_at': '$timestamp',
    'os': '$OS',
    'arch': '$ARCH'
}

with open('$VERSIONS_FILE', 'w') as f:
    json.dump(data, f, indent=2)
" 2>/dev/null || warn "Failed to save version info for $component"
}

install_mxpy() {
    log "Installing/updating mxpy CLI..."
    
    # Method 1: Using pipx (recommended)
    if command -v pipx >/dev/null 2>&1; then
        log "Using pipx for mxpy installation..."
        pipx install multiversx-sdk-cli --force || pipx upgrade multiversx-sdk-cli
        local version=$(mxpy --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo "unknown")
        save_version "mxpy" "$version"
        log "mxpy installed/updated to version: $version"
        return 0
    fi
    
    # Method 2: Using pip with virtual environment
    log "Using pip with virtual environment..."
    local venv_dir="$SDK_DIR/mxpy-venv"
    
    python3 -m venv "$venv_dir"
    source "$venv_dir/bin/activate"
    pip install --upgrade pip
    pip install multiversx-sdk-cli --upgrade
    
    # Create wrapper script
    local wrapper_script="$SDK_DIR/bin/mxpy"
    mkdir -p "$(dirname "$wrapper_script")"
    cat > "$wrapper_script" << EOF
#!/bin/bash
source "$venv_dir/bin/activate"
exec mxpy "\$@"
EOF
    chmod +x "$wrapper_script"
    
    local version=$("$wrapper_script" --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo "unknown")
    save_version "mxpy" "$version"
    log "mxpy installed to version: $version"
    
    # Add to PATH if not already there
    if [[ ":$PATH:" != *":$SDK_DIR/bin:"* ]]; then
        echo "export PATH=\"$SDK_DIR/bin:\$PATH\"" >> ~/.bashrc
        warn "Added $SDK_DIR/bin to PATH. Please run 'source ~/.bashrc' or restart your shell."
    fi
}

install_rust() {
    log "Installing/updating Rust toolchain..."
    
    if ! command -v rustup >/dev/null 2>&1; then
        log "Installing Rust via rustup..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source ~/.cargo/env
    else
        log "Updating Rust toolchain..."
        rustup update
    fi
    
    # Install required components
    rustup component add clippy rustfmt
    rustup target add wasm32-unknown-unknown
    
    # Install cargo tools commonly used in MultiversX development
    local cargo_tools=(
        "cargo-audit"
        "cargo-expand"
        "cargo-watch"
        "twiggy"
        "wasm-pack"
    )
    
    for tool in "${cargo_tools[@]}"; do
        log "Installing/updating $tool..."
        cargo install "$tool" --force || warn "Failed to install $tool"
    done
    
    local rust_version=$(rustc --version | cut -d' ' -f2)
    save_version "rust" "$rust_version"
    log "Rust toolchain updated to version: $rust_version"
}

install_node_sdk() {
    log "Installing/updating Node.js SDK..."
    
    # Check if Node.js is installed
    if ! command -v node >/dev/null 2>&1; then
        warn "Node.js not found. Please install Node.js 16+ first."
        return 1
    fi
    
    local node_version=$(node --version | sed 's/^v//')
    log "Using Node.js version: $node_version"
    
    # Install/update MultiversX SDK packages globally
    local packages=(
        "@multiversx/sdk-cli@latest"
        "@multiversx/sdk-core@latest"
        "@multiversx/sdk-wallet@latest"
        "@multiversx/sdk-network-providers@latest"
        "@multiversx/sdk-transaction-processors@latest"
    )
    
    for package in "${packages[@]}"; do
        log "Installing/updating $package..."
        npm install -g "$package" || warn "Failed to install $package"
    done
    
    save_version "nodejs-sdk" "$(npm list -g @multiversx/sdk-core --depth=0 2>/dev/null | grep -o '@[0-9]\+\.[0-9]\+\.[0-9]\+' | sed 's/@//' || echo 'unknown')"
}

install_go_sdk() {
    log "Installing/updating Go SDK..."
    
    if ! command -v go >/dev/null 2>&1; then
        warn "Go not found. Please install Go 1.19+ first."
        return 1
    fi
    
    local go_version=$(go version | grep -oE 'go[0-9]+\.[0-9]+\.[0-9]+' | sed 's/go//')
    log "Using Go version: $go_version"
    
    # Create SDK workspace
    local go_sdk_dir="$SDK_DIR/go-sdk"
    mkdir -p "$go_sdk_dir"
    cd "$go_sdk_dir"
    
    # Initialize Go module if not exists
    if [ ! -f "go.mod" ]; then
        go mod init multiversx-go-sdk
    fi
    
    # Install/update Go SDK packages
    go get -u github.com/multiversx/mx-sdk-go@latest
    go get -u github.com/multiversx/mx-chain-core-go@latest
    
    local go_sdk_version=$(go list -m github.com/multiversx/mx-sdk-go 2>/dev/null | cut -d' ' -f2 || echo "unknown")
    save_version "go-sdk" "$go_sdk_version"
    log "Go SDK updated to version: $go_sdk_version"
}

install_python_sdk() {
    log "Installing/updating Python SDK..."
    
    # Create virtual environment for Python SDK
    local python_sdk_dir="$SDK_DIR/python-sdk-venv"
    python3 -m venv "$python_sdk_dir"
    source "$python_sdk_dir/bin/activate"
    
    pip install --upgrade pip
    pip install multiversx-sdk --upgrade
    
    local python_sdk_version=$(pip show multiversx-sdk | grep Version | cut -d' ' -f2 || echo "unknown")
    save_version "python-sdk" "$python_sdk_version"
    log "Python SDK updated to version: $python_sdk_version"
}

install_code_snippets() {
    log "Installing code snippets for IDEs..."
    
    local snippets_dir="$SDK_DIR/snippets"
    mkdir -p "$snippets_dir/vscode" "$snippets_dir/idea"
    
    # VS Code snippets
    cat > "$snippets_dir/vscode/multiversx.code-snippets" << 'EOF'
{
    "MultiversX Smart Contract": {
        "prefix": "mx-contract",
        "body": [
            "multiversx_sc::imports!();",
            "",
            "#[multiversx_sc::contract]",
            "pub trait ${1:ContractName} {",
            "    #[init]",
            "    fn init(&self) {}",
            "    ",
            "    #[endpoint]",
            "    fn ${2:endpoint_name}(&self) {",
            "        // TODO: Implement endpoint",
            "    }",
            "}"
        ],
        "description": "Basic MultiversX smart contract template"
    },
    "MultiversX Test": {
        "prefix": "mx-test",
        "body": [
            "#[test]",
            "fn test_${1:test_name}() {",
            "    let mut setup = ContractSetup::new(${2:contract_name}::contract_obj);",
            "    ",
            "    // TODO: Implement test",
            "}"
        ],
        "description": "Basic MultiversX smart contract test"
    }
}
EOF
    
    log "Code snippets installed in: $snippets_dir"
    log "VS Code: Copy $snippets_dir/vscode/multiversx.code-snippets to ~/.config/Code/User/snippets/"
}

run_doctor() {
    log "Running MultiversX SDK diagnostics..."
    
    local issues=0
    
    echo "=== System Check ==="
    echo "OS: $OS ($ARCH)"
    echo "Shell: $SHELL"
    echo "PATH: $PATH"
    echo ""
    
    echo "=== SDK Components ==="
    
    # Check mxpy
    if command -v mxpy >/dev/null 2>&1; then
        local mxpy_version=$(mxpy --version 2>/dev/null || echo "unknown")
        echo "✓ mxpy: $mxpy_version"
    else
        echo "✗ mxpy: Not installed"
        ((issues++))
    fi
    
    # Check Rust
    if command -v rustc >/dev/null 2>&1; then
        local rust_version=$(rustc --version | cut -d' ' -f2)
        echo "✓ Rust: $rust_version"
        
        # Check WASM target
        if rustup target list --installed | grep -q "wasm32-unknown-unknown"; then
            echo "  ✓ WASM target installed"
        else
            echo "  ✗ WASM target not installed"
            ((issues++))
        fi
    else
        echo "✗ Rust: Not installed"
        ((issues++))
    fi
    
    # Check Node.js
    if command -v node >/dev/null 2>&1; then
        local node_version=$(node --version)
        echo "✓ Node.js: $node_version"
        
        # Check MultiversX packages
        if npm list -g @multiversx/sdk-core >/dev/null 2>&1; then
            echo "  ✓ MultiversX SDK installed"
        else
            echo "  ⚠ MultiversX SDK not installed globally"
        fi
    else
        echo "⚠ Node.js: Not installed (optional)"
    fi
    
    # Check Python
    if command -v python3 >/dev/null 2>&1; then
        local python_version=$(python3 --version | cut -d' ' -f2)
        echo "✓ Python: $python_version"
    else
        echo "⚠ Python: Not installed (optional for some tools)"
    fi
    
    # Check Docker
    if command -v docker >/dev/null 2>&1; then
        echo "✓ Docker: $(docker --version | cut -d' ' -f3 | tr -d ',')"
    else
        echo "⚠ Docker: Not installed (optional)"
    fi
    
    echo ""
    echo "=== Environment Variables ==="
    echo "HOME: ${HOME:-not set}"
    echo "CARGO_HOME: ${CARGO_HOME:-not set}"
    echo "RUSTUP_HOME: ${RUSTUP_HOME:-not set}"
    echo ""
    
    if [ $issues -eq 0 ]; then
        log "✓ No critical issues found!"
    else
        warn "Found $issues critical issues that need attention."
        log "Run '$0 install' to fix most issues automatically."
    fi
}

show_status() {
    log "MultiversX SDK Status"
    echo "======================"
    
    if [ -f "$VERSIONS_FILE" ] && [ -s "$VERSIONS_FILE" ]; then
        python3 -c "
import json
import datetime

try:
    with open('$VERSIONS_FILE', 'r') as f:
        data = json.load(f)
    
    for component, info in data.items():
        version = info.get('version', 'unknown')
        installed_at = info.get('installed_at', 'unknown')
        if installed_at != 'unknown':
            try:
                dt = datetime.datetime.fromisoformat(installed_at.replace('Z', '+00:00'))
                installed_at = dt.strftime('%Y-%m-%d %H:%M')
            except:
                pass
        
        print(f'{component:15} {version:15} {installed_at}')
        
except (FileNotFoundError, json.JSONDecodeError):
    print('No version information available. Run install first.')
"
    else
        echo "No SDK components installed yet."
        echo "Run '$0 install' to install all components."
    fi
}

backup_sdk() {
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local backup_file="$BACKUP_DIR/sdk_backup_$timestamp.tar.gz"
    
    log "Creating backup: $backup_file"
    
    tar -czf "$backup_file" -C "$SDK_DIR" \
        --exclude="backups" \
        --exclude="*.log" \
        --exclude="target" \
        --exclude="node_modules" \
        . 2>/dev/null || true
    
    log "Backup created: $backup_file"
}

clean_sdk() {
    log "Cleaning SDK cache and temporary files..."
    
    # Clean Rust cache
    if [ -d "$HOME/.cargo" ]; then
        cargo clean 2>/dev/null || true
    fi
    
    # Clean npm cache
    if command -v npm >/dev/null 2>&1; then
        npm cache clean --force 2>/dev/null || true
    fi
    
    # Clean pip cache
    if command -v pip3 >/dev/null 2>&1; then
        pip3 cache purge 2>/dev/null || true
    fi
    
    # Clean SDK temporary files
    find "$SDK_DIR" -name "*.tmp" -delete 2>/dev/null || true
    find "$SDK_DIR" -name "*.log" -mtime +7 -delete 2>/dev/null || true
    
    log "Cleanup completed."
}

install_all() {
    log "Installing/updating all MultiversX SDK components..."
    
    setup_directories
    check_system_requirements
    
    install_mxpy
    install_rust
    
    if command -v node >/dev/null 2>&1; then
        install_node_sdk
    else
        warn "Skipping Node.js SDK (Node.js not installed)"
    fi
    
    if command -v go >/dev/null 2>&1; then
        install_go_sdk
    else
        warn "Skipping Go SDK (Go not installed)"
    fi
    
    if command -v python3 >/dev/null 2>&1; then
        install_python_sdk
    else
        warn "Skipping Python SDK (Python3 not installed)"
    fi
    
    install_code_snippets
    
    log "SDK installation/update completed!"
    log "Run '$0 doctor' to verify the installation."
}

# Parse command line arguments
FORCE=false
BETA=false
OFFLINE=false
VERSION=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --force)
            FORCE=true
            shift
            ;;
        --beta)
            BETA=true
            shift
            ;;
        --offline)
            OFFLINE=true
            shift
            ;;
        --version)
            VERSION="$2"
            shift 2
            ;;
        *)
            break
            ;;
    esac
done

# Main command handling
case "${1:-}" in
    install)
        setup_directories
        install_all
        ;;
    update)
        setup_directories
        install_all
        ;;
    status)
        setup_directories
        show_status
        ;;
    doctor)
        setup_directories
        run_doctor
        ;;
    backup)
        setup_directories
        backup_sdk
        ;;
    clean)
        setup_directories
        clean_sdk
        ;;
    install-mxpy)
        setup_directories
        install_mxpy
        ;;
    install-rust)
        setup_directories
        install_rust
        ;;
    install-node)
        setup_directories
        install_node_sdk
        ;;
    install-go)
        setup_directories
        install_go_sdk
        ;;
    install-python)
        setup_directories
        install_python_sdk
        ;;
    install-snippets)
        setup_directories
        install_code_snippets
        ;;
    *)
        usage
        exit 1
        ;;
esac
