#!/bin/bash

# MultiversX DevOps Automation Suite
# Advanced CI/CD, Infrastructure as Code, and Deployment Automation
# Author: George Pricop (Gzeu)
# Date: October 2025

set -e

# Configuration
DEVOPS_DIR="./devops"
CICD_DIR="$DEVOPS_DIR/cicd"
INFRA_DIR="$DEVOPS_DIR/infrastructure"
DEPLOY_DIR="$DEVOPS_DIR/deployments"
SCRIPTS_DIR="$DEVOPS_DIR/scripts"
TEMPLATES_DIR="$DEVOPS_DIR/templates"
LOGS_DIR="./logs/devops"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

# DevOps symbols
ROCKET="🚀"
GEAR="⚙️"
CLOUD="☁️"
ROBOT="🤖"
HAMMER="🔨"
WRENCH="🔧"
CHECKMARK="✓"
CROSS="✗"
WARNING="⚠️"
INFO="ℹ️"

# Logging functions
log() { echo -e "${GREEN}[$(date +'%H:%M:%S')] $CHECKMARK${NC} $1"; }
warn() { echo -e "${YELLOW}[$(date +'%H:%M:%S')] $WARNING${NC} $1"; }
error() { echo -e "${RED}[$(date +'%H:%M:%S')] $CROSS${NC} $1"; }
info() { echo -e "${BLUE}[$(date +'%H:%M:%S')] $INFO${NC} $1"; }
devops() { echo -e "${PURPLE}[$(date +'%H:%M:%S')] $GEAR${NC} $1"; }
deploy() { echo -e "${CYAN}[$(date +'%H:%M:%S')] $ROCKET${NC} $1"; }

# Print DevOps banner
print_devops_banner() {
    clear
    echo -e "${PURPLE}"
    echo "  ╭──────────────────────────────────────────────────────────────────────╮"
    echo "  │              $GEAR MultiversX DevOps Automation Suite $GEAR              │"
    echo "  │                   CI/CD, IaC, and Deployment                   │"
    echo "  ╰──────────────────────────────────────────────────────────────────────╯"
    echo -e "${NC}"
    echo ""
}

# Initialize DevOps environment
init_devops_environment() {
    mkdir -p "$DEVOPS_DIR"
    mkdir -p "$CICD_DIR"
    mkdir -p "$INFRA_DIR"
    mkdir -p "$DEPLOY_DIR"
    mkdir -p "$SCRIPTS_DIR"
    mkdir -p "$TEMPLATES_DIR"
    mkdir -p "$LOGS_DIR"
    
    log "DevOps environment initialized"
}

