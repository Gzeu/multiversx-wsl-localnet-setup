#!/bin/bash

# MultiversX Advanced Security & Vulnerability Scanner
# Automated security analysis and vulnerability detection
# Author: George Pricop (Gzeu)
# Date: October 2025

set -e

# Configuration
SECURITY_DIR="./security"
REPORTS_DIR="$SECURITY_DIR/reports"
TOOLS_DIR="$SECURITY_DIR/tools"
CONFIG_DIR="$SECURITY_DIR/config"
CONTRACTS_DIR="./contracts"

# Security tool versions
MYTHRIL_VERSION="latest"
SLITHER_VERSION="latest"
ADERYN_VERSION="latest"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

# Security symbols
SHIELD="🛡️"
LOCK="🔒"
WARNING="⚠️"
EYE="👁️"
BUG="🐛"
CHECKMARK="✓"
CROSS="✗"
SCAN="🔍"

# Logging functions
log() { echo -e "${GREEN}[$(date +'%H:%M:%S')] $CHECKMARK${NC} $1"; }
warn() { echo -e "${YELLOW}[$(date +'%H:%M:%S')] $WARNING${NC} $1"; }
error() { echo -e "${RED}[$(date +'%H:%M:%S')] $CROSS${NC} $1"; }
info() { echo -e "${BLUE}[$(date +'%H:%M:%S')] $EYE${NC} $1"; }
security() { echo -e "${PURPLE}[$(date +'%H:%M:%S')] $SHIELD${NC} $1"; }
scan() { echo -e "${CYAN}[$(date +'%H:%M:%S')] $SCAN${NC} $1"; }

# Print security banner
print_security_banner() {
    clear
    echo -e "${RED}"
    echo "  ╭──────────────────────────────────────────────────────────────────────╮"
    echo "  │            $SHIELD MultiversX Advanced Security Scanner $SHIELD            │"
    echo "  │                Automated Vulnerability Detection                │"
    echo "  ╰──────────────────────────────────────────────────────────────────────╯"
    echo -e "${NC}"
    echo ""
}

# Initialize security environment
init_security_environment() {
    mkdir -p "$SECURITY_DIR"
    mkdir -p "$REPORTS_DIR"
    mkdir -p "$TOOLS_DIR"
    mkdir -p "$CONFIG_DIR"
    
    log "Security environment initialized"
}

# Check security dependencies
check_security_dependencies() {
    local missing_deps=()
    
    # Check Python for security tools
    if ! command -v python3 &> /dev/null; then
        missing_deps+=("python3")
    fi
    
    # Check pip
    if ! command -v pip3 &> /dev/null; then
        missing_deps+=("python3-pip")
    fi
    
    # Check Rust for Aderyn
    if ! command -v cargo &> /dev/null; then
        missing_deps+=("rust")
    fi
    
    # Check Docker for containerized tools
    if ! command -v docker &> /dev/null; then
        warn "Docker not found - some security tools will run in local mode"
    fi
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        error "Missing required dependencies: ${missing_deps[*]}"
        echo ""
        echo "Install dependencies:"
        echo "  Ubuntu/Debian: sudo apt update && sudo apt install ${missing_deps[*]}"
        echo "  Rust: curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
        return 1
    fi
    
    security "All security dependencies are available"
}

# Install Mythril (Ethereum security analyzer)
install_mythril() {
    log "Installing Mythril security analyzer..."
    
    if command -v myth &> /dev/null; then
        warn "Mythril already installed"
        return 0
    fi
    
    if pip3 install mythril; then
        security "Mythril installed successfully"
    else
        error "Failed to install Mythril"
        return 1
    fi
}

# Install Slither (Solidity security analyzer)
install_slither() {
    log "Installing Slither security analyzer..."
    
    if command -v slither &> /dev/null; then
        warn "Slither already installed"
        return 0
    fi
    
    if pip3 install slither-analyzer; then
        security "Slither installed successfully"
    else
        error "Failed to install Slither"
        return 1
    fi
}

# Install Aderyn (Rust security analyzer)
install_aderyn() {
    log "Installing Aderyn security analyzer..."
    
    if command -v aderyn &> /dev/null; then
        warn "Aderyn already installed"
        return 0
    fi
    
    if cargo install aderyn; then
        security "Aderyn installed successfully"
    else
        error "Failed to install Aderyn"
        return 1
    fi
}

