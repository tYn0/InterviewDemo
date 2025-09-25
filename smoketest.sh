#!/usr/bin/env bash

set -euo pipefail

APP=$(terraform -chdir=infra output -raw app_host)
STAT=$(terraform -chdir=infra output -raw static_host)
IP=$(terraform -chdir=infra output -raw public_ip)

echo "IP: $IP"
echo "APP: $APP"
echo "STATIC: $STAT"
echo

# Filters
DROP_RE='^[[:space:]]*[{}] \[[0-9]+ bytes data\]|^\* \[HTTP/2\]'
TLS_KEEP_RE='^\* +(Connected to|SSL connection using|subject:|issuer:|SSL certificate verify ok\.?)'
HDR_KEEP_RE='^< HTTP/|^< [Cc]ontent-[Tt]ype:'
JSON_KEEP_RE='^\{|\['

echo "=== /health (TLS + status + JSON) ==="
curl -sS -i -v "https://$APP/health" 2>&1 \
  | grep -Ev "$DROP_RE" \
  | grep -E -i "$TLS_KEEP_RE|$HDR_KEEP_RE|$JSON_KEEP_RE" || true
echo

TS="smoketest-$(date +%s)"

echo "=== POST /items (status + JSON) ==="
curl -sS -i -v -X POST "https://$APP/items" \
  -H 'content-type: application/json' \
  --data "{\"name\":\"$TS\"}" 2>&1 \
  | grep -Ev "$DROP_RE" \
  | grep -E -i "$HDR_KEEP_RE|$JSON_KEEP_RE" || true
echo

echo "=== GET /items (status + JSON) ==="
curl -sS -i -v "https://$APP/items" 2>&1 \
  | grep -Ev "$DROP_RE" \
  | grep -E -i "$HDR_KEEP_RE|$JSON_KEEP_RE" || true
echo

echo "=== Static / (TLS + status + HTML) ==="
curl -sS -i -v "https://$STAT/" 2>&1 \
  | grep -Ev "$DROP_RE" \
  | grep -E -i "$TLS_KEEP_RE|$HDR_KEEP_RE" || true
echo "--- HTML ---"
curl -sS "https://$STAT/"
echo