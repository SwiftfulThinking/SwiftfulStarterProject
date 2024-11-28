//
//  WelcomeInteractor.swift
//  
//
//  
//

@MainActor
protocol WelcomeInteractor: GlobalInteractor {
    func updateAppState(showTabBarView: Bool)
}

extension CoreInteractor: WelcomeInteractor { }
