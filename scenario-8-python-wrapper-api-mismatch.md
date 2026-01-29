# Scenario 8: Python Wrapper API Mismatch

**Description:** Python SDK devs customize generated code in `_patch.py` by wrapping generated methods with `super()._method(...)`. When service teams introduce TypeSpec changes that result in API changes, the customized wrapper code breaks and requires manual updates.

**Entry Point:** Build/import failure after TypeSpec regeneration

**Problem:** Customized wrapper code in `_patch.py` references old method name that no longer exists in regenerated code.

**Real-World Example:** [azure-sdk-for-python Face SDK](https://github.com/Azure/azure-sdk-for-python/blob/b59df36163bc9b3278e1043055b61c8d44d62f90/sdk/face/azure-ai-vision-face/azure/ai/vision/face/aio/_patch.py#L267-L302)

**Error:**
```
NameError: '_detect_from_url' is not defined
```

**Breaking Change:**

| Change Type | Example | Error |
|-------------|---------|-------|
| Method rename | `_detect_from_url` -> `_detect_face_from_url` | `NameError: '_detect_from_url' is not defined` |

**Workflow Execution:**

| Phase | Action | Result |
|-------|--------|--------|
| **Phase A: TypeSpec** | Regenerate SDK with updated TypeSpec | SDK regenerated. Build/import fails due to wrapper mismatch. |
| **Phase B: Code Customization** | Detect broken method reference in `_patch.py`. Read generated `_client.py` to discover new method name. Update `_patch.py` to use new name. Rebuild SDK. | Build succeeds. Wrapper aligned with new API. |

**Acceptance Criteria:**

- TypeSpec regeneration completes successfully
- Method reference `_detect_from_url` updated to `_detect_face_from_url` in `_patch.py`
- Build/import completes with no errors
- Public API functionality preserved

**Key Learning:** TypeSpec API changes break Python customization wrappers that use `super()._method()` pattern. Phase B can mechanically fix method references by reading the generated code to discover the new name.
