//
//  DevSettingsRouter.swift
//  AIChatCourse
//
//  Created by Nick Sarno on 11/15/24.
//

@MainActor
protocol DevSettingsRouter {
    func dismissScreen()
}

extension CoreRouter: DevSettingsRouter { }
