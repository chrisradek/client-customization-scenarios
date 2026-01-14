#!/bin/bash
# Scenario 3: Teardown
# Restores the original TypeSpec file from backup

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
TYPESPEC_FILE="$REPO_ROOT/azure-rest-api-specs/specification/ai/DocumentIntelligence/models.tsp"
BACKUP_FILE="$TYPESPEC_FILE.backup"

echo "=== Scenario 3: Teardown ==="
echo ""

if [ -f "$BACKUP_FILE" ]; then
    cp "$BACKUP_FILE" "$TYPESPEC_FILE"
    rm "$BACKUP_FILE"
    echo "✓ Restored original TypeSpec from backup"
else
    echo "⚠ No backup file found at: $BACKUP_FILE"
    echo "  Attempting to restore urlSource manually..."
    
    python3 << EOF
import sys

typespec_file = "$TYPESPEC_FILE"

with open(typespec_file, 'r') as f:
    content = f.read()

if 'urlSource?: url;' in content:
    print("✓ TypeSpec already has urlSource (already torn down)")
    sys.exit(0)

if 'sourceUrl?: url;' not in content:
    print("✗ Could not find 'sourceUrl?: url;' in TypeSpec file")
    sys.exit(1)

# Restore original property name
new_content = content.replace(
    '@doc("Document URL to analyze.  Either sourceUrl or base64Source must be specified.")\n  sourceUrl?: url;',
    '@doc("Document URL to analyze.  Either urlSource or base64Source must be specified.")\n  urlSource?: url;'
)

if new_content == content:
    print("✗ Restoration pattern did not match")
    sys.exit(1)

with open(typespec_file, 'w') as f:
    f.write(new_content)

print("✓ Restored urlSource in TypeSpec")
EOF
fi

echo ""
echo "=== Teardown Complete ==="
