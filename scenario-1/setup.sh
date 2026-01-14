#!/bin/bash
# Scenario 1: Customization Conflict After Non-Breaking TypeSpec Addition
# 
# This script sets up the conditions for testing scenario 1:
# - Adds operationId field to the AnalyzeOperation model in TypeSpec
# - This will conflict with the existing Java customization that manually adds the same field
#
# Prerequisites:
# - azure-rest-api-specs repo cloned at ../azure-rest-api-specs
# - azure-sdk-for-java repo cloned at ../azure-sdk-for-java
#
# Usage: ./setup.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"

# Paths
TYPESPEC_FILE="$WORKSPACE_DIR/azure-rest-api-specs/specification/ai/DocumentIntelligence/models.tsp"
JAVA_SDK_DIR="$WORKSPACE_DIR/azure-sdk-for-java/sdk/documentintelligence/azure-ai-documentintelligence"
CUSTOMIZATION_FILE="$JAVA_SDK_DIR/customization/src/main/java/DocumentIntelligenceCustomizations.java"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Scenario 1 Setup ===${NC}"
echo "Setting up: Customization Conflict After Non-Breaking TypeSpec Addition"
echo ""

# Verify prerequisites
echo -e "${YELLOW}Checking prerequisites...${NC}"

if [ ! -f "$TYPESPEC_FILE" ]; then
    echo -e "${RED}ERROR: TypeSpec file not found at $TYPESPEC_FILE${NC}"
    exit 1
fi

if [ ! -f "$CUSTOMIZATION_FILE" ]; then
    echo -e "${RED}ERROR: Customization file not found at $CUSTOMIZATION_FILE${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Prerequisites verified${NC}"
echo ""

# Step 1: Backup original TypeSpec file
echo -e "${YELLOW}Step 1: Backing up original TypeSpec file...${NC}"
BACKUP_FILE="$TYPESPEC_FILE.backup"
if [ ! -f "$BACKUP_FILE" ]; then
    cp "$TYPESPEC_FILE" "$BACKUP_FILE"
    echo -e "${GREEN}✓ Backup created at $BACKUP_FILE${NC}"
else
    echo -e "${YELLOW}  Backup already exists, skipping${NC}"
fi
echo ""

# Step 2: Modify TypeSpec to add operationId field to AnalyzeOperation model
echo -e "${YELLOW}Step 2: Adding operationId field to AnalyzeOperation model...${NC}"

# Use Python for reliable multi-line editing
python3 -c "
import sys
typespec_file = '$TYPESPEC_FILE'

with open(typespec_file, 'r') as f:
    lines = f.readlines()

# Check if operationId already added
for line in lines:
    if 'operationId?: string;' in line:
        print('operationId field already exists in file')
        sys.exit(0)

# Find the AnalyzeOperation model and insert operationId field
new_lines = []
field_added = False

for i, line in enumerate(lines):
    new_lines.append(line)
    
    # Check if we're entering the AnalyzeOperation model
    if 'model AnalyzeOperation {' in line and not field_added:
        # Add the operationId field right after the opening brace
        new_lines.append('  @doc(\"Operation ID\")\n')
        new_lines.append('  operationId?: string;\n')
        new_lines.append('\n')
        field_added = True
        print(f'Added operationId field after line {i+1}')

with open(typespec_file, 'w') as f:
    f.writelines(new_lines)

if field_added:
    print('TypeSpec file modified successfully')
else:
    print('WARNING: Could not find model AnalyzeOperation in file')
    sys.exit(1)
"
echo ""

# Step 3: Display the modified model
echo -e "${YELLOW}Step 3: Verifying modification...${NC}"
echo "Modified AnalyzeOperation model:"
echo "---"
grep -A15 "^model AnalyzeOperation {" "$TYPESPEC_FILE" | head -20
echo "---"
echo ""

# Step 4: Show current customization that will conflict
echo -e "${YELLOW}Step 4: Showing conflicting customization code...${NC}"
echo "The following customization adds operationId field (will conflict):"
echo "---"
grep -n "operationId" "$CUSTOMIZATION_FILE" | head -10
echo "---"
echo ""

# Step 5: Instructions for next steps
echo -e "${GREEN}=== Setup Complete ===${NC}"
echo ""
echo "Next steps to reproduce the scenario:"
echo ""
echo "1. Regenerate Java SDK using azsdk-cli:"
echo "   cd $WORKSPACE_DIR/azure-rest-api-specs"
echo "   azsdk pkg generate \\"
echo "     --local-sdk-repo-path $WORKSPACE_DIR/azure-sdk-for-java \\"
echo "     --tsp-config-path specification/ai/DocumentIntelligence/tspconfig.yaml"
echo ""
echo "2. Build the SDK (expect failure):"
echo "   azsdk pkg build \\"
echo "     --package-path $JAVA_SDK_DIR"
echo ""
echo "3. Expected error:"
echo "   variable operationId is already defined in class AnalyzeOperationDetails"
echo ""
echo "4. To restore original state, run:"
echo "   ./teardown.sh"
echo ""
