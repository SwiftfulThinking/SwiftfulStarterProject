//
//  DevSettingsPresenter.swift
//  
//
//  
//
import SwiftUI
import SwiftfulUtilities

@Observable
@MainActor
class DevSettingsPresenter {
    
    private let interactor: DevSettingsInteractor
    private let router: DevSettingsRouter

    var boolTest: Bool = false
    var enumTest: EnumTestOption = .default
    
    var authData: [(key: String, value: Any)] {
        interactor.auth?.eventParameters.asAlphabeticalArray ?? []
    }
    
    var userData: [(key: String, value: Any)] {
        interactor.currentUser?.eventParameters.asAlphabeticalArray ?? []
    }
    
    var utilitiesData: [(key: String, value: Any)] {
        Utilities.eventParameters.asAlphabeticalArray
    }

    init(interactor: DevSettingsInteractor, router: DevSettingsRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    func onViewAppear() {
        interactor.trackScreenEvent(event: Event.onAppear)
    }
    
    func onViewDisappear() {
        interactor.trackEvent(event: Event.onDisappear)
    }
    
    func loadABTests() {
        boolTest = interactor.activeTests.boolTest
        enumTest = interactor.activeTests.enumTest
    }

    func handleBoolTestChange(oldValue: Bool, newValue: Bool) {
        updateTest(
            property: &boolTest,
            newValue: newValue,
            savedValue: interactor.activeTests.boolTest,
            updateAction: { tests in
                tests.update(boolTest: newValue)
            }
        )
    }
    
    func handleEnumTestChange(oldValue: EnumTestOption, newValue: EnumTestOption) {
        updateTest(
            property: &enumTest,
            newValue: newValue,
            savedValue: interactor.activeTests.enumTest,
            updateAction: { tests in
                tests.update(enumTest: newValue)
            }
        )
    }
        
    private func updateTest<Value: Equatable>(
        property: inout Value,
        newValue: Value,
        savedValue: Value,
        updateAction: (inout ActiveABTests) -> Void
    ) {
        if newValue != savedValue {
            do {
                var tests = interactor.activeTests
                updateAction(&tests)
                try interactor.override(updateTests: tests)
            } catch {
                property = savedValue
            }
        }
    }

    func onBackButtonPressed() {
        router.dismissScreen()
    }

}

extension DevSettingsPresenter {
    
    enum Event: LoggableEvent {
        case onAppear
        case onDisappear

        var eventName: String {
            switch self {
            case .onAppear:             return "TestView_Appear"
            case .onDisappear:          return "TestView_Disappear"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            default:
                return .analytic
            }
        }
    }
    
}
