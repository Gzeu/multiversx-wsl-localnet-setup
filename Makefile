# MultiversX Localnet Development Suite Makefile
# Author: George Pricop (@Gzeu)
# Quick commands for common operations

.PHONY: help setup start stop reset dashboard test backup config clean install deps

# Default target
help:
	@echo ""
	@echo "🚀 MultiversX Localnet Development Suite"
	@echo "==============================================="
	@echo ""
	@echo "Quick Commands:"
	@echo "  make setup     - Initial setup and dependencies"
	@echo "  make start     - Start localnet"
	@echo "  make stop      - Stop localnet"
	@echo "  make reset     - Reset localnet (clean state)"
	@echo "  make dashboard - Launch monitoring dashboard"
	@echo "  make test      - Run test suite"
	@echo "  make backup    - Create backup"
	@echo "  make config    - Configuration management"
	@echo "  make clean     - Clean all data"
	@echo ""
	@echo "Development Workflow:"
	@echo "  make dev       - Setup development environment"
	@echo "  make ci        - Setup CI/CD environment"
	@echo "  make prod      - Setup production-like environment"
	@echo ""
	@echo "Utilities:"
	@echo "  make status    - Show current status"
	@echo "  make logs      - View logs"
	@echo "  make menu      - Launch interactive menu"
	@echo "  make install   - Install system dependencies"
	@echo ""

# System setup and dependencies
install:
	@echo "Installing system dependencies..."
	@sudo apt update
	@sudo apt install -y python3 python3-pip curl wget git jq bc
	@pip3 install --user multiversx-sdk-cli
	@echo "✓ Dependencies installed"

deps: install

setup: deps
	@echo "Setting up MultiversX localnet..."
	@chmod +x *.sh
	@./setup.sh
	@echo "✓ Setup completed"

# Core operations
start:
	@echo "Starting localnet..."
	@./start-localnet.sh

stop:
	@echo "Stopping localnet..."
	@./stop-localnet.sh

reset:
	@echo "Resetting localnet..."
	@./reset-localnet.sh

status:
	@./multiversx-localnet-manager.sh --cli status

# Development environments
dev: setup
	@echo "Setting up development environment..."
	@./config-manager.sh init
	@./config-manager.sh apply dev
	@./start-localnet.sh
	@echo "✓ Development environment ready (2s rounds, fast iteration)"

test-env: setup
	@echo "Setting up testing environment..."
	@./config-manager.sh init
	@./config-manager.sh apply test
	@./start-localnet.sh
	@echo "✓ Testing environment ready (6s rounds, testnet-like)"

ci: setup
	@echo "Setting up CI/CD environment..."
	@./config-manager.sh init
	@./config-manager.sh apply ci
	@./start-localnet.sh
	@echo "✓ CI/CD environment ready (1s rounds, minimal resources)"

prod: setup
	@echo "Setting up production-like environment..."
	@./config-manager.sh init
	@./config-manager.sh apply production
	@./start-localnet.sh
	@echo "✓ Production environment ready (mainnet-like settings)"

# Monitoring and testing
dashboard:
	@echo "Launching monitoring dashboard..."
	@./monitor-dashboard.sh dashboard
	@echo "✓ Dashboard available at http://localhost:8080"

monitor:
	@echo "Starting monitoring..."
	@./monitor-dashboard.sh start

test:
	@echo "Running test suite..."
	@./test-benchmark.sh all

test-quick:
	@echo "Running quick connectivity test..."
	@./test-benchmark.sh connectivity

test-perf:
	@echo "Running performance benchmark..."
	@./test-benchmark.sh throughput

test-stress:
	@echo "Running stress test..."
	@./test-benchmark.sh stress

# Configuration management
config:
	@./config-manager.sh list

config-init:
	@./config-manager.sh init

config-current:
	@./config-manager.sh current

# Backup operations
backup:
	@echo "Creating backup..."
	@./backup-recovery.sh create

backup-list:
	@./backup-recovery.sh list

backup-auto:
	@echo "Starting automatic backups (24h interval)..."
	@./backup-recovery.sh schedule 24

