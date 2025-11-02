# ACTION 2: Create Reusable Component

**Triggers:** "create component", "new component", "create reusable view", "add component", or similar requests

---

## Steps

### 1. Determine component name

- Check if component name is provided in the request
- If NOT provided: Ask "What is the name of the new component?" (e.g., "CustomButton", "ProfileCard", "LoadingSpinner")
- Component names should be descriptive and end with appropriate suffix (Button, Card, View, etc.)

### 2. Determine component location

- Default location: `/SwiftfulStarterProject/Components/Views/`
- Ask user if they want it in a different Components subfolder:
  - `/Components/Views/` - General reusable views (DEFAULT)
  - `/Components/Modals/` - Modal/popup components
  - `/Components/Images/` - Image-related components
- If unsure, use `/Components/Views/`

### 3. Create the component file

- Create single file: `ComponentNameView.swift` in chosen location
- Structure:
  ```swift
  import SwiftUI

  struct ComponentNameView: View {

      // All data is injected - no @State, no @Observable objects
      // Make as much as possible optional for flexibility
      let title: String?
      let isLoading: Bool

      // All actions are injected as closures (optional)
      let onTap: (() -> Void)?

      var body: some View {
          // Unwrap optionals in the view
          if let title {
              Text(title)
                  .onTapGesture {
                      onTap?()
                  }
          }
      }
  }

  #Preview {
      ComponentNameView(
          title: "Preview Title",
          isLoading: false,
          onTap: { }
      )
  }
  ```

### 4. Component Rules (CRITICAL)

- **NO business logic** - UI only
- **NO @State** for data (only for UI state like animations)
- **NO @Observable objects** or Presenters
- **NO @StateObject or @ObservedObject**
- **ALL data is injected** via init parameters
- **Make as much as possible OPTIONAL** - then unwrap in the view body for maximum flexibility
- **ALL loading states are injected** as Bool parameters
- **ALL actions are closures** (e.g., `onTap: (() -> Void)?`, `onSubmit: ((String) -> Void)?`)
- **ALWAYS use ImageLoaderView** for images (never AsyncImage unless specifically requested)
- **PREFER maxWidth/maxHeight with alignment** over Spacer() - Use `.frame(maxWidth: .infinity, alignment: .leading)` instead of `Spacer()`
- **AVOID fixed frames** when possible - let SwiftUI handle sizing naturally
- **Create MULTIPLE #Previews** showing different data states (all data, partial data, no data, loading, etc.)

### 5. Verify creation

- Confirm file location
- Inform user: "Created reusable component at /Components/Views/ComponentNameView.swift"

---

## Example Components

### Button with loading state

```swift
struct CustomButtonView: View {
    let title: String?
    let isLoading: Bool
    let isEnabled: Bool
    let onTap: (() -> Void)?

    var body: some View {
        Button {
            onTap?()
        } label: {
            if isLoading {
                ProgressView()
            } else if let title {
                Text(title)
            }
        }
        .disabled(!isEnabled || isLoading)
    }
}

#Preview("Default") {
    CustomButtonView(
        title: "Submit",
        isLoading: false,
        isEnabled: true,
        onTap: { print("Tapped") }
    )
}

#Preview("Loading") {
    CustomButtonView(
        title: "Submit",
        isLoading: true,
        isEnabled: true,
        onTap: { print("Tapped") }
    )
}

#Preview("Disabled") {
    CustomButtonView(
        title: "Submit",
        isLoading: false,
        isEnabled: false,
        onTap: { print("Tapped") }
    )
}

#Preview("No Title") {
    CustomButtonView(
        title: nil,
        isLoading: false,
        isEnabled: true,
        onTap: { print("Tapped") }
    )
}
```

### Card with image (use ImageLoaderView)

```swift
struct ProfileCardView: View {
    let imageUrl: String?
    let title: String?
    let subtitle: String?
    let onTap: (() -> Void)?

    var body: some View {
        VStack(spacing: 8) {
            if let imageUrl {
                ImageLoaderView(urlString: imageUrl)
                    .aspectRatio(1, contentMode: .fill)
                    .clipShape(Circle())
            }

            if let title {
                Text(title)
                    .font(.headline)
            }

            if let subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .onTapGesture {
            onTap?()
        }
    }
}

#Preview("Full Data") {
    ProfileCardView(
        imageUrl: "https://picsum.photos/100",
        title: "John Doe",
        subtitle: "Software Engineer",
        onTap: { print("Tapped") }
    )
    .frame(width: 150)
}

#Preview("No Image") {
    ProfileCardView(
        imageUrl: nil,
        title: "Jane Smith",
        subtitle: "Designer",
        onTap: { print("Tapped") }
    )
    .frame(width: 150)
}

#Preview("Title Only") {
    ProfileCardView(
        imageUrl: nil,
        title: "Alex Johnson",
        subtitle: nil,
        onTap: nil
    )
    .frame(width: 150)
}

#Preview("Empty") {
    ProfileCardView(
        imageUrl: nil,
        title: nil,
        subtitle: nil,
        onTap: nil
    )
    .frame(width: 150)
}
```

---

## Layout Best Practices

### ✅ PREFERRED - Use maxWidth with alignment

```swift
VStack(spacing: 8) {
    Text("Title")
        .frame(maxWidth: .infinity, alignment: .leading)

    Text("Description")
        .frame(maxWidth: .infinity, alignment: .leading)
}
```

### ❌ AVOID - Using Spacer

```swift
VStack(spacing: 8) {
    HStack {
        Text("Title")
        Spacer()
    }

    HStack {
        Text("Description")
        Spacer()
    }
}
```

---

## Important Notes

- Components are DUMB UI - they display what they're told and call callbacks
- All logic stays in Presenters, components just render
- This keeps components reusable across different screens
- Prefer maxWidth/maxHeight with alignment over Spacer for cleaner layouts
