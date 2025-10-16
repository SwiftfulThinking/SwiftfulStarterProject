import SwiftUI

@MainActor
protocol ExperiencePointsExampleInteractor: GlobalInteractor {
    var currentExperiencePointsData: CurrentExperiencePointsData { get }
    @discardableResult func addExperiencePoints(points: Int, metadata: [String: GamificationDictionaryValue]) async throws -> ExperiencePointsEvent
}

extension CoreInteractor: ExperiencePointsExampleInteractor { }
