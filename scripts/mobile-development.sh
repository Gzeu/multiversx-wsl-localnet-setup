#!/usr/bin/env bash
# MultiversX Mobile Development Suite
# Flutter and React Native development tools for MultiversX dApps

set -euo pipefail

# Configuration
MOBILE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../mobile" && pwd)"
TEMPLATES_DIR="$MOBILE_DIR/templates"
PROJECTS_DIR="$MOBILE_DIR/projects"
TOOLS_DIR="$MOBILE_DIR/tools"
DOCS_DIR="$MOBILE_DIR/docs"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[$(date '+%Y-%m-%d %H:%M:%S')] WARN:${NC} $1"
}

error() {
    echo -e "${RED}[$(date '+%Y-%m-%d %H:%M:%S')] ERROR:${NC} $1"
}

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

usage() {
    cat << EOF
MultiversX Mobile Development Suite

Usage: $0 [COMMAND] [OPTIONS]

Setup Commands:
    setup               Initialize mobile development environment
    install-flutter     Install Flutter SDK
    install-rn          Install React Native CLI
    doctor              Check development environment
    
Project Commands:
    create-flutter      Create new Flutter dApp project
    create-react-native Create new React Native dApp project
    list-projects       List existing mobile projects
    build-project       Build mobile project
    test-project        Run tests for mobile project
    
Template Commands:
    create-template     Create new dApp template
    list-templates      List available templates
    apply-template      Apply template to existing project
    
Development Commands:
    start-dev           Start development server
    hot-reload          Enable hot reload
    debug               Start debugging session
    profile             Run performance profiling
    
Deployment Commands:
    build-android       Build Android APK/AAB
    build-ios           Build iOS IPA
    deploy-testflight   Deploy to TestFlight
    deploy-playstore    Deploy to Play Store
    
MultiversX Integration:
    init-wallet         Initialize MultiversX wallet integration
    add-sdk             Add MultiversX SDK to project
    generate-contracts  Generate contract bindings
    test-integration    Test blockchain integration
    
Options:
    --project NAME      Project name
    --template NAME     Template to use
    --platform PLATFORM Target platform (android, ios, both)
    --debug             Enable debug mode
    --release           Build for release
    
Examples:
    $0 setup                                    # Setup development environment
    $0 create-flutter --project my-dapp        # Create Flutter dApp
    $0 build-project --project my-dapp --release # Build release version
    $0 init-wallet --project my-dapp           # Add wallet integration
EOF
}

setup_directories() {
    log "Setting up mobile development directories..."
    mkdir -p "$MOBILE_DIR" "$TEMPLATES_DIR" "$PROJECTS_DIR" "$TOOLS_DIR" "$DOCS_DIR"
    mkdir -p "$TEMPLATES_DIR/flutter" "$TEMPLATES_DIR/react-native"
}

check_system_requirements() {
    log "Checking system requirements for mobile development..."
    
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
    
    log "Operating System: $OS"
    
    # Check required tools
    local tools_status=()
    command -v git >/dev/null 2>&1 && tools_status+=("Git: ✅") || tools_status+=("Git: ❌")
    command -v curl >/dev/null 2>&1 && tools_status+=("curl: ✅") || tools_status+=("curl: ❌")
    command -v unzip >/dev/null 2>&1 && tools_status+=("unzip: ✅") || tools_status+=("unzip: ❌")
    
    # Platform-specific checks
    if [ "$OS" = "linux" ]; then
        command -v snap >/dev/null 2>&1 && tools_status+=("snap: ✅") || tools_status+=("snap: ❌")
    fi
    
    printf '%s\n' "${tools_status[@]}"
}

install_flutter() {
    log "Installing Flutter SDK..."
    
    local flutter_version="3.19.0"
    local install_dir="$HOME/development"
    local flutter_dir="$install_dir/flutter"
    
    mkdir -p "$install_dir"
    cd "$install_dir"
    
    if [ -d "$flutter_dir" ]; then
        warn "Flutter already installed. Updating..."
        cd "$flutter_dir"
        git pull
    else
        log "Downloading Flutter SDK..."
        if [ "$OS" = "linux" ]; then
            curl -O "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${flutter_version}-stable.tar.xz"
            tar xf "flutter_linux_${flutter_version}-stable.tar.xz"
        elif [ "$OS" = "macos" ]; then
            curl -O "https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_${flutter_version}-stable.zip"
            unzip "flutter_macos_${flutter_version}-stable.zip"
        fi
    fi
    
    # Add to PATH
    local shell_rc="$HOME/.bashrc"
    [ "$OS" = "macos" ] && shell_rc="$HOME/.zshrc"
    
    if ! grep -q "flutter/bin" "$shell_rc" 2>/dev/null; then
        echo "export PATH=\"$flutter_dir/bin:\$PATH\"" >> "$shell_rc"
        log "Added Flutter to PATH in $shell_rc"
        export PATH="$flutter_dir/bin:$PATH"
    fi
    
    # Run Flutter doctor
    "$flutter_dir/bin/flutter" doctor
    
    log "Flutter installation completed!"
    log "Run 'flutter doctor' to check for any remaining setup steps."
}