# Install all security tools
install_security_tools() {
    print_security_banner
    
    info "Installing security analysis tools..."
    
    init_security_environment
    check_security_dependencies || return 1
    
    # Install security analyzers
    install_mythril || warn "Mythril installation failed"
    install_slither || warn "Slither installation failed" 
    install_aderyn || warn "Aderyn installation failed"
    
    # Create security configurations
    create_security_configs
    
    security "Security tools installation completed!"
}

# Create security configuration files
create_security_configs() {
    log "Creating security configurations..."
    
    # Mythril config
    cat > "$CONFIG_DIR/mythril.yml" << 'EOF'
# Mythril Configuration
analysis:
  max_depth: 22
  call_depth_limit: 3
  create_timeout: 10
  execution_timeout: 86400
  
detectors:
  - SWC-101  # Integer Overflow
  - SWC-107  # Reentrancy
  - SWC-104  # Unchecked Call Return Value
  - SWC-105  # Unprotected Ether Withdrawal
  - SWC-108  # State Variable Default Visibility
  
output:
  format: json
  detailed: true
EOF

    # Slither config
    cat > "$CONFIG_DIR/slither.config.json" << 'EOF'
{
    "detectors_to_run": "all",
    "detectors_to_exclude": [],
    "disable_color": false,
    "filter_paths": [],
    "exclude_informational": false,
    "exclude_low": false,
    "exclude_medium": false,
    "exclude_high": false,
    "json": true,
    "sarif": false
}
EOF

    # Custom MultiversX security rules
    cat > "$CONFIG_DIR/multiversx_rules.yml" << 'EOF'
# MultiversX Specific Security Rules
rules:
  - id: "MX-001"
    name: "Unprotected Storage Access"
    description: "Check for unprotected storage operations"
    pattern: "storage_set|storage_get"
    severity: "high"
    
  - id: "MX-002"
    name: "Missing Payment Validation"
    description: "Endpoint should validate payment requirements"
    pattern: "#\[payable\]"
    severity: "medium"
    
  - id: "MX-003"
    name: "Integer Overflow Risk"
    description: "Check for potential integer overflow"
    pattern: "checked_add|checked_sub|checked_mul"
    severity: "high"
    
  - id: "MX-004"
    name: "Reentrancy Risk"
    description: "Check for reentrancy vulnerabilities"
    pattern: "call_value|async_call"
    severity: "critical"
    
  - id: "MX-005"
    name: "Access Control"
    description: "Check for proper access control"
    pattern: "only_owner|require_caller"
    severity: "high"
EOF

    success "Security configurations created"
}

# Scan smart contracts with Mythril
scan_with_mythril() {
    local contract_path="$1"
    local output_file="$REPORTS_DIR/mythril_$(date +%Y%m%d_%H%M%S).json"
    
    scan "Running Mythril security analysis on: $contract_path"
    
    if [ -f "$contract_path" ]; then
        if myth analyze "$contract_path" --config "$CONFIG_DIR/mythril.yml" -o "$output_file" 2>/dev/null; then
            security "Mythril analysis completed: $output_file"
            
            # Parse results
            local issues=$(jq '.issues | length' "$output_file" 2>/dev/null || echo "0")
            if [ "$issues" -gt 0 ]; then
                warn "Found $issues potential security issues"
            else
                security "No security issues found"
            fi
        else
            error "Mythril analysis failed for $contract_path"
        fi
    else
        error "Contract file not found: $contract_path"
    fi
}

# Scan smart contracts with Slither
scan_with_slither() {
    local contract_path="$1"
    local output_file="$REPORTS_DIR/slither_$(date +%Y%m%d_%H%M%S).json"
    
    scan "Running Slither security analysis on: $contract_path"
    
    if [ -f "$contract_path" ]; then
        if slither "$contract_path" --config-file "$CONFIG_DIR/slither.config.json" --json "$output_file" 2>/dev/null; then
            security "Slither analysis completed: $output_file"
            
            # Parse results
            local detectors=$(jq '.results.detectors | length' "$output_file" 2>/dev/null || echo "0")
            if [ "$detectors" -gt 0 ]; then
                warn "Found $detectors potential issues"
            else
                security "No issues detected"
            fi
        else
            error "Slither analysis failed for $contract_path"
        fi
    else
        error "Contract file not found: $contract_path"
    fi
}

