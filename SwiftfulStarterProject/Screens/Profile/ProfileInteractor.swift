import SwiftUI

@MainActor
protocol ProfileInteractor {
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: ProfileInteractor { }
