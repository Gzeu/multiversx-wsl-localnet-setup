# MultiversX WSL Localnet Setup - Complete Development Suite

🚀 **Professional MultiversX localnet development environment with advanced monitoring, testing, and management tools**

A comprehensive bash-based toolkit for MultiversX blockchain development, featuring automated setup, real-time monitoring, performance testing, backup/recovery, and configuration management - all optimized for WSL2/Ubuntu environments.

## ✨ Features

### 🎯 Core Functionality
- **Automated Setup**: One-click MultiversX localnet installation and configuration
- **Interactive Management**: Beautiful terminal-based UI for all operations
- **WSL2 Optimized**: Specifically designed for Windows Subsystem for Linux
- **Template-Based Config**: Pre-configured templates for different development scenarios

### 📊 Advanced Monitoring
- **Real-time Dashboard**: Web-based monitoring interface with live metrics
- **Performance Analytics**: TPS monitoring, transaction tracking, and network statistics
- **Visual Reporting**: Auto-generated performance reports and charts
- **Alerting System**: Automated notifications for network issues

### 🧪 Testing & Benchmarking
- **Comprehensive Test Suite**: Automated testing for all network components
- **Performance Benchmarks**: Throughput testing and stress testing capabilities
- **Smart Contract Testing**: Automated deployment and interaction testing
- **Load Testing**: Multi-threaded transaction generation and analysis

### 💾 Backup & Recovery
- **Automated Backups**: Scheduled full and incremental backups
- **Quick Recovery**: One-click restore from any backup point
- **Data Integrity**: Backup verification and corruption detection
- **Version Management**: Automatic cleanup of old backups

### ⚙️ Configuration Management
- **Multiple Templates**: Dev, Test, Production, and CI/CD configurations
- **Dynamic Switching**: Hot-swap between different network configurations
- **Custom Profiles**: Create and manage custom configuration templates
- **Environment Optimization**: Tailored settings for different use cases

## 🚀 Quick Start

### Prerequisites
- Windows 10/11 with WSL2 enabled
- Ubuntu 20.04+ (or compatible Linux distribution)
- Python 3.8+
- Git

### Installation

```bash
# Clone the repository
git clone https://github.com/Gzeu/multiversx-wsl-localnet-setup.git
cd multiversx-wsl-localnet-setup

# Make scripts executable
chmod +x *.sh

# Launch the interactive manager
./multiversx-localnet-manager.sh
```

### One-Line Setup
```bash
curl -sSL https://raw.githubusercontent.com/Gzeu/multiversx-wsl-localnet-setup/main/setup.sh | bash
```

## 📋 Usage

### Interactive Mode (Recommended)

Launch the comprehensive management interface:

```bash
./multiversx-localnet-manager.sh
```

This provides a beautiful terminal interface with:
- ✅ Real-time status display
- 🎮 Easy navigation with number keys
- 📊 Integrated monitoring and testing
- 🔧 Configuration management
- 💾 Backup operations

### Command Line Interface

For automation and scripting:

```bash
# Basic operations
./multiversx-localnet-manager.sh --cli start
./multiversx-localnet-manager.sh --cli stop
./multiversx-localnet-manager.sh --cli status

# Advanced operations
./multiversx-localnet-manager.sh --cli dashboard
./multiversx-localnet-manager.sh --cli test all
./multiversx-localnet-manager.sh --cli backup create
```

### Individual Components

Each component can be used independently:

```bash
# Monitoring Dashboard
./monitor-dashboard.sh start          # Start monitoring
./monitor-dashboard.sh dashboard      # Launch web dashboard

# Testing Suite
./test-benchmark.sh all              # Run all tests
./test-benchmark.sh throughput       # TPS benchmark
./test-benchmark.sh contract         # Smart contract tests

# Configuration Management
./config-manager.sh init             # Create templates
./config-manager.sh apply dev        # Apply dev template
./config-manager.sh list             # List all templates

# Backup System
./backup-recovery.sh create          # Create full backup
./backup-recovery.sh restore backup_name
./backup-recovery.sh schedule 24     # Auto backup every 24h
```

