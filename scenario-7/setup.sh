#!/bin/bash
# Scenario 7: Feature Request Requiring Code Customization (Manual Guidance)
#
# This is a MANUAL GUIDANCE scenario - TypeSpec cannot solve it.
# The scenario tests the tool's ability to recognize when TypeSpec has no
# applicable decorators and return guidance for code customizations instead.
#
# User Request: "Add operationId property to AnalyzeOperationDetails by parsing
#               it from the Operation-Location header during polling"
#
# Why TypeSpec Cannot Solve This:
# - No TypeSpec decorator supports LRO polling customization
# - No TypeSpec decorator can extract data from HTTP response headers
# - Runtime polling behavior requires code customizations
#
# No setup required - this scenario is for testing tool guidance behavior.

echo "Scenario 7: Manual Guidance for LRO Polling Customization"
echo "No setup required - this is a manual guidance scenario."
echo ""
echo "Test this scenario by providing the user prompt to the tool and verifying"
echo "it returns appropriate manual guidance instead of TypeSpec changes."
