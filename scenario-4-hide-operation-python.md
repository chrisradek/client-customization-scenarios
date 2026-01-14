# Scenario 4: Hide Operation from Python SDK

**Description:** Hide internal polling operation `getCreateProjectStatus` from Python SDK using language-scoped `@access` decorator.

**Entry Point:** User prompt ("Remove get_create_project_status from Python SDK")

**Workflow Execution:**

| Phase                 | Action                                                                                                          | Result                                                                                                   |
| --------------------- | --------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------- |
| **Phase A: TypeSpec** | Apply `@access` decorator to mark operation as internal for Python<br/>Regenerate Python SDK<br/>Validate build | SDK regenerates successfully<br/>Operation hidden from public API<br/>Build passes<br/>No Phase B needed |

**Acceptance Criteria:**

- `@access` decorator applied with correct scope (e.g., `"python"`)
- Operation `getCreateProjectStatus` hidden from public API in Python SDK only
- SDK regenerates successfully
- Build completes with no errors

**Key Learning:** `@access` decorator provides language-scoped visibility control without code customizations.

---

## Test Implementation

### Approach

Use a real TypeSpec project that has operations we want to hide from Python. The `azure-rest-api-specs/specification/batch/Azure.Batch` project is an excellent example - it already uses `@@access(..., Access.internal, "python")` to hide operations.

For testing, we can either:
1. Use an existing operation that's NOT yet hidden and apply `@access` to it
2. Create a minimal TypeSpec project with a public operation and hide it

### Source Files

**TypeSpec with Python-scoped @access (existing example):**
- `azure-rest-api-specs/specification/batch/Azure.Batch/client.tsp` (lines 182-195)
- Example: `@@access(Azure.Batch.Pools.removeNodes, Access.internal, "python");`

**Python SDK (generated internal methods):**
- `azure-sdk-for-python/sdk/batch/azure-batch/azure/batch/_operations/_operations.py`
- Internal methods: `_resize_pool_internal`, `_remove_nodes_internal` (prefixed with `_`)

### Setup Steps

1. **Find a public operation to hide (or use existing project):**
   Look for an operation in Azure.AI.Projects or another TypeSpec that is currently public in Python.

2. **Simulate user prompt:**
   ```
   "Remove get_task_file_properties from Python SDK public API"
   ```

3. **Expected TypeSpec change:**
   ```typespec
   // Add to client.tsp:
   @@access(Azure.AI.Projects.SomeOperation.getStatus, Access.internal, "python");
   ```

4. **Regenerate Python SDK:**
   ```bash
   cd azure-sdk-for-python
   # Run TypeSpec generation
   ```

### Expected Tool Resolution

**Phase A:** Apply `@access` decorator with Python scope:
```typespec
@@access(Azure.AI.Projects.SomeOperation, Access.internal, "python");
```

**Phase B:** Not needed (TypeSpec decorator is sufficient)

### Validation

- [ ] `@access` decorator applied with correct scope (`"python"`)
- [ ] Operation hidden from public API in Python SDK only
- [ ] Other languages (Java, .NET, etc.) still have public access
- [ ] SDK regenerates successfully
- [ ] Build completes with no errors

### Real Example from Batch

The Batch project shows the complete pattern:
```typespec
// Hide from Python public API
@@access(Azure.Batch.Pools.removeNodes, Access.internal, "python");
// Also rename to indicate internal
@@clientName(BatchClient.removeNodes, "removeNodesInternal", "python");
```

Result in Python SDK:
- Generated: `_remove_nodes_internal()` (private, prefixed with `_`)
- Handwritten wrapper: `begin_remove_nodes()` (public LRO method)
