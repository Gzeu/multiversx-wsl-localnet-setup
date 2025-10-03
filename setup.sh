#!/usr/bin/env bash
set -euo pipefail

# === Config ===
WORKDIR="${HOME}/mx-localnet"
TESTWALLETS_DIR="${HOME}/multiversx-sdk/testwallets/latest/users"
ALICE_PEM="${TESTWALLETS_DIR}/alice.pem"
TESTNET_PROXY="https://testnet-gateway.multiversx.com"

# === 1) Update & pachete de bază ===
sudo apt update && sudo apt upgrade -y
sudo apt install -y python3 python3-pip git curl build-essential make jq pkg-config libssl-dev

# === 2) Rust & Cargo (rustup) ===
if ! command -v rustup >/dev/null 2>&1; then
  # Instalare rustup conform recomandărilor oficiale (script cu TLS v1.2)
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  # Sourcing pentru sesiunea curentă
  source "$HOME/.cargo/env"
fi
rustup update

# === 3) mxpy CLI ===
pip3 install --user --upgrade multiversx-sdk-cli
export PATH="$HOME/.local/bin:$PATH"
mxpy --version || true

# === 4) Verificare/instalare dependențe CLI ===
# 'deps check' și 'deps install' sunt gestionate din mxpy
mxpy deps check rust || true
mxpy deps check python || true
mxpy deps check testwallets || mxpy deps install testwallets --overwrite

# === 5) Localnet: setup & start ===
mkdir -p "$WORKDIR"
cd "$WORKDIR"
mxpy localnet setup
# pornește localnet în background
mxpy localnet start &

# Așteaptă proxy-ul local pe 7950
echo "Aștept proxy localnet pe http://localhost:7950 ..."
for i in $(seq 1 60); do
  if curl -sf "http://localhost:7950/network/config" >/dev/null 2>&1; then
    echo "Proxy Localnet disponibil."
    break
  fi
  sleep 2
done

# === 6) Wallet-uri ===
# Opțiunea A: folosește walletul de dezvoltare Alice PEM pre-mintat pentru localnet
if [ ! -f "$ALICE_PEM" ]; then
  echo "Testwallet Alice nu este disponibil încă; încearcă 'mxpy deps install testwallets --overwrite' și re-rulează."
fi

# Opțiunea B: creează un keystore și convertește în PEM (dacă preferi wallet propriu)
# mxpy wallet new --format keystore-mnemonic --outfile test_wallet.json
# mxpy wallet convert --infile test_wallet.json --in-format keystore-mnemonic --outfile walletKey.pem --out-format pem

# === 7) Exemplu opțional: creare template + build + deploy (sc-meta) ===
if command -v sc-meta >/dev/null 2>&1; then
  CONTRACT_DIR="${HOME}/my-contract"
  # generează un contract template 'empty' (are init/upgrade)
  sc-meta new --template empty --name my-contract --path "${HOME}"
  cd "$CONTRACT_DIR"
  # build care produce output/*.wasm
  sc-meta all build
  BYTECODE="$(ls output/*.wasm | head -n 1 || true)"
  if [ -n "${BYTECODE:-}" ] && [ -f "$ALICE_PEM" ]; then
    # deploy pe Localnet (chain=localnet, proxy local)
    mxpy contract deploy \
      --bytecode "$BYTECODE" \
      --gas-limit 50000000 \
      --pem "$ALICE_PEM" \
      --proxy "http://localhost:7950" \
      --chain localnet \
      --send
  else
    echo "Nu s-a găsit bytecode sau ALICE_PEM; sar peste deploy."
  fi
else
  echo "sc-meta nu este instalat; sar peste build/deploy contract. Vezi documentația sc-meta pentru instalare."
fi

# === 8) Config Testnet (proxy + chain T) ===
# Creează și comută un env pentru testnet astfel încât --proxy să fie implicit
mxpy config-env new testnet || true
mxpy config-env set proxy_url "${TESTNET_PROXY}" --env testnet
mxpy config-env switch --env testnet

echo "Setup finalizat:
- Localnet rulează cu proxy pe http://localhost:7950
- Testnet env configurat (proxy implicit ${TESTNET_PROXY}, chain= T la deploy)
- Pentru xEGLD de Testnet, folosește Faucet din Web Wallet (tab Faucet)
"
