# MultiversX Enterprise Localnet Development Suite Makefile
# Author: George Pricop (@Gzeu)
# Quick commands for common operations - Enhanced with Enterprise Features

.PHONY: help setup start stop reset dashboard test backup config clean install deps ai security devops monitoring sdk compliance mobile

# Default target
help:
	@echo ""
	@echo "🚀 MultiversX Enterprise Localnet AI-Powered Development Suite v3.0"
	@echo "====================================================================="
	@echo ""
	@echo "🚀 Quick Commands:"
	@echo "  make setup       - Initial setup and dependencies"
	@echo "  make start       - Start localnet"
	@echo "  make stop        - Stop localnet"
	@echo "  make reset       - Reset localnet (clean state)"
	@echo "  make dashboard   - Launch monitoring dashboard"
	@echo "  make test        - Run test suite"
	@echo ""
	@echo "🏢 Enterprise Features:"
	@echo "  make enterprise-setup      - Complete enterprise stack"
	@echo "  make monitoring-start      - Start Prometheus + Grafana"
	@echo "  make chain-simulator       - Launch blockchain simulator"
	@echo "  make sdk-update            - Update all SDKs to latest"
	@echo "  make compliance-audit      - Run MiCA + GDPR compliance"
	@echo "  make mobile-setup          - Setup mobile development"
	@echo ""
	@echo "🤖 AI-Powered Tools:"
	@echo "  make ai-install  - Install AI assistant (Gemini CLI + FastMCP)"
	@echo "  make ai-chat     - Start AI chat session"
	@echo "  make ai-review   - AI code review"
	@echo "  make ai-generate - AI contract generation"
	@echo ""
	@echo "🛡️ Security & Compliance:"
	@echo "  make security-install - Install security tools"
	@echo "  make security-scan    - Quick security scan"
	@echo "  make security-audit   - Comprehensive audit"
	@echo "  make mica-check       - MiCA compliance check"
	@echo "  make gdpr-check       - GDPR compliance check"
	@echo ""
	@echo "⚙️ DevOps & Deployment:"
	@echo "  make devops-setup     - Setup CI/CD + Docker + IaC"
	@echo "  make docker-build     - Build Docker image"
	@echo "  make docker-run       - Start Docker containers"
	@echo "  make deploy-testnet   - Deploy to testnet"
	@echo "  make deploy-mainnet   - Deploy to mainnet"
	@echo ""
	@echo "📱 Mobile Development:"
	@echo "  make mobile-setup       - Setup Flutter/React Native"
	@echo "  make mobile-flutter     - Create Flutter dApp"
	@echo "  make mobile-rn          - Create React Native dApp"
	@echo "  make mobile-doctor      - Check mobile dev environment"
	@echo ""
	@echo "📊 Advanced Workflows:"
	@echo "  make full-enterprise    - Complete enterprise initialization"
	@echo "  make dev-cycle         - Full dev cycle (reset + setup + test)"
	@echo "  make production-ready  - Production validation pipeline"
	@echo "  make menu              - Launch interactive menu"
	@echo ""

# System setup and dependencies
install:
	@echo "📦 Installing system dependencies..."
	@sudo apt update
	@sudo apt install -y python3 python3-pip curl wget git jq bc nodejs npm build-essential docker.io docker-compose
	@pip3 install --user multiversx-sdk-cli
	@echo "✅ Dependencies installed"

deps: install

