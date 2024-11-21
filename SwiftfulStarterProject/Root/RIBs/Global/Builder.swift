//
//  Builder.swift
//  SwiftfulStarterProject
//
//  Created by Nick Sarno on 11/19/24.
//
import SwiftUI

@MainActor
protocol Builder {
    func build() -> AnyView
}
