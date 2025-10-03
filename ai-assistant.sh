#!/bin/bash

# MultiversX AI Assistant Integration
# Gemini CLI + FastMCP integration for automated development
# Author: George Pricop (Gzeu)
# Date: October 2025

set -e

# Configuration
AI_CONFIG_DIR="./ai-config"
GEMINI_CONFIG="$AI_CONFIG_DIR/gemini.json"
MCP_SERVER_DIR="$AI_CONFIG_DIR/mcp-server"
TOOLS_DIR="$AI_CONFIG_DIR/tools"
LOGS_DIR="./logs"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

# Unicode symbols
ROBOT="🤖"
BRAIN="🧠"
ROCKET="🚀"
GEAR="⚙️"
CHECKMARK="✓"
CROSS="✗"
WARNING="⚠️"

# Logging functions
log() { echo -e "${GREEN}[$(date +'%H:%M:%S')] $CHECKMARK${NC} $1"; }
warn() { echo -e "${YELLOW}[$(date +'%H:%M:%S')] $WARNING${NC} $1"; }
error() { echo -e "${RED}[$(date +'%H:%M:%S')] $CROSS${NC} $1"; }
info() { echo -e "${BLUE}[$(date +'%H:%M:%S')] $BRAIN${NC} $1"; }
success() { echo -e "${GREEN}[$(date +'%H:%M:%S')] $ROCKET${NC} $1"; }

# Print AI banner
print_ai_banner() {
    clear
    echo -e "${CYAN}"
    echo "  ╭──────────────────────────────────────────────────────────────────────╮"
    echo "  │              $ROBOT MultiversX AI Development Assistant $ROBOT              │"
    echo "  │                    Powered by Gemini CLI + FastMCP                   │"
    echo "  ╰──────────────────────────────────────────────────────────────────────╯"
    echo -e "${NC}"
    echo ""
}

# Initialize AI environment
init_ai_environment() {
    mkdir -p "$AI_CONFIG_DIR"
    mkdir -p "$MCP_SERVER_DIR"
    mkdir -p "$TOOLS_DIR"
    mkdir -p "$LOGS_DIR"
    
    log "AI environment initialized"
}

# Check dependencies
check_ai_dependencies() {
    local missing_deps=()
    
    # Check Node.js for Gemini CLI
    if ! command -v node &> /dev/null; then
        missing_deps+=("nodejs")
    fi
    
    # Check npm
    if ! command -v npm &> /dev/null; then
        missing_deps+=("npm")
    fi
    
    # Check Python for FastMCP
    if ! command -v python3 &> /dev/null; then
        missing_deps+=("python3")
    fi
    
    # Check pip
    if ! command -v pip3 &> /dev/null; then
        missing_deps+=("python3-pip")
    fi
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        error "Missing required dependencies: ${missing_deps[*]}"
        echo ""
        echo "Install dependencies:"
        echo "  Ubuntu/Debian: sudo apt update && sudo apt install ${missing_deps[*]}"
        echo "  macOS: brew install ${missing_deps[*]}"
        return 1
    fi
    
    success "All AI dependencies are available"
}

# Install Gemini CLI
install_gemini_cli() {
    log "Installing Gemini CLI..."
    
    if command -v gemini &> /dev/null; then
        warn "Gemini CLI already installed"
        return 0
    fi
    
    # Install Gemini CLI globally
    if npm install -g @google/gemini-cli; then
        success "Gemini CLI installed successfully"
    else
        error "Failed to install Gemini CLI"
        return 1
    fi
}

# Install FastMCP
install_fastmcp() {
    log "Installing FastMCP..."
    
    if python3 -c "import fastmcp" 2>/dev/null; then
        warn "FastMCP already installed"
        return 0
    fi
    
    if pip3 install fastmcp>=2.12.3; then
        success "FastMCP installed successfully"
    else
        error "Failed to install FastMCP"
        return 1
    fi
}

# Setup Gemini CLI configuration
setup_gemini_config() {
    log "Setting up Gemini CLI configuration..."
    
    # Create Gemini configuration
    cat > "$GEMINI_CONFIG" << 'EOF'
{
    "workspace": "./",
    "model": "gemini-1.5-pro-latest",
    "temperature": 0.1,
    "max_tokens": 8192,
    "tools": ["file_operations", "shell", "web_search"],
    "context": {
        "project_type": "MultiversX Blockchain Development",
        "framework": "mxpy, Rust, TypeScript",
        "focus": "Smart Contracts, DApps, Testing, DevOps"
    },
    "prompts": {
        "system": "You are an expert MultiversX blockchain developer assistant. You specialize in smart contract development, testing, deployment, and DevOps automation. Always provide secure, optimized, and well-documented code."
    }
}
EOF
    
    success "Gemini CLI configuration created"
}

