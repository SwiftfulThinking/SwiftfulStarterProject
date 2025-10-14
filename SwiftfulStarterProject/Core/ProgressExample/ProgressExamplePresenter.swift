import SwiftUI

@Observable
@MainActor
class ProgressExamplePresenter {

    private let interactor: ProgressExampleInteractor
    private let router: ProgressExampleRouter

    var allProgress: [String: Double] {
        interactor.getAllProgress()
    }

    var allProgressItems: [ProgressItem] {
        interactor.getAllProgressItems()
    }

    init(interactor: ProgressExampleInteractor, router: ProgressExampleRouter) {
        self.interactor = interactor
        self.router = router
    }

    func onViewAppear(delegate: ProgressExampleDelegate) {
        interactor.trackScreenEvent(event: Event.onAppear(delegate: delegate))
    }

    func onViewDisappear(delegate: ProgressExampleDelegate) {
        interactor.trackEvent(event: Event.onDisappear(delegate: delegate))
    }

    func addProgress(id: String, value: Double, metadata: [String: GamificationDictionaryValue]? = nil) async throws {
        try await interactor.addProgress(id: id, value: value, metadata: metadata)
    }

    func deleteProgress(id: String) async throws {
        try await interactor.deleteProgress(id: id)
    }

    func deleteAllProgress() async throws {
        try await interactor.deleteAllProgress()
    }
}

extension ProgressExamplePresenter {
    
    enum Event: LoggableEvent {
        case onAppear(delegate: ProgressExampleDelegate)
        case onDisappear(delegate: ProgressExampleDelegate)

        var eventName: String {
            switch self {
            case .onAppear:                 return "ProgressExampleView_Appear"
            case .onDisappear:              return "ProgressExampleView_Disappear"
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