# Scan Rust contracts with Aderyn
scan_with_aderyn() {
    local contract_dir="$1"
    local output_file="$REPORTS_DIR/aderyn_$(date +%Y%m%d_%H%M%S).json"
    
    scan "Running Aderyn security analysis on: $contract_dir"
    
    if [ -d "$contract_dir" ]; then
        if aderyn "$contract_dir" --output "$output_file" 2>/dev/null; then
            security "Aderyn analysis completed: $output_file"
        else
            error "Aderyn analysis failed for $contract_dir"
        fi
    else
        error "Contract directory not found: $contract_dir"
    fi
}

# Custom MultiversX security scanner
scan_multiversx_specific() {
    local contract_path="$1"
    local output_file="$REPORTS_DIR/multiversx_scan_$(date +%Y%m%d_%H%M%S).json"
    
    scan "Running MultiversX-specific security analysis..."
    
    # Initialize results
    echo '{"timestamp": "'$(date -Iseconds)'", "contract": "'$contract_path'", "issues": []}' > "$output_file"
    
    if [ ! -f "$contract_path" ]; then
        error "Contract file not found: $contract_path"
        return 1
    fi
    
    local issues_found=0
    
    # Check for common MultiversX vulnerabilities
    
    # 1. Unprotected storage operations
    if grep -n "storage_set\|storage_get" "$contract_path" | grep -v "require\|only_owner" > /dev/null; then
        warn "Potential unprotected storage access found"
        ((issues_found++))
    fi
    
    # 2. Missing payment validation
    if grep -n "#\[endpoint\]" "$contract_path" | while read -r line; do
        line_num=$(echo "$line" | cut -d: -f1)
        if ! sed -n "$((line_num-5)),$((line_num+5))p" "$contract_path" | grep -q "#\[payable\]\|require.*payment"; then
            warn "Endpoint without payment validation at line $line_num"
            ((issues_found++))
        fi
    done; then
        :
    fi
    
    # 3. Integer overflow checks
    if grep -n "\+\|-\|\*" "$contract_path" | grep -v "checked_" > /dev/null; then
        warn "Potential integer overflow - consider using checked arithmetic"
        ((issues_found++))
    fi
    
    # 4. Reentrancy checks
    if grep -n "async_call\|call_value" "$contract_path" | grep -v "reentrancy_guard" > /dev/null; then
        warn "Potential reentrancy vulnerability found"
        ((issues_found++))
    fi
    
    # 5. Access control
    if grep -n "storage_set\|transfer" "$contract_path" | grep -v "only_owner\|require_caller" > /dev/null; then
        warn "Missing access control on sensitive operations"
        ((issues_found++))
    fi
    
    if [ $issues_found -eq 0 ]; then
        security "MultiversX-specific scan completed - no issues found"
    else
        warn "MultiversX scan found $issues_found potential issues"
    fi
    
    # Update JSON report
    jq '.issues_count = '$issues_found'' "$output_file" > "${output_file}.tmp" && mv "${output_file}.tmp" "$output_file"
    
    security "MultiversX scan report: $output_file"
}

# Gas analysis for optimization
analyze_gas_usage() {
    local contract_path="$1"
    local output_file="$REPORTS_DIR/gas_analysis_$(date +%Y%m%d_%H%M%S).txt"
    
    scan "Analyzing gas usage patterns..."
    
    if [ ! -f "$contract_path" ]; then
        error "Contract file not found: $contract_path"
        return 1
    fi
    
    echo "Gas Usage Analysis - $(date)" > "$output_file"
    echo "Contract: $contract_path" >> "$output_file"
    echo "" >> "$output_file"
    
    # Analyze gas-expensive operations
    echo "=== Gas-Expensive Operations ===" >> "$output_file"
    
    # Storage operations
    local storage_ops=$(grep -n "storage_set\|storage_get" "$contract_path" | wc -l)
    echo "Storage operations: $storage_ops" >> "$output_file"
    
    # External calls
    local external_calls=$(grep -n "async_call\|call_value" "$contract_path" | wc -l)
    echo "External calls: $external_calls" >> "$output_file"
    
    # Loops
    local loops=$(grep -n "for\|while" "$contract_path" | wc -l)
    echo "Loops: $loops" >> "$output_file"
    
    # Complex computations
    local math_ops=$(grep -n "pow\|sqrt\|div" "$contract_path" | wc -l)
    echo "Math operations: $math_ops" >> "$output_file"
    
    echo "" >> "$output_file"
    echo "=== Optimization Recommendations ===" >> "$output_file"
    
    if [ $storage_ops -gt 10 ]; then
        echo "- Consider batching storage operations" >> "$output_file"
    fi
    
    if [ $external_calls -gt 5 ]; then
        echo "- Minimize external calls" >> "$output_file"
    fi
    
    if [ $loops -gt 3 ]; then
        echo "- Review loop efficiency and gas limits" >> "$output_file"
    fi
    
    security "Gas analysis completed: $output_file"
}

