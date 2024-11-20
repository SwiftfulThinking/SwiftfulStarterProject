//
//  Error+EXT.swift
//  SwiftfulStarterProject
//
//  Created by Nick Sarno on 11/19/24.
//
import Foundation

extension Error {
    
    var eventParameters: [String: Any] {
        [
            "error_description": localizedDescription
        ]
    }
}

struct AppError: LocalizedError {
    let message: String

    init(_ message: String) {
        self.message = message
    }

    var errorDescription: String? {
        return message
    }
}
