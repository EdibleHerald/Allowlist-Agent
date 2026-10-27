#!/bin/bash



# OPNsense Whitelist Automation

# Manages authorized client IP addresses



set -euo pipefail



OPNSENSE_URL="https://192.168.130.1"

ALIAS_NAME="Authorized_Clients"
ALIAS_UUID="0661253b-670f-4e57-9f50-7cb6b9ac77d8"


# Load API credentials

source "$HOME/opnsense-api/.env"



# Check credentials

if [[ -z "${OPNSENSE_KEY:-}" || -z "${OPNSENSE_SECRET:-}" ]]; then

    echo "Error: Missing API credentials."

    exit 1

fi



echo "Whitelist updater initialized."

echo "Firewall: $OPNSENSE_URL"

echo "Alias: $ALIAS_NAME"

# Check that an action and IP address were provided

if [[ $# -ne 2 ]]; then

    echo "Usage: bash update-whitelist.sh {add|remove} IP_ADDRESS"

    exit 1

fi



ACTION="$1"

CLIENT_IP="$2"

# Validate the requested action

if [[ "$ACTION" != "add" && "$ACTION" != "remove" ]]; then

    echo "Error: Action must be add or remove."

    exit 1

fi

# Validate the IPv4 address

if ! python3 -c 'import ipaddress, sys; ipaddress.IPv4Address(sys.argv[1])' "$CLIENT_IP"; then

    echo "Error: Invalid IPv4 address."

    exit 1

fi

# Retrieve the current whitelist from OPNsense

echo "Retrieving current whitelist..."



ALIAS_RESPONSE=$(curl -k -sS --fail-with-body -u "$OPNSENSE_KEY:$OPNSENSE_SECRET" -X POST -H "Content-Type: application/json" -d '{}' "$OPNSENSE_URL/api/firewall/alias/getItem/$ALIAS_UUID")

# Extract the current IP addresses from the API response

CURRENT_IPS=$(printf '%s' "$ALIAS_RESPONSE" | python3 -c '

import json

import sys



data = json.load(sys.stdin)

alias = data.get("alias", {})

content = alias.get("content", "")



if isinstance(content, dict):

    content = content.get("value", "")



if isinstance(content, list):

    content = "\n".join(str(ip) for ip in content)



print(content or "")

')

# Add or remove the requested IP address

UPDATED_IPS=$(python3 -c '

import ipaddress

import sys



action = sys.argv[1]

client_ip = str(ipaddress.IPv4Address(sys.argv[2]))

current_ips = sys.argv[3].split()



ips = set(current_ips)



if action == "add":

    ips.add(client_ip)

else:

    ips.discard(client_ip)



print("\n".join(sorted(ips, key=ipaddress.IPv4Address)))

' "$ACTION" "$CLIENT_IP" "$CURRENT_IPS")

# Build the JSON request for OPNsense

JSON_PAYLOAD=$(python3 -c '

import json

import sys



print(json.dumps({

    "alias": {

        "name": "Authorized_Clients",

        "type": "host",

        "content": sys.argv[1]

    }

}))

' "$UPDATED_IPS")

# Send the updated whitelist to OPNsense

echo "Updating OPNsense whitelist..."

UPDATE_RESPONSE=$(curl -k -sS --fail-with-body -u "$OPNSENSE_KEY:$OPNSENSE_SECRET" -X POST -H "Content-Type: application/json" -d "$JSON_PAYLOAD" "$OPNSENSE_URL/api/firewall/alias/setItem/$ALIAS_UUID")

# Verify the API accepted the update

if ! printf '%s' "$UPDATE_RESPONSE" | python3 -c '

import json

import sys



response = json.load(sys.stdin)

sys.exit(0 if response.get("result") == "saved" else 1)

'; then

    echo "Error: OPNsense did not save the whitelist."

    exit 1

fi



echo "Whitelist saved successfully."

# Apply the updated whitelist to the firewall

echo "Applying firewall changes..."

RECONFIGURE_RESPONSE=$(curl -k -sS --fail-with-body -u "$OPNSENSE_KEY:$OPNSENSE_SECRET" -X POST -H "Content-Type: application/json" -d '{}' "$OPNSENSE_URL/api/firewall/alias/reconfigure")

# Verify the firewall applied the changes

if ! printf '%s' "$RECONFIGURE_RESPONSE" | python3 -c '

import json

import sys



response = json.load(sys.stdin)

sys.exit(0 if response.get("status") == "ok" else 1)

'; then

    echo "Error: Firewall reconfiguration failed."

    exit 1

fi



echo "Firewall changes applied successfully."
