# Scenario 5: .NET Build Errors from Analyzer

## Overview

This scenario simulates .NET analyzer errors (AZC0012) caused by generic model names
like "Sku", "Connection", "Deployment", and "Index". The setup script removes the
`@clientName` decorators that fix these naming issues.

## Expected Errors After Regeneration

After running `setup.sh` and regenerating the .NET SDK, you should see:

```
error AZC0012: Avoid single word type names: 'Sku'
error AZC0012: Avoid single word type names: 'Connection'
error AZC0012: Avoid single word type names: 'Deployment'
error AZC0012: Avoid single word type names: 'Index'
```

## Usage

### 1. Setup (Introduce Errors)

```bash
./setup.sh
```

This comments out `@clientName` decorators in `client.tsp` for:
- `Azure.AI.Projects.Sku` → "ModelDeploymentSku"
- `Azure.AI.Projects.Connection` → "AIProjectConnection" (csharp)
- `Azure.AI.Projects.Deployment` → "AIProjectDeployment" (csharp)
- `Azure.AI.Projects.Index` → "AIProjectIndex" (csharp)

### 2. Regenerate .NET SDK

```bash
cd ../../azure-sdk-for-net

azsdk-cli generate from-tsp \
  --tsp-config ../azure-rest-api-specs/specification/ai/Azure.AI.Projects/tspconfig.yaml \
  --repo-root .
```

### 3. Build .NET SDK (Expect Errors)

```bash
cd sdk/ai/Azure.AI.Projects
dotnet build
```

### 4. Teardown (Restore Original)

```bash
./teardown.sh
```

## Expected Tool Resolution

The tool should resolve AZC0012 errors by adding `@clientName` decorators in `client.tsp`:

```typespec
@@clientName(Azure.AI.Projects.Sku, "ModelDeploymentSku");
@@clientName(Azure.AI.Projects.Connection, "AIProjectConnection", "csharp");
@@clientName(Azure.AI.Projects.Deployment, "AIProjectDeployment", "csharp");
@@clientName(Azure.AI.Projects.Index, "AIProjectIndex", "csharp");
```

## Key Paths

| Resource | Path |
|----------|------|
| TypeSpec | `azure-rest-api-specs/specification/ai/Azure.AI.Projects/client.tsp` |
| .NET SDK | `azure-sdk-for-net/sdk/ai/Azure.AI.Projects` |

## Validation Checklist

- [ ] `@clientName` decorators applied for all analyzer violations
- [ ] All .NET analyzer errors resolved (AZC0012)
- [ ] Build completes with no errors
- [ ] Renamed types follow .NET naming conventions
- [ ] Other languages unaffected (csharp-scoped decorators)

## Key Learning

.NET analyzer errors are resolved with scoped `@clientName` decorators in TypeSpec.
No Phase B code customizations are required.
