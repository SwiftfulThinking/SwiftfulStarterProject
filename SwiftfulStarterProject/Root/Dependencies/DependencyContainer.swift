//
//  DependencyContainer.swift
//  SwiftfulStarterProject
//
//  
//
import SwiftUI

@Observable
@MainActor
class DependencyContainer {
    private var services: [String: Any] = [:]

    // MARK: - Register (without name)

    func register<T>(_ type: T.Type, service: T) {
        let key = "\(type)"
        services[key] = service
    }

    func register<T>(_ type: T.Type, service: () -> T) {
        let key = "\(type)"
        services[key] = service()
    }

    // MARK: - Register (with key)

    func register<T>(_ type: T.Type, key: String, service: T) {
        let key = "\(type)-\(key)"
        services[key] = service
    }

    func register<T>(_ type: T.Type, key: String, service: () -> T) {
        let key = "\(type)-\(key)"
        services[key] = service()
    }

    // MARK: - Resolve (without key)

    func resolve<T>(_ type: T.Type) -> T? {
        let key = "\(type)"
        return services[key] as? T
    }

    // MARK: - Resolve (with key)

    func resolve<T>(_ type: T.Type, key: String) -> T? {
        let key = "\(type)-\(key)"
        return services[key] as? T
    }
}
