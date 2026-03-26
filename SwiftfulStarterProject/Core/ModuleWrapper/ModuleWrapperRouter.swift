import SwiftUI

@MainActor
protocol ModuleWrapperRouter: GlobalRouter {
    func showDevSettingsView()
}

extension CoreRouter: ModuleWrapperRouter { }
