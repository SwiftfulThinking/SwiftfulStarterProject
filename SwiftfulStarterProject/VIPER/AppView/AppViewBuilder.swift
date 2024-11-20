//
//  AppViewBuilder.swift
//  AIChatCourse
//
//  Created by Nick Sarno on 10/5/24.
//
import SwiftUI

struct AppViewBuilder<TabbarView: View, OnboardingView: View>: View {

    var showTabBar: Bool = false
    var tabbarView: () -> TabbarView
    var onboardingView: () -> OnboardingView

    var body: some View {
        ZStack {
            if showTabBar {
                tabbarView()
                    .transition(.move(edge: .trailing))
            } else {
                onboardingView()
                    .transition(.move(edge: .leading))
            }
        }
        .animation(.smooth, value: showTabBar)
    }
}

private struct PreviewView: View {

    @State private var showTabBar: Bool = false

    var body: some View {
        AppViewBuilder(
            showTabBar: showTabBar,
            tabbarView: {
                ZStack {
                    Color.red.ignoresSafeArea()
                    Text("Tabbar")
                }
            },
            onboardingView: {
                ZStack {
                    Color.blue.ignoresSafeArea()
                    Text("Onboarding")
                }
            }
        )
        .onTapGesture {
            showTabBar.toggle()
        }
    }
}

#Preview {
    PreviewView()
}
