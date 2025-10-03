# MultiversX WSL Localnet Setup

**Automation bash scripts, configs, and docs for MultiversX Localnet/Testnet dev setup in WSL2/Ubuntu. Includes CLI, Rust, sc-meta, and troubleshooting.**

---

## 🎯 Project Theme

This repository provides a comprehensive, automated solution for setting up a complete MultiversX development environment on Windows Subsystem for Linux 2 (WSL2) or native Ubuntu systems. It streamlines the installation and configuration of all necessary tools, dependencies, and blockchain nodes for smart contract development, testing, and deployment on MultiversX.

**Key Focus Areas:**
- ✅ Zero-friction environment setup for MultiversX development
- ✅ Localnet and Testnet configuration automation
- ✅ Smart contract development toolchain (Rust, sc-meta, mxpy)
- ✅ Common troubleshooting scenarios and solutions
- ✅ Best practices for WSL2/Ubuntu MultiversX development

---

## 🚀 Quick Start Workflow

### Prerequisites
- Windows 10/11 with WSL2 enabled OR Ubuntu 20.04/22.04 LTS
- At least 8GB RAM and 20GB free disk space
- Basic familiarity with terminal/command line

### Installation Steps

1. **Clone this repository:**
   ```bash
   git clone https://github.com/Gzeu/multiversx-wsl-localnet-setup.git
   cd multiversx-wsl-localnet-setup
   ```

2. **Run the main setup script:**
   ```bash
   chmod +x setup.sh
   ./setup.sh
   ```
   This will automatically install:
   - System dependencies (build tools, libraries)
   - Rust toolchain (via rustup)
   - MultiversX CLI (`mxpy`)
   - `sc-meta` for smart contract management
   - Node.js and development utilities

3. **Initialize the localnet:**
   ```bash
   ./init-localnet.sh
   ```
   This configures and starts a local MultiversX blockchain for development.

4. **Verify installation:**
   ```bash
   mxpy --version
   sc-meta --version
   rustc --version
   ```

---

## 📋 Main Components

### Core Scripts
- **`setup.sh`** - Master installation script for all dependencies
- **`init-localnet.sh`** - Localnet initialization and configuration
- **`start-localnet.sh`** - Start local blockchain nodes
- **`stop-localnet.sh`** - Stop local blockchain nodes
- **`reset-localnet.sh`** - Reset localnet to clean state
- **`install-rust.sh`** - Standalone Rust toolchain installer
- **`install-mxpy.sh`** - MultiversX Python CLI installer
- **`install-sc-meta.sh`** - Smart contract meta-build tool installer

### Configuration Files
- **`config/`** - Node configurations, genesis files, validator keys
- **`wallets/`** - Development wallet PEM files (DO NOT use in production)
- **`docker/`** - Docker Compose configurations for containerized setup

### Documentation
- **`docs/INSTALLATION.md`** - Detailed installation guide
- **`docs/TROUBLESHOOTING.md`** - Common issues and solutions
- **`docs/TESTNET.md`** - Connecting to MultiversX Testnet
- **`docs/SMART_CONTRACTS.md`** - SC development workflow
- **`docs/WSL2_OPTIMIZATION.md`** - WSL2-specific performance tips

---

## 🔧 Development Workflow

### Typical Development Cycle

1. **Start your local blockchain:**
   ```bash
   ./start-localnet.sh
   ```

2. **Create a new smart contract project:**
   ```bash
   sc-meta new --template adder my-contract
   cd my-contract
   ```

3. **Build your smart contract:**
   ```bash
   sc-meta all build
   ```

4. **Deploy to localnet:**
   ```bash
   mxpy contract deploy --bytecode=output/my-contract.wasm \
     --pem=../wallets/wallet-owner.pem \
     --proxy=http://localhost:7950 \
     --chain=localnet \
     --recall-nonce \
     --gas-limit=5000000
   ```

5. **Interact with deployed contract:**
   ```bash
   mxpy contract call <CONTRACT_ADDRESS> \
     --function="myFunction" \
     --arguments <ARGS> \
     --pem=../wallets/wallet-owner.pem \
     --proxy=http://localhost:7950 \
     --chain=localnet
   ```

6. **Stop localnet when done:**
   ```bash
   ./stop-localnet.sh
   ```

---

## 🛠️ Troubleshooting Quick Reference

### Common Issues

**Issue: `mxpy: command not found`**
```bash
# Solution: Reload shell configuration
source ~/.bashrc  # or ~/.zshrc
# OR reinstall mxpy
./install-mxpy.sh
```

**Issue: Localnet nodes won't start**
```bash
# Check for port conflicts
sudo netstat -tulpn | grep -E '7950|10000'
# Kill conflicting processes
./stop-localnet.sh
./reset-localnet.sh
./start-localnet.sh
```

**Issue: Rust compilation errors**
```bash
# Update Rust to latest stable
rustup update stable
rustup default stable
# Clean and rebuild
cargo clean
sc-meta all build
```

**Issue: WSL2 performance issues**
- Store projects in WSL filesystem (`~/projects`), not Windows mounts (`/mnt/c/`)
- Increase WSL2 memory: Create `%USERPROFILE%\.wslconfig` with:
  ```ini
  [wsl2]
  memory=8GB
  processors=4
  ```

For detailed troubleshooting, see **[docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)**

---

## 📚 Additional Resources

- [MultiversX Official Documentation](https://docs.multiversx.com/)
- [MultiversX SDK Cookbook](https://docs.multiversx.com/sdk-and-tools/sdk-py/)
- [Smart Contract Examples](https://github.com/multiversx/mx-sdk-rs/tree/master/contracts/examples)
- [MultiversX Developer Discord](https://discord.gg/multiversx)
- [Rust Book](https://doc.rust-lang.org/book/)

---

## 🤝 Contributing

Contributions are welcome! Please:
1. Fork this repository
2. Create a feature branch (`git checkout -b feature/improvement`)
3. Commit your changes (`git commit -am 'Add new feature'`)
4. Push to the branch (`git push origin feature/improvement`)
5. Open a Pull Request

---

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

---

## ⚠️ Security Notice

**WARNING:** The wallet PEM files included in this repository are for **DEVELOPMENT USE ONLY**. Never use these keys on mainnet or with real funds. Always generate new, secure keys for testnet and production deployments.

---

## 🔔 Project Status

**Current Version:** 1.0.0 (Initial Setup)  
**Status:** 🚧 Active Development  
**Last Updated:** October 2025

### Roadmap
- [ ] Complete automation scripts (setup, localnet management)
- [ ] Add comprehensive documentation
- [ ] Docker Compose configurations
- [ ] CI/CD integration examples
- [ ] Video tutorials and screencasts
- [ ] Performance optimization guides
- [ ] Integration with popular IDEs (VS Code, IntelliJ)

---

**Happy Building on MultiversX! 🚀**
