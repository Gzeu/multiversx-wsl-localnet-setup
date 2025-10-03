# MultiversX Localnet Development Suite Makefile
# Author: George Pricop (@Gzeu)
# Quick commands for common operations

.PHONY: help setup start stop reset dashboard test backup config clean install deps ai security devops

# Default target
help:
	@echo ""
	@echo "🚀 MultiversX Localnet AI-Powered Development Suite v2.0"
	@echo "================================================================"
	@echo ""
	@echo "🚀 Quick Commands:"
	@echo "  make setup       - Initial setup and dependencies"
	@echo "  make start       - Start localnet"
	@echo "  make stop        - Stop localnet"
	@echo "  make reset       - Reset localnet (clean state)"
	@echo "  make dashboard   - Launch monitoring dashboard"
	@echo "  make test        - Run test suite"
	@echo ""
	@echo "🤖 AI-Powered Tools:"
	@echo "  make ai-install  - Install AI assistant (Gemini CLI + FastMCP)"
	@echo "  make ai-chat     - Start AI chat session"
	@echo "  make ai-review   - AI code review"
	@echo "  make ai-generate - AI contract generation"
	@echo ""
	@echo "🛡️ Security Tools:"
	@echo "  make security-install - Install security tools"
	@echo "  make security-scan    - Quick security scan"
	@echo "  make security-audit   - Comprehensive audit"
	@echo "  make gas-analysis     - Gas usage analysis"
	@echo ""
	@echo "⚙️ DevOps & Deployment:"
	@echo "  make devops-setup     - Setup CI/CD + Docker + IaC"
	@echo "  make docker-build     - Build Docker image"
	@echo "  make docker-run       - Start Docker containers"
	@echo "  make deploy-testnet   - Deploy to testnet"
	@echo "  make deploy-mainnet   - Deploy to mainnet"
	@echo ""
	@echo "📊 Development Workflows:"
	@echo "  make dev             - Setup development environment"
	@echo "  make quick-start     - Dev environment + dashboard"
	@echo "  make full-setup      - Complete initialization"
	@echo "  make dev-cycle       - Full dev cycle (reset + setup + test)"
	@echo "  make pre-deploy      - Pre-deployment validation"
	@echo ""
	@echo "🔧 Configuration & Management:"
	@echo "  make config          - Configuration management"
	@echo "  make backup          - Create backup"
	@echo "  make status          - Show current status"
	@echo "  make logs            - View logs"
	@echo "  make clean           - Clean temporary files"
	@echo "  make menu            - Launch interactive menu"
	@echo ""

# System setup and dependencies
install:
	@echo "📦 Installing system dependencies..."
	@sudo apt update
	@sudo apt install -y python3 python3-pip curl wget git jq bc nodejs npm build-essential
	@pip3 install --user multiversx-sdk-cli
	@echo "✅ Dependencies installed"

deps: install

setup: deps
	@echo "⚙️ Setting up MultiversX localnet..."
	@chmod +x *.sh
	@./setup.sh
	@echo "✅ Setup completed"

# Core operations
start:
	@echo "🚀 Starting localnet..."
	@./start-localnet.sh

stop:
	@echo "🛑 Stopping localnet..."
	@./stop-localnet.sh

reset:
	@echo "🔄 Resetting localnet..."
	@./reset-localnet.sh

status:
	@./multiversx-localnet-manager.sh --cli status

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

monitoring-up:
	@echo "📊 Starting monitoring stack..."
	@docker-compose --profile monitoring up -d

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

