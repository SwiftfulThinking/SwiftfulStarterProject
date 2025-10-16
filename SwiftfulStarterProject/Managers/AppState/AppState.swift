//
//  AppState.swift
//  SwiftfulStarterProject
//
//  
//
import SwiftUI
import SwiftfulRouting

@MainActor
@Observable
class AppState {
    
    let startingModuleId: String
    
    init(startingModuleId: String = UserDefaults.lastModuleId) {
        self.startingModuleId = startingModuleId
    }
    
}
