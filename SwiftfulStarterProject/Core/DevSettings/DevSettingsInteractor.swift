//
//  DevSettingsInteractor.swift
//  
//
//  
//
@MainActor
protocol DevSettingsInteractor: GlobalInteractor {
    var activeTests: ActiveABTests { get } // #feature: abtesting
    var auth: UserAuthInfo? { get }
    var currentUser: UserModel? { get }

    func override(updateTests: ActiveABTests) throws // #feature: abtesting
}

extension CoreInteractor: DevSettingsInteractor { }
