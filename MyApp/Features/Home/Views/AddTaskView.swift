import SwiftUI

/// Modal form for creating a task.
struct AddTaskView: View {
    @State private var viewModel: AddTaskViewModel
    @Environment(\.dismiss) private var dismiss

    /// Creates the view with its view model.
    init(viewModel: AddTaskViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            Form {
                if let errorMessage = viewModel.errorMessage {
                    Section {
                        ErrorBanner(message: errorMessage)
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }

                Section {
                    TextField("Title", text: $viewModel.title)
                        .accessibilityIdentifier("addTask.title")
                    TextField("Notes", text: $viewModel.notes, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section {
                    Picker("Priority", selection: $viewModel.priority) {
                        ForEach(TaskPriority.allCases) { priority in
                            Text(priority.title).tag(priority)
                        }
                    }

                    Toggle("Due Date", isOn: $viewModel.hasDueDate.animation())

                    if viewModel.hasDueDate {
                        DatePicker("Date", selection: $viewModel.dueDate, in: Date.now..., displayedComponents: .date)
                    }
                }
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .disabled(viewModel.isSaving)
                }
                ToolbarItem(placement: .confirmationAction) {
                    if viewModel.isSaving {
                        ProgressView()
                    } else {
                        Button("Save") {
                            Task { await viewModel.save() }
                        }
                        .disabled(!viewModel.canSave)
                        .accessibilityIdentifier("addTask.save")
                    }
                }
            }
            .interactiveDismissDisabled(viewModel.isSaving)
            .onChange(of: viewModel.didSave) { _, didSave in
                if didSave { dismiss() }
            }
        }
    }
}

#Preview {
    AddTaskView(
        viewModel: AddTaskViewModel(taskService: MockTaskService(latency: .zero), onCreate: { _ in })
    )
}
