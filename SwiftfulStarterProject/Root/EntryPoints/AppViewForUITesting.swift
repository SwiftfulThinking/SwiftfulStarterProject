//
//  AppViewForUITesting.swift
//  SwiftfulStarterProject
//
//  
//
import SwiftUI

struct AppViewForUITesting: View {
    
    var container: DependencyContainer
    
    private var builder: CoreBuilder {
        CoreBuilder(interactor: CoreInteractor(container: container))
    }
    
    private func processInfoContains(_ value: String) -> Bool {
        ProcessInfo.processInfo.arguments.contains(value)
    }

    var body: some View {
        if processInfoContains("STARTSCREEN_[ADDSCREENNAME]") {
            RouterView { _ in
                Text("Screen")
            }
        } else {
            builder.build()
        }
    }
}
