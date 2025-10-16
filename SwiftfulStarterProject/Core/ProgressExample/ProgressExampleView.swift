import SwiftUI

struct ProgressExampleDelegate {
    var eventParameters: [String: Any]? {
        nil
    }
}

struct ProgressExampleView: View {

    @State var presenter: ProgressExamplePresenter
    let delegate: ProgressExampleDelegate
    @State private var errorMessage: String?
    @State private var newId: String = ""
    @State private var newValue: String = "0.5"
    @State private var showAddSheet: Bool = false

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

                // Progress Summary
                VStack(spacing: 8) {
                    Text("Progress Items")
                        .font(.headline)
                    Text("\(presenter.allProgressItems.count)")
                        .font(.system(size: 48, weight: .bold))
                    if presenter.allProgressItems.isEmpty {
                        Text("No progress items")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()

                // Add Progress Button
                Button("Add Progress Item") {
                    showAddSheet = true
                }
                .buttonStyle(.borderedProminent)

                // Progress Items List
                if !presenter.allProgressItems.isEmpty {
                    VStack(spacing: 12) {
                        ForEach(presenter.allProgressItems, id: \.id) { item in
                            ProgressItemCard(
                                item: item,
                                onDelete: {
                                    Task {
                                        do {
                                            errorMessage = nil
                                            try await presenter.deleteProgress(id: item.id)
                                        } catch {
                                            errorMessage = "Error: \(error.localizedDescription)"
                                        }
                                    }
                                }
                            )
                        }

                        // Delete All Button
                        Button("Delete All Progress") {
                            Task {
                                do {
                                    errorMessage = nil
                                    try await presenter.deleteAllProgress()
                                } catch {
                                    errorMessage = "Error: \(error.localizedDescription)"
                                }
                            }
                        }
                        .buttonStyle(.bordered)
                        .tint(.red)
                    }
                    .padding(.horizontal)
                }
            }
            .padding()
        }
        .navigationTitle("Progress Testing")
        .onAppear {
            presenter.onViewAppear(delegate: delegate)
        }
        .onDisappear {
            presenter.onViewDisappear(delegate: delegate)
        }
        .sheet(isPresented: $showAddSheet) {
            NavigationStack {
                Form {
                    Section("Progress Details") {
                        TextField("ID (e.g., level_1, world_2)", text: $newId)
                        TextField("Value (0.0 - 1.0)", text: $newValue)
                            .keyboardType(.decimalPad)
                    }
                }
                .navigationTitle("Add Progress")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            showAddSheet = false
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Add") {
                            Task {
                                do {
                                    errorMessage = nil
                                    guard !newId.isEmpty else {
                                        errorMessage = "ID cannot be empty"
                                        return
                                    }
                                    guard let value = Double(newValue), value >= 0.0, value <= 1.0 else {
                                        errorMessage = "Value must be between 0.0 and 1.0"
                                        return
                                    }
                                    try await presenter.addProgress(id: newId, value: value)
                                    showAddSheet = false
                                    newId = ""
                                    newValue = "0.5"
                                } catch {
                                    errorMessage = "Error: \(error.localizedDescription)"
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

struct ProgressItemCard: View {
    let item: ProgressItem
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.id)
                        .font(.headline)
                    Text("Progress: \(Int(item.value * 100))%")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    if !item.metadata.isEmpty {
                        Text("Metadata: \(item.metadata.count) items")
                            .font(.caption)
                            .foregroundStyle(.blue)
                    }
                }

                Spacer()

                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundStyle(.red)
                }
                .buttonStyle(.bordered)
            }

            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                        .cornerRadius(4)

                    Rectangle()
                        .fill(Color.blue)
                        .frame(width: geometry.size.width * item.value, height: 8)
                        .cornerRadius(4)
                }
            }
            .frame(height: 8)

            HStack {
                Text("Created: \(item.dateCreated.formatted(date: .abbreviated, time: .shortened))")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("Modified: \(item.dateModified.formatted(date: .abbreviated, time: .shortened))")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

#Preview("No Progress") {
    let container = DevPreview.shared.container()

    // Empty progress (no items) but user is logged in
    let progressManager = ProgressManager(
        services: MockProgressServices(items: []),
        configuration: ProgressConfiguration.mockDefault()
    )
    Task { try? await progressManager.logIn(userId: "mock_user_123") }
    container.register(ProgressManager.self, key: Constants.progressKey, service: progressManager)

    let interactor = CoreInteractor(container: container)
    let builder = CoreBuilder(interactor: interactor)
    let delegate = ProgressExampleDelegate()

    return RouterView { router in
        builder.progressExampleView(router: router, delegate: delegate)
    }
}

