#!/usr/bin/env bash
set -euo pipefail

# MultiversX AI Trading Suite - Basic Functionality
# Features:
# - Fetch market data from public APIs
# - Simple moving average crossover strategy
# - Paper trading ledger with PnL
# - Risk controls and dry-run by default
# - Hooks for future on-chain execution via MultiversX SDK/CLI

# Config
SYMBOL=${SYMBOL:-"EGLDUSDT"}
BASE_ASSET=${BASE_ASSET:-"EGLD"}
QUOTE_ASSET=${QUOTE_ASSET:-"USDT"}
INTERVAL=${INTERVAL:-"1m"}
FAST_MA=${FAST_MA:-9}
SLOW_MA=${SLOW_MA:-21}
RISK_PER_TRADE=${RISK_PER_TRADE:-0.02}
START_CAPITAL=${START_CAPITAL:-1000}
DATA_LIMIT=${DATA_LIMIT:-200}
DATA_PROVIDER=${DATA_PROVIDER:-"binance"} # binance|coingecko
LEDGER_FILE=${LEDGER_FILE:-"scripts/.ai_trading_paper_ledger.json"}
DRY_RUN=${DRY_RUN:-"true"}

# Utilities
log() { echo "[AI-TRADING] $(date '+%Y-%m-%d %H:%M:%S') - $*"; }
require() { command -v "$1" >/dev/null 2>&1 || { echo "Missing dependency: $1"; exit 1; }; }
json_get() { jq -r "$1" 2>/dev/null; }

dep_checks() {
  for bin in curl jq awk sed date; do require "$bin"; done
}

init_ledger() {
  if [[ ! -f "$LEDGER_FILE" ]]; then
    mkdir -p "$(dirname "$LEDGER_FILE")"
    cat > "$LEDGER_FILE" <<JSON
{
  "symbol": "$SYMBOL",
  "capital": $START_CAPITAL,
  "base_position": 0,
  "quote_position": $START_CAPITAL,
  "last_price": null,
  "trades": []
}
JSON
  fi
}

fetch_data_binance() {
  local url="https://api.binance.com/api/v3/klines?symbol=$SYMBOL&interval=$INTERVAL&limit=$DATA_LIMIT"
  curl -sS "$url" | jq -r 'map({openTime: .[0], open: (.[1]|tonumber), high: (.[2]|tonumber), low: (.[3]|tonumber), close: (.[4]|tonumber), volume: (.[5]|tonumber)})'
}

fetch_data_coingecko() {
  local cg_id=${CG_ID:-"elrond-erd-2"}
  local days=1
  local url="https://api.coingecko.com/api/v3/coins/$cg_id/market_chart?vs_currency=usd&days=$days&interval=minute"
  curl -sS "$url" | jq -r '.prices | map({openTime: .[0], close: (.[1]|tonumber)})'
}

fetch_data() {
  case "$DATA_PROVIDER" in
    binance) fetch_data_binance ;;
    coingecko) fetch_data_coingecko ;;
    *) echo "Unsupported DATA_PROVIDER: $DATA_PROVIDER"; exit 1;;
  esac
}

sma_series() {
  local period="$1"
  jq --argjson p "$period" '
    reduce to_entries[] as $i (
      {sum:0, buf: [], out: []};
      .buf += [$i.value.close] |
      (if (.buf|length) > $p then .buf |= .[1:] else . end) |
      .sum = (.buf|add) |
      .out += [ (if (.buf|length) >= $p then (.buf|add)/($p) else null end) ]
    ) | .out'
}

last_non_null() { jq -r 'reverse | map(select(.) ) | .[0]'; }

signal_from_cross() {
  # expects data with close and adds fast/slow SMA; returns buy|sell|hold
  jq --argjson f "$FAST_MA" --argjson s "$SLOW_MA" -r '
    . as $d |
    ($d | ( . | to_entries | map(.value) ) | [.[].close]) as $closes |
    $d as $series |
    $series | [ .[] ] as $rows |
    $rows
  ' >/dev/null 2>/dev/null # placeholder to keep structure
}

