#!/bin/bash
# Scenario 6: Create Python Subclient Architecture
# This is a user-prompt driven scenario (Phase A only)
# Setup: Create backup of DocumentIntelligence client.tsp which will be modified

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "=== Scenario 6: Create Python Subclient Architecture ==="
echo "This is a user-prompt driven scenario."
echo ""

# DocumentIntelligence client.tsp will be modified to add subclient architecture for Python
CLIENT_TSP="$REPO_ROOT/azure-rest-api-specs/specification/ai/DocumentIntelligence/client.tsp"
BACKUP_FILE="$CLIENT_TSP.backup"

if [ ! -f "$CLIENT_TSP" ]; then
    echo "✗ TypeSpec file not found: $CLIENT_TSP"
    exit 1
fi

echo "✓ TypeSpec file found: $CLIENT_TSP"
echo ""

# Create backup
if [ ! -f "$BACKUP_FILE" ]; then
    cp "$CLIENT_TSP" "$BACKUP_FILE"
    echo "✓ Created backup: $BACKUP_FILE"
else
    echo "⚠ Backup already exists: $BACKUP_FILE"
fi

echo ""
echo "Reference for subclient patterns:"
echo "  Face client.tsp demonstrates @client, @operationGroup, @clientInitialization"
echo "  Location: azure-rest-api-specs/specification/ai/Face/client.tsp"
echo ""
echo "Setup complete. Ready for user prompt."
