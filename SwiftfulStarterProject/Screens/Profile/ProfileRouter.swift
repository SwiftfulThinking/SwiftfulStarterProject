import SwiftUI

@MainActor
protocol ProfileRouter: GlobalRouter {
    func showSettingsView()
}

extension CoreRouter: ProfileRouter { }
