### 🚀 Learn how to build and use this package: https://www.swiftful-thinking.com/offers/REyNLwwH

# Starter Project 🌹

Starter project for SwiftUI apps using VIPER architecture. 

## Overview

<details>
<summary> Details (Click to expand) </summary>
<br>
  
A starter project using VIPER/RIBs architecture in SwiftUI. You can learn how this architecture works and how to build this yourself in the [SwiftUI Advanced Architecture course.](https://www.swiftful-thinking.com/offers/REyNLwwH). This architecture can help your team build 10x faster, while writing testable code. The VIPER structure creates clear seperation of concerns and removes the guesswork for junior devs.

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

#### 4. Your new project folder should appear SwiftfulStarterProject folder.

```
- The new project will should all files already renamed.
- Manually add your Firebase plist files at /NewProjectName/Supporting Files/GoogleServicePLists
- Run the mock scheme to build without Firebase
```
#### 5. Install Xcode templates to expedite development

https://github.com/SwiftfulThinking/XcodeTemplates

</details>

## Architecture

<details>
<summary> Details (Click to expand) </summary>
<br>
  
This architecture is taught in-depth in the [SwiftUI Advanced Architecture course](https://www.swiftful-thinking.com/offers/REyNLwwH). Large groups, companies or educational institutions who decide to use this as training material can inquire about discounted rates at hello@swiftful-thinking.com.

#### Why?

In this architecture, the SwiftUI framework is focused solely on building the UI layer of the application. Although Apple has provided data-centric Property Wrappers, such as @AppStorage or @Query, these have limited testability and ultimately restrict our ability to mock and develop the codebase with different environments. 

##### Spectrum

// TIMELINE IMAGE

We begin building a "Vanilla SwiftUI app". This is a basic SwiftUI implementation where all logic is held in the View. This is the easiest and most convenient way to build SwiftUI applications. Keeping all logic in the View, we can leverage SwiftUI's Environment and many Property Wrappers, such as @AppStorage. However, this leads to the "Massive-View-Controller" problem and severely limits testability. 

We improve the architecture by introducing MVVM. In MVVM, we add an additional layer between the View and the Dependencies (ie. the ViewModel). This allows us to move the business logic from the View into the ViewModel and then write tests for the ViewModel's logic. Although this is great for testability, it is less convenient for the developer, since we can no longer rely on SwiftUI's environment. Instead we need to inject the Dependencies into each ViewModel ourselves.

If we further architect the application, we can decouple the routing from the View and model that logic into the ViewModel as well. To further improve testability of the ViewModel, we can abstract both the routing dependencies and the data dependencies to protocols. We can rename the ViewModel as Presenter, which now has a Router and an Interactor, completing the VIPER implementation.

##### VIPER

// VIPER IMAGE

When implemented well, VIPER is an improvement to MVVM architecture. In SwiftUI, both architectures run on the same foundation - an observable class that publishes updates back to the View. The main difference being that VIPER also includes the routing logic for the screen. You can think of the Presenter in the same way that you think of a ViewModel.

##### RIBs

// RIBs image

In
VIPER is to one screen as RIB is to one module. Outside of the 

While VIPER represents one "screen", a "RIB" represents 
Of the architectures listed, a "Vanilla SwiftUI App" 

Improving from a "Vanilla SwiftUI" app, we can refactor the codebase to MVVM. Moving to MVVM means that we no longer use SwiftUI's environment for our data. Instead, we inject our dependencies into each ViewModel. 

##### Ultimate architecture

// Image of final

</details>