## 🎯 Configuration Templates

### Development Template (`dev`)
- **Round Duration**: 2 seconds (fast iteration)
- **Validators**: 1 per shard (minimal setup)
- **Features**: All enabled from epoch 0
- **Use Case**: Daily development work

### Testing Template (`test`) 
- **Round Duration**: 6 seconds (testnet-like)
- **Validators**: 2 per shard (realistic consensus)
- **Features**: Testnet-like conditions
- **Use Case**: Pre-deployment testing

### Production Template (`production`)
- **Round Duration**: 6 seconds (mainnet-like)
- **Validators**: Large consensus groups
- **Features**: Full security features
- **Use Case**: Final validation

### CI/CD Template (`ci`)
- **Round Duration**: 1 second (ultra-fast)
- **Validators**: Minimal (resource optimized)
- **Features**: Lightweight for automation
- **Use Case**: Automated testing pipelines

## 📊 Monitoring Dashboard

Access the real-time web dashboard at `http://localhost:8080` after starting monitoring:

### Features
- 📈 **Live Metrics**: TPS, block height, transaction count
- 🔄 **Network Status**: Real-time validator and shard status
- 📋 **Activity Logs**: Recent network activity and events
- 🎨 **Beautiful UI**: Modern, responsive design with animations
- 🔄 **Auto-refresh**: Updates every 5 seconds

## 🧪 Testing Capabilities

### Test Types
- **Connectivity Tests**: API endpoint validation
- **Throughput Benchmarks**: TPS measurement and analysis
- **Smart Contract Tests**: Deployment and interaction testing
- **Stress Tests**: Network resilience under load
- **Integration Tests**: End-to-end workflow validation

### Test Reports
Automatically generated reports include:
- Performance metrics and recommendations
- Network stability analysis
- Optimization suggestions
- Comparative benchmarks

## 💾 Backup System

### Backup Types
- **Full Backups**: Complete network state snapshot
- **Incremental Backups**: Only changed files since last backup
- **Scheduled Backups**: Automated periodic backups
- **Metadata Tracking**: Detailed backup information and integrity

### Recovery Options
- **Point-in-time Recovery**: Restore to any backup timestamp
- **Selective Recovery**: Restore specific components only
- **Integrity Verification**: Validate backup before restore
- **Safe Recovery**: Automatic backup of current state before restore

## 🔧 Advanced Configuration

### Environment Variables

```bash
# Localnet Configuration
export LOCALNET_SHARDS=3                    # Number of shards
export LOCALNET_VALIDATORS_PER_SHARD=2       # Validators per shard
export LOCALNET_ROUND_DURATION=4000          # Round duration (ms)
export LOCALNET_ROUNDS_PER_EPOCH=50          # Rounds per epoch

# Monitoring Configuration
export MONITORING_PORT=8080                  # Dashboard port
export METRICS_INTERVAL=5                    # Metric collection interval
export MAX_BACKUPS=10                        # Maximum backup retention

# Testing Configuration
export TEST_DURATION=60                      # Test duration (seconds)
export MAX_TPS_TARGET=50                     # Target TPS for benchmarks
```

### Custom Templates

Create custom configuration templates:

1. Initialize template system: `./config-manager.sh init`
2. Copy existing template: `cp -r configs/templates/dev configs/templates/custom`
3. Modify configuration files in `configs/templates/custom/`
4. Apply custom template: `./config-manager.sh apply custom`

## 🛠️ Development Workflow

### Recommended Development Process

1. **Setup**: Use dev template for fast iteration
   ```bash
   ./config-manager.sh apply dev
   ./multiversx-localnet-manager.sh --cli start
   ```

2. **Development**: Code and test with real-time monitoring
   ```bash
   ./monitor-dashboard.sh dashboard  # Launch monitoring
   # Develop your smart contracts...
   ```

3. **Testing**: Run comprehensive tests
   ```bash
   ./test-benchmark.sh all
   ```

