#!/bin/bash
# Scenario 6: Create Python Subclient Architecture
# Teardown: Restore DocumentIntelligence client.tsp from backup

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "=== Scenario 6 Teardown ==="
echo ""

# Restore DocumentIntelligence client.tsp
CLIENT_TSP="$REPO_ROOT/azure-rest-api-specs/specification/ai/DocumentIntelligence/client.tsp"
BACKUP_FILE="$CLIENT_TSP.backup"

if [ -f "$BACKUP_FILE" ]; then
    cp "$BACKUP_FILE" "$CLIENT_TSP"
    rm "$BACKUP_FILE"
    echo "✓ Restored client.tsp from backup"
else
    echo "⚠ No backup found: $BACKUP_FILE"
    echo "  Nothing to restore"
fi

echo ""
echo "Teardown complete."
