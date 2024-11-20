//
//  ABTestService.swift
//  AIChatCourse
//
//  Created by Nick Sarno on 10/31/24.
//

@MainActor
protocol ABTestService: Sendable {
    var activeTests: ActiveABTests { get }
    func saveUpdatedConfig(updatedTests: ActiveABTests) throws
    func fetchUpdatedConfig() async throws -> ActiveABTests
}
