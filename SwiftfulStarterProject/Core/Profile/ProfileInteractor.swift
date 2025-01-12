import SwiftUI

@MainActor
protocol ProfileInteractor: GlobalInteractor {
    
}

extension CoreInteractor: ProfileInteractor { }