# Utilities
logs:
	@echo "📜 Showing recent logs..."
	@tail -n 50 logs/*.log 2>/dev/null || echo "No logs found"

logs-follow:
	@echo "📜 Following logs (Ctrl+C to exit)..."
	@tail -f logs/*.log

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

clean-all:
	@echo "⚠️ WARNING: This will remove ALL data including backups!"
	@read -p "Type 'DELETE' to confirm: " confirm; \
	if [ "$$confirm" = "DELETE" ]; then \
		./multiversx-localnet-manager.sh --cli stop; \
		rm -rf logs backups test-results data configs dashboard security devops ai-config; \
		rm -rf ~/MultiversX/testnet; \
		echo "✅ All data removed"; \
	else \
		echo "❌ Cancelled"; \
	fi

# AI-Powered Development Workflows
ai-dev-cycle: ai-install config-init dev ai-review test
	@echo "🤖 AI-powered development cycle completed!"

ai-security-audit: ai-install security-install ai-review security-audit
	@echo "🛡️ AI + Security audit completed!"

ai-deploy-pipeline: ai-install security-install ai-review security-scan deploy-testnet
	@echo "🚀 AI-powered deployment pipeline completed!"

# Development workflow shortcuts
quick-start: dev dashboard
	@echo "⚡ Quick start completed!"
	@echo "  - Localnet: Running (dev mode)"
	@echo "  - Dashboard: http://localhost:8080"
	@echo "  - API: http://localhost:7950"

full-setup: setup config-init backup-auto ai-install security-install devops-setup
	@echo "🎉 Full setup completed!"
	@echo "  - All templates created"
	@echo "  - AI assistant ready"
	@echo "  - Security tools installed"
	@echo "  - DevOps automation configured"
	@echo "  - Automatic backups enabled"

enterprise-setup: full-setup monitoring-up
	@echo "🏢 Enterprise setup completed!"
	@echo "  - Full monitoring stack"
	@echo "  - Professional dashboards"
	@echo "  - Complete automation"

# CI/CD helpers
ci-test: ci test security-scan
	@echo "✅ CI/CD test pipeline completed"

ci-quick: ci test-quick
	@echo "⚡ CI/CD quick test completed"

ci-security: ci security-scan
	@echo "🛡️ CI/CD security pipeline completed"

# Performance testing workflows
performance-test: prod test-perf test-stress gas-analysis
	@echo "📊 Performance testing completed"

load-test: test-stress
	@echo "💪 Load testing completed"

benchmark: test-perf
	@echo "📈 Benchmark completed"

# Security workflows
security-full: security-install security-audit gas-analysis
	@echo "🔒 Complete security analysis finished"

vuln-scan: security-scan
	@echo "🔍 Vulnerability scan completed"

compliance-check: security-audit
	@echo "📋 Compliance check completed"

# DevOps workflows
devops-full: devops-setup docker-build monitoring-up
	@echo "⚙️ Full DevOps stack deployed"

infra-deploy: infra-plan infra-apply
	@echo "🏗️ Infrastructure deployment completed"

cicd-setup: devops-setup
	@echo "🔄 CI/CD pipeline configured"

# Multi-environment workflows
multi-deploy: deploy-testnet
	@echo "🌐 Multi-environment deployment initiated"

staging-deploy: test-env deploy-testnet
	@echo "🎭 Staging deployment completed"

production-deploy: prod security-audit deploy-mainnet
	@echo "🏭 Production deployment completed"

# AI-specific workflows
ai-contract-cycle: ai-install ai-generate ai-review test security-scan
	@echo "🤖 AI contract development cycle completed"

ai-optimization: ai-install ai-review gas-analysis
	@echo "⚡ AI optimization cycle completed"

ai-security-review: ai-install ai-review security-audit
	@echo "🛡️ AI security review completed"

# Monitoring and observability
monitoring-full: dashboard monitor
	@echo "📊 Full monitoring suite started"

observability: monitoring-up dashboard
	@echo "👁️ Complete observability stack running"

metrics: dashboard
	@echo "📈 Metrics dashboard launched"

# Development productivity shortcuts
dev-productivity: ai-install quick-start ai-chat
	@echo "🚀 Developer productivity suite ready!"

code-quality: ai-review security-scan gas-analysis
	@echo "✨ Code quality analysis completed"

project-health: status test security-scan
	@echo "❤️ Project health check completed"

# Info and status targets
info:
	@echo "📊 MultiversX Localnet Status:"
	@echo ""
	@echo "Network Status:"
	@./multiversx-localnet-manager.sh --cli status || echo "  Not running"
	@echo ""
	@echo "Configuration:"
	@./config-manager.sh current 2>/dev/null || echo "  No active configuration"
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
	@echo "DevOps:"
	@[ -f ".github/workflows/multiversx-ci-cd.yml" ] && echo "  ✅ GitHub Actions configured" || echo "  ❌ GitHub Actions not configured"
	@[ -f "docker-compose.yml" ] && echo "  ✅ Docker configured" || echo "  ❌ Docker not configured"
	@[ -d "devops/infrastructure" ] && echo "  ✅ Infrastructure as Code ready" || echo "  ❌ IaC not configured"
	@echo ""
	@echo "Disk Usage:"
	@du -sh ~/MultiversX/testnet 2>/dev/null | sed 's/^/  Localnet: /' || echo "  Localnet: Not initialized"
	@du -sh backups 2>/dev/null | sed 's/^/  Backups: /' || echo "  Backups: None"
	@du -sh logs 2>/dev/null | sed 's/^/  Logs: /' || echo "  Logs: None"

version:
	@echo "🚀 MultiversX Localnet AI-Powered Development Suite v2.0.0"
	@echo "👨‍💻 Author: George Pricop (@Gzeu)"
	@echo "🐙 GitHub: https://github.com/Gzeu/multiversx-wsl-localnet-setup"
	@echo "🌟 Features: AI Assistant, Security Scanning, DevOps Automation"

# Advanced workflow combinations
full-development-cycle: full-setup ai-contract-cycle security-full devops-full
	@echo "🎯 Complete development cycle finished!"

pre-mainnet-validation: prod security-audit performance-test compliance-check
	@echo "🔒 Pre-mainnet validation completed!"

automated-pipeline: ci-security ai-review deploy-testnet
	@echo "🤖 Automated development pipeline completed!"

# Help for specific areas
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
	@echo "  make gas-analysis      - Gas usage optimization analysis"
	@echo "  make security-mythril  - Mythril static analysis"
	@echo "  make security-slither  - Slither vulnerability detection"

help-devops:
	@echo "⚙️ DevOps Commands:"
	@echo "  make devops-setup      - Complete DevOps automation setup"
	@echo "  make docker-build      - Build Docker development image"
	@echo "  make docker-run        - Start Docker containers"
	@echo "  make monitoring-up     - Start monitoring stack (Grafana + Prometheus)"
	@echo "  make deploy-testnet    - Deploy contracts to testnet"
	@echo "  make deploy-mainnet    - Deploy contracts to mainnet"

help-workflows:
	@echo "🔄 Advanced Workflows:"
	@echo "  make full-setup              - Complete initialization"
	@echo "  make enterprise-setup        - Enterprise-grade setup"
	@echo "  make ai-dev-cycle           - AI-powered development cycle"
	@echo "  make pre-mainnet-validation - Complete pre-deployment validation"
	@echo "  make automated-pipeline     - Full automated CI/CD pipeline"

help-all: help help-ai help-security help-devops help-workflows

# Check if running in WSL
check-wsl:
	@if grep -qi microsoft /proc/version 2>/dev/null; then \
		echo "✅ Running in WSL environment"; \
	else \
		echo "⚠️ Not running in WSL (some features may not work optimally)"; \
	fi

# Project statistics
stats:
	@echo "📊 Project Statistics:"
	@echo "  Scripts: $(ls -1 *.sh | wc -l)"
	@echo "  Total lines of code: $(find . -name '*.sh' -o -name '*.py' -o -name '*.yml' -o -name '*.yaml' | xargs wc -l | tail -1)"
	@echo "  Contracts: $(find ./contracts -name '*.rs' 2>/dev/null | wc -l)"
	@echo "  Test files: $(find ./test-results -name '*.json' 2>/dev/null | wc -l)"
	@echo "  Backups: $(ls -1 ./backups/*.tar.gz 2>/dev/null | wc -l)"
	@echo "  Security reports: $(find ./security/reports -name '*' -type f 2>/dev/null | wc -l)"

# Interactive setup wizard
wizard:
	@echo "🧙‍♂️ MultiversX Setup Wizard"
	@echo "This will guide you through the complete setup process."
	@echo ""
	@read -p "Install AI tools? [Y/n]: " ai; \
	read -p "Install security tools? [Y/n]: " security; \
	read -p "Setup DevOps automation? [Y/n]: " devops; \
	read -p "Create development environment? [Y/n]: " dev; \
	echo "" && echo "🚀 Starting wizard..."; \
	[ "$$ai" != "n" ] && make ai-install; \
	[ "$$security" != "n" ] && make security-install; \
	[ "$$devops" != "n" ] && make devops-setup; \
	[ "$$dev" != "n" ] && make dev; \
	echo "🎉 Wizard completed!"

# Emergency procedures
emergency-stop:
	@echo "🚨 Emergency stop - killing all processes..."
	@pkill -f mxpy || true
	@pkill -f python3 || true
	@docker-compose down || true
	@echo "⛑️ Emergency stop completed"

emergency-backup:
	@echo "🚨 Emergency backup..."
	@./backup-recovery.sh create
	@echo "💾 Emergency backup completed"

rescue-mode: emergency-stop emergency-backup reset setup
	@echo "🛟 Rescue mode completed - system restored to clean state"