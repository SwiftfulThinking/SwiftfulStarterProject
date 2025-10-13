import SwiftUI

struct ExperiencePointsExampleDelegate {
    var eventParameters: [String: Any]? {
        nil
    }
}

struct ExperiencePointsExampleView: View {

    @State var presenter: ExperiencePointsExamplePresenter
    let delegate: ExperiencePointsExampleDelegate
    @State private var errorMessage: String?
    @State private var pointsToAdd: String = "100"

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Error message
                if let errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .padding(.horizontal)
                }

                // Experience Points Info
                VStack(spacing: 8) {
                    Text("Experience Points")
                        .font(.headline)
                    Text("\(presenter.currentExperiencePointsData.totalPoints ?? 0) XP")
                        .font(.system(size: 48, weight: .bold))
                    Text("Total Events: \(presenter.currentExperiencePointsData.totalEvents ?? 0)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text("Today: \(presenter.currentExperiencePointsData.todayEventCount ?? 0) events")
                        .font(.subheadline)
                        .foregroundStyle(.blue)
                    if let lastEventDate = presenter.currentExperiencePointsData.lastEventDate {
                        Text("Last: \(lastEventDate.formatted(date: .abbreviated, time: .shortened))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    if let userId = presenter.currentExperiencePointsData.userId {
                        Text("User: \(userId)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("Not logged in")
                            .font(.caption2)
                            .foregroundStyle(.orange)
                    }
                }
                .padding()

                // Add Points Input
                VStack(spacing: 12) {
                    HStack {
                        Text("Points:")
                        TextField("100", text: $pointsToAdd)
                            .keyboardType(.numberPad)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 100)
                    }

                    Button("Add Experience Points") {
                        Task {
                            do {
                                errorMessage = nil
                                guard let points = Int(pointsToAdd), points > 0 else {
                                    errorMessage = "Please enter a valid number"
                                    return
                                }
                                try await presenter.addExperiencePoints(points: points)
                            } catch {
                                errorMessage = "Error: \(error.localizedDescription)"
                            }
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }

                // Recent Events Calendar
                if let recentEvents = presenter.currentExperiencePointsData.recentEvents {
                    ExperiencePointsCalendarView(recentEvents: recentEvents)
                        .padding()
                }
            }
            .padding()
        }
        .navigationTitle("XP Testing")
        .onAppear {
            presenter.onViewAppear(delegate: delegate)
        }
        .onDisappear {
            presenter.onViewDisappear(delegate: delegate)
        }
    }
}

struct ExperiencePointsCalendarView: View {
    let recentEvents: [ExperiencePointsEvent]
    @State private var currentMonth = Date()

    private var calendar: Calendar {
        Calendar.current
    }

    private var monthYearText: String {
        currentMonth.formatted(.dateTime.month(.wide).year())
    }

    private var daysInMonth: [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start) else {
            return []
        }

        var dates: [Date] = []
        var currentDate = monthFirstWeek.start

        while currentDate < monthInterval.end {
            dates.append(currentDate)
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = nextDate
        }

        return dates
    }

    var body: some View {
        VStack(spacing: 12) {
            Text(monthYearText)
                .font(.headline)

            // Day headers
            HStack(spacing: 0) {
                ForEach(["S", "M", "T", "W", "T", "F", "S"], id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }

            // Calendar grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(daysInMonth, id: \.self) { date in
                    let isCurrentMonth = calendar.isDate(date, equalTo: currentMonth, toGranularity: .month)
                    let dayEvents = recentEvents.filter { event in
                        calendar.isDate(event.timestamp, inSameDayAs: date)
                    }
                    let totalPoints = dayEvents.reduce(0) { $0 + $1.points }

                    ExperienceDayCell(
                        date: date,
                        totalPoints: totalPoints,
                        eventCount: dayEvents.count,
                        isCurrentMonth: isCurrentMonth
                    )
                }
            }
        }
    }
}

struct ExperienceDayCell: View {
    let date: Date
    let totalPoints: Int
    let eventCount: Int
    let isCurrentMonth: Bool

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(backgroundColor)
                    .frame(width: 36, height: 36)

