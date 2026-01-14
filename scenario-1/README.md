# Scenario 1: Customization Conflict After Non-Breaking TypeSpec Addition

## Overview

This scenario tests the tool's ability to detect and resolve duplicate field injection conflicts when a TypeSpec model gains a property that already exists in the code customization.

## Problem Description

- **Service team** adds optional property `operationId` to the `AnalyzeOperation` model in TypeSpec
- **Java customization** already injects this field manually via `clazz.addField("String", "operationId", ...)`
- **Result**: Duplicate field compilation error

## Files Involved

| File | Purpose |
|------|---------|
| `azure-rest-api-specs/.../DocumentIntelligence/models.tsp` | TypeSpec model definition |
| `azure-sdk-for-java/.../DocumentIntelligenceCustomizations.java` | Java customization that adds operationId |

## Setup

```bash
# Run setup script to modify TypeSpec
./setup.sh
```

This will:
1. Backup the original TypeSpec file
2. Add `operationId?: string;` to the `AnalyzeOperation` model
3. Display the conflicting customization code

## Reproduce the Error

After running setup, regenerate and build the SDK using `azsdk-cli`:

```bash
# Navigate to azure-rest-api-specs (where azsdk-cli MCP server is configured)
cd ../../azure-rest-api-specs

# Regenerate Java SDK from TypeSpec
azsdk pkg generate \
  --local-sdk-repo-path ../azure-sdk-for-java \
  --tsp-config-path specification/ai/DocumentIntelligence/tspconfig.yaml

# Build the SDK (expect failure)
azsdk pkg build \
  --package-path ../azure-sdk-for-java/sdk/documentintelligence/azure-ai-documentintelligence
```

Alternatively, if using the CLI directly:
```bash
cd ../../azure-sdk-tools/tools/azsdk-cli
dotnet run -- pkg generate \
  --local-sdk-repo-path ../../../azure-sdk-for-java \
  --tsp-config-path ../../../azure-rest-api-specs/specification/ai/DocumentIntelligence/tspconfig.yaml

dotnet run -- pkg build \
  --package-path ../../../azure-sdk-for-java/sdk/documentintelligence/azure-ai-documentintelligence
```

### Expected Error

```
[ERROR] Failed to execute goal org.apache.maven.plugins:maven-compiler-plugin:3.13.0:compile
.../AnalyzeOperationDetails.java:[178,20] variable operationId is already defined in class AnalyzeOperationDetails
```

## Expected Tool Resolution

### Phase A (TypeSpec)
- Analyze build failure
- Determine no TypeSpec changes needed (property intentionally added to spec)
- Forward issue to Phase B

### Phase B (Code Customization)
- Detect duplicate field injection in `DocumentIntelligenceCustomizations.java`
- Remove `clazz.addField("String", "operationId", ...)` on line 177
- Adjust related setter/getter methods to use generated field
- Rebuild SDK

## Validation Criteria

- [ ] Build completes with no errors (warnings acceptable)
- [ ] `operationId` field exists in generated code (from TypeSpec)
- [ ] `getResultId()` method still returns operationId
- [ ] Polling strategy correctly sets operationId

## Teardown

```bash
# Restore original state
./teardown.sh
```

## User Prompt for Testing

When testing with the customization tool, use this entry point:

```
Build failure in azure-sdk-for-java documentintelligence SDK:
variable operationId is already defined in class AnalyzeOperationDetails
```
