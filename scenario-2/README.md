# Scenario 2: API Review Rename

## Description

This scenario simulates API review feedback requesting a naming change. The `@clientName` decorator in `client.tsp` uses "ID" instead of "Id" for `EntraIDCredentials`, which doesn't follow .NET naming conventions.

## Problem

Model name `AIProjectConnectionEntraIDCredential` doesn't follow .NET casing conventions ("Id" vs "ID").

## Files Modified

- **TypeSpec**: `azure-rest-api-specs/specification/ai/Azure.AI.Projects/client.tsp` (line 65)
- **Change**: `"AIProjectConnectionEntraIdCredential"` → `"AIProjectConnectionEntraIDCredential"`

## Scripts

### Setup

```bash
./setup.sh
```

Modifies `client.tsp` to use incorrect "ID" casing, simulating the "before" state.

### Teardown

```bash
./teardown.sh
```

Restores the original `client.tsp` from backup.

## azsdk-cli Commands

### Generate .NET SDK

```bash
azsdk pkg generate \
  --local-sdk-repo-path /home/cradek/workplace/client-customization-workflow-space/azure-sdk-for-net \
  --tsp-config-path specification/ai/Azure.AI.Projects/tspconfig.yaml
```

### Build .NET SDK

```bash
azsdk pkg build \
  --package-path /home/cradek/workplace/client-customization-workflow-space/azure-sdk-for-net/sdk/ai/Azure.AI.Projects
```

## Expected Resolution

**Phase A (TypeSpec):** Update the `@clientName` decorator to use correct "Id" casing:

```typespec
@@clientName(Azure.AI.Projects.EntraIDCredentials,
  "AIProjectConnectionEntraIdCredential",  // Fixed: "Id" instead of "ID"
  "csharp"
);
```

**Phase B:** Not needed (TypeSpec change is sufficient)

## Validation Criteria

- [ ] `@clientName` decorator updated with "Id" casing
- [ ] Only .NET SDK affected (other languages unchanged)
- [ ] SDK regenerates successfully
- [ ] Build completes with no errors
- [ ] Generated class name is `AIProjectConnectionEntraIdCredential`
