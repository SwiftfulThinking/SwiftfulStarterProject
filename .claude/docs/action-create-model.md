# ACTION 4: Create Data Model

**Triggers:** "create data model", "new model", "create model", "new data type", or similar requests

**Note:** This action applies to struct/class models. If the user specifically asks for an enum or other type, create that instead of using the template.

---

## Steps

### 1. Check if Xcode templates are installed

```bash
ls ~/Library/Developer/Xcode/Templates/MyTemplates/ModelTemplate.xctemplate
```

### 2. If templates NOT found

- Respond: "The Xcode templates are not installed. Please install them first:"
- Provide link: https://github.com/SwiftfulThinking/XcodeTemplates
- Include installation instructions:
  ```bash
  cd ~/Library/Developer/Xcode
  mkdir -p Templates
  # Then drag MyTemplates folder into Templates directory
  ```
- Stop here. Do not proceed without templates.

### 3. If templates ARE installed

- Check if model name is provided in the request
- If NOT provided: Ask "What is the name of the new model?" (e.g., "User", "Post", "Message")
- Note: Don't include "Model" suffix in the name - template adds it automatically

### 4. Determine model location

- List all available managers in `/Managers/` directory
- Ask: "Which manager should this model be stored under?"
- Show options from available managers (e.g., "User", "Auth", "Purchases", etc.)
- Models are stored in `/Managers/[Manager]/Models/`
- If user wants a new manager, suggest creating the manager first with ACTION 3

### 5. Create the model using templates

- Read template file from `~/Library/Developer/Xcode/Templates/MyTemplates/ModelTemplate.xctemplate/___VARIABLE_modelName___Model.swift`
- Substitute placeholders:
  - `___VARIABLE_modelName:identifier___` → ModelName (e.g., "User", "Post")
  - `___VARIABLE_lowercasedmodelname:identifier___` → modelname (e.g., "user", "post")
- Create folder if needed: `/SwiftfulStarterProject/Managers/ManagerName/Models/`
- Create file: `ModelNameModel.swift`

### 6. Verify creation

- Confirm file location
- Inform user: "Created model at /Managers/ManagerName/Models/ModelNameModel.swift"
- Remind: "The template provides basic structure. Add your custom properties to replace the default 'value' property."

---

## Model Template Structure

```swift
import SwiftUI
import IdentifiableByString
import SwiftfulDataManagers

public struct ModelNameModel: StringIdentifiable, Codable, Sendable, DMProtocol {
    let id: String
    let value: String?  // Replace with your custom properties
    let customProperty: Bool?  // Example custom property

    init(
        id: String,
        value: String? = nil,
        customProperty: Bool? = nil
    ) {
        self.id = id
        self.value = value
        self.customProperty = customProperty
    }

    enum CodingKeys: String, CodingKey {
        case id
        case value
        case customProperty = "custom_property"  // Always use snake_case
    }

    var eventParameters: [String: Any] {
        // Auto-generated for analytics tracking
        let dict: [String: Any?] = [
            "modelname_\(CodingKeys.id.rawValue)": id,
            "modelname_\(CodingKeys.value.rawValue)": value,
            "modelname_\(CodingKeys.customProperty.rawValue)": customProperty
        ]
        return dict.compactMapValues({ $0 })
    }

    static var mocks: [ModelNameModel] {
        [
            ModelNameModel(id: "1", value: "Mock 1", customProperty: true),
            ModelNameModel(id: "2", value: "Mock 2", customProperty: false)
        ]
    }
}
```

---

## Important Requirements

- ALWAYS use the template when creating models
- **ALL models must conform to: StringIdentifiable, Codable, Sendable, DMProtocol**
- **ALL models used with DataManagers MUST be declared as `public struct`** (not just `struct`)
- DMProtocol is required for SwiftfulDataManagers compatibility
- The template provides: CodingKeys, eventParameters, mocks structure
- Replace the default `value` property with your actual model properties
- Update CodingKeys enum when adding/removing properties
- **ALWAYS use snake_case for CodingKeys raw values** (e.g., `case myProperty = "my_property"`)
- **ALWAYS implement `eventParameters`** computed property for analytics
- **ALWAYS implement `static var mocks`** array for preview/testing
- Models are stored under their related manager in the Models subfolder
- Sendable conformance is required for Swift 6 concurrency safety
