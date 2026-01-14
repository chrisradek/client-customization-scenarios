# Scenario 7: Feature Request Requiring Code Customization (No TypeSpec Solution)

**Description:** User requests adding operation ID extraction from polling headers for Java LRO operations, but TypeSpec has no decorator to customize polling behavior or extract data from response headers.

**Entry Point:** User prompt ("Add operationId property to AnalyzeOperationDetails by parsing it from the Operation-Location header during polling")

**Problem:** LRO polling needs to extract operation ID from `Operation-Location` header and inject it into `AnalyzeOperationDetails` response object. TypeSpec cannot customize polling strategies or header parsing logic. No customization files exist yet.

**Workflow Execution:**

| Phase                 | Action                                                                                                                                     | Result                                                               |
| --------------------- | ------------------------------------------------------------------------------------------------------------------------------------------ | -------------------------------------------------------------------- |
| **Phase A: TypeSpec** | Analyze request<br/>Determine no TypeSpec decorator supports polling customization or header extraction<br/>No TypeSpec changes applicable | SDK unchanged<br/>No customization files found                       |
| **Manual Guidance**   | Detect no `/customization/` directory or `*Customization.java` files exist<br/>Return guidance to create customization infrastructure      | Tool suggests creating customization class with LRO polling examples |

**Acceptance Criteria:**

- Tool determines TypeSpec cannot solve the request (no applicable decorators for polling/headers)
- Tool identifies no customization files exist for Java
- Tool returns manual guidance including:
  - Instruction to create customization infrastructure (e.g., `DocumentIntelligenceCustomizations.java`)
  - Code pattern/example for customizing polling strategies with header extraction
  - Reference to Java customization documentation and LRO customization examples

**Key Learning:** When feature requests involve runtime behavior like polling strategies or header extraction that TypeSpec cannot address, tool provides guidance to create the appropriate customization files with concrete examples.

---

## Test Implementation

### Approach

This scenario tests the tool's ability to recognize when TypeSpec cannot solve a problem and provide manual guidance instead. The example is extracting `operationId` from LRO polling headers - something TypeSpec has no decorators for.

Use the DocumentIntelligence project as a reference for what the final solution looks like, but simulate testing against a project that does NOT have these customizations yet.

### Source Files (Reference Implementation)

The DocumentIntelligence Java SDK shows the complete solution:

**1. Helper Class (handwritten):**
- `azure-sdk-for-java/sdk/documentintelligence/azure-ai-documentintelligence/src/main/java/com/azure/ai/documentintelligence/implementation/AnalyzeOperationDetailsHelper.java`
- Provides accessor pattern to set private fields on generated model

**2. Customization File:**
- `azure-sdk-for-java/sdk/documentintelligence/azure-ai-documentintelligence/customization/src/main/java/DocumentIntelligenceCustomizations.java`

**Key customizations:**
```java
// Add operationId field to model (line 177)
clazz.addField("String", "operationId", Modifier.Keyword.PRIVATE);

// Add parseOperationId method to PollingUtils (lines 194-215)
clazz.addMethod("parseOperationId", Modifier.Keyword.PRIVATE)
    .setType("String")
    .setModifiers(Modifier.Keyword.STATIC)
    .addParameter("String", "operationLocationHeader")
    .setBody(StaticJavaParser.parseBlock("{ "
        + "Matcher matcher = PATTERN.matcher(operationLocationHeader);"
        + "if (matcher.find()) { return matcher.group(1); }"
        + "return null; }"));

// Override poll() method in polling strategy (lines 230-268)
clazz.addMethod("poll", Modifier.Keyword.PUBLIC)
    .setType("Mono<PollResponse<T>>")
    .addMarkerAnnotation(Override.class)
    .setBody(/* extract operationId from header and inject into response */);
```

### Setup Steps

1. **Simulate user prompt:**
   ```
   "Add operationId property to AnalyzeOperationDetails by parsing it from the Operation-Location header during polling"
   ```

2. **Simulate a project WITHOUT customization files:**
   - Use a TypeSpec project that generates LRO operations
   - No `/customization/` directory exists
   - No `*Customization.java` files exist

### Expected Tool Resolution

**Phase A:** Tool analyzes request and determines:
- No TypeSpec decorator supports polling customization
- No TypeSpec decorator can extract data from response headers
- No TypeSpec changes are applicable

**Manual Guidance:** Tool detects no customization infrastructure exists and returns:

1. **Instruction to create customization infrastructure:**
   ```
   Create customization directory:
   sdk/{service}/azure-{service}/customization/src/main/java/

   Create customization class:
   {Service}Customizations.java extending com.azure.autorest.customization.Customization
   ```

2. **Code pattern for LRO polling customization:**
   ```java
   // 1. Add field to model
   customization.getClass(MODELS_PACKAGE, "AnalyzeOperationDetails")
       .customizeAst(ast -> ast.getClassByName("AnalyzeOperationDetails")
           .ifPresent(clazz -> clazz.addField("String", "operationId", Modifier.Keyword.PRIVATE)));

   // 2. Add helper class for setting private fields
   // (Create AnalyzeOperationDetailsHelper.java manually)

   // 3. Override polling strategy to extract operationId from headers
   packageCustomization.getClass("OperationLocationPollingStrategy")
       .customizeAst(ast -> /* override poll() method */);
   ```

3. **Reference documentation:**
   - Link to Java SDK customization documentation
   - Link to LRO customization examples
   - Link to accessor pattern documentation

### Validation

- [ ] Tool determines TypeSpec cannot solve the request
- [ ] Tool identifies no customization files exist for Java
- [ ] Tool returns manual guidance with:
  - [ ] Instructions to create customization directory structure
  - [ ] Code pattern for adding fields to models
  - [ ] Code pattern for customizing polling strategies
  - [ ] Reference to documentation

### Why TypeSpec Cannot Solve This

TypeSpec decorators can:
- Rename models/properties (`@clientName`)
- Hide operations (`@access`)
- Define client structure (`@client`, `@operationGroup`)

TypeSpec decorators CANNOT:
- Customize LRO polling behavior
- Extract data from HTTP response headers
- Inject runtime logic into generated code
- Modify how polling strategies work

These require code customizations that manipulate the generated code at build time.
