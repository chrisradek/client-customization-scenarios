# Scenario 3: TypeSpec Rename Causing Customization Drift

## Overview

This scenario demonstrates what happens when a TypeSpec property is renamed, but the SDK customization code still references the old name. The customization "drifts" out of sync with the generated code.

## The Problem

- **TypeSpec Change**: Property `urlSource` is renamed to `sourceUrl` in `AnalyzeDocumentRequest`
- **Java Customization**: Still references `setUrlSource` method (line 148 of DocumentIntelligenceCustomizations.java)
- **Result**: Customization logic silently fails (the `forEach` operates on an empty collection)

## Files Involved

| File | Description |
|------|-------------|
| `azure-rest-api-specs/specification/ai/DocumentIntelligence/models.tsp` | TypeSpec model with renamed property |
| `azure-sdk-for-java/sdk/documentintelligence/azure-ai-documentintelligence/customization/src/main/java/DocumentIntelligenceCustomizations.java` | Java customization referencing old method name |

## Setup

```bash
# Apply the TypeSpec rename (urlSource -> sourceUrl)
./setup.sh
```

This will:
1. Create a backup of the original TypeSpec file
2. Rename `urlSource` to `sourceUrl` in `models.tsp`

## Expected Behavior

After setup, the Java customization at line 148:
```java
clazz.getMethodsByName("setUrlSource").forEach(NodeWithModifiers::setModifiers);
```

Will no longer find `setUrlSource` (it's now `setSourceUrl`), so the `forEach` does nothing.

## Using azsdk-cli to Detect and Fix

### Step 1: Regenerate the Java SDK

```bash
cd azure-sdk-for-java
# Run TypeSpec generation for documentintelligence
./eng/scripts/typespec/regenerate.sh sdk/documentintelligence/azure-ai-documentintelligence
```

### Step 2: Build and Observe

```bash
cd azure-sdk-for-java/sdk/documentintelligence/azure-ai-documentintelligence
mvn compile
```

The build may succeed, but the customization logic is broken (silently fails).

### Step 3: Detect Drift with azsdk-cli

```bash
# Analyze customization drift
azsdk-cli customization analyze \
  --sdk-path azure-sdk-for-java/sdk/documentintelligence/azure-ai-documentintelligence \
  --spec-path azure-rest-api-specs/specification/ai/DocumentIntelligence

# Check for renamed methods/properties
azsdk-cli customization check-references \
  --customization-file azure-sdk-for-java/sdk/documentintelligence/azure-ai-documentintelligence/customization/src/main/java/DocumentIntelligenceCustomizations.java
```

### Step 4: Fix the Customization

Update line 148 in `DocumentIntelligenceCustomizations.java`:

```java
// Before (broken):
clazz.getMethodsByName("setUrlSource").forEach(NodeWithModifiers::setModifiers);

// After (fixed):
clazz.getMethodsByName("setSourceUrl").forEach(NodeWithModifiers::setModifiers);
```

Or use azsdk-cli:
```bash
azsdk-cli customization fix \
  --sdk-path azure-sdk-for-java/sdk/documentintelligence/azure-ai-documentintelligence \
  --rename setUrlSource:setSourceUrl
```

### Step 5: Rebuild and Verify

```bash
cd azure-sdk-for-java/sdk/documentintelligence/azure-ai-documentintelligence
mvn compile
```

## Teardown

```bash
# Restore original TypeSpec
./teardown.sh
```

## Key Learnings

1. **Silent Failures**: Not all customization drift causes build failures. `getMethodsByName()` returns an empty collection if the method doesn't exist.
2. **Two-Phase Resolution**: 
   - Phase A: TypeSpec rename is intentional (no TypeSpec changes needed)
   - Phase B: Update customization to reference the new method name
3. **Validation**: After fixing, verify that the customization logic actually executes on the renamed method.

## Acceptance Criteria

- [ ] TypeSpec regeneration completes successfully
- [ ] All references to `setUrlSource` updated to `setSourceUrl` in customization
- [ ] Build completes with no errors
- [ ] Customization logic applies correctly (method modifiers are updated)
