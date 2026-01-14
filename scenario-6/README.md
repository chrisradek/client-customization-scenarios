# Scenario 6: Create Python Subclient Architecture

## Overview

This is a **user-prompt driven scenario** (Phase A only). The user requests a subclient architecture for the Python SDK, adding `@operationGroup` and `@clientInitialization` decorators to organize operations into subclients.

## Target Project

**DocumentIntelligence TypeSpec:** `azure-rest-api-specs/specification/ai/DocumentIntelligence/client.tsp`

This project already has two clients defined:
- `DocumentIntelligenceClient` - Document analysis operations
- `DocumentIntelligenceAdministrationClient` - Model and classifier management operations

The scenario tests adding `@operationGroup` decorators to create subclients within the administration client for Python.

## User Prompt

```
For Python SDK, add operation groups to DocumentIntelligenceAdministrationClient:
- A "Models" subclient for model operations
- A "Classifiers" subclient for classifier operations
```

## Reference Implementation

The Face TypeSpec provides a complete example of subclient architecture:

**File:** `azure-rest-api-specs/specification/ai/Face/client.tsp`

### Key Decorators

| Decorator | Purpose | Example |
|-----------|---------|---------|
| `@client` | Define a client class (can be scoped to languages) | `@client({ name: "FaceClient", service: Face })` |
| `@operationGroup` | Group operations into a logical subclient | `@operationGroup interface LargeFaceList { ... }` |
| `@clientInitialization` | Specify required parameters for client initialization | `@clientInitialization(LargeFaceListClientOptions, "csharp,java")` |

## Expected Tool Action

Modify `DocumentIntelligence/client.tsp` to add operation groups for Python:

```typespec
// Add within or after DocumentIntelligenceAdministrationClient definition

@operationGroup
interface Models {
  buildDocumentModel is DocumentModels.buildModel;
  composeModel is DocumentModels.composeModel;
  getModel is DocumentModels.getModel;
  listModels is DocumentModels.listModels;
  deleteModel is DocumentModels.deleteModel;
  // ... other model operations
}

@operationGroup
interface Classifiers {
  buildClassifier is DocumentClassifiers.buildClassifier;
  getClassifier is DocumentClassifiers.getClassifier;
  listClassifiers is DocumentClassifiers.listClassifiers;
  deleteClassifier is DocumentClassifiers.deleteClassifier;
  // ... other classifier operations
}
```

## azsdk-cli Commands

```bash
# Generate Python SDK from TypeSpec
azsdk pkg generate \
  --local-sdk-repo-path ../azure-sdk-for-python \
  --tsp-config-path specification/ai/DocumentIntelligence/tspconfig.yaml

# Build Python SDK
cd ../azure-sdk-for-python/sdk/documentintelligence/azure-ai-documentintelligence
pip install -e .
```

## Validation Criteria

- [ ] `@operationGroup` decorators added for Models and Classifiers
- [ ] SDK regenerates successfully with new architecture
- [ ] Build completes with no errors
- [ ] Python client has subclient accessors (e.g., `client.models`, `client.classifiers`)

## Key Learning

Complex client architecture can be achieved with TypeSpec decorators alone—no code customizations required.
