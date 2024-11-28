//
//  SettingsRouter.swift
//  
//
//  
//
import SwiftUI

@MainActor
protocol SettingsRouter {
    func showCreateAccountView(delegate: CreateAccountDelegate, onDismiss: (() -> Void)?)
    func dismissScreen()
    
    func showAlert(error: Error)
    func showAlert(_ option: DialogOption, title: String, subtitle: String?, buttons: (@Sendable () -> AnyView)?)
    
    func dismissModal()
}

extension CoreRouter: SettingsRouter { }
