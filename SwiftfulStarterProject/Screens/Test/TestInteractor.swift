import SwiftUI

@MainActor
protocol TestInteractor: GlobalInteractor {
    
}

extension CoreInteractor: TestInteractor { }
