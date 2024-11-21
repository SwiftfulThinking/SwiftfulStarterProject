//
//  SwiftfulStarterProjectApp.swift
//  SwiftfulStarterProject
//
//  Created by Nick Sarno on 11/19/24.
//

import SwiftUI

@main
struct AppEntryPoint {
    
    /// Entry point is either (1) empty build for Unit Testing or (2) actual app.
    static func main() {
        if Utilities.isUnitTesting {
            AppViewForUnitTesting.main()
        } else {
            SwiftfulStarterProjectApp.main()
        }
    }
}

struct SwiftfulStarterProjectApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            Group {
                if Utilities.isUITesting {
                    AppViewForUITesting(container: delegate.dependencies.container)
                } else {
                    delegate.builder.build()
                }
            }
        }
    }
}
