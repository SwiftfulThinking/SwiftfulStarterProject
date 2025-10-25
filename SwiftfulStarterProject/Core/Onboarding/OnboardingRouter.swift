import SwiftUI

@MainActor
protocol OnboardingRouter: GlobalRouter {
    
}

extension CoreRouter: OnboardingRouter { }
