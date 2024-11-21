import SwiftUI

@MainActor
protocol ProfileRouter {
    func showSettingsView()
}

extension CoreRouter: ProfileRouter { }