#Preview("Single Item") {
    let container = DevPreview.shared.container()

    // Single progress item at 50%
    let items = [
        ProgressItem.mock(id: "level_1", progressKey: "default", value: 0.5)
    ]
    let progressManager = ProgressManager(
        services: MockProgressServices(items: items),
        configuration: ProgressConfiguration.mockDefault()
    )
    Task { try? await progressManager.logIn(userId: "mock_user_123") }
    container.register(ProgressManager.self, key: Constants.progressKey, service: progressManager)

    let interactor = CoreInteractor(container: container)
    let builder = CoreBuilder(interactor: interactor)
    let delegate = ProgressExampleDelegate()

    return RouterView { router in
        builder.progressExampleView(router: router, delegate: delegate)
    }
}

#Preview("Multiple Items") {
    let container = DevPreview.shared.container()

    // Multiple progress items with varying values
    let items = [
        ProgressItem.mock(id: "level_1", progressKey: "default", value: 1.0),
        ProgressItem.mock(id: "level_2", progressKey: "default", value: 0.75),
        ProgressItem.mock(id: "level_3", progressKey: "default", value: 0.5),
        ProgressItem.mock(id: "level_4", progressKey: "default", value: 0.25),
        ProgressItem.mock(id: "level_5", progressKey: "default", value: 0.0)
    ]
    let progressManager = ProgressManager(
        services: MockProgressServices(items: items),
        configuration: ProgressConfiguration.mockDefault()
    )
    Task { try? await progressManager.logIn(userId: "mock_user_123") }
    container.register(ProgressManager.self, key: Constants.progressKey, service: progressManager)

    let interactor = CoreInteractor(container: container)
    let builder = CoreBuilder(interactor: interactor)
    let delegate = ProgressExampleDelegate()

    return RouterView { router in
        builder.progressExampleView(router: router, delegate: delegate)
    }
}

#Preview("With Metadata") {
    let container = DevPreview.shared.container()

    // Progress items with metadata
    let items = [
        ProgressItem(
            id: "world_1_level_1",
            progressKey: "default",
            value: 1.0,
            metadata: ["world": .string("world_1"), "difficulty": .string("easy")]
        ),
        ProgressItem(
            id: "world_1_level_2",
            progressKey: "default",
            value: 0.8,
            metadata: ["world": .string("world_1"), "difficulty": .string("medium")]
        ),
        ProgressItem(
            id: "world_2_level_1",
            progressKey: "default",
            value: 0.5,
            metadata: ["world": .string("world_2"), "difficulty": .string("hard")]
        )
    ]
    let progressManager = ProgressManager(
        services: MockProgressServices(items: items),
        configuration: ProgressConfiguration.mockDefault()
    )
    Task { try? await progressManager.logIn(userId: "mock_user_123") }
    container.register(ProgressManager.self, key: Constants.progressKey, service: progressManager)

    let interactor = CoreInteractor(container: container)
    let builder = CoreBuilder(interactor: interactor)
    let delegate = ProgressExampleDelegate()

    return RouterView { router in
        builder.progressExampleView(router: router, delegate: delegate)
    }
}

#Preview("Many Items") {
    let container = DevPreview.shared.container()

    // Many progress items
    let items = (1...20).map { index in
        ProgressItem.mock(
            id: "item_\(index)",
            progressKey: "default",
            value: Double(index) / 20.0
        )
    }
    let progressManager = ProgressManager(
        services: MockProgressServices(items: items),
        configuration: ProgressConfiguration.mockDefault()
    )
    Task { try? await progressManager.logIn(userId: "mock_user_123") }
    container.register(ProgressManager.self, key: Constants.progressKey, service: progressManager)

    let interactor = CoreInteractor(container: container)
    let builder = CoreBuilder(interactor: interactor)
    let delegate = ProgressExampleDelegate()

    return RouterView { router in
        builder.progressExampleView(router: router, delegate: delegate)
    }
}

extension CoreBuilder {
    
    func progressExampleView(router: AnyRouter, delegate: ProgressExampleDelegate) -> some View {
        ProgressExampleView(
            presenter: ProgressExamplePresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
    
}

extension CoreRouter {
    
    func showProgressExampleView(delegate: ProgressExampleDelegate) {
        router.showScreen(.push) { router in
            builder.progressExampleView(router: router, delegate: delegate)
        }
    }
    
}
