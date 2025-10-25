//
//  OnboardingConstants.swift
//  SwiftfulStarterProject
//
//  Created by Nick Sarno on 10/24/25.
//

import SwiftUI
import SwiftfulOnboarding

@MainActor
struct OnboardingConstants {

    static let headerConfiguration = OnbHeaderConfiguration(
        headerStyle: .progressBar,
        headerAlignment: .center,
        showBackButton: .afterFirstSlide,
        backButtonColor: .blue,
        progressBarAccentColor: .blue
    )

    static let slides: [OnbSlideType] = [
        .regular(
            id: "welcome",
            title: "Welcome!",
            subtitle: "Get started with our amazing app",
            media: .systemIcon(named: "star.fill"),
            mediaPosition: .top,
            contentAlignment: .center
        ),
        .multipleChoice(
            id: "interests",
            title: "What are you interested in?",
            subtitle: "Select all that apply",
            options: [
                OnbChoiceOption(
                    id: "tech",
                    content: OnbButtonContentData(
                        text: "Technology",
                        secondaryContent: .media(media: .systemIcon(named: "laptopcomputer", size: .small))
                    )
                ),
                OnbChoiceOption(
                    id: "design",
                    content: OnbButtonContentData(
                        text: "Design",
                        secondaryContent: .media(media: .systemIcon(named: "paintbrush", size: .small))
                    )
                ),
                OnbChoiceOption(
                    id: "business",
                    content: OnbButtonContentData(
                        text: "Business",
                        secondaryContent: .media(media: .systemIcon(named: "briefcase", size: .small))
                    )
                )
            ],
            selectionBehavior: .multi(max: 3),
            contentAlignment: .top
        )
    ]
}
