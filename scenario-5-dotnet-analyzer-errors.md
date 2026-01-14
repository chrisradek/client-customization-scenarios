# Scenario 5: .NET Build Errors from Analyzer

**Description:** .NET analyzer errors (AZC0030, AZC0012) for naming violations: model ends with "Parameters", type name "Tasks" too generic.

**Entry Point:** Build failure (.NET analyzer)

**Errors:**

- `AZC0030`: Model name ends with 'Parameters'
- `AZC0012`: Type name 'Tasks' too generic

**Workflow Execution:**

| Phase                 | Action                                                                                                                                            | Result                                                                                             |
| --------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------- |
| **Phase A: TypeSpec** | Parse analyzer error messages<br/>Apply `@clientName` decorators for .NET<br/>Rename problematic types<br/>Regenerate .NET SDK<br/>Validate build | SDK regenerates with new names<br/>Analyzer errors resolved<br/>Build passes<br/>No Phase B needed |

**Acceptance Criteria:**

- `@clientName` decorators applied for all analyzer violations (AZC0030, AZC0012, etc.)
- All .NET analyzer errors resolved
- Build completes with no errors
- Renamed types follow .NET naming conventions

**Key Learning:** .NET analyzer errors resolved with scoped `@clientName` decorators, no code customizations required.

---

## Test Implementation

### Approach

Use the real `azure-rest-api-specs/specification/ai/Azure.AI.Projects` TypeSpec project and `azure-sdk-for-net` SDK. This project already demonstrates fixing .NET analyzer errors using `@clientName` decorators.

For testing, simulate the "before" state by removing the `@clientName` decorators for generic names, then have the tool fix the analyzer errors.

### Source Files

**TypeSpec with csharp-scoped @clientName (existing fixes):**
- `azure-rest-api-specs/specification/ai/Azure.AI.Projects/client.tsp`
- Line 26: `@@clientName(Azure.AI.Projects.Sku, "ModelDeploymentSku");` - fixes AZC0012
- Line 37: `@@clientName(Azure.AI.Projects.Connection, "AIProjectConnection", "csharp");` - fixes AZC0012
- Line 38: `@@clientName(Azure.AI.Projects.Deployment, "AIProjectDeployment", "csharp");` - fixes AZC0012
- Line 47: `@@clientName(Azure.AI.Projects.Index, "AIProjectIndex", "csharp");` - fixes AZC0012

**TypeSpec Models (generic names that trigger errors):**
- `deployments/models.tsp`: `model Sku { ... }`, `model Deployment { ... }`
- `indexes/models.tsp`: `model Index { ... }`
- `connections/models.tsp`: `model Connection { ... }`

**.NET Analyzer Rules:**
- `AZC0012`: Avoid single word type names (e.g., "Sku", "Index", "Connection")
- `AZC0030`: Improper model name suffix (e.g., names ending with "Parameters")

### Setup Steps

1. **Remove @clientName decorators (simulate "before" state):**
   ```bash
   # Comment out or remove lines 26, 37, 38, 47 in client.tsp
   ```

2. **Regenerate .NET SDK:**
   ```bash
   cd azure-sdk-for-net
   # Run TypeSpec generation for Azure.AI.Projects
   ```

3. **Build .NET SDK (expect analyzer errors):**
   ```bash
   cd azure-sdk-for-net/sdk/ai/Azure.AI.Projects
   dotnet build
   ```

### Expected Errors

```
error AZC0012: Avoid single word type names: 'Sku'
error AZC0012: Avoid single word type names: 'Index'
error AZC0012: Avoid single word type names: 'Connection'
error AZC0012: Avoid single word type names: 'Deployment'
```

### Expected Tool Resolution

**Phase A:** Parse analyzer error messages and apply `@clientName` decorators:
```typespec
@@clientName(Azure.AI.Projects.Sku, "ModelDeploymentSku");
@@clientName(Azure.AI.Projects.Connection, "AIProjectConnection", "csharp");
@@clientName(Azure.AI.Projects.Deployment, "AIProjectDeployment", "csharp");
@@clientName(Azure.AI.Projects.Index, "AIProjectIndex", "csharp");
```

**Phase B:** Not needed (TypeSpec decorators are sufficient)

### Validation

- [ ] `@clientName` decorators applied for all analyzer violations
- [ ] All .NET analyzer errors resolved (AZC0012, AZC0030)
- [ ] Build completes with no errors
- [ ] Renamed types follow .NET naming conventions
- [ ] Other languages unaffected (if scope is csharp-specific)

### Alternative: Create Minimal Test Project

Create a TypeSpec project in `scenarios/scenario-5/` with models that trigger analyzer errors:
```typespec
model Sku { ... }  // AZC0012
model Tasks { ... }  // AZC0012
model CreateParameters { ... }  // AZC0030
```
