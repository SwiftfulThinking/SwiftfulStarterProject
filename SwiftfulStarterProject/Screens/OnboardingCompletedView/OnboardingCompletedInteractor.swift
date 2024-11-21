//
//  OnboardingCompletedInteractor.swift
//  AIChatCourse
//
//  Created by Nick Sarno on 11/15/24.
//

@MainActor
protocol OnboardingCompletedInteractor {
    func trackEvent(event: LoggableEvent)
    func markOnboardingCompleteForCurrentUser() async throws
    func updateAppState(showTabBarView: Bool)
}

extension CoreInteractor: OnboardingCompletedInteractor { }
