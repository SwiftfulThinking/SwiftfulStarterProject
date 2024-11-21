import SwiftUI

@MainActor
protocol TestRouter: GlobalRouter {
    
}

extension CoreRouter: TestRouter { }
