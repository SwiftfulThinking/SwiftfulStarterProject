//
//  WelcomeInteractor.swift
//  AIChatCourse
//
//  Created by Nick Sarno on 11/15/24.
//

@MainActor
protocol WelcomeInteractor: GlobalInteractor {
    func updateAppState(showTabBarView: Bool)
}

extension CoreInteractor: WelcomeInteractor { }
