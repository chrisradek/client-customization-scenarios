#!/bin/bash
# Scenario 5 Setup: Remove @clientName decorators to trigger AZC0012 errors
# This removes @clientName decorators for generic model names (Sku, Connection, Deployment, Index)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
CLIENT_TSP="$REPO_ROOT/azure-rest-api-specs/specification/ai/Azure.AI.Projects/client.tsp"
BACKUP_FILE="$CLIENT_TSP.backup"

echo "=== Scenario 5 Setup: .NET Analyzer Errors (AZC0012) ==="

# Create backup
if [ ! -f "$BACKUP_FILE" ]; then
    cp "$CLIENT_TSP" "$BACKUP_FILE"
    echo "✓ Created backup: $BACKUP_FILE"
else
    echo "⚠ Backup already exists: $BACKUP_FILE"
fi

# Use Python for reliable text replacement
python3 << EOF
import re

client_tsp = "$CLIENT_TSP"

# Read the file
with open(client_tsp, 'r') as f:
    content = f.read()

# Lines to remove (decorators that fix generic names)
patterns_to_remove = [
    r'@@clientName\(Azure\.AI\.Projects\.Sku, "ModelDeploymentSku"\);\n',
    r'@@clientName\(Azure\.AI\.Projects\.Connection, "AIProjectConnection", "csharp"\);\n',
    r'@@clientName\(Azure\.AI\.Projects\.Deployment, "AIProjectDeployment", "csharp"\);\n',
    r'@@clientName\(Azure\.AI\.Projects\.Index, "AIProjectIndex", "csharp"\);\n',
]

modified = content
for pattern in patterns_to_remove:
    if re.search(pattern, modified):
        modified = re.sub(pattern, '', modified)
        print(f"Removed: {pattern[:50]}...")

# Write the modified content
with open(client_tsp, 'w') as f:
    f.write(modified)

print("Done modifying client.tsp")
EOF

echo ""
echo "=== Setup Complete ==="
echo ""
echo "Next steps:"
echo "1. Regenerate .NET SDK:"
echo "   cd $REPO_ROOT/azure-sdk-for-net"
echo "   azsdk-cli generate from-tsp \\"
echo "     --tsp-config $REPO_ROOT/azure-rest-api-specs/specification/ai/Azure.AI.Projects/tspconfig.yaml \\"
echo "     --repo-root $REPO_ROOT/azure-sdk-for-net"
echo ""
echo "2. Build .NET SDK (expect AZC0012 errors):"
echo "   cd $REPO_ROOT/azure-sdk-for-net/sdk/ai/Azure.AI.Projects"
echo "   dotnet build"
echo ""
echo "Expected errors:"
echo "  - AZC0012: Avoid single word type names: 'Sku'"
echo "  - AZC0012: Avoid single word type names: 'Connection'"
echo "  - AZC0012: Avoid single word type names: 'Deployment'"
echo "  - AZC0012: Avoid single word type names: 'Index'"
