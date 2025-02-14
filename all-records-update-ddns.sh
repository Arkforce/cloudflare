#!/bin/bash

# Cloudflare API details
API_TOKEN="your-api-token"  # Replace with your API Token
ZONE_ID="your-zone-id"  # Replace with your Cloudflare Zone ID
DOMAIN="ak5.link"  # Your main domain

# Get your current public IP address
IP=$(curl -s http://ipv4.icanhazip.com)

# Get all A records for the domain
RECORDS=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records?type=A" \
  -H "Authorization: Bearer $API_TOKEN" \
  -H "Content-Type: application/json")

# Extract all record IDs and names
RECORD_IDS=$(echo "$RECORDS" | jq -r '.result[] | select(.name | test("'$DOMAIN'$|\\.'$DOMAIN'$")) | .id')
RECORD_NAMES=$(echo "$RECORDS" | jq -r '.result[] | select(.name | test("'$DOMAIN'$|\\.'$DOMAIN'$")) | .name')

# Loop through each record and update its IP
echo "Updating DNS records for $DOMAIN with new IP: $IP"
for RECORD_ID in $RECORD_IDS; do
  RECORD_NAME=$(echo "$RECORDS" | jq -r '.result[] | select(.id=="'$RECORD_ID'") | .name')

  curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$RECORD_ID" \
    -H "Authorization: Bearer $API_TOKEN" \
    -H "Content-Type: application/json" \
    --data '{"type":"A","name":"'"$RECORD_NAME"'","content":"'"$IP"'","ttl":120,"proxied":false}' \
    | jq '.success'

  echo "Updated: $RECORD_NAME"
done

echo "DNS update complete."
