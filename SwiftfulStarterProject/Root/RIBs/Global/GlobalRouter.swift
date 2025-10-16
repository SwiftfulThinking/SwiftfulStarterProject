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
    
    func dismissScreen() {
        router.dismissScreen()
    }
    
    func dismissEnvironment() {
        router.dismissEnvironment()
    }
    
    func dismissPushStack() {
        router.dismissPushStack()
    }
    
    func dismissModal() {
        router.dismissModal()
    }
    
    func showNextScreen() throws {
        try router.tryShowNextScreen()
    }
    
    func showNextScreenOrDismissEnvironment() {
        router.showNextScreenOrDismissEnvironment()
    }
    
    func showNextScreenOrDismissPushStack() {
        router.showNextScreenOrDismissPushStack()
    }
    
    func showAlert(_ option: AlertStyle, title: String, subtitle: String?, buttons: (@Sendable () -> AnyView)?) {
        router.showAlert(option, title: title, subtitle: subtitle, buttons: {
            buttons?()
        })
    }
    
    func showSimpleAlert(title: String, subtitle: String?) {
        router.showAlert(.alert, title: title, subtitle: subtitle, buttons: { })
    }
    
    func showAlert(error: Error) {
        router.showAlert(.alert, title: "Error", subtitle: error.localizedDescription, buttons: { })
    }
    
    func dismissAlert() {
        router.dismissAlert()
    }
}
