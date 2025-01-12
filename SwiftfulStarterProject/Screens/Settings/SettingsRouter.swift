//
//  SettingsRouter.swift
//  
//
//  
//
import SwiftUI

@MainActor
protocol SettingsRouter: GlobalRouter {
    func showCreateAccountView(delegate: CreateAccountDelegate, onDismiss: (() -> Void)?)
}

extension CoreRouter: SettingsRouter { }
