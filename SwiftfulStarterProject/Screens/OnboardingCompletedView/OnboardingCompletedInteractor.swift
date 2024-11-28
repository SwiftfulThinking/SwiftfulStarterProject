//
//  OnboardingCompletedInteractor.swift
//  
//
//  
//

@MainActor
protocol OnboardingCompletedInteractor: GlobalInteractor {
    func saveOnboardingComplete() async throws
    func updateAppState(showTabBarView: Bool)
}

extension CoreInteractor: OnboardingCompletedInteractor { }
