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
    
    func dismissModal() {
        router.dismissModal()
    }
    
    func showAlert(_ option: DialogOption, title: String, subtitle: String?, buttons: (@Sendable () -> AnyView)?) {
        router.showAlert(option, title: title, subtitle: subtitle, alert: {
            buttons?()
        })
    }
    
    func showSimpleAlert(text: String) {
        router.showBasicAlert(text: text)
    }
    
    func showAlert(error: Error) {
        router.showAlert(.alert, title: "Error", subtitle: error.localizedDescription, alert: { })
    }
    
    func dismissAlert() {
        router.dismissAlert()
    }
}
