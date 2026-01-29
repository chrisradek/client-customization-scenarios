# Scenario 8: Python Wrapper API Mismatch

## Overview

It requires much manual effort to update customized code. For example, if Python SDK devs want to customize generated code, they need to add code in `_patch.py`. However, if service teams introduce TypeSpec changes which result in API changes, they need to update the customized code to adopt the change.

**Real-World Example:** [Face SDK _patch.py](https://github.com/Azure/azure-sdk-for-python/blob/b59df36163bc9b3278e1043055b61c8d44d62f90/sdk/face/azure-ai-vision-face/azure/ai/vision/face/aio/_patch.py#L267-L302)

## The Problem

1. **Python SDK devs customize generated code** by creating wrapper methods in `_patch.py`
2. **Service teams rename a method in TypeSpec** (e.g., `detectFromUrl` -> `detectFaceFromUrl`)
3. **Wrapper code breaks** because it calls `super()._detect_from_url(...)` but the method is now `_detect_face_from_url`
4. **Manual effort required** to find and update all method references

## Python Customization Pattern

Python SDKs use `_patch.py` files with class inheritance:

```python
# _patch.py
from ._client import FaceClient as FaceClientGenerated

class FaceClient(FaceClientGenerated):
    async def detect_from_url(self, body, *, url, detection_model, ...):
        # Custom docstring, validation, logging, etc.
        return await super()._detect_from_url(  # <-- Calls generated method
            body,
            url=url,
            detection_model=detection_model,
            ...
        )
```

## What Breaks

### Before TypeSpec Change:

```python
# Generated code has:
async def _detect_from_url(self, body, *, url, ...):

# Customization calls:
return await super()._detect_from_url(body, url=url, ...)
```

### After TypeSpec Change (method renamed):

```python
# Generated code now has:
async def _detect_face_from_url(self, body, *, url, ...):

# Customization still calls OLD name:
return await super()._detect_from_url(body, url=url, ...)
# NameError: '_detect_from_url' is not defined
```

## Files Involved

| File | Description |
|------|-------------|
| `azure-rest-api-specs/.../routes.tsp` | TypeSpec operation definition |
| `azure-sdk-for-python/.../aio/_patch.py` | Async customization wrapping generated client |
| `azure-sdk-for-python/.../_patch.py` | Sync customization wrapping generated client |
| `azure-sdk-for-python/.../aio/_client.py` | Generated async client |

## Using azsdk-cli to Detect and Fix

### Step 1: Regenerate the Python SDK

```bash
cd azure-sdk-for-python/sdk/face/azure-ai-vision-face
tsp-client update
```

### Step 2: Observe the Error

```bash
python -c "from azure.ai.vision.face.aio import FaceClient"
# NameError: name '_detect_from_url' is not defined
```

### Step 3: Run azsdk-cli

```bash
cd azure-sdk-tools/tools/azsdk-cli

dotnet run -- tsp client customized-update <commit-sha> \
  --package-path "../azure-sdk-for-python/sdk/face/azure-ai-vision-face"
```

### Step 4: Expected Fix

The tool reads the generated `_client.py` to discover the new method name and updates `_patch.py`:

```python
# Before (broken):
return await super()._detect_from_url(body, url=url, ...)

# After (fixed):
return await super()._detect_face_from_url(body, url=url, ...)
```

### Step 5: Rebuild and Verify

```bash
python -c "from azure.ai.vision.face.aio import FaceClient; print('Import successful')"
```

## Key Learnings

1. **Python uses inheritance pattern** - Customizations inherit from generated classes and call `super()._method()`
2. **Method renames break wrappers** - The `super()` call references a method that no longer exists
3. **Both sync and async affected** - Python SDKs have both `_patch.py` and `aio/_patch.py`
4. **Phase B can fix mechanically** - Reading generated code reveals the new method name

## Acceptance Criteria

- TypeSpec regeneration completes successfully
- Method reference `_detect_from_url` updated to `_detect_face_from_url` in `_patch.py`
- SDK imports successfully
- Public API works correctly