# Create GitHub Actions workflows
create_github_workflows() {
    log "Creating GitHub Actions workflows..."
    
    mkdir -p ".github/workflows"
    
    # Main CI/CD workflow
    cat > ".github/workflows/multiversx-ci-cd.yml" << 'EOF'
name: MultiversX CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

env:
  CARGO_TERM_COLOR: always
  NODE_VERSION: '18'
  PYTHON_VERSION: '3.11'

jobs:
  test:
    name: Test Suite
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
      
    - name: Setup Node.js
      uses: actions/setup-node@v4
      with:
        node-version: ${{ env.NODE_VERSION }}
        
    - name: Setup Python
      uses: actions/setup-python@v4
      with:
        python-version: ${{ env.PYTHON_VERSION }}
        
    - name: Setup Rust
      uses: actions-rs/toolchain@v1
      with:
        toolchain: stable
        override: true
        
    - name: Install mxpy
      run: |
        pip3 install multiversx-sdk-cli
        
    - name: Setup MultiversX Localnet
      run: |
        chmod +x *.sh
        ./config-manager.sh init
        ./config-manager.sh apply ci
        ./setup.sh
        ./start-localnet.sh
        
    - name: Wait for localnet
      run: |
        timeout 60 bash -c 'until curl -s http://localhost:7950/network/status; do sleep 2; done'
        
    - name: Run tests
      run: |
        ./test-benchmark.sh all
        
    - name: Security scan
      run: |
        ./advanced-security.sh install
        ./advanced-security.sh quick
        
    - name: Upload test results
      uses: actions/upload-artifact@v3
      if: always()
      with:
        name: test-results
        path: |
          ./test-results/
          ./security/reports/
          
  build:
    name: Build Smart Contracts
    runs-on: ubuntu-latest
    needs: test
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
      
    - name: Setup Rust
      uses: actions-rs/toolchain@v1
      with:
        toolchain: stable
        override: true
        
    - name: Install sc-meta
      run: cargo install multiversx-sc-meta
      
    - name: Build contracts
      run: |
        find ./contracts -name Cargo.toml -execdir cargo build --release \;
        
    - name: Upload artifacts
      uses: actions/upload-artifact@v3
      with:
        name: contract-artifacts
        path: |
          ./contracts/**/target/release/
          ./contracts/**/*.wasm
          
  deploy-testnet:
    name: Deploy to Testnet
    runs-on: ubuntu-latest
    needs: [test, build]
    if: github.ref == 'refs/heads/develop'
    environment: testnet
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
      
    - name: Download artifacts
      uses: actions/download-artifact@v3
      with:
        name: contract-artifacts
        
    - name: Deploy contracts
      env:
        TESTNET_PEM: ${{ secrets.TESTNET_PEM }}
      run: |
        echo "$TESTNET_PEM" > testnet.pem
        ./devops-automation.sh deploy testnet
        
  deploy-mainnet:
    name: Deploy to Mainnet
    runs-on: ubuntu-latest
    needs: [test, build]
    if: github.ref == 'refs/heads/main'
    environment: mainnet
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
      
    - name: Download artifacts
      uses: actions/download-artifact@v3
      with:
        name: contract-artifacts
        
    - name: Deploy contracts
      env:
        MAINNET_PEM: ${{ secrets.MAINNET_PEM }}
      run: |
        echo "$MAINNET_PEM" > mainnet.pem
        ./devops-automation.sh deploy mainnet
EOF

    # Security workflow
    cat > ".github/workflows/security.yml" << 'EOF'
name: Security Scan

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]
  schedule:
    - cron: '0 2 * * *'  # Daily at 2 AM

jobs:
  security:
    name: Security Analysis
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
      
    - name: Setup Python
      uses: actions/setup-python@v4
      with:
        python-version: '3.11'
        
    - name: Setup Rust
      uses: actions-rs/toolchain@v1
      with:
        toolchain: stable
        override: true
        
    - name: Install security tools
      run: |
        ./advanced-security.sh install
        
    - name: Run comprehensive audit
      run: |
        ./advanced-security.sh audit ./contracts
        
    - name: Upload security reports
      uses: actions/upload-artifact@v3
      if: always()
      with:
        name: security-reports
        path: ./security/reports/
        
    - name: Comment PR with results
      if: github.event_name == 'pull_request'
      uses: actions/github-script@v6
      with:
        script: |
          const fs = require('fs');
          const path = './security/reports/';
          
          if (fs.existsSync(path)) {
            const files = fs.readdirSync(path);
            const auditFiles = files.filter(f => f.includes('audit'));
            
            if (auditFiles.length > 0) {
              const auditContent = fs.readFileSync(path + auditFiles[0], 'utf8');
              
              github.rest.issues.createComment({
                issue_number: context.issue.number,
                owner: context.repo.owner,
                repo: context.repo.repo,
                body: `## 🛡️ Security Audit Results\n\n\`\`\`\n${auditContent.substring(0, 1000)}...\n\`\`\`\n\nFull report available in artifacts.`
              });
            }
          }
EOF

    success "GitHub Actions workflows created"
}

# Create deployment scripts
create_deployment_scripts() {
    log "Creating deployment scripts..."
    
    # Multi-network deployment script
    cat > "$DEPLOY_DIR/deploy-contracts.sh" << 'EOF'
#!/bin/bash

# Multi-network contract deployment script
# Usage: ./deploy-contracts.sh <network> [contract-path]

set -e

NETWORK="${1:-testnet}"
CONTRACT_PATH="${2:-./contracts}"
DEPLOY_LOG="./logs/devops/deploy_${NETWORK}_$(date +%Y%m%d_%H%M%S).log"

# Network configurations
case $NETWORK in
    "localnet")
        PROXY="http://localhost:7950"
        CHAIN_ID="localnet"
        PEM_FILE="./testnet/wallets/users/alice.pem"
        ;;
    "testnet")
        PROXY="https://testnet-gateway.multiversx.com"
        CHAIN_ID="T"
        PEM_FILE="./testnet.pem"
        ;;
    "mainnet")
        PROXY="https://gateway.multiversx.com"
        CHAIN_ID="1"
        PEM_FILE="./mainnet.pem"
        ;;
    *)
        echo "Unknown network: $NETWORK"
        echo "Usage: $0 {localnet|testnet|mainnet} [contract-path]"
        exit 1
        ;;
