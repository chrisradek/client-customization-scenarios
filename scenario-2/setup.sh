#!/bin/bash
# Scenario 2: API Review Rename - Setup Script
# Removes @@clientName decorator for EntraIDCredentials to simulate missing rename

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
CLIENT_TSP="$REPO_ROOT/azure-rest-api-specs/specification/ai/Azure.AI.Projects/client.tsp"
BACKUP_FILE="$CLIENT_TSP.backup"

echo "=== Scenario 2: API Review Rename - Setup ==="
echo "Removing @@clientName decorator for EntraIDCredentials from client.tsp"

# Backup original file
if [ ! -f "$BACKUP_FILE" ]; then
    cp "$CLIENT_TSP" "$BACKUP_FILE"
    echo "Created backup at: $BACKUP_FILE"
else
    echo "Backup already exists at: $BACKUP_FILE"
fi

# Use Python for reliable text replacement
python3 -c "
import sys
import re

client_tsp = '$CLIENT_TSP'

with open(client_tsp, 'r') as f:
    content = f.read()

# Remove the entire @@clientName block for EntraIDCredentials (spans multiple lines)
# Pattern matches:
#   @@clientName(Azure.AI.Projects.EntraIDCredentials,
#     \"AIProjectConnectionEntraIdCredential\",
#     \"csharp\"
#   );
pattern = r'@@clientName\(Azure\.AI\.Projects\.EntraIDCredentials,\s*\"AIProjectConnectionEntraIdCredential\",\s*\"csharp\"\s*\);\n'

if re.search(pattern, content):
    content = re.sub(pattern, '', content)
    with open(client_tsp, 'w') as f:
        f.write(content)
    print('Successfully removed @@clientName decorator for EntraIDCredentials')
elif 'EntraIDCredentials' not in content or 'AIProjectConnectionEntraIdCredential' not in content:
    print('File already has the @@clientName decorator removed')
else:
    print('ERROR: Could not match the expected @@clientName pattern in client.tsp', file=sys.stderr)
    sys.exit(1)
"

echo ""
echo "Setup complete. The @@clientName decorator for EntraIDCredentials has been removed."
echo "This simulates a missing rename that should be flagged by API review (AZC0012)."
