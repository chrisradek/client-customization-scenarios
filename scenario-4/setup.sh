#!/bin/bash
# Scenario 4: Hide Operation from Python SDK
# Setup Script
#
# This is a USER-PROMPT driven scenario (Phase A only).
# No modifications are made - the user prompt triggers the workflow.
# We create backups of files that may be modified so teardown can restore them.
#
# The scenario tests adding @access decorator to hide an operation from Python.
# Reference: azure-rest-api-specs/specification/batch/Azure.Batch/client.tsp (lines 172-188)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

TYPESPEC_FILE="$WORKSPACE_ROOT/azure-rest-api-specs/specification/batch/Azure.Batch/client.tsp"
BACKUP_FILE="$TYPESPEC_FILE.backup"

echo "=== Scenario 4: Hide Operation from Python SDK ==="
echo ""
echo "This is a user-prompt driven scenario. No setup modifications needed."
echo ""

# Create backup of files that may be modified during testing
if [ -f "$TYPESPEC_FILE" ]; then
    if [ ! -f "$BACKUP_FILE" ]; then
        cp "$TYPESPEC_FILE" "$BACKUP_FILE"
        echo "✓ Created backup: $BACKUP_FILE"
    else
        echo "⚠ Backup already exists, skipping backup creation"
    fi
else
    echo "⚠ TypeSpec file not found: $TYPESPEC_FILE"
fi

echo ""
echo "User Prompt to Test:"
echo "  \"Remove get_task_file_properties from Python SDK public API\""
echo ""
echo "Expected Tool Action:"
echo "  Add @@access(Azure.Batch.Tasks.getTaskFileProperties, Access.internal, \"python\");"
echo "  to azure-rest-api-specs/specification/batch/Azure.Batch/client.tsp"
echo ""
echo "Reference Example (already exists in Batch):"
echo "  File: azure-rest-api-specs/specification/batch/Azure.Batch/client.tsp"
echo "  Lines 172-188 show existing @access decorators for Python"
echo ""
echo "Setup complete. Ready for testing."