setup: deps
	@echo "⚙️ Setting up MultiversX localnet..."
	@chmod +x *.sh scripts/*.sh
	@./setup.sh
	@echo "✅ Setup completed"

# Enterprise setup - NEW
enterprise-setup: setup
	@echo "🏢 Setting up enterprise environment..."
	@chmod +x scripts/*.sh
	@./scripts/enterprise-monitoring.sh setup
	@./scripts/sdk-manager-2025.sh install
	@./scripts/chain-simulator.sh setup
	@./scripts/compliance-suite.sh setup
	@echo "✅ Enterprise setup completed!"
	@echo "  - Monitoring: http://localhost:3000 (Grafana)"
	@echo "  - Prometheus: http://localhost:9090"
	@echo "  - Chain Simulator: Ready"
	@echo "  - Compliance Framework: Initialized"

full-enterprise: enterprise-setup ai-install security-install mobile-setup
	@echo "🎉 Complete enterprise suite ready!"

# Core operations
start:
	@echo "🚀 Starting localnet..."
	@./start-localnet.sh

stop:
	@echo "🛑 Stopping localnet..."
	@./stop-localnet.sh

restart: stop start
	@echo "🔄 Localnet restarted"

reset:
	@echo "🔄 Resetting localnet..."
	@./reset-localnet.sh

status:
	@./multiversx-localnet-manager.sh --cli status

# Enterprise Monitoring - NEW
monitoring-start:
	@echo "📊 Starting enterprise monitoring stack..."
	@./scripts/enterprise-monitoring.sh start

monitoring-stop:
	@echo "📊 Stopping monitoring stack..."
	@./scripts/enterprise-monitoring.sh stop

monitoring-dashboard:
	@echo "📊 Opening monitoring dashboard..."
	@./scripts/enterprise-monitoring.sh dashboard

monitoring-status:
	@echo "📊 Monitoring status:"
	@./scripts/enterprise-monitoring.sh status

# SDK Management - NEW
sdk-update:
	@echo "🔄 Updating all SDKs to latest versions..."
	@./scripts/sdk-manager-2025.sh update

sdk-status:
	@echo "📋 Current SDK versions:"
	@./scripts/sdk-manager-2025.sh status

sdk-doctor:
	@echo "🩺 SDK diagnostics:"
	@./scripts/sdk-manager-2025.sh doctor

sdk-install-rust:
	@./scripts/sdk-manager-2025.sh install-rust

sdk-install-node:
	@./scripts/sdk-manager-2025.sh install-node

sdk-install-python:
	@./scripts/sdk-manager-2025.sh install-python

# Chain Simulator - NEW
chain-simulator:
	@echo "⛓️ Starting chain simulator..."
	@./scripts/chain-simulator.sh start

sim-stop:
	@echo "⛓️ Stopping chain simulator..."
	@./scripts/chain-simulator.sh stop

sim-status:
	@echo "⛓️ Chain simulator status:"
	@./scripts/chain-simulator.sh status

sim-reset:
	@echo "⛓️ Resetting chain simulator..."
	@./scripts/chain-simulator.sh reset

sim-scenarios:
	@echo "📋 Available test scenarios:"
	@./scripts/chain-simulator.sh list-scenarios

sim-load-test:
	@echo "💪 Running load test..."
	@./scripts/chain-simulator.sh load-test

sim-stress-test:
	@echo "🔥 Running stress test..."
	@./scripts/chain-simulator.sh stress-test

# Compliance Suite - NEW
compliance-audit:
	@echo "📋 Running comprehensive compliance audit..."
	@./scripts/compliance-suite.sh audit

mica-check:
	@echo "🏛️ Checking MiCA compliance..."
	@./scripts/compliance-suite.sh mica-check

gdpr-check:
	@echo "🔐 Checking GDPR compliance..."
	@./scripts/compliance-suite.sh gdpr-check

compliance-setup:
	@echo "📋 Setting up compliance framework..."
	@./scripts/compliance-suite.sh setup

compliance-report:
	@echo "📄 Generating compliance report..."
	@./scripts/compliance-suite.sh generate-report --format pdf

# Mobile Development - NEW
mobile-setup:
	@echo "📱 Setting up mobile development environment..."
	@./scripts/mobile-development.sh setup

mobile-flutter:
	@echo "📱 Installing Flutter SDK..."
	@./scripts/mobile-development.sh install-flutter

mobile-rn:
	@echo "📱 Installing React Native CLI..."
	@./scripts/mobile-development.sh install-rn

mobile-doctor:
	@echo "🩺 Mobile development diagnostics..."
	@./scripts/mobile-development.sh doctor

mobile-create-flutter:
	@read -p "Project name: " name; \
	./scripts/mobile-development.sh create-flutter --project "$$name"

mobile-create-rn:
	@read -p "Project name: " name; \
	./scripts/mobile-development.sh create-react-native --project "$$name"

mobile-list:
	@echo "📱 Mobile projects:"
	@./scripts/mobile-development.sh list-projects

# Development environments
dev: setup
	@echo "🛠️ Setting up development environment..."
	@./config-manager.sh init
	@./config-manager.sh apply dev
	@./start-localnet.sh
	@echo "✅ Development environment ready (2s rounds, fast iteration)"

test-env: setup
	@echo "🧪 Setting up testing environment..."
	@./config-manager.sh init
	@./config-manager.sh apply test
	@./start-localnet.sh
	@echo "✅ Testing environment ready (6s rounds, testnet-like)"

ci: setup
	@echo "🤖 Setting up CI/CD environment..."
	@./config-manager.sh init
	@./config-manager.sh apply ci
	@./start-localnet.sh
	@echo "✅ CI/CD environment ready (1s rounds, minimal resources)"

prod: setup
	@echo "🏭 Setting up production-like environment..."
	@./config-manager.sh init
	@./config-manager.sh apply production
	@./start-localnet.sh
	@echo "✅ Production environment ready (mainnet-like settings)"

# AI-Powered Tools
ai-install:
	@echo "🤖 Installing AI assistant tools..."
	@./ai-assistant.sh install

ai-chat:
	@echo "🧠 Starting AI chat session..."
	@./ai-assistant.sh chat

ai-review:
	@echo "👁️ Starting AI code review..."
	@./ai-assistant.sh code-review

ai-generate:
	@echo "⚡ Starting AI code generation..."
	@read -p "Contract name: " name; \
	read -p "Description: " desc; \
	./ai-assistant.sh generate "$$name" "$$desc"

ai-test:
	@echo "🧪 AI-powered testing..."
	@./ai-assistant.sh test

ai-deploy:
	@echo "🚀 AI deployment assistance..."
	@./ai-assistant.sh deploy

# Security Tools
security-install:
	@echo "🛡️ Installing security tools..."
	@./advanced-security.sh install

security-scan:
	@echo "🔍 Running security scan..."
	@./advanced-security.sh quick

security-audit:
	@echo "🔒 Running comprehensive security audit..."
	@./advanced-security.sh audit

security-enhanced:
	@echo "🛡️ Running enhanced security scan with compliance..."
	@./scripts/compliance-suite.sh security-audit

gas-analysis:
	@echo "⚡ Analyzing gas usage..."
	@./advanced-security.sh gas ./contracts

security-mythril:
	@echo "🔍 Running Mythril analysis..."
	@read -p "Contract file: " file; \
	./advanced-security.sh mythril "$$file"

security-slither:
	@echo "🐍 Running Slither analysis..."
	@read -p "Contract file: " file; \
	./advanced-security.sh slither "$$file"

# DevOps & Deployment
devops-setup:
	@echo "⚙️ Setting up DevOps automation..."
	@./devops-automation.sh init

docker-build:
	@echo "🐳 Building Docker image..."
	@docker build -t multiversx-localnet .

docker-run:
	@echo "🏃 Starting Docker containers..."
	@docker-compose up -d multiversx-localnet

docker-ci:
	@echo "🤖 Running CI Docker container..."
	@docker-compose --profile ci up --build multiversx-ci

infra-plan:
	@echo "📋 Planning infrastructure changes..."
	@cd devops/infrastructure/terraform && terraform plan

infra-apply:
	@echo "🏗️ Applying infrastructure changes..."
	@cd devops/infrastructure/terraform && terraform apply

deploy-localnet:
	@echo "🏠 Deploying to localnet..."
	@./devops-automation.sh deploy localnet

deploy-testnet:
	@echo "🧪 Deploying to testnet..."
	@./devops-automation.sh deploy testnet

deploy-mainnet:
	@echo "🌐 Deploying to mainnet..."
	@./devops-automation.sh deploy mainnet

# Monitoring and testing
dashboard:
	@echo "📊 Launching monitoring dashboard..."
	@./monitor-dashboard.sh dashboard
	@echo "✅ Dashboard available at http://localhost:8080"

monitor:
	@echo "👁️ Starting monitoring..."
	@./monitor-dashboard.sh start

test:
	@echo "🧪 Running test suite..."
	@./test-benchmark.sh all

test-quick:
	@echo "⚡ Running quick connectivity test..."
	@./test-benchmark.sh connectivity

test-perf:
	@echo "📈 Running performance benchmark..."
	@./test-benchmark.sh throughput

test-stress:
	@echo "💪 Running stress test..."
	@./test-benchmark.sh stress

test-contract:
	@echo "📝 Testing smart contract deployment..."
	@./test-benchmark.sh contract

# Configuration management
config:
	@./config-manager.sh list

config-init:
	@./config-manager.sh init

config-current:
	@./config-manager.sh current

config-dev:
	@./config-manager.sh apply dev

config-test:
	@./config-manager.sh apply test

config-prod:
	@./config-manager.sh apply production

config-ci:
	@./config-manager.sh apply ci

# Backup operations
backup:
	@echo "💾 Creating backup..."
	@./backup-recovery.sh create

backup-incremental:
	@echo "📦 Creating incremental backup..."
	@./backup-recovery.sh incremental

backup-list:
	@./backup-recovery.sh list

backup-auto:
	@echo "🔄 Starting automatic backups (24h interval)..."
	@./backup-recovery.sh schedule 24

restore:
	@echo "🔄 Available backups:"
	@./backup-recovery.sh list
	@read -p "Backup name to restore: " name; \
	./backup-recovery.sh restore "$$name"

# Enterprise workflows - NEW
enterprise-dev-cycle: enterprise-setup ai-review security-enhanced compliance-audit
	@echo "🏢 Enterprise development cycle completed!"

enterprise-deployment: compliance-audit security-audit deploy-testnet
	@echo "🚀 Enterprise deployment pipeline completed!"

production-ready: security-audit compliance-audit performance-test deploy-mainnet
	@echo "✅ Production-ready validation completed!"

enterprise-monitoring: monitoring-start chain-simulator
	@echo "📊 Enterprise monitoring stack launched!"

# Performance and load testing - Enhanced
performance-test: prod test-perf test-stress gas-analysis sim-load-test
	@echo "📊 Comprehensive performance testing completed"

load-test-suite: sim-load-test sim-stress-test test-stress
	@echo "💪 Complete load testing suite finished"

benchmark-enterprise: performance-test compliance-audit
	@echo "📈 Enterprise benchmarking completed"

# Utilities
logs:
	@echo "📜 Showing recent logs..."
	@tail -n 50 logs/*.log 2>/dev/null || echo "No logs found"

logs-follow:
	@echo "📜 Following logs (Ctrl+C to exit)..."
	@tail -f logs/*.log

logs-monitoring:
	@echo "📊 Showing monitoring logs..."
	@tail -n 50 monitoring/logs/*.log 2>/dev/null || echo "No monitoring logs found"

logs-compliance:
	@echo "📋 Showing compliance logs..."
	@tail -n 50 compliance/logs/*.log 2>/dev/null || echo "No compliance logs found"

logs-security:
	@echo "🔒 Showing security logs..."
	@tail -n 50 security/reports/*.txt security/reports/*.json 2>/dev/null || echo "No security logs found"

logs-devops:
	@echo "⚙️ Showing DevOps logs..."
	@tail -n 50 logs/devops/*.log 2>/dev/null || echo "No DevOps logs found"

menu:
	@./multiversx-localnet-manager.sh

# Fund wallet (requires WALLET_ADDRESS)
fund:
	@if [ -z "$(WALLET_ADDRESS)" ]; then \
		echo "Usage: make fund WALLET_ADDRESS=erd1..."; \
	else \
		echo "💰 Funding wallet $(WALLET_ADDRESS)..."; \
		./faucet.sh $(WALLET_ADDRESS); \
	fi

# Cleanup operations
clean:
	@echo "🧹 Cleaning up temporary files..."
	@rm -rf ./logs/*.log ./data/metrics/*.json ./test-results/*.json 2>/dev/null || true
	@echo "✅ Temporary files cleaned"

clean-enterprise:
	@echo "🧹 Cleaning enterprise data..."
	@./scripts/enterprise-monitoring.sh cleanup || true
	@./scripts/chain-simulator.sh reset || true
	@rm -rf monitoring/data simulator/data compliance/reports 2>/dev/null || true
	@echo "✅ Enterprise data cleaned"

clean-all: clean-enterprise
	@echo "⚠️ WARNING: This will remove ALL data including backups!"
	@read -p "Type 'DELETE' to confirm: " confirm; \
	if [ "$$confirm" = "DELETE" ]; then \
		./multiversx-localnet-manager.sh --cli stop; \
		./scripts/enterprise-monitoring.sh stop || true; \
		./scripts/chain-simulator.sh stop || true; \
		rm -rf logs backups test-results data configs dashboard security devops ai-config; \
		rm -rf monitoring simulator compliance mobile; \
		rm -rf ~/MultiversX/testnet; \
		echo "✅ All data removed"; \
	else \
		echo "❌ Cancelled"; \
	fi

# Development workflow shortcuts
quick-start: dev dashboard
	@echo "⚡ Quick start completed!"
	@echo "  - Localnet: Running (dev mode)"
	@echo "  - Dashboard: http://localhost:8080"
	@echo "  - API: http://localhost:7950"

enterprise-quick-start: dev enterprise-monitoring
	@echo "🏢 Enterprise quick start completed!"
	@echo "  - Localnet: Running (dev mode)"
	@echo "  - Grafana: http://localhost:3000 (admin/admin)"
	@echo "  - Prometheus: http://localhost:9090"
	@echo "  - API: http://localhost:7950"

full-setup: setup config-init backup-auto ai-install security-install devops-setup
	@echo "🎉 Full setup completed!"
	@echo "  - All templates created"
	@echo "  - AI assistant ready"
	@echo "  - Security tools installed"
	@echo "  - DevOps automation configured"
	@echo "  - Automatic backups enabled"

# CI/CD helpers
ci-test: ci test security-scan compliance-audit
	@echo "✅ Enhanced CI/CD test pipeline completed"

ci-enterprise: ci test-quick security-enhanced mica-check
	@echo "🏢 Enterprise CI/CD pipeline completed"

ci-quick: ci test-quick
	@echo "⚡ CI/CD quick test completed"

ci-security: ci security-scan
	@echo "🛡️ CI/CD security pipeline completed"

# Advanced workflow combinations
full-development-cycle: full-enterprise ai-review security-enhanced compliance-audit
	@echo "🎯 Complete enterprise development cycle finished!"

pre-mainnet-validation: prod security-audit compliance-audit performance-test mica-check gdpr-check
	@echo "🔒 Pre-mainnet validation completed with full compliance!"

automated-pipeline: ci-enterprise ai-review deploy-testnet
	@echo "🤖 Automated enterprise development pipeline completed!"

# Info and status targets
info:
	@echo "📊 MultiversX Enterprise Localnet Status:"
	@echo ""
	@echo "Network Status:"
	@./multiversx-localnet-manager.sh --cli status || echo "  Not running"
	@echo ""
	@echo "Enterprise Services:"
	@./scripts/enterprise-monitoring.sh status 2>/dev/null || echo "  Monitoring: Not started"
	@./scripts/chain-simulator.sh status 2>/dev/null || echo "  Simulator: Not started"
	@echo ""
	@echo "Configuration:"
	@./config-manager.sh current 2>/dev/null || echo "  No active configuration"
	@echo ""
	@echo "SDK Status:"
	@./scripts/sdk-manager-2025.sh status 2>/dev/null || echo "  SDKs: Not checked"
	@echo ""
	@echo "AI Tools:"
	@command -v gemini >/dev/null && echo "  ✅ Gemini CLI installed" || echo "  ❌ Gemini CLI not installed"
	@python3 -c "import fastmcp" 2>/dev/null && echo "  ✅ FastMCP installed" || echo "  ❌ FastMCP not installed"
	@echo ""
	@echo "Security Tools:"
	@command -v myth >/dev/null && echo "  ✅ Mythril installed" || echo "  ❌ Mythril not installed"
	@command -v slither >/dev/null && echo "  ✅ Slither installed" || echo "  ❌ Slither not installed"
	@command -v aderyn >/dev/null && echo "  ✅ Aderyn installed" || echo "  ❌ Aderyn not installed"
	@echo ""
	@echo "Mobile Development:"
	@command -v flutter >/dev/null && echo "  ✅ Flutter installed" || echo "  ❌ Flutter not installed"
	@command -v react-native >/dev/null && echo "  ✅ React Native installed" || echo "  ❌ React Native not installed"
	@echo ""
	@echo "DevOps:"
	@[ -f ".github/workflows/ci.yml" ] && echo "  ✅ GitHub Actions configured" || echo "  ❌ GitHub Actions not configured"
	@[ -f "docker-compose.yml" ] && echo "  ✅ Docker configured" || echo "  ❌ Docker not configured"
	@[ -d "devops/infrastructure" ] && echo "  ✅ Infrastructure as Code ready" || echo "  ❌ IaC not configured"
	@echo ""
	@echo "Compliance:"
	@[ -d "compliance" ] && echo "  ✅ Compliance framework initialized" || echo "  ❌ Compliance not setup"
	@echo ""
	@echo "Disk Usage:"
	@du -sh ~/MultiversX/testnet 2>/dev/null | sed 's/^/  Localnet: /' || echo "  Localnet: Not initialized"
	@du -sh backups 2>/dev/null | sed 's/^/  Backups: /' || echo "  Backups: None"
	@du -sh logs 2>/dev/null | sed 's/^/  Logs: /' || echo "  Logs: None"
	@du -sh monitoring/data 2>/dev/null | sed 's/^/  Monitoring: /' || echo "  Monitoring: No data"

version:
	@echo "🚀 MultiversX Enterprise Localnet AI-Powered Development Suite v3.0.0"
	@echo "👨‍💻 Author: George Pricop (@Gzeu)"
	@echo "🐙 GitHub: https://github.com/Gzeu/multiversx-wsl-localnet-setup"
	@echo "🌟 Features: AI Assistant, Enterprise Monitoring, Compliance, Mobile Dev"
	@echo "🏢 New: Prometheus + Grafana, Chain Simulator, MiCA/GDPR Compliance"

# Help for specific areas - Enhanced
help-enterprise:
	@echo "🏢 Enterprise Commands:"
	@echo "  make enterprise-setup       - Complete enterprise stack initialization"
	@echo "  make monitoring-start       - Start Prometheus + Grafana monitoring"
	@echo "  make chain-simulator        - Launch advanced blockchain simulator"
	@echo "  make sdk-update            - Update all MultiversX SDKs"
	@echo "  make compliance-audit      - Run MiCA + GDPR compliance audit"
	@echo "  make mobile-setup          - Setup Flutter/React Native development"
	@echo "  make enterprise-dev-cycle  - Full enterprise development workflow"

help-monitoring:
	@echo "📊 Monitoring Commands:"
	@echo "  make monitoring-start      - Start Prometheus + Grafana stack"
	@echo "  make monitoring-stop       - Stop monitoring services"
	@echo "  make monitoring-dashboard  - Open Grafana dashboard"
	@echo "  make monitoring-status     - Check monitoring services status"

help-compliance:
	@echo "📋 Compliance Commands:"
	@echo "  make compliance-setup      - Initialize compliance framework"
	@echo "  make compliance-audit      - Full compliance audit"
	@echo "  make mica-check           - MiCA regulation compliance"
	@echo "  make gdpr-check           - GDPR privacy compliance"
	@echo "  make compliance-report    - Generate PDF compliance report"

help-mobile:
	@echo "📱 Mobile Development Commands:"
	@echo "  make mobile-setup         - Setup mobile development environment"
	@echo "  make mobile-flutter       - Install Flutter SDK"
	@echo "  make mobile-rn           - Install React Native CLI"
	@echo "  make mobile-doctor       - Check mobile development setup"
	@echo "  make mobile-create-flutter - Create new Flutter dApp"
	@echo "  make mobile-create-rn     - Create new React Native dApp"

help-ai:
	@echo "🤖 AI Assistant Commands:"
	@echo "  make ai-install      - Install AI tools (Gemini CLI + FastMCP)"
	@echo "  make ai-chat         - Interactive AI chat session"
	@echo "  make ai-review       - AI-powered code review"
	@echo "  make ai-generate     - Generate smart contracts with AI"
	@echo "  make ai-test         - AI testing assistance"
	@echo "  make ai-deploy       - AI deployment guidance"

help-security:
	@echo "🛡️ Security Commands:"
	@echo "  make security-install  - Install security analysis tools"
	@echo "  make security-scan     - Quick vulnerability scan"
	@echo "  make security-audit    - Comprehensive security audit"
	@echo "  make security-enhanced - Enhanced security with compliance"
	@echo "  make gas-analysis      - Gas usage optimization analysis"
	@echo "  make security-mythril  - Mythril static analysis"
	@echo "  make security-slither  - Slither vulnerability detection"

help-devops:
	@echo "⚙️ DevOps Commands:"
	@echo "  make devops-setup      - Complete DevOps automation setup"
	@echo "  make docker-build      - Build Docker development image"
	@echo "  make docker-run        - Start Docker containers"
	@echo "  make deploy-testnet    - Deploy contracts to testnet"
	@echo "  make deploy-mainnet    - Deploy contracts to mainnet"

help-workflows:
	@echo "🔄 Enterprise Workflows:"
	@echo "  make full-enterprise         - Complete enterprise initialization"
	@echo "  make enterprise-dev-cycle    - Full enterprise development cycle"
	@echo "  make pre-mainnet-validation  - Complete pre-deployment validation"
	@echo "  make automated-pipeline      - Full automated CI/CD pipeline"
	@echo "  make production-ready        - Production readiness validation"

help-all: help help-enterprise help-monitoring help-compliance help-mobile help-ai help-security help-devops help-workflows

# Check if running in WSL
check-wsl:
	@if grep -qi microsoft /proc/version 2>/dev/null; then \
		echo "✅ Running in WSL environment"; \
	else \
		echo "⚠️ Not running in WSL (some features may not work optimally)"; \
	fi

# Project statistics - Enhanced
stats:
	@echo "📊 Project Statistics:"
	@echo "  Scripts: $$(ls -1 *.sh scripts/*.sh 2>/dev/null | wc -l)"
	@echo "  Total lines of code: $$(find . -name '*.sh' -o -name '*.py' -o -name '*.yml' -o -name '*.yaml' | xargs wc -l 2>/dev/null | tail -1 | awk '{print $$1}' || echo '0')"
	@echo "  Contracts: $$(find ./contracts -name '*.rs' 2>/dev/null | wc -l)"
	@echo "  Test files: $$(find ./test-results -name '*.json' 2>/dev/null | wc -l)"
	@echo "  Backups: $$(ls -1 ./backups/*.tar.gz 2>/dev/null | wc -l)"
	@echo "  Security reports: $$(find ./security/reports -name '*' -type f 2>/dev/null | wc -l)"
	@echo "  Compliance reports: $$(find ./compliance/reports -name '*' -type f 2>/dev/null | wc -l)"
	@echo "  Mobile projects: $$(find ./mobile/projects -maxdepth 1 -type d 2>/dev/null | wc -l)"

# Interactive setup wizard - Enhanced
wizard:
	@echo "🧙‍♂️ MultiversX Enterprise Setup Wizard"
	@echo "This will guide you through the complete enterprise setup process."
	@echo ""
	@read -p "Install AI tools? [Y/n]: " ai; \
	read -p "Install security tools? [Y/n]: " security; \
	read -p "Setup DevOps automation? [Y/n]: " devops; \
	read -p "Setup enterprise monitoring? [Y/n]: " monitoring; \
	read -p "Initialize compliance framework? [Y/n]: " compliance; \
	read -p "Setup mobile development? [Y/n]: " mobile; \
	read -p "Create development environment? [Y/n]: " dev; \
	echo "" && echo "🚀 Starting enterprise wizard..."; \
	[ "$$ai" != "n" ] && make ai-install; \
	[ "$$security" != "n" ] && make security-install; \
	[ "$$devops" != "n" ] && make devops-setup; \
	[ "$$monitoring" != "n" ] && make monitoring-start; \
	[ "$$compliance" != "n" ] && make compliance-setup; \
	[ "$$mobile" != "n" ] && make mobile-setup; \
	[ "$$dev" != "n" ] && make dev; \
	echo "🎉 Enterprise wizard completed!"

# Emergency procedures - Enhanced
emergency-stop:
	@echo "🚨 Emergency stop - killing all processes..."
	@pkill -f mxpy || true
	@pkill -f python3 || true
	@./scripts/enterprise-monitoring.sh stop || true
	@./scripts/chain-simulator.sh stop || true
	@docker-compose down || true
	@echo "⛑️ Emergency stop completed"

emergency-backup:
	@echo "🚨 Emergency backup..."
	@./backup-recovery.sh create
	@./scripts/enterprise-monitoring.sh backup || true
	@echo "💾 Emergency backup completed"

rescue-mode: emergency-stop emergency-backup reset setup
	@echo "🛟 Rescue mode completed - system restored to clean state"

# Validation targets
validate-config:
	@echo "✅ Validating configuration..."
	@./config-manager.sh validate || echo "⚠️ Configuration issues found"

validate-enterprise:
	@echo "🏢 Validating enterprise setup..."
	@[ -d "monitoring" ] && echo "  ✅ Monitoring configured" || echo "  ❌ Monitoring not setup"
	@[ -d "compliance" ] && echo "  ✅ Compliance framework ready" || echo "  ❌ Compliance not initialized"
	@[ -d "mobile" ] && echo "  ✅ Mobile development ready" || echo "  ❌ Mobile development not setup"
	@[ -f "scripts/enterprise-monitoring.sh" ] && echo "  ✅ Enterprise scripts available" || echo "  ❌ Enterprise scripts missing"