esac

echo "🚀 Deploying contracts to $NETWORK network..."
echo "Proxy: $PROXY"
echo "Chain ID: $CHAIN_ID"
echo "Contracts: $CONTRACT_PATH"
echo ""

# Create log file
mkdir -p "$(dirname "$DEPLOY_LOG")"
echo "Deployment started: $(date)" > "$DEPLOY_LOG"
echo "Network: $NETWORK" >> "$DEPLOY_LOG"
echo "" >> "$DEPLOY_LOG"

# Check PEM file
if [ ! -f "$PEM_FILE" ]; then
    echo "❌ PEM file not found: $PEM_FILE"
    exit 1
fi

# Find and deploy contracts
DEPLOYED_CONTRACTS=""

if [ -d "$CONTRACT_PATH" ]; then
    find "$CONTRACT_PATH" -name "*.wasm" | while read -r wasm_file; do
        contract_name=$(basename "$wasm_file" .wasm)
        
        echo "📦 Deploying $contract_name..."
        echo "Deploying $contract_name - $(date)" >> "$DEPLOY_LOG"
        
        # Deploy contract
        if mxpy contract deploy \
            --bytecode="$wasm_file" \
            --pem="$PEM_FILE" \
            --proxy="$PROXY" \
            --chain="$CHAIN_ID" \
            --gas-limit=60000000 \
            --send \
            --outfile="./deployments/${contract_name}_${NETWORK}.json" \
            2>&1 | tee -a "$DEPLOY_LOG"; then
            
            echo "✅ $contract_name deployed successfully"
            DEPLOYED_CONTRACTS="$DEPLOYED_CONTRACTS\n- $contract_name"
        else
            echo "❌ Failed to deploy $contract_name"
            echo "FAILED: $contract_name" >> "$DEPLOY_LOG"
        fi
        
        echo "" >> "$DEPLOY_LOG"
    done
else
    echo "❌ Contract path not found: $CONTRACT_PATH"
    exit 1
fi

echo "" >> "$DEPLOY_LOG"
echo "Deployment completed: $(date)" >> "$DEPLOY_LOG"

echo ""
echo "🎉 Deployment completed!"
echo "Log: $DEPLOY_LOG"
echo "Deployed contracts:"
echo -e "$DEPLOYED_CONTRACTS"
EOF

    chmod +x "$DEPLOY_DIR/deploy-contracts.sh"
    
    # Environment management script
    cat > "$SCRIPTS_DIR/manage-environments.sh" << 'EOF'
#!/bin/bash

# Environment management script
# Handles localnet, testnet, and mainnet configurations

set -e

ENVIRONMENT="${1:-localnet}"
ACTION="${2:-status}"

case $ENVIRONMENT in
    "localnet")
        case $ACTION in
            "start")
                echo "🚀 Starting localnet environment..."
                ./config-manager.sh apply dev
                ./start-localnet.sh
                ./monitor-dashboard.sh dashboard &
                echo "✅ Localnet environment started"
                ;;
            "stop")
                echo "🛑 Stopping localnet environment..."
                ./stop-localnet.sh
                ./monitor-dashboard.sh stop
                echo "✅ Localnet environment stopped"
                ;;
            "reset")
                echo "🔄 Resetting localnet environment..."
                ./reset-localnet.sh
                ./setup.sh
                ./start-localnet.sh
                echo "✅ Localnet environment reset"
                ;;
            "status")
                if curl -s http://localhost:7950/network/status > /dev/null; then
                    echo "✅ Localnet is running"
                else
                    echo "❌ Localnet is not running"
                fi
                ;;
        esac
        ;;
    "testnet")
        echo "🧪 Testnet operations..."
        echo "Proxy: https://testnet-gateway.multiversx.com"
        echo "Explorer: https://testnet-explorer.multiversx.com"
        ;;
    "mainnet")
        echo "🌐 Mainnet operations..."
        echo "Proxy: https://gateway.multiversx.com"
        echo "Explorer: https://explorer.multiversx.com"
        ;;
