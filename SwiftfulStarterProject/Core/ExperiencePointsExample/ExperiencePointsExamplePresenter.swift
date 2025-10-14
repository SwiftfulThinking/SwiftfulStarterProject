import SwiftUI

@Observable
@MainActor
class ExperiencePointsExamplePresenter {

    private let interactor: ExperiencePointsExampleInteractor
    private let router: ExperiencePointsExampleRouter

    var currentExperiencePointsData: CurrentExperiencePointsData {
        interactor.currentExperiencePointsData
    }

    init(interactor: ExperiencePointsExampleInteractor, router: ExperiencePointsExampleRouter) {
        self.interactor = interactor
        self.router = router
    }

    func onViewAppear(delegate: ExperiencePointsExampleDelegate) {
        interactor.trackScreenEvent(event: Event.onAppear(delegate: delegate))
    }

    func onViewDisappear(delegate: ExperiencePointsExampleDelegate) {
        interactor.trackEvent(event: Event.onDisappear(delegate: delegate))
    }

    func addExperiencePoints(points: Int) async throws {
        try await interactor.addExperiencePoints(points: points, metadata: [:])
    }
}

extension ExperiencePointsExamplePresenter {
    
    enum Event: LoggableEvent {
        case onAppear(delegate: ExperiencePointsExampleDelegate)
        case onDisappear(delegate: ExperiencePointsExampleDelegate)

        var eventName: String {
            switch self {
            case .onAppear:                 return "ExperiencePointsExampleView_Appear"
            case .onDisappear:              return "ExperiencePointsExampleView_Disappear"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .onAppear(delegate: let delegate), .onDisappear(delegate: let delegate):
                return delegate.eventParameters
//            default:
//                return nil
            }
        }
        
        var type: LogType {
            switch self {
            default:
                return .analytic
            }
        }
    }

}
