# Scenario 1: Customization Conflict After Non-Breaking TypeSpec Addition

**Description:** Service team adds optional property `operationId` to TypeSpec, but Java customization already injects this field manually, causing duplicate field compilation error.

**Entry Point:** Build failure

**Problem:** TypeSpec now generates `operationId`, conflicting with existing `addField("operationId")` in `DocumentIntelligenceCustomizations.java`.

**Error:**

```
[ERROR] Failed to execute goal org.apache.maven.plugins:maven-compiler-plugin:3.13.0:compile
/azure-ai-documentintelligence/src/main/java/com/azure/ai/documentintelligence/models/AnalyzeOperationDetails.java:[178,20] variable operationId is already defined in class AnalyzeOperationDetails
```

**Workflow Execution:**

| Phase                           | Action                                                                                                   | Result                                                 |
| ------------------------------- | -------------------------------------------------------------------------------------------------------- | ------------------------------------------------------ |
| **Phase A: TypeSpec**           | Analyze build failure<br/>Determine no TypeSpec changes needed<br/>(property already exists in spec)     | No TypeSpec modifications<br/>Forward issue to Phase B |
| **Phase B: Code Customization** | Detect duplicate field injection<br/>Remove `addField("operationId")` from customization<br/>Rebuild SDK | Build succeeds<br/>Customization simplified            |

**Acceptance Criteria:**

- Build completes with no errors (warnings are acceptable)
- Duplicate field `addField("operationId")` is removed from customization class
- Generated code contains the `operationId` property from TypeSpec
- SDK functionality is preserved (property accessible and works as expected)

**Key Learning:** Non-breaking TypeSpec additions can break existing customizations that manually inject the same fields.

---

## Test Implementation

### Approach

Use the real `azure-rest-api-specs/specification/ai/DocumentIntelligence` TypeSpec project and `azure-sdk-for-java` SDK. Simulate the scenario by adding an `operationId` field to the TypeSpec model, which will conflict with the existing Java customization.

### Source Files

**TypeSpec Model (current state - no operationId):**
- `azure-rest-api-specs/specification/ai/DocumentIntelligence/models.tsp` (lines 452-468)
- Model `AnalyzeOperation` does NOT have `operationId` field

**Java Customization (adds operationId manually):**
- `azure-sdk-for-java/sdk/documentintelligence/azure-ai-documentintelligence/customization/src/main/java/DocumentIntelligenceCustomizations.java`
- Line 177: `clazz.addField("String", "operationId", Modifier.Keyword.PRIVATE);`

### Setup Steps

1. **Modify TypeSpec to add operationId field:**
   ```typespec
   @doc("Status and result of the analyze operation.")
   model AnalyzeOperation {
     @doc("Operation ID")
     operationId?: string;  // <-- ADD THIS LINE
     
     @doc("Operation status.  notStarted, running, succeeded, or failed")
     status: DocumentIntelligenceOperationStatus;
     // ... rest of model
   }
   ```

2. **Regenerate Java SDK:**
   ```bash
   cd azure-sdk-for-java
   # Run TypeSpec generation for documentintelligence
   ```

3. **Build Java SDK (expect failure):**
   ```bash
   cd azure-sdk-for-java/sdk/documentintelligence/azure-ai-documentintelligence
   mvn compile
   ```

### Expected Error

```
[ERROR] Failed to execute goal org.apache.maven.plugins:maven-compiler-plugin:3.13.0:compile
/azure-ai-documentintelligence/src/main/java/com/azure/ai/documentintelligence/models/AnalyzeOperationDetails.java:[178,20] variable operationId is already defined in class AnalyzeOperationDetails
```

### Expected Tool Resolution

**Phase A:** No TypeSpec changes needed (the field is intentionally added to spec)

**Phase B:** Remove the duplicate field injection from `DocumentIntelligenceCustomizations.java`:
- Remove line 177: `clazz.addField("String", "operationId", Modifier.Keyword.PRIVATE);`
- Update `setOperationId` method to reference the generated field instead of the injected one
- May need to adjust `AnalyzeOperationDetailsHelper` usage

### Validation

- [ ] Build completes with no errors after Phase B
- [ ] `operationId` field exists in generated `AnalyzeOperationDetails.java` (from TypeSpec)
- [ ] `getResultId()` method still works (returns the operationId)
- [ ] Polling strategy still sets operationId correctly
