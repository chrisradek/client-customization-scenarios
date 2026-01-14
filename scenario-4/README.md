# Scenario 4: Hide Operation from Python SDK

## Overview

This scenario tests hiding an internal operation from the Python SDK public API using the language-scoped `@access` decorator in TypeSpec.

**Type:** User-prompt driven scenario (Phase A only)

## User Prompt

```
Remove get_task_file_properties from Python SDK public API
```

## Expected Tool Action

Add the `@access` decorator with Python scope to `client.tsp`:

```typespec
@@access(Azure.Batch.Tasks.getTaskFileProperties, Access.internal, "python");
```

Optionally, also rename the internal method:

```typespec
@@clientName(BatchClient.getTaskFileProperties, "getTaskFilePropertiesInternal", "python");
```

## Reference Example

The Azure Batch TypeSpec already contains examples of this pattern:

**File:** `azure-rest-api-specs/specification/batch/Azure.Batch/client.tsp` (lines 172-188)

```typespec
@@access(Azure.Batch.Tasks.getTaskFileProperties, Access.internal, "python");
@@clientName(BatchClient.getTaskFileProperties,
  "getTaskFilePropertiesInternal",
  "python"
);
@@access(Azure.Batch.Nodes.getNodeFileProperties, Access.internal, "python");
@@clientName(BatchClient.getNodeFileProperties,
  "getNodeFilePropertiesInternal",
  "python"
);
// Python LRO private methods
@@access(Azure.Batch.Pools.removeNodes, Access.internal, "python");
@@clientName(BatchClient.removeNodes, "removeNodesInternal", "python");
@@access(Azure.Batch.Pools.resizePool, Access.internal, "python");
@@clientName(BatchClient.resizePool, "resizePoolInternal", "python");
```

## Key Paths

| Component | Path |
|-----------|------|
| TypeSpec Definition | `azure-rest-api-specs/specification/batch/Azure.Batch/client.tsp` |
| Python SDK | `azure-sdk-for-python/sdk/batch/azure-batch` |
| Generated Operations | `azure-sdk-for-python/sdk/batch/azure-batch/azure/batch/_operations/_operations.py` |

## azsdk-cli Commands

### Generate Python SDK

```bash
cd azure-sdk-for-python

# Generate SDK from TypeSpec
azsdk sdk generate \
  --sdk-repo . \
  --spec-repo ../azure-rest-api-specs \
  --service batch \
  --package azure-batch \
  --language python
```

### Build and Validate Python SDK

```bash
cd azure-sdk-for-python/sdk/batch/azure-batch

# Install dependencies
pip install -e ".[dev]"

# Run linting
pylint azure/batch

# Run mypy type checking
mypy azure/batch

# Run tests
pytest tests/
```

### Alternative: Using tox

```bash
cd azure-sdk-for-python/sdk/batch/azure-batch

# Run all checks
tox -e lint
tox -e mypy
tox -e pytest
```

## Workflow Phases

| Phase | Action | Result |
|-------|--------|--------|
| **Phase A: TypeSpec** | Apply `@access` decorator to mark operation as internal for Python | SDK regenerates successfully |
| | Regenerate Python SDK | Operation hidden from public API |
| | Validate build | Build passes |
| **Phase B** | Not needed | TypeSpec decorator is sufficient |

## Validation Checklist

- [ ] `@access` decorator applied with correct scope (`"python"`)
- [ ] Operation `getTaskFileProperties` hidden from public API in Python SDK only
- [ ] Other languages (Java, .NET, etc.) still have public access
- [ ] SDK regenerates successfully
- [ ] Build completes with no errors

## Result in Python SDK

After applying the decorator, the Python SDK will generate:
- Internal method: `_get_task_file_properties_internal()` (prefixed with `_`)
- The operation is no longer part of the public API

## Key Learning

The `@access` decorator provides language-scoped visibility control without requiring code customizations in the SDK. This is the preferred approach for hiding operations from specific language SDKs.

## Scripts

- `setup.sh` - Displays scenario information (no modifications needed)
- `teardown.sh` - Restores any changes made during testing