# Utilities
logs:
	@echo "Showing recent logs..."
	@tail -n 50 logs/*.log 2>/dev/null || echo "No logs found"

logs-follow:
	@echo "Following logs (Ctrl+C to exit)..."
	@tail -f logs/*.log

menu:
	@./multiversx-localnet-manager.sh

# Fund wallet (requires WALLET_ADDRESS)
fund:
	@if [ -z "$(WALLET_ADDRESS)" ]; then \
		echo "Usage: make fund WALLET_ADDRESS=erd1..."; \
	else \
		echo "Funding wallet $(WALLET_ADDRESS)..."; \
		./faucet.sh $(WALLET_ADDRESS); \
	fi

# Cleanup operations
clean:
	@echo "Cleaning up temporary files..."
	@rm -rf ./logs/*.log ./data/metrics/*.json ./test-results/*.json 2>/dev/null || true
	@echo "✓ Temporary files cleaned"

clean-all:
	@echo "WARNING: This will remove ALL data including backups!"
	@read -p "Type 'DELETE' to confirm: " confirm; \
	if [ "$$confirm" = "DELETE" ]; then \
		./multiversx-localnet-manager.sh --cli stop; \
		rm -rf logs backups test-results data configs dashboard; \
		rm -rf ~/MultiversX/testnet; \
		echo "✓ All data removed"; \
	else \
		echo "Cancelled"; \
	fi

# Development workflow shortcuts
quick-start: dev dashboard
	@echo "🚀 Quick start completed!"
	@echo "  - Localnet: Running (dev mode)"
	@echo "  - Dashboard: http://localhost:8080"
	@echo "  - API: http://localhost:7950"

full-setup: setup config-init backup-auto
	@echo "🎉 Full setup completed!"
	@echo "  - All templates created"
	@echo "  - Automatic backups enabled"
	@echo "  - Ready for development"

# CI/CD helpers
ci-test: ci test
	@echo "✓ CI/CD test pipeline completed"

ci-quick: ci test-quick
	@echo "✓ CI/CD quick test completed"

# Info targets
info:
	@echo "📈 MultiversX Localnet Status:"
	@echo ""
	@echo "Network Status:"
	@./multiversx-localnet-manager.sh --cli status || echo "  Not running"
	@echo ""
	@echo "Configuration:"
	@./config-manager.sh current 2>/dev/null || echo "  No active configuration"
	@echo ""
	@echo "Disk Usage:"
	@du -sh ~/MultiversX/testnet 2>/dev/null | sed 's/^/  Localnet: /' || echo "  Localnet: Not initialized"
	@du -sh backups 2>/dev/null | sed 's/^/  Backups: /' || echo "  Backups: None"
	@du -sh logs 2>/dev/null | sed 's/^/  Logs: /' || echo "  Logs: None"

version:
	@echo "MultiversX Localnet Development Suite v1.0.0"
	@echo "Author: George Pricop (@Gzeu)"
	@echo "GitHub: https://github.com/Gzeu/multiversx-wsl-localnet-setup"

# Development shortcuts for common workflows
dev-cycle: stop reset config-init dev test
	@echo "🔄 Development cycle completed"

pre-deploy: test-env test backup
	@echo "🚀 Pre-deployment validation completed"

performance-test: prod test-perf test-stress
	@echo "📊 Performance testing completed"

# Help for specific areas
help-config:
	@echo "Configuration Management:"
	@echo "  make config          - List available templates"
	@echo "  make config-init     - Initialize default templates"
	@echo "  make config-current  - Show current configuration"
	@echo "  make dev            - Apply development template"
	@echo "  make test-env       - Apply testing template"
	@echo "  make ci             - Apply CI/CD template"
	@echo "  make prod           - Apply production template"

help-test:
	@echo "Testing Commands:"
	@echo "  make test           - Run full test suite"
	@echo "  make test-quick     - Quick connectivity test"
	@echo "  make test-perf      - Performance benchmark"
	@echo "  make test-stress    - Network stress test"
	@echo "  make ci-test        - CI/CD test pipeline"

help-backup:
	@echo "Backup Commands:"
	@echo "  make backup         - Create full backup"
	@echo "  make backup-list    - List available backups"
	@echo "  make backup-auto    - Enable automatic backups"

help-dev:
	@echo "Development Workflows:"
	@echo "  make quick-start    - Setup dev + dashboard"
	@echo "  make full-setup     - Complete initialization"
	@echo "  make dev-cycle      - Full dev cycle (reset + setup + test)"
	@echo "  make pre-deploy     - Pre-deployment validation"
	@echo "  make performance-test - Performance validation"

# Check if running in WSL
check-wsl:
	@if grep -qi microsoft /proc/version 2>/dev/null; then \
		echo "✓ Running in WSL environment"; \
	else \
		echo "⚠ Not running in WSL (some features may not work optimally)"; \
	fi