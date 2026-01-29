#!/bin/bash

# Scenario 8: Python Wrapper API Mismatch - Teardown
# Restores original TypeSpec file

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SPEC_REPO="${SCRIPT_DIR}/../../azure-rest-api-specs"

TSP_FILE="${SPEC_REPO}/specification/ai/Face/routes.tsp"
BACKUP_FILE="${TSP_FILE}.backup"

echo "=== Python Wrapper API Mismatch Teardown ==="
echo ""

if [ -f "$BACKUP_FILE" ]; then
    echo "Restoring original TypeSpec file..."
    mv "$BACKUP_FILE" "$TSP_FILE"
    echo "Done. Original TypeSpec file restored."
else
    echo "No backup file found at: $BACKUP_FILE"
    echo "Nothing to restore."
fi