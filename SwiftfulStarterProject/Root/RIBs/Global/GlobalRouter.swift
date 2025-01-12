//
//  GlobalRouter.swift
//  SwiftfulStarterProject
//
//  
//
import SwiftUI

@MainActor
protocol GlobalRouter {
    var router: AnyRouter { get }
}

extension GlobalRouter {
    
    /// Dismiss the current screen
    func dismissScreen() {
        router.dismissScreen()
    }
    
    /// Dismiss the closest sheet or fullScreenCover
    func dismissEnvironment() {
        router.dismissEnvironment()
    }
    
    /// Dismiss all screens pushed onto the NavStack
    func dismissScreenStack() {
        router.dismissScreenStack()
    }
    
    func dismissModal(id: String?) {
        router.dismissModal(id: id)
    }
    
    func dismissAllModals() {
        router.dismissAllModals()
    }
    
    func showNextScreen() throws {
        try router.showNextScreen()
    }
    
    func showNextScreenOrDismissEnvironment() {
        do {
            try showNextScreen()
        } catch {
            dismissEnvironment()
        }
    }
    
    func showNextScreenOrDismissScreenStack() {
        do {
            try showNextScreen()
        } catch {
            dismissScreenStack()
        }
    }
    
    func showAlert(_ option: DialogOption, title: String, subtitle: String?, buttons: (@Sendable () -> AnyView)?) {
        router.showAlert(option, title: title, subtitle: subtitle, alert: {
            buttons?()
        })
    }
    
    func showSimpleAlert(title: String, subtitle: String?) {
        router.showAlert(.alert, title: title, subtitle: subtitle, alert: { })
    }
    
    func showAlert(error: Error) {
        router.showAlert(.alert, title: "Error", subtitle: error.localizedDescription, alert: { })
    }
    
    func dismissAlert() {
        router.dismissAlert()
    }
}
