# Scenario 7: Feature Request Requiring Code Customization

## Scenario Type

**Manual Guidance** - TypeSpec cannot solve this request.

## User Prompt

```
Add operationId property to AnalyzeOperationDetails by parsing it from the Operation-Location header during polling
```

## Expected Tool Behavior

1. **Analyze the request** and determine TypeSpec has no applicable decorators
2. **Recognize limitations**:
   - TypeSpec cannot customize LRO polling behavior
   - TypeSpec cannot extract data from HTTP response headers
   - TypeSpec cannot inject runtime logic into generated code
3. **Return manual guidance** with:
   - Instructions to create customization infrastructure
   - Code patterns for LRO polling customization
   - References to working examples

## Why TypeSpec Cannot Solve This

TypeSpec decorators can:
- Rename models/properties (`@clientName`)
- Control visibility (`@access`, `@usage`)
- Define client structure (`@client`, `@operationGroup`)

TypeSpec decorators **CANNOT**:
- Customize LRO polling behavior
- Extract data from HTTP response headers
- Inject runtime logic into generated code
- Modify how polling strategies work

These require Java code customizations that manipulate generated code at build time.

## Reference Implementation

The DocumentIntelligence Java SDK contains a working implementation of this pattern:

### Customization File
**Path:** `azure-sdk-for-java/sdk/documentintelligence/azure-ai-documentintelligence/customization/src/main/java/DocumentIntelligenceCustomizations.java`

Key customizations:
- Adds `operationId` field to `AnalyzeOperationDetails` model
- Adds `parseOperationId()` method to `PollingUtils`
- Overrides `poll()` method in polling strategy to extract operationId from headers

### Helper Class (Accessor Pattern)
**Path:** `azure-sdk-for-java/sdk/documentintelligence/azure-ai-documentintelligence/src/main/java/com/azure/ai/documentintelligence/implementation/AnalyzeOperationDetailsHelper.java`

Provides accessor pattern to set private fields on generated models.

## Expected Guidance Content

The tool should provide guidance including:

### 1. Create Customization Infrastructure
```
sdk/{service}/azure-{service}/customization/src/main/java/{Service}Customizations.java
```

### 2. Add Field to Model
```java
customization.getClass(MODELS_PACKAGE, "AnalyzeOperationDetails")
    .customizeAst(ast -> ast.getClassByName("AnalyzeOperationDetails")
        .ifPresent(clazz -> clazz.addField("String", "operationId", Modifier.Keyword.PRIVATE)));
```

### 3. Create Helper Class for Accessor Pattern
```java
public final class AnalyzeOperationDetailsHelper {
    private static AnalyzeOperationDetailsAccessor accessor;

    public interface AnalyzeOperationDetailsAccessor {
        void setOperationId(AnalyzeOperationDetails details, String operationId);
    }

    public static void setAccessor(AnalyzeOperationDetailsAccessor accessor) {
        AnalyzeOperationDetailsHelper.accessor = accessor;
    }

    public static void setOperationId(AnalyzeOperationDetails details, String operationId) {
        accessor.setOperationId(details, operationId);
    }
}
```

### 4. Override Polling Strategy
```java
packageCustomization.getClass("OperationLocationPollingStrategy")
    .customizeAst(ast -> {
        // Add parseOperationId method
        // Override poll() to extract operationId from Operation-Location header
        // Inject operationId into response using helper class
    });
```

## Documentation Links

- [Java SDK Customization Guide](https://github.com/Azure/azure-sdk-for-java/wiki/Customizations)
- [LRO Polling Customization](https://github.com/Azure/azure-sdk-for-java/wiki/Long-Running-Operations)

## Validation Checklist

- [ ] Tool determines TypeSpec cannot solve the request
- [ ] Tool identifies this requires code customization (not TypeSpec changes)
- [ ] Tool returns manual guidance with:
  - [ ] Instructions for customization infrastructure
  - [ ] Code patterns for model field addition
  - [ ] Code patterns for polling strategy customization
  - [ ] Reference to accessor/helper class pattern