esac
EOF

    chmod +x "$SCRIPTS_DIR/manage-environments.sh"
    
    success "Deployment scripts created"
}

# Create Docker configurations
create_docker_config() {
    log "Creating Docker configurations..."
    
    # Main Dockerfile
    cat > "Dockerfile" << 'EOF'
# MultiversX Development Environment
FROM ubuntu:22.04

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    python3 \
    python3-pip \
    nodejs \
    npm \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Install mxpy
RUN pip3 install multiversx-sdk-cli

# Install MultiversX tools
RUN cargo install multiversx-sc-meta

# Setup workspace
WORKDIR /workspace
COPY . /workspace/

# Make scripts executable
RUN chmod +x *.sh

# Install dependencies
RUN ./setup.sh

# Expose ports
EXPOSE 7950 8080

# Default command
CMD ["./multiversx-localnet-manager.sh"]
EOF

    # Docker Compose for development
    cat > "docker-compose.yml" << 'EOF'
version: '3.8'

services:
  multiversx-localnet:
    build: .
    container_name: multiversx-localnet
    ports:
      - "7950:7950"  # MultiversX Proxy
      - "8080:8080"  # Monitoring Dashboard
    volumes:
      - ./contracts:/workspace/contracts
      - ./logs:/workspace/logs
      - ./backups:/workspace/backups
      - ./test-results:/workspace/test-results
    environment:
      - LOCALNET_CONFIG=dev
      - MONITORING_ENABLED=true
    restart: unless-stopped
    
  multiversx-ci:
    build:
      context: .
      dockerfile: Dockerfile.ci
    container_name: multiversx-ci
    volumes:
      - ./contracts:/workspace/contracts
      - ./test-results:/workspace/test-results
    environment:
      - LOCALNET_CONFIG=ci
      - CI=true
    profiles:
      - ci
    
  monitoring:
    image: grafana/grafana:latest
    container_name: multiversx-monitoring
    ports:
      - "3000:3000"
    volumes:
      - grafana-storage:/var/lib/grafana
      - ./devops/monitoring/grafana:/etc/grafana/provisioning
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
    profiles:
      - monitoring
    
  prometheus:
    image: prom/prometheus:latest
    container_name: multiversx-prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./devops/monitoring/prometheus.yml:/etc/prometheus/prometheus.yml
    profiles:
      - monitoring

volumes:
  grafana-storage:

networks:
  default:
    name: multiversx-network
EOF

    # CI-specific Dockerfile
    cat > "Dockerfile.ci" << 'EOF'
FROM ubuntu:22.04

# Optimized for CI/CD - minimal image
RUN apt-get update && apt-get install -y \
    curl \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Install only essential tools
RUN pip3 install multiversx-sdk-cli

WORKDIR /workspace
COPY . /workspace/

RUN chmod +x *.sh

# CI configuration
RUN ./config-manager.sh init && ./config-manager.sh apply ci

CMD ["./test-benchmark.sh", "all"]
EOF

    success "Docker configurations created"
}

# Create Infrastructure as Code templates
create_iac_templates() {
    log "Creating Infrastructure as Code templates..."
    
    mkdir -p "$INFRA_DIR/terraform"
    mkdir -p "$INFRA_DIR/ansible"
    
    # Terraform configuration for AWS
    cat > "$INFRA_DIR/terraform/main.tf" << 'EOF'
# MultiversX Infrastructure on AWS
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# VPC for MultiversX infrastructure
resource "aws_vpc" "multiversx_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = {
    Name = "MultiversX VPC"
    Project = "MultiversX"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "multiversx_igw" {
  vpc_id = aws_vpc.multiversx_vpc.id
  
  tags = {
    Name = "MultiversX IGW"
  }
}

# Public Subnet
resource "aws_subnet" "multiversx_public" {
  vpc_id                  = aws_vpc.multiversx_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true
  
  tags = {
    Name = "MultiversX Public Subnet"
  }
}

# Security Group
resource "aws_security_group" "multiversx_sg" {
  name        = "multiversx-security-group"
  description = "Security group for MultiversX infrastructure"
  vpc_id      = aws_vpc.multiversx_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 7950
    to_port     = 7950
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "MultiversX Security Group"
  }
}