                Text(date, format: .dateTime.day())
                    .font(.caption)
                    .foregroundStyle(textColor)
            }

            // Event indicator
            if eventCount > 0 {
                Text("\(totalPoints)")
                    .font(.system(size: 8))
                    .foregroundStyle(.green)
            }
        }
        .frame(height: 50)
    }

    private var backgroundColor: Color {
        if !isCurrentMonth {
            return .clear
        }

        let isToday = Calendar.current.isDateInToday(date)
        if isToday {
            return .blue.opacity(0.2)
        }

        if eventCount > 0 {
            return .green.opacity(0.1)
        }

        return .clear
    }

    private var textColor: Color {
        if !isCurrentMonth {
            return .gray.opacity(0.3)
        }
        return .primary
    }
}

#Preview("No XP") {
    let container = DevPreview.shared.container()

    // Blank XP (0 points) but user is logged in
    let xpData = CurrentExperiencePointsData(
        experienceKey: "main",
        userId: "mock_user_123",
        totalPoints: 0,
        totalEvents: 0,
        todayEventCount: 0
    )
    let xpManager = ExperiencePointsManager(
        services: MockExperiencePointsServices(data: xpData),
        configuration: ExperiencePointsConfiguration.mockDefault()
    )
    Task { try? await xpManager.logIn(userId: "mock_user_123") }
    container.register(ExperiencePointsManager.self, key: Constants.xpKey, service: xpManager)

    let interactor = CoreInteractor(container: container)
    let builder = CoreBuilder(interactor: interactor)
    let delegate = ExperiencePointsExampleDelegate()

    return RouterView { router in
        builder.experiencePointsExampleView(router: router, delegate: delegate)
    }
}

#Preview("Active XP") {
    let container = DevPreview.shared.container()

    // Active XP with some points
    let xpData = CurrentExperiencePointsData.mockActive(totalPoints: 2500)
    let xpManager = ExperiencePointsManager(
        services: MockExperiencePointsServices(data: xpData),
        configuration: ExperiencePointsConfiguration.mockDefault()
    )
    Task { try? await xpManager.logIn(userId: "mock_user_123") }
    container.register(ExperiencePointsManager.self, key: Constants.xpKey, service: xpManager)

    let interactor = CoreInteractor(container: container)
    let builder = CoreBuilder(interactor: interactor)
    let delegate = ExperiencePointsExampleDelegate()

    return RouterView { router in
        builder.experiencePointsExampleView(router: router, delegate: delegate)
    }
}

#Preview("With Recent Events") {
    let container = DevPreview.shared.container()

    // XP with recent events showing on calendar
    let xpData = CurrentExperiencePointsData.mockWithRecentEvents(eventCount: 10)
    let xpManager = ExperiencePointsManager(
        services: MockExperiencePointsServices(data: xpData),
        configuration: ExperiencePointsConfiguration.mockDefault()
    )
    Task { try? await xpManager.logIn(userId: "mock_user_123") }
    container.register(ExperiencePointsManager.self, key: Constants.xpKey, service: xpManager)

    let interactor = CoreInteractor(container: container)
    let builder = CoreBuilder(interactor: interactor)
    let delegate = ExperiencePointsExampleDelegate()

    return RouterView { router in
        builder.experiencePointsExampleView(router: router, delegate: delegate)
    }
}

#Preview("High XP User") {
    let container = DevPreview.shared.container()

    // User with high XP total
    let xpData = CurrentExperiencePointsData(
        experienceKey: "main",
        userId: "mock_user_123",
        totalPoints: 50000,
        totalEvents: 1000,
        todayEventCount: 15,
        lastEventDate: Date(),
        createdAt: Calendar.current.date(byAdding: .year, value: -1, to: Date()),
        updatedAt: Date()
    )
    let xpManager = ExperiencePointsManager(
        services: MockExperiencePointsServices(data: xpData),
        configuration: ExperiencePointsConfiguration.mockDefault()
    )
    Task { try? await xpManager.logIn(userId: "mock_user_123") }
    container.register(ExperiencePointsManager.self, key: Constants.xpKey, service: xpManager)

    let interactor = CoreInteractor(container: container)
    let builder = CoreBuilder(interactor: interactor)
    let delegate = ExperiencePointsExampleDelegate()

    return RouterView { router in
        builder.experiencePointsExampleView(router: router, delegate: delegate)
    }
}

extension CoreBuilder {

    func experiencePointsExampleView(router: AnyRouter, delegate: ExperiencePointsExampleDelegate) -> some View {
        ExperiencePointsExampleView(
            presenter: ExperiencePointsExamplePresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }

}

extension CoreRouter {

    func showExperiencePointsExampleView(delegate: ExperiencePointsExampleDelegate) {
        router.showScreen(.push) { router in
            builder.experiencePointsExampleView(router: router, delegate: delegate)
        }
    }

}
