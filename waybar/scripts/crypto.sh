#!/bin/bash

# Fetch crypto prices from CoinGecko API
RESPONSE=$(curl -s "https://api.coingecko.com/api/v3/simple/price?ids=bitcoin,ethereum,solana&vs_currencies=usd&include_24hr_change=true")

if [ $? -ne 0 ] || [ -z "$RESPONSE" ]; then
    echo '{"text": "Crypto: Error", "tooltip": "Failed to fetch crypto prices"}'
    exit 0
fi

# Parse JSON response
BTC=$(echo "$RESPONSE" | jq -r '.bitcoin.usd // 0' | xargs printf "%.0f")
BTC_CHANGE=$(echo "$RESPONSE" | jq -r '.bitcoin.usd_24h_change // 0' | xargs printf "%.1f")

ETH=$(echo "$RESPONSE" | jq -r '.ethereum.usd // 0' | xargs printf "%.0f")
ETH_CHANGE=$(echo "$RESPONSE" | jq -r '.ethereum.usd_24h_change // 0' | xargs printf "%.1f")

SOL=$(echo "$RESPONSE" | jq -r '.solana.usd // 0' | xargs printf "%.0f")
SOL_CHANGE=$(echo "$RESPONSE" | jq -r '.solana.usd_24h_change // 0' | xargs printf "%.1f")

# Format output with better icons (using simple symbols that render properly)
TEXT="BTC \$${BTC} | ETH \$${ETH} | SOL \$${SOL}"

# Create tooltip with 24h changes
TOOLTIP="Bitcoin: \$${BTC} (${BTC_CHANGE}%)\nEthereum: \$${ETH} (${ETH_CHANGE}%)\nSolana: \$${SOL} (${SOL_CHANGE}%)"

echo "{\"text\": \"$TEXT\", \"tooltip\": \"$TOOLTIP\"}"