# EC2 Instance for MultiversX node
resource "aws_instance" "multiversx_node" {
  count                  = var.node_count
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name              = var.key_pair_name
  vpc_security_group_ids = [aws_security_group.multiversx_sg.id]
  subnet_id             = aws_subnet.multiversx_public.id
  
  user_data = templatefile("${path.module}/user_data.sh", {
    node_index = count.index
  })
  
  tags = {
    Name = "MultiversX Node ${count.index + 1}"
    Project = "MultiversX"
  }
}

# Data sources
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}
EOF

    # Terraform variables
    cat > "$INFRA_DIR/terraform/variables.tf" << 'EOF'
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"
}

variable "node_count" {
  description = "Number of MultiversX nodes"
  type        = number
  default     = 3
}

variable "key_pair_name" {
  description = "AWS Key Pair name"
  type        = string
}
EOF

    # User data script for EC2 instances
    cat > "$INFRA_DIR/terraform/user_data.sh" << 'EOF'
#!/bin/bash

# Update system
apt-get update
apt-get install -y curl wget git python3 python3-pip docker.io

# Install MultiversX development environment
cd /home/ubuntu
git clone https://github.com/Gzeu/multiversx-wsl-localnet-setup.git
cd multiversx-wsl-localnet-setup

# Setup environment
chmod +x *.sh
./setup.sh

# Start localnet with production config
./config-manager.sh init
./config-manager.sh apply production
./start-localnet.sh

# Enable monitoring
./monitor-dashboard.sh start

# Setup systemd service
cat > /etc/systemd/system/multiversx-localnet.service << EOL
[Unit]
Description=MultiversX Localnet
After=network.target

[Service]
Type=forking
User=ubuntu
WorkingDirectory=/home/ubuntu/multiversx-wsl-localnet-setup
ExecStart=/home/ubuntu/multiversx-wsl-localnet-setup/start-localnet.sh
ExecStop=/home/ubuntu/multiversx-wsl-localnet-setup/stop-localnet.sh
Restart=always

[Install]
WantedBy=multi-user.target
EOL

systemctl enable multiversx-localnet
systemctl start multiversx-localnet
EOF

    success "Infrastructure as Code templates created"
}

# Create monitoring configuration
create_monitoring_config() {
    log "Creating monitoring configurations..."
    
    mkdir -p "$DEVOPS_DIR/monitoring"
    
    # Prometheus configuration
    cat > "$DEVOPS_DIR/monitoring/prometheus.yml" << 'EOF'
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'multiversx-localnet'
    static_configs:
      - targets: ['localhost:7950']
    scrape_interval: 5s
    metrics_path: '/network/status'
    
  - job_name: 'multiversx-dashboard'
    static_configs:
      - targets: ['localhost:8080']
    scrape_interval: 10s
    
  - job_name: 'node-exporter'
    static_configs:
      - targets: ['localhost:9100']
EOF

    # Grafana dashboard configuration
    mkdir -p "$DEVOPS_DIR/monitoring/grafana/dashboards"
    mkdir -p "$DEVOPS_DIR/monitoring/grafana/datasources"
    
    cat > "$DEVOPS_DIR/monitoring/grafana/datasources/prometheus.yml" << 'EOF'
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
EOF

    success "Monitoring configurations created"
}

# Deploy to specific network
deploy_to_network() {
    local network="$1"
    
    if [ -z "$network" ]; then
        error "Network parameter required"
        echo "Usage: $0 deploy <network>"
        echo "Networks: localnet, testnet, mainnet"
        return 1
    fi
    
    deploy "Starting deployment to $network..."
    
    # Check if deployment script exists
    if [ ! -f "$DEPLOY_DIR/deploy-contracts.sh" ]; then
        error "Deployment script not found. Run 'init' first."
        return 1
    fi
    
    # Execute deployment
    "$DEPLOY_DIR/deploy-contracts.sh" "$network"
    
    deploy "Deployment to $network completed!"
}

