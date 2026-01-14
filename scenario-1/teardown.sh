#!/bin/bash
# Scenario 1: Teardown Script
# 
# This script restores the original state after testing scenario 1:
# - Restores the original TypeSpec file from backup
# - Optionally cleans up generated files
#
# Usage: ./teardown.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"

# Paths
TYPESPEC_FILE="$WORKSPACE_DIR/azure-rest-api-specs/specification/ai/DocumentIntelligence/models.tsp"
BACKUP_FILE="$TYPESPEC_FILE.backup"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Scenario 1 Teardown ===${NC}"
echo "Restoring original state..."
echo ""

# Step 1: Restore TypeSpec file from backup
echo -e "${YELLOW}Step 1: Restoring TypeSpec file...${NC}"
if [ -f "$BACKUP_FILE" ]; then
    cp "$BACKUP_FILE" "$TYPESPEC_FILE"
    rm "$BACKUP_FILE"
    echo -e "${GREEN}✓ TypeSpec file restored from backup${NC}"
else
    echo -e "${YELLOW}  No backup file found, attempting to remove added lines...${NC}"
    
    # Use Python to remove the added operationId field
    python3 -c "
import sys

typespec_file = '$TYPESPEC_FILE'

with open(typespec_file, 'r') as f:
    lines = f.readlines()

# Remove the operationId field we added
new_lines = []
skip_next = 0

for i, line in enumerate(lines):
    if skip_next > 0:
        skip_next -= 1
        continue
    
    # Check if this is the operationId doc we added
    if '@doc(\"Operation ID\")' in line:
        # Skip this line and the next two (operationId field and blank line)
        skip_next = 2
        print(f'Removed operationId field at line {i+1}')
        continue
    
    new_lines.append(line)

with open(typespec_file, 'w') as f:
    f.writelines(new_lines)

print('TypeSpec file cleaned up')
"
fi
echo ""

# Step 2: Verify restoration
echo -e "${YELLOW}Step 2: Verifying restoration...${NC}"
echo "Current AnalyzeOperation model:"
echo "---"
grep -A10 "^model AnalyzeOperation {" "$TYPESPEC_FILE" | head -15
echo "---"
echo ""

echo -e "${GREEN}=== Teardown Complete ===${NC}"
echo ""
echo "The TypeSpec file has been restored to its original state."
echo "You may need to regenerate the SDK if you want to reset generated files."
echo ""
