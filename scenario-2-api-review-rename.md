# Scenario 2: API Review Feedback Requiring Multi-Language Customizations

**Description:** API review requests renaming model `AIProjectConnectionEntraIDCredential` to use "Id" (not "ID") in .NET, requiring scoped TypeSpec changes.

**Entry Point:** API review feedback

**Problem:** Model name doesn't follow .NET casing conventions ("Id" vs "ID").

**Workflow Execution:**

| Phase                 | Action                                                                                                                        | Result                                                              |
| --------------------- | ----------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------- |
| **Phase A: TypeSpec** | Analyze feedback requirements<br/>Apply `@clientName` with proper scoping for .NET<br/>Regenerate .NET SDK<br/>Validate build | SDK regenerates successfully<br/>Build passes<br/>No Phase B needed |

**Acceptance Criteria:**

- `@clientName` decorator applied with correct scope (e.g., `"csharp"`)
- Model renamed only in .NET SDK (other languages unchanged)
- SDK regenerates successfully
- Build completes with no errors

**Key Learning:** API review naming feedback typically resolved with scoped `@clientName` decorators. Tool validates all affected language builds.

**Note:** Sample updates are out of scope for the customization workflow—sample errors are ignored during validation as they may require manual updates. Generated samples are automatically updated during regeneration; handwritten samples may require manual updates or use of `azsdk_package_samples_generate`. In this example, samples that reference `AIProjectConnectionEntraIDCredential` may require manual updates or regeneration using `azsdk_package_samples_generate`. Sample updates are out of scope for the customization workflow—samples are not validated during SDK builds.

---

## Test Implementation

### Approach

Use the real `azure-rest-api-specs/specification/ai/Azure.AI.Projects` TypeSpec project and `azure-sdk-for-net` SDK. Simulate the "before" state by modifying the `@clientName` decorator to use "ID" instead of "Id", then have the tool fix it based on API review feedback.

### Source Files

**TypeSpec Client Customizations (current state - correct "Id"):**
- `azure-rest-api-specs/specification/ai/Azure.AI.Projects/client.tsp` (lines 64-67)
- Currently uses correct casing: `"AIProjectConnectionEntraIdCredential"`

**TypeSpec Model:**
- `azure-rest-api-specs/specification/ai/Azure.AI.Projects/connections/models.tsp` (lines 68-73)
- Base model name: `EntraIDCredentials`

**.NET Generated API:**
- `azure-sdk-for-net/sdk/ai/Azure.AI.Projects/api/Azure.AI.Projects.netstandard2.0.cs`
- Class: `AIProjectConnectionEntraIdCredential`

### Setup Steps

1. **Modify TypeSpec to use incorrect casing (simulate "before" state):**
   ```typespec
   // In client.tsp, change:
   @@clientName(Azure.AI.Projects.EntraIDCredentials,
     "AIProjectConnectionEntraIDCredential",  // <-- Use "ID" instead of "Id"
     "csharp"
   );
   ```

2. **Regenerate .NET SDK:**
   ```bash
   cd azure-sdk-for-net
   # Run TypeSpec generation for Azure.AI.Projects
   ```

3. **Simulate API Review Feedback (user prompt):**
   ```
   "API review feedback: Rename AIProjectConnectionEntraIDCredential to use 'Id' instead of 'ID' to follow .NET naming conventions"
   ```

### Expected Tool Resolution

**Phase A:** Apply `@clientName` decorator with correct casing:
```typespec
@@clientName(Azure.AI.Projects.EntraIDCredentials,
  "AIProjectConnectionEntraIdCredential",  // <-- Fixed to "Id"
  "csharp"
);
```

**Phase B:** Not needed (TypeSpec change is sufficient)

### Validation

- [ ] `@clientName` decorator updated with "Id" casing
- [ ] Only .NET SDK affected (other languages unchanged)
- [ ] SDK regenerates successfully
- [ ] Build completes with no errors
- [ ] Generated class name is `AIProjectConnectionEntraIdCredential`

### Alternative Test Approach

If modifying existing code is not desired, create a minimal TypeSpec project in `scenarios/scenario-2/`:
```
scenarios/scenario-2/
├── main.tsp
├── client.tsp
└── tspconfig.yaml
```

With a simple model that has incorrect "ID" casing, then run the tool to fix it.
