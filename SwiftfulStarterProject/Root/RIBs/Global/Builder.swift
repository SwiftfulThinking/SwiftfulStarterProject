//
//  Builder.swift
//  SwiftfulStarterProject
//
//  
//
import SwiftUI

@MainActor
protocol Builder {
    func build() -> AnyView
}
