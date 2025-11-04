#!/usr/bin/env bash
set -euo pipefail

# This script fetches the latest release versions for Ethereum clients
# and outputs them as GitHub Actions environment variables

echo "Fetching latest release versions for Ethereum clients..."

# Function to get latest GitHub release tag (excluding pre-releases)
get_latest_github_release() {
  local repo=$1
  local tag

  # Get latest release (not pre-release)
  tag=$(gh api "repos/${repo}/releases" --jq '[.[] | select(.prerelease == false)] | .[0].tag_name' 2>/dev/null || echo "")

  if [ -z "$tag" ]; then
    echo "Warning: Could not fetch release for ${repo}, trying latest tag..." >&2
    tag=$(gh api "repos/${repo}/tags" --jq '.[0].name' 2>/dev/null || echo "latest")
  fi

  echo "$tag"
}

# Function to clean version tags (remove 'v' prefix if present)
clean_version() {
  echo "$1" | sed 's/^v//'
}

# Consensus Layer Clients
echo "Fetching consensus layer client versions..."

LIGHTHOUSE_RAW=$(get_latest_github_release "sigp/lighthouse")
LIGHTHOUSE_VERSION=$(clean_version "$LIGHTHOUSE_RAW")
echo "Lighthouse: ${LIGHTHOUSE_VERSION}"

PRYSM_RAW=$(get_latest_github_release "prysmaticlabs/prysm")
PRYSM_VERSION=$(clean_version "$PRYSM_RAW")
echo "Prysm: ${PRYSM_VERSION}"

TEKU_RAW=$(get_latest_github_release "Consensys/teku")
TEKU_VERSION=$(clean_version "$TEKU_RAW")
echo "Teku: ${TEKU_VERSION}"

NIMBUS_RAW=$(get_latest_github_release "status-im/nimbus-eth2")
NIMBUS_VERSION=$(clean_version "$NIMBUS_RAW")
echo "Nimbus: ${NIMBUS_VERSION}"

LODESTAR_RAW=$(get_latest_github_release "ChainSafe/lodestar")
LODESTAR_VERSION=$(clean_version "$LODESTAR_RAW")
echo "Lodestar: ${LODESTAR_VERSION}"

# Grandine doesn't have public GitHub releases, using Docker Hub
# Query Docker Hub API for latest tag
GRANDINE_VERSION=$(curl -s "https://hub.docker.com/v2/repositories/sifrai/grandine/tags/?page_size=100" | \
  jq -r '.results | map(select(.name | test("^v?[0-9]+\\.[0-9]+\\.[0-9]+$"))) | .[0].name' || echo "stable")
echo "Grandine: ${GRANDINE_VERSION}"

# Execution Layer Clients
echo "Fetching execution layer client versions..."

GETH_RAW=$(get_latest_github_release "ethereum/go-ethereum")
GETH_VERSION=$(clean_version "$GETH_RAW")
echo "Geth: ${GETH_VERSION}"

NETHERMIND_RAW=$(get_latest_github_release "NethermindEth/nethermind")
NETHERMIND_VERSION=$(clean_version "$NETHERMIND_RAW")
echo "Nethermind: ${NETHERMIND_VERSION}"

BESU_RAW=$(get_latest_github_release "hyperledger/besu")
BESU_VERSION=$(clean_version "$BESU_RAW")
echo "Besu: ${BESU_VERSION}"

RETH_RAW=$(get_latest_github_release "paradigmxyz/reth")
RETH_VERSION=$(clean_version "$RETH_RAW")
echo "Reth: ${RETH_VERSION}"

ERIGON_RAW=$(get_latest_github_release "erigontech/erigon")
ERIGON_VERSION=$(clean_version "$ERIGON_RAW")
echo "Erigon: ${ERIGON_VERSION}"

# Output for GitHub Actions
if [ -n "${GITHUB_ENV:-}" ]; then
  echo "Writing versions to GITHUB_ENV..."
  {
    echo "LIGHTHOUSE_VERSION=${LIGHTHOUSE_VERSION}"
    echo "PRYSM_VERSION=${PRYSM_VERSION}"
    echo "TEKU_VERSION=${TEKU_VERSION}"
    echo "NIMBUS_VERSION=${NIMBUS_VERSION}"
    echo "LODESTAR_VERSION=${LODESTAR_VERSION}"
    echo "GRANDINE_VERSION=${GRANDINE_VERSION}"
    echo "GETH_VERSION=${GETH_VERSION}"
    echo "NETHERMIND_VERSION=${NETHERMIND_VERSION}"
    echo "BESU_VERSION=${BESU_VERSION}"
    echo "RETH_VERSION=${RETH_VERSION}"
    echo "ERIGON_VERSION=${ERIGON_VERSION}"
  } >> "$GITHUB_ENV"
fi

# Also output for GITHUB_OUTPUT if available (for use in subsequent steps)
if [ -n "${GITHUB_OUTPUT:-}" ]; then
  echo "Writing versions to GITHUB_OUTPUT..."
  {
    echo "lighthouse_version=${LIGHTHOUSE_VERSION}"
    echo "prysm_version=${PRYSM_VERSION}"
    echo "teku_version=${TEKU_VERSION}"
    echo "nimbus_version=${NIMBUS_VERSION}"
    echo "lodestar_version=${LODESTAR_VERSION}"
    echo "grandine_version=${GRANDINE_VERSION}"
    echo "geth_version=${GETH_VERSION}"
    echo "nethermind_version=${NETHERMIND_VERSION}"
    echo "besu_version=${BESU_VERSION}"
    echo "reth_version=${RETH_VERSION}"
    echo "erigon_version=${ERIGON_VERSION}"
  } >> "$GITHUB_OUTPUT"
fi

echo ""
echo "✅ Successfully fetched all client versions"
