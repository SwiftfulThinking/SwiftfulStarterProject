import SwiftUI

@MainActor
protocol OnboardingRouter: GlobalRouter {
    func showOnboardingCompletedView(delegate: OnboardingCompletedDelegate)
}

extension CoreRouter: OnboardingRouter { }