# Comprehensive security audit
comprehensive_audit() {
    local target="${1:-.}"
    
    print_security_banner
    security "Starting comprehensive security audit..."
    
    # Find all contract files
    local rust_contracts=$(find "$target" -name "*.rs" -path "*/src/*" 2>/dev/null || true)
    local solidity_contracts=$(find "$target" -name "*.sol" 2>/dev/null || true)
    
    if [ -z "$rust_contracts" ] && [ -z "$solidity_contracts" ]; then
        error "No smart contracts found in $target"
        return 1
    fi
    
    # Create audit report header
    local audit_report="$REPORTS_DIR/comprehensive_audit_$(date +%Y%m%d_%H%M%S).md"
    
    cat > "$audit_report" << EOF
# MultiversX Security Audit Report

**Date:** $(date)
**Target:** $target
**Tools Used:** Mythril, Slither, Aderyn, Custom MultiversX Scanner

## Summary

This report contains the results of a comprehensive security audit performed on the MultiversX smart contracts.

## Contracts Analyzed

EOF
    
    # Audit Rust contracts (MultiversX)
    if [ -n "$rust_contracts" ]; then
        echo "### Rust Contracts (MultiversX)" >> "$audit_report"
        echo "" >> "$audit_report"
        
        while IFS= read -r contract; do
            echo "- $contract" >> "$audit_report"
            
            log "Auditing Rust contract: $contract"
            
            # MultiversX-specific scan
            scan_multiversx_specific "$contract"
            
            # Gas analysis
            analyze_gas_usage "$contract"
            
            # Aderyn scan for Rust
            local contract_dir=$(dirname "$contract")
            scan_with_aderyn "$contract_dir"
            
        done <<< "$rust_contracts"
    fi
    
    # Audit Solidity contracts (if any)
    if [ -n "$solidity_contracts" ]; then
        echo "" >> "$audit_report"
        echo "### Solidity Contracts" >> "$audit_report"
        echo "" >> "$audit_report"
        
        while IFS= read -r contract; do
            echo "- $contract" >> "$audit_report"
            
            log "Auditing Solidity contract: $contract"
            
            # Mythril scan
            scan_with_mythril "$contract"
            
            # Slither scan
            scan_with_slither "$contract"
            
        done <<< "$solidity_contracts"
    fi
    
    # Generate summary
    echo "" >> "$audit_report"
    echo "## Audit Results Summary" >> "$audit_report"
    echo "" >> "$audit_report"
    
    local total_reports=$(find "$REPORTS_DIR" -name "*$(date +%Y%m%d)*" -type f | wc -l)
    echo "- Total reports generated: $total_reports" >> "$audit_report"
    echo "- Report location: $REPORTS_DIR" >> "$audit_report"
    echo "" >> "$audit_report"
    
    echo "## Recommendations" >> "$audit_report"
    echo "" >> "$audit_report"
    echo "1. Review all HIGH and CRITICAL severity findings immediately" >> "$audit_report"
    echo "2. Implement additional unit tests for identified edge cases" >> "$audit_report"
    echo "3. Consider formal verification for critical functions" >> "$audit_report"
    echo "4. Regular security audits before major releases" >> "$audit_report"
    echo "5. Gas optimization based on usage analysis" >> "$audit_report"
    
    security "Comprehensive audit completed!"
    echo ""
    echo -e "${CYAN}Audit Report: $audit_report${NC}"
    echo -e "${CYAN}Detailed Reports: $REPORTS_DIR${NC}"
}

