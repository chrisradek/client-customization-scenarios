#!/bin/bash
# Scenario 2: API Review Rename - Teardown Script
# Restores client.tsp from backup

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
CLIENT_TSP="$REPO_ROOT/azure-rest-api-specs/specification/ai/Azure.AI.Projects/client.tsp"
BACKUP_FILE="$CLIENT_TSP.backup"

echo "=== Scenario 2: API Review Rename - Teardown ==="

if [ -f "$BACKUP_FILE" ]; then
    cp "$BACKUP_FILE" "$CLIENT_TSP"
    rm "$BACKUP_FILE"
    echo "Restored client.tsp from backup"
    echo "Removed backup file"
else
    echo "No backup file found at: $BACKUP_FILE"
    echo "Nothing to restore"
fi

echo ""
echo "Teardown complete."