install_react_native() {
    log "Installing React Native CLI..."
    
    # Check if Node.js is installed
    if ! command -v node >/dev/null 2>&1; then
        error "Node.js is required for React Native. Please install Node.js 16+ first."
        return 1
    fi
    
    local node_version=$(node --version | sed 's/^v//')
    log "Using Node.js version: $node_version"
    
    # Install React Native CLI globally
    npm install -g @react-native-community/cli
    
    # Install Android development tools info
    log "React Native CLI installed successfully!"
    log "Next steps for Android development:"
    log "  1. Install Android Studio"
    log "  2. Set up Android SDK"
    log "  3. Configure ANDROID_HOME environment variable"
    log "  4. Add platform-tools to PATH"
    
    if [ "$OS" = "macos" ]; then
        log "Next steps for iOS development (macOS only):"
        log "  1. Install Xcode from the App Store"
        log "  2. Install Xcode Command Line Tools: xcode-select --install"
        log "  3. Install CocoaPods: sudo gem install cocoapods"
    fi
}

run_doctor() {
    log "Running mobile development environment diagnostics..."
    
    echo "=== System Information ==="
    echo "OS: $OS"
    echo "Shell: $SHELL"
    echo ""
    
    echo "=== Development Tools ==="
    
    # Check Flutter
    if command -v flutter >/dev/null 2>&1; then
        local flutter_version=$(flutter --version | head -n1 | cut -d' ' -f2)
        echo "✅ Flutter: $flutter_version"
        flutter doctor --machine | python3 -c "
import json, sys
try:
    data = json.load(sys.stdin)
    for check in data:
        status = '✅' if check['status'] == 'installed' else '⚠️'
        print(f'  {status} {check[\"name\"]}')
except:
    print('  Could not parse Flutter doctor output')
" 2>/dev/null || echo "  Run 'flutter doctor' for detailed status"
    else
        echo "❌ Flutter: Not installed"
    fi
    
    # Check React Native
    if command -v npx >/dev/null 2>&1 && npx react-native --version >/dev/null 2>&1; then
        local rn_version=$(npx react-native --version)
        echo "✅ React Native: $rn_version"
    else
        echo "❌ React Native: Not installed"
    fi
    
    # Check Android development
    echo ""
    echo "=== Android Development ==="
    if [ -n "${ANDROID_HOME:-}" ] && [ -d "$ANDROID_HOME" ]; then
        echo "✅ ANDROID_HOME: $ANDROID_HOME"
        if [ -f "$ANDROID_HOME/platform-tools/adb" ]; then
            echo "✅ ADB: $("$ANDROID_HOME/platform-tools/adb" version | head -n1)"
        else
            echo "⚠️  ADB: Not found in platform-tools"
        fi
    else
        echo "❌ ANDROID_HOME: Not set"
        echo "❌ Android SDK: Not configured"
    fi
    
    # Check iOS development (macOS only)
    if [ "$OS" = "macos" ]; then
        echo ""
        echo "=== iOS Development (macOS) ==="
        if command -v xcodebuild >/dev/null 2>&1; then
            local xcode_version=$(xcodebuild -version | head -n1)
            echo "✅ Xcode: $xcode_version"
        else
            echo "❌ Xcode: Not installed"
        fi
        
        if command -v pod >/dev/null 2>&1; then
            local pod_version=$(pod --version)
            echo "✅ CocoaPods: $pod_version"
        else
            echo "❌ CocoaPods: Not installed"
        fi
    fi
    
    # Check MultiversX tools
    echo ""
    echo "=== MultiversX Integration ==="
    if command -v mxpy >/dev/null 2>&1; then
        echo "✅ mxpy: $(mxpy --version | head -n1)"
    else
        echo "⚠️  mxpy: Not installed (required for blockchain integration)"
    fi
}