# Quick security scan
quick_scan() {
    local target="${1:-.}"
    
    info "Running quick security scan on: $target"
    
    # Find Rust contracts
    local contracts=$(find "$target" -name "*.rs" -path "*/src/*" 2>/dev/null | head -5)
    
    if [ -z "$contracts" ]; then
        error "No Rust contracts found in $target"
        return 1
    fi
    
    while IFS= read -r contract; do
        scan_multiversx_specific "$contract"
    done <<< "$contracts"
    
    security "Quick scan completed"
}

# Security compliance check
check_compliance() {
    info "Checking security compliance..."
    
    local compliance_report="$REPORTS_DIR/compliance_$(date +%Y%m%d_%H%M%S).txt"
    
    echo "Security Compliance Check - $(date)" > "$compliance_report"
    echo "" >> "$compliance_report"
    
    # Check for security tools
    echo "=== Tool Availability ===" >> "$compliance_report"
    command -v myth &>/dev/null && echo "✓ Mythril installed" >> "$compliance_report" || echo "✗ Mythril missing" >> "$compliance_report"
    command -v slither &>/dev/null && echo "✓ Slither installed" >> "$compliance_report" || echo "✗ Slither missing" >> "$compliance_report"
    command -v aderyn &>/dev/null && echo "✓ Aderyn installed" >> "$compliance_report" || echo "✗ Aderyn missing" >> "$compliance_report"
    
    # Check for recent audits
    echo "" >> "$compliance_report"
    echo "=== Recent Audits ===" >> "$compliance_report"
    local recent_audits=$(find "$REPORTS_DIR" -name "*audit*" -mtime -30 2>/dev/null | wc -l)
    echo "Recent audits (30 days): $recent_audits" >> "$compliance_report"
    
    # Security best practices check
    echo "" >> "$compliance_report"
    echo "=== Best Practices ===" >> "$compliance_report"
    
    if [ -f ".github/workflows/security.yml" ]; then
        echo "✓ Automated security workflow exists" >> "$compliance_report"
    else
        echo "✗ No automated security workflow" >> "$compliance_report"
    fi
    
    if [ -d "tests/security" ]; then
        echo "✓ Security tests directory exists" >> "$compliance_report"
    else
        echo "✗ No dedicated security tests" >> "$compliance_report"
    fi
    
    security "Compliance check completed: $compliance_report"
}

# Main CLI interface
case "${1:-help}" in
    "install")
        install_security_tools
        ;;
    "audit")
        comprehensive_audit "$2"
        ;;
    "quick")
        init_security_environment
        quick_scan "$2"
        ;;
    "mythril")
        init_security_environment
        scan_with_mythril "$2"
        ;;
    "slither")
        init_security_environment
        scan_with_slither "$2"
        ;;
    "aderyn")
        init_security_environment
        scan_with_aderyn "$2"
        ;;
    "gas")
        init_security_environment
        analyze_gas_usage "$2"
        ;;
    "compliance")
        init_security_environment
        check_compliance
        ;;
    "reports")
        if [ -d "$REPORTS_DIR" ]; then
            echo -e "${CYAN}Security Reports:${NC}"
            ls -la "$REPORTS_DIR"
        else
            warn "No reports directory found"
        fi
        ;;
    "help")
        echo -e "${RED}$SHIELD MultiversX Advanced Security Scanner${NC}"
        echo ""
        echo "Usage: $0 <command> [options]"
        echo ""
        echo "Commands:"
        echo "  install              Install security tools (Mythril, Slither, Aderyn)"
        echo "  audit [path]         Comprehensive security audit"
        echo "  quick [path]         Quick security scan"
        echo "  mythril <file>       Scan with Mythril"
        echo "  slither <file>       Scan with Slither"
        echo "  aderyn <dir>         Scan with Aderyn"
        echo "  gas <file>           Gas usage analysis"
        echo "  compliance           Security compliance check"
        echo "  reports              List security reports"
        echo "  help                 Show this help message"
        echo ""
        echo "Examples:"
        echo "  $0 install                    # Install all security tools"
        echo "  $0 audit ./contracts          # Full audit of contracts directory"
        echo "  $0 quick ./src/lib.rs         # Quick scan of specific file"
        echo "  $0 gas ./contracts/token.rs   # Analyze gas usage"
        echo ""
        ;;
    *)
        error "Unknown command: $1"
        echo "Use '$0 help' for usage information"
        exit 1
        ;;
esac