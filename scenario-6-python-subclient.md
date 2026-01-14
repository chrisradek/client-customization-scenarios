# Scenario 6: Create Python Subclient Architecture

**Description:** Restructure Python SDK with main client (`DocumentProcessingClient`) for service operations and subclient (`ProjectClient`) for project-scoped operations.

**Entry Point:** User prompt ("Use 2 clients for Python SDK: one main client and one sub-client that specifies the project id")

**Workflow Execution:**

| Phase                 | Action                                                                                                                                                                                                                                              | Result                                                                              |
| --------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------- |
| **Phase A: TypeSpec** | Create `client.tsp` with custom client definitions<br/>Define main client for project operations<br/>Define subclient for document operations<br/>Use `@client` and `@clientInitialization` decorators<br/>Regenerate Python SDK<br/>Validate build | SDK regenerates with two-client architecture<br/>Build passes<br/>No Phase B needed |

**Acceptance Criteria:**

- `@client` decorator creates correct two-client structure (main client + subclient)
- `@clientInitialization` decorator applied if needed for project ID parameter
- SDK regenerates successfully with new architecture
- Build completes with no errors
- Client architecture matches requirements (operations correctly distributed)

**Key Learning:** Complex client architecture achieved with TypeSpec decorators alone, no code customizations required.

---

## Test Implementation

### Approach

Use the real `azure-rest-api-specs/specification/ai/Face` TypeSpec project which demonstrates the subclient architecture pattern using `@client`, `@operationGroup`, and `@clientInitialization` decorators.

For testing, we can either:
1. Use an existing project and modify its client structure
2. Create a minimal TypeSpec project demonstrating the pattern

### Source Files

**TypeSpec with subclient architecture (real example):**
- `azure-rest-api-specs/specification/ai/Face/client.tsp`

**Key decorators:**
```typespec
// Main client definition (lines 54-82)
@client({
  name: "FaceClient",
  service: Face,
})
interface FaceClient {
  detectFromUrl is FaceDetectionOperations.detectFromUrl;
  // ... main operations
}

// Subclient with language-specific naming (lines 84-97)
@client(
  {
    name: "FaceAdministrationClient",
    service: Face,
  },
  "csharp,python,javascript,go"
)
namespace FaceAdministrationClient {
  // Subclient options model with required parameter
  model LargeFaceListClientOptions {
    largeFaceListId: collectionId;
  }

  // Operation group within subclient (lines 119-155)
  @operationGroup
  @clientInitialization(LargeFaceListClientOptions, "csharp,java")
  interface LargeFaceList {
    create is FaceListOperations.createLargeFaceList;
    // ... operations scoped to this subclient
  }
}
```

**Python SDK (generated clients):**
- `azure-sdk-for-python/sdk/face/azure-ai-vision-face/azure/ai/vision/face/_client.py`
- Classes: `FaceClient`, `FaceAdministrationClient`, `FaceSessionClient`

### Setup Steps

1. **Simulate user prompt:**
   ```
   "Use 2 clients for Python SDK: one main client (DocumentProcessingClient) for service operations and one sub-client (ProjectClient) that specifies the project id"
   ```

2. **Expected TypeSpec changes (create client.tsp):**
   ```typespec
   import "@azure-tools/typespec-client-generator-core";
   using Azure.ClientGenerator.Core;

   // Main client
   @client({
     name: "DocumentProcessingClient",
     service: DocumentProcessing,
   })
   interface DocumentProcessingClient {
     // Service-level operations
     listProjects is Operations.listProjects;
     createProject is Operations.createProject;
   }

   // Subclient with project ID parameter
   @client({
     name: "ProjectClient",
     service: DocumentProcessing,
   }, "python")
   namespace ProjectClient {
     model ProjectClientOptions {
       projectId: string;
     }

     @operationGroup
     @clientInitialization(ProjectClientOptions, "python")
     interface Documents {
       // Project-scoped operations
       analyzeDocument is Operations.analyzeDocument;
       getDocumentStatus is Operations.getDocumentStatus;
     }
   }
   ```

3. **Regenerate Python SDK:**
   ```bash
   cd azure-sdk-for-python
   # Run TypeSpec generation
   ```

### Expected Tool Resolution

**Phase A:** Create `client.tsp` with custom client definitions:
- `@client` decorator for main client
- Subclient namespace with `@client` scoped to Python
- `@operationGroup` for operation grouping
- `@clientInitialization` for required subclient parameters

**Phase B:** Not needed (TypeSpec decorators are sufficient)

### Validation

- [ ] `@client` decorator creates correct two-client structure
- [ ] `@clientInitialization` applied for project ID parameter
- [ ] SDK regenerates successfully with new architecture
- [ ] Build completes with no errors
- [ ] Python client architecture matches requirements:
  - `DocumentProcessingClient` with service operations
  - `ProjectClient` with project-scoped operations requiring `project_id`

### Key Decorators Reference

| Decorator | Purpose |
|-----------|---------|
| `@client` | Define a client class (can be scoped to languages) |
| `@operationGroup` | Group operations into a logical subclient |
| `@clientInitialization` | Specify required parameters for client initialization |
| `@clientName` | Rename client for specific languages |
