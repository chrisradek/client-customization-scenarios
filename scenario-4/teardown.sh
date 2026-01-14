#!/bin/bash
# Scenario 4: Hide Operation from Python SDK
# Teardown Script
#
# Restores files from backups created during setup.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

TYPESPEC_FILE="$WORKSPACE_ROOT/azure-rest-api-specs/specification/batch/Azure.Batch/client.tsp"
BACKUP_FILE="$TYPESPEC_FILE.backup"

echo "=== Scenario 4: Teardown ==="
echo ""

if [ -f "$BACKUP_FILE" ]; then
    cp "$BACKUP_FILE" "$TYPESPEC_FILE"
    rm "$BACKUP_FILE"
    echo "✓ Restored client.tsp from backup"
else
    echo "⚠ No backup file found at: $BACKUP_FILE"
    echo "  Nothing to restore"
fi

echo ""
echo "Teardown complete."