create_flutter_template() {
    log "Creating Flutter dApp template..."
    
    local template_dir="$TEMPLATES_DIR/flutter/multiversx-dapp"
    mkdir -p "$template_dir"
    
    # Create pubspec.yaml
    cat > "$template_dir/pubspec.yaml" << 'EOF'
name: multiversx_dapp_template
description: A MultiversX dApp template built with Flutter
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'
  flutter: ">=3.10.0"

dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0
  web3dart: ^2.7.3
  provider: ^6.0.5
  shared_preferences: ^2.2.0
  qr_code_scanner: ^1.0.1
  qr_flutter: ^4.1.0
  crypto: ^3.0.3
  bip39: ^1.0.6
  
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  build_runner: ^2.4.7
  json_annotation: ^4.8.1
  json_serializable: ^6.7.1

flutter:
  uses-material-design: true
  assets:
    - assets/images/
    - assets/icons/
EOF

    # Create main.dart
    mkdir -p "$template_dir/lib"
    cat > "$template_dir/lib/main.dart" << 'EOF'
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/multiversx_service.dart';
import 'screens/home_screen.dart';
import 'providers/wallet_provider.dart';

void main() {
  runApp(const MultiversXDApp());
}

class MultiversXDApp extends StatelessWidget {
  const MultiversXDApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WalletProvider()),
        Provider(create: (_) => MultiversXService()),
      ],
      child: MaterialApp(
        title: 'MultiversX dApp',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
EOF

    # Create MultiversX service
    mkdir -p "$template_dir/lib/services"
    cat > "$template_dir/lib/services/multiversx_service.dart" << 'EOF'
import 'dart:convert';
import 'package:http/http.dart' as http;

class MultiversXService {
  static const String mainnetUrl = 'https://gateway.multiversx.com';
  static const String testnetUrl = 'https://testnet-gateway.multiversx.com';
  static const String devnetUrl = 'https://devnet-gateway.multiversx.com';
  static const String localnetUrl = 'http://localhost:7950';
  
  final String baseUrl;
  
  MultiversXService({this.baseUrl = localnetUrl});
  
  Future<Map<String, dynamic>> getNetworkConfig() async {
    final response = await http.get(Uri.parse('$baseUrl/network/config'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to load network config');
  }
  
  Future<Map<String, dynamic>> getAccount(String address) async {
    final response = await http.get(Uri.parse('$baseUrl/accounts/$address'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to load account');
  }
  
  Future<String> sendTransaction(Map<String, dynamic> transaction) async {
    final response = await http.post(
      Uri.parse('$baseUrl/transactions'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(transaction),
    );
    
    if (response.statusCode == 201) {
      final result = json.decode(response.body);
      return result['data']['txHash'];
    }
    throw Exception('Failed to send transaction');
  }
}
EOF

    # Create wallet provider
    mkdir -p "$template_dir/lib/providers"
    cat > "$template_dir/lib/providers/wallet_provider.dart" << 'EOF'
import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class WalletProvider extends ChangeNotifier {
  String? _address;
  String? _privateKey;
  double _balance = 0.0;
  bool _isConnected = false;
  
  String? get address => _address;
  double get balance => _balance;
  bool get isConnected => _isConnected;
  
  Future<void> generateWallet() async {
    // Generate a new wallet
    // This is a simplified implementation
    final bytes = List<int>.generate(32, (i) => i);
    final privateKey = sha256.convert(bytes).toString();
    
    _privateKey = privateKey;
    _address = 'erd1' + privateKey.substring(0, 60); // Simplified address generation
    _isConnected = true;
    
    notifyListeners();
  }
  
  Future<void> importWallet(String privateKey) async {
    _privateKey = privateKey;
    _address = 'erd1' + privateKey.substring(0, 60); // Simplified
    _isConnected = true;
    
    notifyListeners();
  }
  
  Future<void> updateBalance(double newBalance) async {
    _balance = newBalance;
    notifyListeners();
  }
  
  void disconnect() {
    _address = null;
    _privateKey = null;
    _balance = 0.0;
    _isConnected = false;
    notifyListeners();
  }
}
EOF

    # Create home screen
    mkdir -p "$template_dir/lib/screens"
    cat > "$template_dir/lib/screens/home_screen.dart" << 'EOF'
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wallet_provider.dart';
import '../services/multiversx_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? networkConfig;
  
  @override
  void initState() {
    super.initState();
    _loadNetworkConfig();
  }
  
  Future<void> _loadNetworkConfig() async {
    try {
      final service = context.read<MultiversXService>();
      final config = await service.getNetworkConfig();
      setState(() {
        networkConfig = config;
      });
    } catch (e) {
      print('Error loading network config: $e');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MultiversX dApp'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer<WalletProvider>(
        builder: (context, wallet, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Network Status',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        if (networkConfig != null)
                          Text('Chain ID: ${networkConfig!['data']['erd_chain_id']}')
                        else
                          const Text('Loading network config...'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Wallet',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        if (wallet.isConnected) ..[
                          Text('Address: ${wallet.address}'),
                          Text('Balance: ${wallet.balance} EGLD'),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: wallet.disconnect,
                            child: const Text('Disconnect'),
                          ),
                        ] else ..[
                          const Text('No wallet connected'),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: wallet.generateWallet,
                                child: const Text('Generate Wallet'),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () => _showImportDialog(context),
                                child: const Text('Import Wallet'),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  void _showImportDialog(BuildContext context) {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Wallet'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Private Key',
            hintText: 'Enter your private key',
          ),
          obscureText: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<WalletProvider>().importWallet(controller.text);
              Navigator.of(context).pop();
            },
            child: const Text('Import'),
          ),
        ],
      ),
    );
  }
}
EOF

    log "Flutter template created at: $template_dir"
}

create_react_native_template() {
    log "Creating React Native dApp template..."
    
    local template_dir="$TEMPLATES_DIR/react-native/multiversx-dapp"
    mkdir -p "$template_dir"
    
    # Create package.json
    cat > "$template_dir/package.json" << 'EOF'
{
  "name": "MultiversXDAppTemplate",
  "version": "0.0.1",
  "private": true,
  "scripts": {
    "android": "react-native run-android",
    "ios": "react-native run-ios",
    "lint": "eslint .",
    "start": "react-native start",
    "test": "jest",
    "postinstall": "cd ios && pod install && cd .."
  },
  "dependencies": {
    "react": "18.2.0",
    "react-native": "0.73.0",
    "@react-navigation/native": "^6.1.9",
    "@react-navigation/native-stack": "^6.9.17",
    "react-native-safe-area-context": "^4.7.4",
    "react-native-screens": "^3.27.0",
    "@multiversx/sdk-core": "^12.15.0",
    "@multiversx/sdk-wallet": "^4.2.0",
    "@multiversx/sdk-network-providers": "^2.7.0",
    "react-native-keychain": "^8.1.3",
    "react-native-qrcode-svg": "^6.2.0",
    "react-native-camera": "^4.2.1"
  },
  "devDependencies": {
    "@babel/core": "^7.20.0",
    "@babel/preset-env": "^7.20.0",
    "@babel/runtime": "^7.20.0",
    "@react-native/eslint-config": "^0.73.1",
    "@react-native/metro-config": "^0.73.2",
    "@react-native/typescript-config": "^0.73.1",
    "@types/react": "^18.2.6",
    "@types/react-test-renderer": "^18.0.0",
    "babel-jest": "^29.6.3",
    "eslint": "^8.19.0",
    "jest": "^29.6.3",
    "metro-react-native-babel-preset": "0.77.0",
    "prettier": "2.8.8",
    "react-test-renderer": "18.2.0",
    "typescript": "4.8.4"
  }
}
EOF

    # Create App.tsx
    cat > "$template_dir/App.tsx" << 'EOF'
import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { WalletProvider } from './src/providers/WalletProvider';
import HomeScreen from './src/screens/HomeScreen';
import WalletScreen from './src/screens/WalletScreen';

const Stack = createNativeStackNavigator();

export default function App() {
  return (
    <WalletProvider>
      <NavigationContainer>
        <Stack.Navigator initialRouteName="Home">
          <Stack.Screen name="Home" component={HomeScreen} />
          <Stack.Screen name="Wallet" component={WalletScreen} />
        </Stack.Navigator>
      </NavigationContainer>
    </WalletProvider>
  );
}
EOF

    log "React Native template created at: $template_dir"
}

setup_mobile_development() {
    log "Setting up MultiversX mobile development environment..."
    
    setup_directories
    check_system_requirements
    create_flutter_template
    create_react_native_template
    
    # Create development scripts
    cat > "$TOOLS_DIR/create_project.sh" << 'EOF'
#!/bin/bash
# Create new MultiversX mobile project

set -euo pipefail

PROJECT_NAME="$1"
TEMPLATE="$2"
TARGET_DIR="../projects/$PROJECT_NAME"

if [ "$TEMPLATE" = "flutter" ]; then
    cp -r "../templates/flutter/multiversx-dapp" "$TARGET_DIR"
    cd "$TARGET_DIR"
    sed -i "s/multiversx_dapp_template/$PROJECT_NAME/g" pubspec.yaml
elif [ "$TEMPLATE" = "react-native" ]; then
    cp -r "../templates/react-native/multiversx-dapp" "$TARGET_DIR"
    cd "$TARGET_DIR"
    sed -i "s/MultiversXDAppTemplate/$PROJECT_NAME/g" package.json
fi

echo "Project $PROJECT_NAME created successfully!"
EOF

    chmod +x "$TOOLS_DIR/create_project.sh"
    
    # Create documentation
    cat > "$DOCS_DIR/README.md" << 'EOF'
# MultiversX Mobile Development

This directory contains templates, tools, and documentation for developing MultiversX mobile dApps.

## Getting Started

### Prerequisites
- Flutter SDK (for Flutter projects)
- React Native CLI (for React Native projects)
- Android Studio (for Android development)
- Xcode (for iOS development, macOS only)

### Creating a New Project

#### Flutter
```bash
./scripts/mobile-development.sh create-flutter --project my-dapp
```

#### React Native
```bash
./scripts/mobile-development.sh create-react-native --project my-dapp
```

### Development Workflow

1. Create project from template
2. Install dependencies
3. Configure MultiversX network settings
4. Implement wallet integration
5. Add smart contract interactions
6. Test on emulator/device
7. Build for production

## Templates

- **flutter/multiversx-dapp**: Basic Flutter dApp template
- **react-native/multiversx-dapp**: Basic React Native dApp template

## Resources

- [MultiversX SDK Documentation](https://docs.multiversx.com)
- [Flutter Documentation](https://flutter.dev/docs)
- [React Native Documentation](https://reactnative.dev/docs)
EOF

    log "Mobile development environment setup completed!"
    log "Templates created:"
    log "  - Flutter: $TEMPLATES_DIR/flutter/multiversx-dapp"
    log "  - React Native: $TEMPLATES_DIR/react-native/multiversx-dapp"
    log "Documentation: $DOCS_DIR/README.md"
}

create_flutter_project() {
    local project_name="${PROJECT_NAME:-}"
    if [ -z "$project_name" ]; then
        error "Project name required. Use --project NAME"
        exit 1
    fi
    
    log "Creating Flutter project: $project_name"
    
    local project_dir="$PROJECTS_DIR/$project_name"
    if [ -d "$project_dir" ]; then
        error "Project already exists: $project_dir"
        exit 1
    fi
    
    # Copy template
    cp -r "$TEMPLATES_DIR/flutter/multiversx-dapp" "$project_dir"
    
    # Update project name
    cd "$project_dir"
    sed -i "s/multiversx_dapp_template/$project_name/g" pubspec.yaml
    
    log "Flutter project created: $project_dir"
    log "Next steps:"
    log "  1. cd $project_dir"
    log "  2. flutter pub get"
    log "  3. flutter run"
}

list_projects() {
    log "Mobile projects:"
    
    if [ -d "$PROJECTS_DIR" ] && [ -n "$(ls -A "$PROJECTS_DIR" 2>/dev/null)" ]; then
        for project in "$PROJECTS_DIR"/*/; do
            local project_name=$(basename "$project")
            local project_type="Unknown"
            
            if [ -f "$project/pubspec.yaml" ]; then
                project_type="Flutter"
            elif [ -f "$project/package.json" ]; then
                project_type="React Native"
            fi
            
            printf "  %-20s %s\n" "$project_name" "$project_type"
        done
    else
        log "No projects found. Create one with 'create-flutter' or 'create-react-native'."
    fi
}

# Parse command line arguments
PROJECT_NAME=""
TEMPLATE=""
PLATFORM="both"
DEBUG=false
RELEASE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --project)
            PROJECT_NAME="$2"
            shift 2
            ;;
        --template)
            TEMPLATE="$2"
            shift 2
            ;;
        --platform)
            PLATFORM="$2"
            shift 2
            ;;
        --debug)
            DEBUG=true
            shift
            ;;
        --release)
            RELEASE=true
            shift
            ;;
        *)
            break
            ;;
    esac
done

# Main command handling
case "${1:-}" in
    setup)
        setup_mobile_development
        ;;
    install-flutter)
        install_flutter
        ;;
    install-rn|install-react-native)
        install_react_native
        ;;
    doctor)
        check_system_requirements
        run_doctor
        ;;
    create-flutter)
        create_flutter_project
        ;;
    list-projects)
        list_projects
        ;;
    *)
        usage
        exit 1
        ;;
esac
