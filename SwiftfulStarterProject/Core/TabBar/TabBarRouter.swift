import SwiftUI

@MainActor
protocol TabBarRouter: GlobalRouter {
    func showCreateAccountView(delegate: CreateAccountDelegate, onDismiss: (() -> Void)?)
}

extension CoreRouter: TabBarRouter { }
