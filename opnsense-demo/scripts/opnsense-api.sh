#!/bin/bash

# OPNsense API Prototype
# Firewall Automation

set -e

OPNSENSE_URL="https://192.168.130.1"

# Load private API credentials
source .env

# Verify credentials are present
if [[ -z "${OPNSENSE_KEY:-}" || -z "${OPNSENSE_SECRET:-}" ]]; then
    echo "Error: API credentials are missing."
    exit 1
fi

echo "Connecting to OPNsense..."

# Retrieve firewall alias information
curl -k --fail-with-body --silent --show-error \
    -u "$OPNSENSE_KEY:$OPNSENSE_SECRET" \
    -X POST \
    -H "Content-Type: application/json" \
    -d '{}' \
    "$OPNSENSE_URL/api/firewall/alias/searchItem"

echo
echo "API request completed!"
