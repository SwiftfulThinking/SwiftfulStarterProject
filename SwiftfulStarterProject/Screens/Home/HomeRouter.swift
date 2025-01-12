import SwiftUI

@MainActor
protocol HomeRouter: GlobalRouter {
    func showDevSettingsView()
}

extension CoreRouter: HomeRouter { }
