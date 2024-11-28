//
//  DevSettingsRouter.swift
//  
//
//  
//

@MainActor
protocol DevSettingsRouter {
    func dismissScreen()
}

extension CoreRouter: DevSettingsRouter { }
