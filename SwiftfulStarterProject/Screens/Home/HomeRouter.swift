import SwiftUI

@MainActor
protocol HomeRouter: GlobalRouter {
    
}

extension CoreRouter: HomeRouter { }
