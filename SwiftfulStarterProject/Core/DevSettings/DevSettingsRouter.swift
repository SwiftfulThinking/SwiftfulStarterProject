//
//  DevSettingsRouter.swift
//  
//
//  
//

@MainActor
protocol DevSettingsRouter: GlobalRouter {
    func switchToOnboardingModule()
    func switchToCoreModule()
}

extension CoreRouter: DevSettingsRouter { }
