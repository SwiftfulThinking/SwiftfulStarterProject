import SwiftUI

struct StreakExampleDelegate {
    var eventParameters: [String: Any]? {
        nil
    }
}

struct StreakExampleView: View {

    @State var presenter: StreakExamplePresenter
    let delegate: StreakExampleDelegate
    @State private var errorMessage: String?

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

                // Streak Info
                VStack(spacing: 8) {
                    Text("Current Streak")
                        .font(.headline)
                    Text("\(presenter.currentStreakData.currentStreak ?? 0)")
                        .font(.system(size: 48, weight: .bold))
                    Text("Longest: \(presenter.currentStreakData.longestStreak ?? 0)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text("Freezes: \(presenter.currentStreakData.freezesRemaining ?? 0)")
                        .font(.subheadline)
                        .foregroundStyle(.blue)
                    if let lastEventDate = presenter.currentStreakData.lastEventDate {
                        Text("Last: \(lastEventDate.formatted(date: .abbreviated, time: .shortened))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    if let userId = presenter.currentStreakData.userId {
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

                // Buttons
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        Button("Add Streak Event") {
                            Task {
                                do {
                                    errorMessage = nil
                                    try await presenter.addStreakEvent()
                                } catch {
                                    errorMessage = "Error: \(error.localizedDescription)"
                                }
                            }
                        }
                        .buttonStyle(.borderedProminent)

                        Button("Add Freeze") {
                            Task {
                                do {
                                    errorMessage = nil
                                    try await presenter.addFreeze()
                                } catch {
                                    errorMessage = "Error: \(error.localizedDescription)"
                                }
                            }
                        }
                        .buttonStyle(.bordered)
                    }

                    Button("Use Freeze") {
                        Task {
                            do {
                                errorMessage = nil
                                try await presenter.useFreeze()
                            } catch {
                                errorMessage = "Error: \(error.localizedDescription)"
                            }
                        }
                    }
                    .buttonStyle(.bordered)
                    .disabled((presenter.currentStreakData.freezesRemaining ?? 0) == 0)
                }

                // Calendar
                MonthCalendarView(recentEvents: presenter.currentStreakData.recentEvents ?? [])
                    .padding()
            }
            .padding()
        }
        .navigationTitle("Streak Testing")
        .onAppear {
            presenter.onViewAppear(delegate: delegate)
        }
        .onDisappear {
            presenter.onViewDisappear(delegate: delegate)
        }
    }
}

struct MonthCalendarView: View {
    let recentEvents: [StreakEvent]
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

                    DayCell(
                        date: date,
                        events: dayEvents,
                        isCurrentMonth: isCurrentMonth
                    )
                }
            }
        }
    }
}

struct DayCell: View {
    let date: Date
    let events: [StreakEvent]
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
            HStack(spacing: 2) {
                if events.contains(where: { $0.isFreeze }) {
                    Circle()
                        .fill(.blue)
                        .frame(width: 4, height: 4)
                }
                if events.contains(where: { !$0.isFreeze }) {
                    Circle()
                        .fill(.green)
                        .frame(width: 4, height: 4)
                }
            }
            .frame(height: 4)
        }
    }

    private var backgroundColor: Color {
        if !isCurrentMonth {
            return .clear
        }

        let isToday = Calendar.current.isDateInToday(date)
        if isToday {
            return .blue.opacity(0.2)
        }

        if events.contains(where: { $0.isFreeze }) {
            return .blue.opacity(0.1)
        } else if !events.isEmpty {
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

#Preview("No Streak") {
    let container = DevPreview.shared.container()

    // Blank streak (0 days) but user is logged in
    let streakData = CurrentStreakData(
        streakKey: "workout",
        userId: "mock_user_123",
        currentStreak: 0,
        longestStreak: 0,
        totalEvents: 0,
        freezesRemaining: 0,
        eventsRequiredPerDay: 1,
        todayEventCount: 0
    )
    let streakManager = StreakManager(
        services: MockStreakServices(streak: streakData),
        configuration: StreakConfiguration.mockDefault()
    )
    container.register(StreakManager.self, key: Dependencies.streakConfiguration.streakKey, service: streakManager)

    let interactor = CoreInteractor(container: container)
    let builder = CoreBuilder(interactor: interactor)
    let delegate = StreakExampleDelegate()

    return RouterView { router in
        builder.streakExampleView(router: router, delegate: delegate)
    }
}

#Preview("5 Day Streak") {
    let container = DevPreview.shared.container()

    // 5 day active streak
    let streakData = CurrentStreakData.mockActive(currentStreak: 5)
    let streakManager = StreakManager(
        services: MockStreakServices(streak: streakData),
        configuration: StreakConfiguration.mockDefault()
    )
    container.register(StreakManager.self, key: Dependencies.streakConfiguration.streakKey, service: streakManager)

    let interactor = CoreInteractor(container: container)
    let builder = CoreBuilder(interactor: interactor)
    let delegate = StreakExampleDelegate()

    return RouterView { router in
        builder.streakExampleView(router: router, delegate: delegate)
    }
}

#Preview("Longest 10, Current 3") {
    let container = DevPreview.shared.container()

    // Create events for a previous 10-day streak and current 3-day streak
    var calendar = Calendar.current
    calendar.timeZone = .current
    let today = Date()

    var events: [StreakEvent] = []

    // Current 3-day streak (days 1-3 ago, NOT including today so streak is "at risk")
    for daysAgo in 1...3 {
        let date = calendar.date(byAdding: .day, value: -daysAgo, to: today)!
        events.append(StreakEvent.mock(timestamp: date))
    }

    // Gap of 2 days (breaks the streak)

    // Previous 10-day streak (days 6-15 ago)
    for daysAgo in 6...15 {
        let date = calendar.date(byAdding: .day, value: -daysAgo, to: today)!
        events.append(StreakEvent.mock(timestamp: date))
    }

    let streakData = CurrentStreakData.mockWithRecentEvents(
        streakKey: "workout",
        userId: "mock_user_123",
        recentEvents: events
    )

    let streakManager = StreakManager(
        services: MockStreakServices(streak: streakData),
        configuration: StreakConfiguration.mockDefault()
    )
    container.register(StreakManager.self, key: Dependencies.streakConfiguration.streakKey, service: streakManager)

    let interactor = CoreInteractor(container: container)
    let builder = CoreBuilder(interactor: interactor)
    let delegate = StreakExampleDelegate()

    return RouterView { router in
        builder.streakExampleView(router: router, delegate: delegate)
    }
}

extension CoreBuilder {
    
    func streakExampleView(router: AnyRouter, delegate: StreakExampleDelegate) -> some View {
        StreakExampleView(
            presenter: StreakExamplePresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
    
}

extension CoreRouter {
    
    func showStreakExampleView(delegate: StreakExampleDelegate) {
        router.showScreen(.push) { router in
            builder.streakExampleView(router: router, delegate: delegate)
        }
    }
    
}
