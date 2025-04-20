//
//  OnboardingCompletedInteractor.swift
//  
//
//  
//

@MainActor
protocol OnboardingCompletedInteractor: GlobalInteractor {
    func saveOnboardingComplete() async throws
}

extension CoreInteractor: OnboardingCompletedInteractor { }
