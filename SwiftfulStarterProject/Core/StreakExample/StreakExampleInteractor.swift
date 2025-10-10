import SwiftUI

@MainActor
protocol StreakExampleInteractor: GlobalInteractor {
    var currentStreakData: CurrentStreakData { get }
    func addStreakEvent(id: String, timestamp: Date, metadata: [String: GamificationDictionaryValue]) async throws -> StreakEvent
    func addStreakFreeze(id: String, expiresAt: Date?) async throws -> StreakFreeze
}

extension CoreInteractor: StreakExampleInteractor { }