4. **Pre-deployment**: Switch to test template
   ```bash
   ./config-manager.sh apply test
   ./multiversx-localnet-manager.sh --cli reset
   ./test-benchmark.sh all
   ```

5. **Backup**: Create backup before major changes
   ```bash
   ./backup-recovery.sh create
   ```

### CI/CD Integration

```yaml
# GitHub Actions example
- name: Setup MultiversX Localnet
  run: |
    git clone https://github.com/Gzeu/multiversx-wsl-localnet-setup.git
    cd multiversx-wsl-localnet-setup
    ./config-manager.sh apply ci
    ./multiversx-localnet-manager.sh --cli start
    
- name: Run Tests
  run: |
    cd multiversx-wsl-localnet-setup
    ./test-benchmark.sh all
```

## 📁 Directory Structure

```
multiversx-wsl-localnet-setup/
├── 🚀 multiversx-localnet-manager.sh    # Master control script
├── ⚙️  setup.sh                         # Initial setup
├── ▶️  start-localnet.sh                # Start localnet
├── ⏹️  stop-localnet.sh                 # Stop localnet
├── 🔄 reset-localnet.sh                # Reset localnet
├── 💰 faucet.sh                        # Fund wallets
├── 📊 monitor-dashboard.sh             # Monitoring & dashboard
├── 🧪 test-benchmark.sh                # Testing suite
├── 💾 backup-recovery.sh               # Backup system
├── ⚙️  config-manager.sh                # Configuration management
├── 📋 contracts/                       # Smart contract templates
├── 🔧 configs/                         # Configuration templates
├── 💾 backups/                         # Backup storage
├── 📊 test-results/                    # Test reports
├── 📈 dashboard/                       # Web dashboard files
├── 📝 logs/                            # System logs
└── 📊 data/                            # Runtime data
```

## 🔍 Troubleshooting

### Common Issues

**Localnet won't start:**
```bash
# Check dependencies
./multiversx-localnet-manager.sh --cli status

# Reset everything
./reset-localnet.sh
./setup.sh
```

**Port conflicts:**
```bash
# Check what's using port 7950
sudo netstat -tlnp | grep 7950

# Kill conflicting processes
sudo pkill -f mxpy
```

**WSL2 networking issues:**
```bash
# Restart WSL networking
wsl --shutdown
# Restart your WSL terminal
```

**Performance issues:**
```bash
# Use CI template for lightweight setup
./config-manager.sh apply ci

# Reduce monitoring frequency
export METRICS_INTERVAL=30
```

### Log Analysis

```bash
# View real-time logs
./multiversx-localnet-manager.sh         # Option 10

# Or manually:
tail -f logs/*.log
tail -f ~/MultiversX/testnet/logs/*.log
```

## 🤝 Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Commit your changes: `git commit -m 'Add amazing feature'`
4. Push to the branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

### Development Guidelines

- Follow existing code style and structure
- Add appropriate logging and error handling
- Update documentation for new features
- Test on Ubuntu 20.04+ and WSL2
- Ensure backward compatibility

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

**George Pricop (@Gzeu)**
- GitHub: [@Gzeu](https://github.com/Gzeu)
- MultiversX Developer & Blockchain Enthusiast
- Location: București, Romania

## 🙏 Acknowledgments

- MultiversX Team for the excellent blockchain platform
- MultiversX Developer Community for guidance and feedback
- WSL2 team for making Linux development on Windows seamless

## 📊 Project Stats

![GitHub stars](https://img.shields.io/github/stars/Gzeu/multiversx-wsl-localnet-setup?style=social)
![GitHub forks](https://img.shields.io/github/forks/Gzeu/multiversx-wsl-localnet-setup?style=social)
![GitHub issues](https://img.shields.io/github/issues/Gzeu/multiversx-wsl-localnet-setup)
![GitHub license](https://img.shields.io/github/license/Gzeu/multiversx-wsl-localnet-setup)

---

⭐ **If this project helped you, please give it a star!** ⭐