# Setup complete DevOps environment
setup_devops_complete() {
    print_devops_banner
    
    devops "Setting up complete DevOps automation..."
    
    init_devops_environment
    create_github_workflows
    create_deployment_scripts
    create_docker_config
    create_iac_templates
    create_monitoring_config
    
    # Update Makefile to include DevOps commands
    if [ -f "Makefile" ]; then
        cat >> "Makefile" << 'EOF'

# DevOps Commands
devops-setup:
	@./devops-automation.sh init

docker-build:
	@docker build -t multiversx-localnet .

docker-run:
	@docker-compose up -d multiversx-localnet

docker-ci:
	@docker-compose --profile ci up --build multiversx-ci

monitoring-up:
	@docker-compose --profile monitoring up -d

infra-plan:
	@cd devops/infrastructure/terraform && terraform plan

infra-apply:
	@cd devops/infrastructure/terraform && terraform apply

deploy-testnet:
	@./devops-automation.sh deploy testnet

deploy-mainnet:
	@./devops-automation.sh deploy mainnet
EOF
    fi
    
    success "Complete DevOps environment setup completed!"
    
    echo ""
    echo -e "${CYAN}🎉 DevOps Automation Suite Ready!${NC}"
    echo ""
    echo "Available operations:"
    echo "  - CI/CD pipelines (GitHub Actions)"
    echo "  - Multi-network deployment"
    echo "  - Infrastructure as Code (Terraform)"
    echo "  - Docker containerization"
    echo "  - Monitoring and observability"
    echo ""
    echo "Quick start:"
    echo "  make docker-build && make docker-run"
    echo "  make deploy-testnet"
    echo "  make monitoring-up"
}

# Main CLI interface
case "${1:-help}" in
    "init")
        setup_devops_complete
        ;;
    "deploy")
        deploy_to_network "$2"
        ;;
    "docker-build")
        devops "Building Docker image..."
        docker build -t multiversx-localnet .
        ;;
    "docker-run")
        devops "Starting Docker containers..."
        docker-compose up -d
        ;;
    "monitoring")
        devops "Starting monitoring stack..."
        docker-compose --profile monitoring up -d
        ;;
    "infra-plan")
        if [ -d "$INFRA_DIR/terraform" ]; then
            cd "$INFRA_DIR/terraform"
            terraform plan
        else
            error "Terraform templates not found. Run 'init' first."
        fi
        ;;
    "infra-apply")
        if [ -d "$INFRA_DIR/terraform" ]; then
            cd "$INFRA_DIR/terraform"
            terraform apply
        else
            error "Terraform templates not found. Run 'init' first."
        fi
        ;;
    "status")
        echo -e "${CYAN}DevOps Status:${NC}"
        echo ""
        
        if [ -d "$DEVOPS_DIR" ]; then
            echo "✅ DevOps environment initialized"
        else
            echo "❌ DevOps environment not initialized"
        fi
        
        if [ -f ".github/workflows/multiversx-ci-cd.yml" ]; then
            echo "✅ GitHub Actions workflows configured"
        else
            echo "❌ GitHub Actions workflows not configured"
        fi
        
        if [ -f "docker-compose.yml" ]; then
            echo "✅ Docker configuration available"
        else
            echo "❌ Docker configuration not available"
        fi
        
        if command -v terraform &> /dev/null; then
            echo "✅ Terraform available"
        else
            echo "❌ Terraform not installed"
        fi
        ;;
    "help")
        echo -e "${PURPLE}$GEAR MultiversX DevOps Automation Suite${NC}"
        echo ""
        echo "Usage: $0 <command> [options]"
        echo ""
        echo "Commands:"
        echo "  init                 Setup complete DevOps environment"
        echo "  deploy <network>     Deploy contracts to network"
        echo "  docker-build         Build Docker image"
        echo "  docker-run           Start Docker containers"
        echo "  monitoring           Start monitoring stack"
        echo "  infra-plan           Plan infrastructure changes"
        echo "  infra-apply          Apply infrastructure changes"
        echo "  status               Show DevOps status"
        echo "  help                 Show this help message"
        echo ""
        echo "Networks: localnet, testnet, mainnet"
        echo ""
        echo "Examples:"
        echo "  $0 init                      # Setup complete DevOps"
        echo "  $0 deploy testnet            # Deploy to testnet"
        echo "  $0 docker-build && $0 docker-run  # Docker setup"
        echo ""
        ;;
    *)
        error "Unknown command: $1"
        echo "Use '$0 help' for usage information"
        exit 1
        ;;
esac