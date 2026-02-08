#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_FILE="${ROOT_DIR}/docs/ecosystem-repos.tsv"

if ! command -v curl >/dev/null 2>&1; then
  echo "error: curl is required" >&2
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "error: jq is required" >&2
  exit 1
fi

API_URL="https://api.github.com/users/t81dev/repos?per_page=100"

{
  echo -e "name\tdescription\thtml_url\tupdated_at"
  curl -fsSL "${API_URL}" \
    | jq -r '.[] | [.name, (.description // ""), .html_url, .updated_at] | @tsv'
} > "${OUT_FILE}"

echo "wrote ${OUT_FILE}"
