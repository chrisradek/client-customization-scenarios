#!/bin/bash

# Scenario 8: Python Wrapper API Mismatch
# This script simulates a TypeSpec method rename that breaks Python customization

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SPEC_REPO="${SCRIPT_DIR}/../../azure-rest-api-specs"
PYTHON_SDK="${SCRIPT_DIR}/../../azure-sdk-for-python"

# Example: Face API TypeSpec file (adjust path as needed for your test)
TSP_FILE="${SPEC_REPO}/specification/ai/Face/routes.tsp"

echo "=== Python Wrapper API Mismatch Setup ==="
echo ""

# Check if TypeSpec file exists
if [ ! -f "$TSP_FILE" ]; then
    echo "Note: TypeSpec file not found at expected path."
    echo "This scenario uses azure-ai-vision-face as an example."
    echo ""
    echo "To test this scenario manually:"
    echo "1. Find a Python SDK with _patch.py customizations"
    echo "2. Rename a method in the corresponding TypeSpec"
    echo "3. Regenerate the SDK and observe the import error"
    echo ""
    exit 0
fi

# Backup original file
echo "1. Backing up original TypeSpec file..."
cp "$TSP_FILE" "${TSP_FILE}.backup"

# Simulate method rename: detectFromUrl -> detectFaceFromUrl
# This causes _detect_from_url -> _detect_face_from_url in generated Python
echo "2. Simulating method rename (detectFromUrl -> detectFaceFromUrl)..."
sed -i 's/detectFromUrl/detectFaceFromUrl/g' "$TSP_FILE"

echo ""
echo "=== Setup Complete ==="
echo ""
echo "The TypeSpec file has been modified to rename 'detectFromUrl' to 'detectFaceFromUrl'."
echo "This will cause the generated Python method to change from '_detect_from_url' to '_detect_face_from_url'."
echo ""
echo "Next steps:"
echo "  1. Regenerate the Python SDK:"
echo "     cd ${PYTHON_SDK}/sdk/face/azure-ai-vision-face"
echo "     tsp-client update"
echo ""
echo "  2. Try to import (expect NameError):"
echo "     python -c \"from azure.ai.vision.face.aio import FaceClient\""
echo "     # NameError: '_detect_from_url' is not defined"
echo ""
echo "  3. Run azsdk-cli to fix:"
echo "     dotnet run -- tsp client customized-update <commit> --package-path <path>"
echo ""
echo "To restore original state, run: ./teardown.sh"