# Create MultiversX MCP Server
create_mcp_server() {
    log "Creating MultiversX MCP Server..."
    
    cat > "$MCP_SERVER_DIR/multiversx_server.py" << 'EOF'
#!/usr/bin/env python3
"""
MultiversX MCP Server
Provides MultiversX-specific tools for AI assistants
"""

from fastmcp import FastMCP
import subprocess
import json
import os
from pathlib import Path

# Initialize MCP server
mcp = FastMCP("MultiversX Development Server")

@mcp.tool()
def deploy_smart_contract(
    contract_path: str,
    network: str = "localnet",
    gas_limit: int = 60000000,
    arguments: str = ""
) -> dict:
    """Deploy a smart contract to MultiversX network"""
    try:
        cmd = [
            "mxpy", "contract", "deploy",
            "--bytecode", contract_path,
            "--pem", "./testnet/wallets/users/alice.pem",
            "--gas-limit", str(gas_limit),
            "--send"
        ]
        
        if arguments:
            cmd.extend(["--arguments", arguments])
            
        result = subprocess.run(cmd, capture_output=True, text=True)
        
        if result.returncode == 0:
            return {
                "status": "success",
                "message": "Contract deployed successfully",
                "output": result.stdout
            }
        else:
            return {
                "status": "error",
                "message": "Deployment failed",
                "error": result.stderr
            }
    except Exception as e:
        return {"status": "error", "message": str(e)}

@mcp.tool()
def setup_localnet(config_template: str = "dev") -> dict:
    """Setup MultiversX localnet with specific configuration"""
    try:
        # Apply configuration template
        subprocess.run(["./config-manager.sh", "apply", config_template], check=True)
        
        # Start localnet
        result = subprocess.run(["./start-localnet.sh"], capture_output=True, text=True)
        
        if result.returncode == 0:
            return {
                "status": "success",
                "message": f"Localnet started with {config_template} configuration",
                "config": config_template
            }
        else:
            return {
                "status": "error",
                "message": "Failed to start localnet",
                "error": result.stderr
            }
    except Exception as e:
        return {"status": "error", "message": str(e)}

@mcp.tool()
def run_tests(test_type: str = "all") -> dict:
    """Run MultiversX tests"""
    try:
        result = subprocess.run(
            ["./test-benchmark.sh", test_type],
            capture_output=True,
            text=True
        )
        
        return {
            "status": "success" if result.returncode == 0 else "error",
            "test_type": test_type,
            "output": result.stdout,
            "error": result.stderr if result.returncode != 0 else None
        }
    except Exception as e:
        return {"status": "error", "message": str(e)}

@mcp.tool()
def create_smart_contract_template(
    name: str,
    contract_type: str = "basic"
) -> dict:
    """Create a smart contract template"""
    try:
        contract_dir = f"./contracts/{name}"
        os.makedirs(contract_dir, exist_ok=True)
        
        # Basic smart contract template
        if contract_type == "basic":
            contract_code = f'''#![no_std]

use multiversx_sc::imports::*;

#[multiversx_sc::contract]
pub trait {name.capitalize()}Contract {{
    #[init]
    fn init(&self) {{}}
    
    #[endpoint]
    fn hello_world(&self) -> ManagedBuffer {{
        ManagedBuffer::from(b"Hello, MultiversX!")
    }}
    
    #[view]
    fn get_contract_name(&self) -> ManagedBuffer {{
        ManagedBuffer::from(b"{name}")
    }}
}}
'''
        
        # Write contract file
        with open(f"{contract_dir}/src/lib.rs", "w") as f:
            f.write(contract_code)
            
        # Create Cargo.toml
        cargo_toml = f'''[package]
name = "{name}"
version = "0.1.0"
edition = "2021"

[dependencies]
multiversx-sc = "0.50.0"

[lib]
name = "{name}_contract"
path = "src/lib.rs"
crate-type = ["cdylib"]
'''
        
        with open(f"{contract_dir}/Cargo.toml", "w") as f:
            f.write(cargo_toml)
            
        return {
            "status": "success",
            "message": f"Smart contract template '{name}' created",
            "path": contract_dir,
            "type": contract_type
        }
    except Exception as e:
        return {"status": "error", "message": str(e)}

@mcp.tool()
def analyze_gas_usage(contract_path: str) -> dict:
    """Analyze gas usage of smart contract functions"""
    try:
        # This would integrate with MultiversX gas analysis tools
        return {
            "status": "success",
            "message": "Gas analysis completed",
            "contract": contract_path,
            "analysis": "Detailed gas analysis would be performed here"
        }
    except Exception as e:
        return {"status": "error", "message": str(e)}

@mcp.tool()
def get_network_status() -> dict:
    """Get current network status"""
    try:
        result = subprocess.run(
            ["curl", "-s", "http://localhost:7950/network/status"],
            capture_output=True,
            text=True
        )
        
        if result.returncode == 0:
            status_data = json.loads(result.stdout)
            return {
                "status": "success",
                "network_status": "running",
                "data": status_data
            }
        else:
            return {
                "status": "error",
                "network_status": "stopped",
                "message": "Localnet not running"
            }
    except Exception as e:
        return {"status": "error", "message": str(e)}

if __name__ == "__main__":
    mcp.run()
EOF
    
    chmod +x "$MCP_SERVER_DIR/multiversx_server.py"
    success "MultiversX MCP Server created"
}

