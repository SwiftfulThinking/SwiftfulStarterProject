//
//  SettingsRouter.swift
//  AIChatCourse
//
//  Created by Nick Sarno on 11/15/24.
//
import SwiftUI

@MainActor
protocol SettingsRouter {
    func showCreateAccountView(delegate: CreateAccountDelegate, onDismiss: (() -> Void)?)
    func dismissScreen()
    
    func showAlert(error: Error)
    func showAlert(_ option: AlertType, title: String, subtitle: String?, buttons: (@Sendable () -> AnyView)?)
    
    func dismissModal()
}

extension CoreRouter: SettingsRouter { }
