//
//  GlobalRouter.swift
//  SwiftfulStarterProject
//
//  Created by Nick Sarno on 11/21/24.
//
import SwiftUI

@MainActor
protocol GlobalRouter {
    var router: Router { get }
}

extension GlobalRouter {
    
    func dismissScreen() {
        router.dismissScreen()
    }
    
    func dismissModal() {
        router.dismissModal()
    }
    
    func showAlert(_ option: AlertType, title: String, subtitle: String?, buttons: (@Sendable () -> AnyView)?) {
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
