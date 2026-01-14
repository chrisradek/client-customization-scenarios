# Scenario 3: TypeSpec Rename Causing Customization Drift

**Description:** Service team renames property `displayName` → `name` in TypeSpec. Java customization still references old name `getField("displayName")`, causing "cannot find symbol" error.

**Entry Point:** Build failure after regeneration

**Problem:** Customization references non-existent field after TypeSpec rename.

**Error:**

```
cannot find symbol: method getField(String)
Note: Field 'displayName' no longer exists in generated model
```

**Workflow Execution:**

| Phase                           | Action                                                                                                                       | Result                                                                                                                              |
| ------------------------------- | ---------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------- |
| **Phase A: TypeSpec**           | Regenerate SDK with updated TypeSpec<br/>Rename is intentional and correct<br/>No TypeSpec changes needed from SDK developer | SDK regenerated successfully<br/>Generated model now has `name` instead of `displayName`<br/>Build fails due to customization drift |
| **Phase B: Code Customization** | Detect reference to non-existent field `displayName`<br/>Update customization to reference `name`<br/>Rebuild SDK            | Build succeeds<br/>Customization aligned with new property name                                                                     |

**Acceptance Criteria:**

- TypeSpec regeneration completes successfully
- All references to old property name `displayName` updated to `name` in customization files (validated in all locations)
- Build completes with no errors
- SDK functionality is preserved (property accessible with new name)

**Key Learning:** Non-breaking TypeSpec renames break customizations referencing old names. Both phases needed to align spec and customization code.

---

## Test Implementation

### Approach

Use the real `azure-rest-api-specs/specification/ai/DocumentIntelligence` TypeSpec project and `azure-sdk-for-java` SDK. Simulate the scenario by renaming a property in TypeSpec (e.g., `urlSource` → `sourceUrl`), which will break the Java customization that references the old method name.

### Source Files

**TypeSpec Model:**
- `azure-rest-api-specs/specification/ai/DocumentIntelligence/models.tsp` (line 369)
- Property: `urlSource?: url;` in `AnalyzeDocumentRequest`

**Java Customization (references old name):**
- `azure-sdk-for-java/sdk/documentintelligence/azure-ai-documentintelligence/customization/src/main/java/DocumentIntelligenceCustomizations.java`
- Line 148: `clazz.getMethodsByName("setUrlSource").forEach(NodeWithModifiers::setModifiers);`

### Setup Steps

1. **Rename property in TypeSpec:**
   ```typespec
   // In models.tsp, change:
   @doc("Document URL to analyze.  Either sourceUrl or base64Source must be specified.")
   sourceUrl?: url;  // <-- Renamed from urlSource
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

The build won't explicitly fail on `getMethodsByName("setUrlSource")` because that API returns an empty collection if no method is found. However, the customization logic that depends on finding that method won't execute, potentially causing:
- Missing modifier changes on the generated method
- API surface issues (method visibility not updated as expected)
- Or if there's strict validation, a runtime/compile error

A more explicit error would occur if the customization used:
```java
clazz.getMethodsByName("setUrlSource").get(0).setModifiers(...);  // IndexOutOfBoundsException
```

### Expected Tool Resolution

**Phase A:** TypeSpec rename is intentional (no changes needed in TypeSpec)

**Phase B:** Update customization to reference new method name:
```java
// Change from:
clazz.getMethodsByName("setUrlSource").forEach(NodeWithModifiers::setModifiers);
// To:
clazz.getMethodsByName("setSourceUrl").forEach(NodeWithModifiers::setModifiers);
```

### Validation

- [ ] TypeSpec regeneration completes successfully
- [ ] All references to old method name `setUrlSource` updated to `setSourceUrl` in customization
- [ ] Build completes with no errors
- [ ] Customization logic applies correctly (method modifiers are updated)

### Alternative Test: More Explicit Failure

For a clearer build failure, modify the customization to explicitly check for the method:
```java
// Add explicit check that will fail:
if (clazz.getMethodsByName("setUrlSource").isEmpty()) {
    throw new RuntimeException("Expected method setUrlSource not found - TypeSpec may have renamed the property");
}
```

Or use a property that's directly referenced in string literals like `getField("displayName")` pattern from the spec.
