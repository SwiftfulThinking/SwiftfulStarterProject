import SwiftUI

@MainActor
protocol StreakExampleInteractor: GlobalInteractor {
    var currentStreakData: CurrentStreakData { get }
    @discardableResult func addStreakEvent(timestamp: Date, metadata: [String: GamificationDictionaryValue]) async throws -> StreakEvent
    @discardableResult func addStreakFreeze(id: String, expiresAt: Date?) async throws -> StreakFreeze
    func useStreakFreezes() async throws
}

extension CoreInteractor: StreakExampleInteractor { } 