make_signals() {
  local data="$1"
  # Compute SMAs
  local fast slow
  fast=$(echo "$data" | sma_series "$FAST_MA")
  slow=$(echo "$data" | sma_series "$SLOW_MA")
  # Attach back to rows and compute cross
  paste_output=$(jq -n --argjson d "$data" --argjson f "$fast" --argjson s "$slow" '
    [$d[] | {close:.close}] as $rows |
    [$f[]] as $fast |
    [$s[]] as $slow |
    reduce range(0; ($rows|length)) as $i (
      [];
      . + [ $rows[$i] + {fast: $fast[$i], slow: $slow[$i]} ]
    )')
  echo "$paste_output" | jq -r '
    . as $rows |
    def dir(x): if x==null then null elif x>0 then 1 elif x<0 then -1 else 0 end;
    reduce range(1; length) as $i (
      {signals: [], prev: null};
      .curr = .[$i] |
      .prev = .[$i-1] |
      .cross = (if (.curr.fast!=null and .curr.slow!=null and .prev.fast!=null and .prev.slow!=null)
        then (.curr.fast - .curr.slow) - (.prev.fast - .prev.slow) else null end) |
      .signals += [ if .cross!=null and .cross>0 then {type:"buy", price:.curr.close} else if .cross!=null and .cross<0 then {type:"sell", price:.curr.close} else {type:"hold", price:.curr.close} end end ]
    ) | .signals | last'
}

paper_trade() {
  local ledger_json; ledger_json=$(cat "$LEDGER_FILE")
  local data; data=$(fetch_data)
  local sig; sig=$(make_signals "$data")
  local type; type=$(echo "$sig" | json_get '.type')
  local price; price=$(echo "$sig" | json_get '.price')

  log "Last signal: $type at price $price"

  local base quote
  base=$(echo "$ledger_json" | json_get '.base_position')
  quote=$(echo "$ledger_json" | json_get '.quote_position')

  local trade_size
  trade_size=$(awk -v q="$quote" -v r="$RISK_PER_TRADE" 'BEGIN{printf "%.2f", q*r}')

  if [[ "$type" == "buy" && $(awk -v q="$quote" 'BEGIN{print (q>0)?1:0}') -eq 1 ]]; then
    local qty; qty=$(awk -v ts="$trade_size" -v p="$price" 'BEGIN{printf "%.6f", ts/p}')
    quote=$(awk -v q="$quote" -v ts="$trade_size" 'BEGIN{printf "%.2f", q-ts}')
    base=$(awk -v b="$base" -v qty="$qty" 'BEGIN{printf "%.6f", b+qty}')
    action="BUY"
  elif [[ "$type" == "sell" && $(awk -v b="$base" 'BEGIN{print (b>0)?1:0}') -eq 1 ]]; then
    local proceeds; proceeds=$(awk -v b="$base" -v p="$price" 'BEGIN{printf "%.2f", b*p}')
    quote=$(awk -v q="$quote" -v pr="$proceeds" 'BEGIN{printf "%.2f", q+pr}')
    base=0
    action="SELL"
  else
    action="HOLD"
  fi

  local equity; equity=$(awk -v b="$base" -v p="$price" -v q="$quote" 'BEGIN{printf "%.2f", q + b*p}')

  log "Action: $action | Base: $base $BASE_ASSET | Quote: $quote $QUOTE_ASSET | Equity: $equity $QUOTE_ASSET"

  if [[ "$DRY_RUN" == "true" ]]; then
    log "Dry-run mode active. Ledger not persisted."
    return 0
  fi

  tmp=$(mktemp)
  echo "$ledger_json" | jq \
    --arg action "$action" \
    --argjson price "$price" \
    --argjson base "$base" \
    --argjson quote "$quote" \
    --arg ts "$(date -u +%FT%TZ)" \
    '.last_price = $price
     | .base_position = $base
     | .quote_position = $quote
     | .trades += [{time:$ts, action:$action, price:$price, base:$base, quote:$quote}]' > "$tmp"
  mv "$tmp" "$LEDGER_FILE"
}

usage() {
  cat <<EOF
MultiversX AI Trading Suite (basic)

Usage:
  $0 run                 # fetch data, generate signal, paper trade
  $0 backtest            # run over fetched series and report PnL (todo)

Env vars:
  SYMBOL=$SYMBOL INTERVAL=$INTERVAL FAST_MA=$FAST_MA SLOW_MA=$SLOW_MA
  START_CAPITAL=$START_CAPITAL DATA_PROVIDER=$DATA_PROVIDER DRY_RUN=$DRY_RUN
  LEDGER_FILE=$LEDGER_FILE

Notes:
  - This is a basic educational tool. Not financial advice.
  - For real trading, integrate with MultiversX smart contracts or custodial exchange APIs with strong risk controls.
EOF
}

main() {
  dep_checks
  init_ledger
  case "${1:-}" in
    run) paper_trade ;;
    backtest) echo "Backtesting placeholder - implement iterative PnL calc" ;;
    *) usage ;;
  esac
}

main "$@"