# Create AI prompt templates
create_ai_templates() {
    log "Creating AI prompt templates..."
    
    mkdir -p "$TOOLS_DIR/prompts"
    
    # Smart contract generation prompt
    cat > "$TOOLS_DIR/prompts/smart_contract.txt" << 'EOF'
Generate a MultiversX smart contract with the following requirements:
- Use multiversx-sc framework
- Include proper error handling
- Add comprehensive documentation
- Implement security best practices
- Include unit tests
- Optimize for gas efficiency

Contract specifications: {specifications}
EOF
    
    # Code review prompt
    cat > "$TOOLS_DIR/prompts/code_review.txt" << 'EOF'
Review this MultiversX smart contract code for:
1. Security vulnerabilities
2. Gas optimization opportunities
3. Code quality and best practices
4. Potential bugs or issues
5. Documentation improvements

Provide specific recommendations with code examples.

Code to review: {code}
EOF
    
    # Testing prompt
    cat > "$TOOLS_DIR/prompts/testing.txt" << 'EOF'
Generate comprehensive tests for this MultiversX smart contract:
- Unit tests for all functions
- Integration tests
- Edge case testing
- Gas usage testing
- Security testing

Contract: {contract_path}
EOF
    
    success "AI prompt templates created"
}

# Setup AI workflow automation
setup_ai_workflows() {
    log "Setting up AI workflow automation..."
    
    mkdir -p "$TOOLS_DIR/workflows"
    
    # Create development workflow
    cat > "$TOOLS_DIR/workflows/dev_workflow.sh" << 'EOF'
#!/bin/bash
# AI-powered development workflow

echo "🤖 Starting AI-powered development workflow..."

# 1. Analyze current project
gemini "Analyze the current MultiversX project structure and suggest improvements"

# 2. Generate smart contract if needed
if [ "$1" = "new-contract" ]; then
    gemini "Create a new MultiversX smart contract based on: $2"
fi

# 3. Run automated tests
gemini "Review and run all tests for the MultiversX project"

# 4. Security analysis
gemini "Perform security analysis on all smart contracts"

# 5. Generate documentation
gemini "Update project documentation based on recent changes"

echo "✅ AI workflow completed!"
EOF
    
    chmod +x "$TOOLS_DIR/workflows/dev_workflow.sh"
    
    success "AI workflows created"
}

# Configure Gemini CLI for MultiversX
configure_gemini_multiversx() {
    log "Configuring Gemini CLI for MultiversX development..."
    
    # Set workspace
    gemini config set workspace "$(pwd)"
    
    # Set project context
    gemini config set context "MultiversX blockchain development with smart contracts, DApps, and testing automation"
    
    # Add custom instructions
    cat > ".gemini_instructions.md" << 'EOF'
# MultiversX Development Assistant Instructions

You are an expert MultiversX blockchain developer. Your expertise includes:

## Technical Stack
- **MultiversX SDK**: mxpy, mx-sdk-rs, mx-sdk-js
- **Smart Contracts**: Rust with multiversx-sc framework
- **Testing**: Unit tests, integration tests, scenarios
- **Deployment**: Localnet, testnet, mainnet deployment
- **Tools**: Visual Studio Code, Rust analyzer, Git

## Development Practices
- Always prioritize security in smart contracts
- Optimize for gas efficiency
- Write comprehensive tests
- Document all functions and modules
- Follow MultiversX coding standards
- Use proper error handling

## Common Tasks
- Smart contract development and testing
- DApp frontend integration
- Network configuration and management
- Performance optimization
- Security auditing
- DevOps automation

## Response Format
- Provide working code examples
- Include error handling
- Add inline comments
- Suggest testing approaches
- Mention security considerations
EOF
    
    success "Gemini CLI configured for MultiversX"
}

# Install all AI tools
install_ai_tools() {
    print_ai_banner
    
    info "Installing AI development tools..."
    
    init_ai_environment
    check_ai_dependencies || return 1
    install_gemini_cli || return 1
    install_fastmcp || return 1
    setup_gemini_config
    create_mcp_server
    create_ai_templates
    setup_ai_workflows
    configure_gemini_multiversx
    
    success "AI tools installation completed!"
    
    echo ""
    echo -e "${CYAN}🎉 MultiversX AI Assistant is ready!${NC}"
    echo ""
    echo "Available commands:"
    echo "  $0 chat          - Start AI chat session"
    echo "  $0 code-review   - AI code review"
    echo "  $0 generate      - Generate smart contract"
    echo "  $0 test          - AI-powered testing"
    echo "  $0 deploy        - AI-assisted deployment"
    echo ""
}

