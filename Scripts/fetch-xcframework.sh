#!/bin/bash
# Download the latest ProbeTool.xcframework artifact from GitHub Actions.
# Requires: GitHub CLI (gh) authenticated.
# Usage: ./Scripts/fetch-xcframework.sh [run-id]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
LIBS_DIR="${PROJECT_DIR}/libs"
REPO="xf22001/probe_web"

mkdir -p "${LIBS_DIR}"

if [ $# -ge 1 ]; then
    RUN_ID="$1"
else
    echo "Fetching latest workflow run..."
    RUN_ID=$(gh run list --repo "${REPO}" --workflow build-ios.yml --limit 1 --json databaseId --jq '.[0].databaseId')
    if [ -z "${RUN_ID}" ]; then
        echo "No workflow runs found. Specify a run ID: $0 <run-id>"
        exit 1
    fi
fi

echo "Downloading ProbeTool.xcframework from run ${RUN_ID}..."
gh run download "${RUN_ID}" \
    --repo "${REPO}" \
    --name probetool-xcframework \
    --dir "${LIBS_DIR}"

echo "Done. xcframework extracted to ${LIBS_DIR}/"
