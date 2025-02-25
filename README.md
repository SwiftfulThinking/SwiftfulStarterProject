### 🚀 Learn how to build and use this package: https://www.swiftful-thinking.com/offers/REyNLwwH?coupon_code=LAUNCH3

# Starter Project 🌹

Starter project for SwiftUI apps using VIPER architecture. 

## Overview

<details>
<summary> Details (Click to expand) </summary>
<br>
  
A starter project using VIPER/RIBs architecture in SwiftUI. You can learn how this architecture works and how to build this yourself in the [SwiftUI Advanced Architecture course](https://www.swiftful-thinking.com/offers/REyNLwwH). This architecture can help your team build 10x faster, while writing testable code. The VIPER structure creates clear seperation of concerns and removes the guesswork for junior devs.

The data managers are erased to protocols and are dependency agnostic. The starter project is connected to Firebase (among other dependencies) but this can easily be swapped out.

Some pre-built features this project contains:
- Onboarding flow
- Tabbar flow
- Authentication logic
- User Management
- Paywall template
- In-app purchasing logic
- Routing logic
- Logging
- Analytics
- Crashlytics
- AB Testing
- Haptics
- Sound Effects
- Push Notifications

</details>

## Setup

<details>
<summary> Details (Click to expand) </summary>
<br>
  
## Steps to create a new project:

#### 1. Download or clone this repo

https://github.com/SwiftfulThinking/SwiftfulStarterProject.git

#### 2. In the terminal, navigate to the project folder

```
cd /pathtoproject/SwiftfulStarterProject
```

#### 3. Run renaming script

```
./rename_project.sh NewProjectName
```

If it doesn't work, you may need to make the script file executable by running

```
chmod +x rename_project.sh
```

#### 4. Your new project folder should appear next to the SwiftfulStarterProject folder.

1. The new project should have all files already renamed.
2. Manually add your Firebase plist files at /NewProjectName/Supporting Files/GoogleServicePLists
3. Run the mock scheme to build without Firebase
4. Update the bundle IDs for your organization


#### 5. Install Xcode templates to expedite development

https://github.com/SwiftfulThinking/XcodeTemplates

</details>

## Architecture

<details>
<summary> Details (Click to expand) </summary>
<br>
  
This architecture is taught in-depth in the [SwiftUI Advanced Architecture course](https://www.swiftful-thinking.com/offers/REyNLwwH). Large groups, companies or educational institutions who decide to use this as training material can inquire about discounted rates at hello@swiftful-thinking.com.

### Why?

In this architecture, the SwiftUI framework is focused solely on building the UI layer of the application. Although Apple has provided data-centric Property Wrappers, such as @AppStorage or @Query, these have limited testability and ultimately restrict our ability to mock and develop the codebase with different environments. 

### Architecture is a Spectrum

We begin building a "Vanilla SwiftUI app". This is a basic SwiftUI implementation where all logic is held in the View. This is the easiest and most convenient way to build SwiftUI applications. Keeping all logic in the View, we can leverage SwiftUI's Environment and many Property Wrappers, such as @AppStorage. However, this leads to the "Massive-View-Controller" problem and severely limits testability. 

We improve the architecture by introducing MVVM. In MVVM, we add an additional layer between the View and the dependencies (ie. the ViewModel). This allows us to move the business logic from the View into the ViewModel and then write tests for the ViewModel's logic. Although this is great for testability, it is less convenient for the developer, since we can no longer rely on SwiftUI's environment. Instead we need to inject the dependencies into each ViewModel ourselves.

If we further architect the application, we can decouple the routing from the View and move that logic into the ViewModel as well. To further improve testability of the ViewModel, we can abstract both the routing dependencies and the data dependencies to protocols. We can rename the ViewModel as Presenter, which now has a Router and an Interactor, completing the VIPER implementation.

![Untitled-4](https://github.com/user-attachments/assets/49eae097-57cf-4072-87d0-ad53b5fe6915)

### VIPER

When implemented well, VIPER is an improvement to MVVM architecture. In SwiftUI, both architectures run on the same foundation - an observable class that publishes updates back to the View. The main difference being that VIPER also includes the routing logic for the screen. You can think of the Presenter in the same way that you think of a ViewModel.

- View
  - UI layer of the screen
- Interactor
  - Data-related logic
- Presenter
  - Business logic between the View and the Router/Interactor layers
- Entity
  - A data model
- Router 
  - Screen routing logic 

![Untitled-3](https://github.com/user-attachments/assets/58536758-d3e8-4d0a-b8b0-81008177048d)

### RIBs

The project also incorporates a RIB pattern to create high-level modules across the application. The Starter Project has the entire project within 1 RIB (ie. CoreRouter, CoreInteractor, CoreBuilder), however, the application can be further broken into more RIBs as displayed in the [SwiftUI Advanced Architecture course](https://www.swiftful-thinking.com/offers/REyNLwwH). Most teams will find it much faster to build with only 1 RIB.

This is a SwiftUI adaptation inspired by Uber's [RIBs architecture](https://github.com/uber/RIBs).

- Router
  - All routing methods for the module
- Interactor
  - All data-related methods for the module
- Builder
  - All screens within the module

The below image shows RIBs structure in an app with 3 RIBs.

![137_architecture](https://github.com/user-attachments/assets/ded49e78-9236-45ad-b21a-b34a693fbf6f)

### The Ultimate Architecture

Implementing VIPER + RIBs, brings a complete SwiftUI architecture that can adapt for any team. 
- VIPER enables the business logic for each screen to be testable.
- RIBs enables us to modulate the codebase while reusing the interactor/router methods within each module.

The below diagram shows an application with 5 VIPER screens set within 1 RIB.

![143_architecture](https://github.com/user-attachments/assets/a3567b98-e590-41ba-b865-23edb28bcf50)

### Where to go from here?

Thanks for reading! This starter project is provided for **free** from Swiftful Thinking. If you want to learn how to use this architecture and 10x your development speed, I highly suggest taking [SwiftUI Advanced Architecture course](https://www.swiftful-thinking.com/offers/REyNLwwH)! 

The starter project includes the following dependencies, which can be easily removed or swapped as needed:

- [Firebase ](https://github.com/firebase/firebase-ios-sdk)
- [SDWebImageSwiftUI](https://github.com/SDWebImage/SDWebImageSwiftUI)
- [SwiftfulAuthenticating](https://github.com/SwiftfulThinking/SwiftfulAuthenticating)
- [SwiftfulAuthenticatingFirebase](https://github.com/SwiftfulThinking/SwiftfulAuthenticatingFirebase)
- [SwiftfulFirestore](https://github.com/SwiftfulThinking/SwiftfulFirestore)
- [SwiftfulHaptics](https://github.com/SwiftfulThinking/SwiftfulHaptics)
- [SwiftfulLogging](https://github.com/SwiftfulThinking/SwiftfulLogging)
- [SwiftfulLoggingCrashlytics](https://github.com/SwiftfulThinking/SwiftfulLoggingFirebaseCrashlytics)
- [SwiftfulLoggingMixpanel](https://github.com/SwiftfulThinking/SwiftfulLoggingMixpanel)
- [SwiftfulLoggingFirebaseAnalytics](https://github.com/SwiftfulThinking/SwiftfulLoggingFirebaseAnalytics)
- [SwiftfulPurchasing](https://github.com/SwiftfulThinking/SwiftfulPurchasing)
- [SwiftfulPurchasingRevenueCat](https://github.com/SwiftfulThinking/SwiftfulPurchasingRevenueCat)
- [SwiftfulRouting](https://github.com/SwiftfulThinking/SwiftfulRouting)
- [SwiftfulSoundEffects](https://github.com/SwiftfulThinking/SwiftfulSoundEffects)
- [SwiftfulUI](https://github.com/SwiftfulThinking/SwiftfulUI)
- [SwiftfulUtilities](https://github.com/SwiftfulThinking/SwiftfulUtilities)

</details>


