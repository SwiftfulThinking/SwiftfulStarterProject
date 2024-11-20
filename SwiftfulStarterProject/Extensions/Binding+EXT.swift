//
//  Binding+EXT.swift
//  AIChatCourse
//
//  Created by Nick Sarno on 10/11/24.
//
import SwiftUI
import Foundation

extension Binding where Value == Bool {
    
    init<T: Sendable>(ifNotNil value: Binding<T?>) {
        self.init {
            value.wrappedValue != nil
        } set: { newValue in
            if !newValue {
                value.wrappedValue = nil
            }
        }
    }
}
