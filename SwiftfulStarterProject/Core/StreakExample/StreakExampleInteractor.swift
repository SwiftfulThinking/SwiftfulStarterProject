import SwiftUI

@MainActor
protocol StreakExampleInteractor: GlobalInteractor {
    var currentStreakData: CurrentStreakData { get }
    func addStreakEvent(id: String, timestamp: Date, metadata: [String: GamificationDictionaryValue]) async throws -> StreakEvent
    func addStreakFreeze(id: String, expiresAt: Date?) async throws -> StreakFreeze
    func useStreakFreeze() async throws
}

extension CoreInteractor: StreakExampleInteractor {

    func useStreakFreeze() async throws {
        // Get all freezes and use the first unused one
        let freezes = try await getAllStreakFreezes()

        guard let firstUnusedFreeze = freezes.first(where: { $0.isAvailable }) else {
            throw NSError(domain: "StreakExample", code: 1, userInfo: [NSLocalizedDescriptionKey: "No freezes available"])
        }

        try await useStreakFreeze(freezeId: firstUnusedFreeze.id)
    }

}
