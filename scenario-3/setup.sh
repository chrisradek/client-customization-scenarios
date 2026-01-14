#!/bin/bash
# Scenario 3: TypeSpec Rename Causing Customization Drift
# This script renames urlSource to sourceUrl in DocumentIntelligence TypeSpec

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
TYPESPEC_FILE="$REPO_ROOT/azure-rest-api-specs/specification/ai/DocumentIntelligence/models.tsp"
BACKUP_FILE="$TYPESPEC_FILE.backup"

echo "=== Scenario 3: TypeSpec Rename Causing Customization Drift ==="
echo ""

# Create backup
if [ ! -f "$BACKUP_FILE" ]; then
    cp "$TYPESPEC_FILE" "$BACKUP_FILE"
    echo "✓ Created backup: $BACKUP_FILE"
else
    echo "⚠ Backup already exists, skipping backup creation"
fi

# Rename urlSource to sourceUrl using Python for reliable replacement
python3 << EOF
import sys

typespec_file = "$TYPESPEC_FILE"

with open(typespec_file, 'r') as f:
    content = f.read()

# Check if already renamed
if 'sourceUrl?: url;' in content:
    print("⚠ TypeSpec already has sourceUrl (already set up)")
    sys.exit(0)

if 'urlSource?: url;' not in content:
    print("✗ Could not find 'urlSource?: url;' in TypeSpec file")
    sys.exit(1)

# Rename property: urlSource -> sourceUrl
# Also update the @doc reference
new_content = content.replace(
    '@doc("Document URL to analyze.  Either urlSource or base64Source must be specified.")\n  urlSource?: url;',
    '@doc("Document URL to analyze.  Either sourceUrl or base64Source must be specified.")\n  sourceUrl?: url;'
)

if new_content == content:
    print("✗ Replacement pattern did not match")
    sys.exit(1)

with open(typespec_file, 'w') as f:
    f.write(new_content)

print("✓ Renamed urlSource to sourceUrl in TypeSpec")
EOF

echo ""
echo "=== Setup Complete ==="
echo ""
echo "The TypeSpec now uses 'sourceUrl' instead of 'urlSource'."
echo "The Java customization still references 'setUrlSource', causing drift."
echo ""
echo "Next steps:"
echo "  1. Regenerate Java SDK (this will create setSourceUrl method)"
echo "  2. Build will succeed but customization logic silently fails"
echo "  3. Use azsdk-cli to detect and fix the customization drift"
echo ""
echo "To tear down: ./teardown.sh"