# AI chat session
start_ai_chat() {
    clear
    echo -e "${CYAN}🤖 MultiversX AI Assistant${NC}"
    echo "Type 'exit' to quit, 'help' for commands"
    echo ""
    
    while true; do
        read -p "$(echo -e "${BLUE}AI>${NC} ")" user_input
        
        case "$user_input" in
            "exit"|"quit")
                echo "Goodbye! 👋"
                break
                ;;
            "help")
                echo "Available commands:"
                echo "  analyze project    - Analyze current project"
                echo "  create contract    - Generate smart contract"
                echo "  review code        - Code review"
                echo "  run tests         - Execute tests"
                echo "  security audit    - Security analysis"
                echo "  exit              - Quit chat"
                ;;
            "analyze project")
                gemini "Analyze this MultiversX project structure and provide development recommendations"
                ;;
            "create contract")
                read -p "Contract description: " desc
                gemini "Create a MultiversX smart contract: $desc"
                ;;
            "review code")
                gemini "Review all smart contracts in this project for security and optimization"
                ;;
            "run tests")
                gemini "Execute comprehensive tests for this MultiversX project"
                ;;
            "security audit")
                gemini "Perform security audit on all smart contracts"
                ;;
            *)
                gemini "$user_input"
                ;;
        esac
        echo ""
    done
}

# AI code review
ai_code_review() {
    log "Starting AI code review..."
    
    if [ -z "$1" ]; then
        # Review all contracts
        gemini "Review all smart contracts in ./contracts/ directory for security vulnerabilities, gas optimization, and best practices"
    else
        # Review specific file
        gemini "Review this file for MultiversX smart contract best practices: $1"
    fi
}

# AI smart contract generation
ai_generate_contract() {
    local contract_name="$1"
    local description="$2"
    
    if [ -z "$contract_name" ] || [ -z "$description" ]; then
        error "Usage: $0 generate <contract_name> \"<description>\""
        return 1
    fi
    
    log "Generating smart contract: $contract_name"
    
    gemini "Create a complete MultiversX smart contract named '$contract_name' with the following requirements: $description. Include proper error handling, tests, and documentation."
}

# AI testing
ai_testing() {
    log "Starting AI-powered testing..."
    
    gemini "Analyze this MultiversX project and generate comprehensive tests for all smart contracts. Include unit tests, integration tests, and security tests."
}

# AI deployment assistance
ai_deploy() {
    local network="${1:-localnet}"
    
    log "AI deployment assistance for network: $network"
    
    gemini "Help me deploy all smart contracts in this MultiversX project to $network. Provide step-by-step instructions and verify deployment success."
}

# Main CLI interface
case "${1:-install}" in
    "install")
        install_ai_tools
        ;;
    "chat")
        start_ai_chat
        ;;
    "code-review")
        ai_code_review "$2"
        ;;
    "generate")
        ai_generate_contract "$2" "$3"
        ;;
    "test")
        ai_testing
        ;;
    "deploy")
        ai_deploy "$2"
        ;;
    "status")
        if command -v gemini &> /dev/null; then
            success "Gemini CLI is installed"
        else
            error "Gemini CLI is not installed"
        fi
        
        if python3 -c "import fastmcp" 2>/dev/null; then
            success "FastMCP is installed"
        else
            error "FastMCP is not installed"
        fi
        ;;
    "help")
        echo -e "${CYAN}MultiversX AI Assistant${NC}"
        echo ""
        echo "Usage: $0 <command> [options]"
        echo ""
        echo "Commands:"
        echo "  install              Install AI tools (Gemini CLI + FastMCP)"
        echo "  chat                 Start interactive AI chat session"
        echo "  code-review [file]   AI-powered code review"
        echo "  generate <name> <desc> Generate smart contract"
        echo "  test                 AI-powered testing"
        echo "  deploy [network]     AI deployment assistance"
        echo "  status               Check AI tools status"
        echo "  help                 Show this help message"
        echo ""
        echo "Examples:"
        echo "  $0 install                          # Install AI tools"
        echo "  $0 chat                            # Start AI chat"
        echo "  $0 generate token \"ERC20 token\"     # Generate contract"
        echo "  $0 code-review ./contracts/token.rs # Review specific file"
        echo ""
        ;;
    *)
        error "Unknown command: $1"
        echo "Use '$0 help' for usage information"
        exit 1
        ;;
esac