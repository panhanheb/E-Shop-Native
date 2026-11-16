import SwiftUI

/// Shows a task's details with actions to complete or delete it.
struct TaskDetailView: View {
    @State private var viewModel: TaskDetailViewModel
    @State private var isConfirmingDelete = false
    @Environment(\.dismiss) private var dismiss

    /// Creates the view with its view model.
    init(viewModel: TaskDetailViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    private var task: TaskItem { viewModel.task }

    private var statusTitle: LocalizedStringKey {
        task.isCompleted ? "Completed" : "In Progress"
    }

    private var toggleTitle: LocalizedStringKey {
        task.isCompleted ? "Mark as Incomplete" : "Mark as Complete"
    }

    var body: some View {
        Form {
            if let errorMessage = viewModel.errorMessage {
                Section {
                    ErrorBanner(message: errorMessage)
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            }

            Section {
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text(task.title)
                        .font(AppFont.title)
                    HStack(spacing: AppSpacing.sm) {
                        PriorityBadge(priority: task.priority)
                        Label(statusTitle, systemImage: task.isCompleted ? AppImages.checkmarkCircleFilled : AppImages.circle)
                            .font(AppFont.caption)
                            .foregroundStyle(task.isCompleted ? AppColors.success : AppColors.textSecondary)
                    }
                }
                .padding(.vertical, AppSpacing.xs)
            }

            Section("Notes") {
                if task.notes.isEmpty {
                    Text("No notes")
                        .foregroundStyle(AppColors.textSecondary)
                } else {
                    Text(task.notes)
                }
            }

            Section("Details") {
                LabeledContent("Due Date") {
                    if let dueDate = task.dueDate {
                        Text(dueDate, format: .dateTime.day().month().year())
                    } else {
                        Text("None")
                    }
                }
                LabeledContent("Created") {
                    Text(task.createdAt, format: .dateTime.day().month().year())
                }
            }

            Section {
                Button {
                    Task { await viewModel.toggleCompletion() }
                } label: {
                    Label(toggleTitle, systemImage: task.isCompleted ? AppImages.undo : AppImages.checkmark)
                }

                Button("Delete Task", role: .destructive) {
                    isConfirmingDelete = true
                }
            }
            .disabled(viewModel.isSaving)
        }
        .navigationTitle("Task")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if viewModel.isLoading || viewModel.isSaving {
                ToolbarItem(placement: .topBarTrailing) {
                    ProgressView()
                }
            }
        }
        .refreshable { await viewModel.refresh() }
        .task { await viewModel.refresh() }
        .confirmationDialog("Delete this task?", isPresented: $isConfirmingDelete, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                Task { await viewModel.delete() }
            }
        } message: {
            Text("This action cannot be undone.")
        }
        .onChange(of: viewModel.isDeleted) { _, isDeleted in
            if isDeleted { dismiss() }
        }
    }
}

#Preview {
    let dependencies = AppDependencies.preview
    NavigationStack {
        TaskDetailView(
            viewModel: dependencies.makeTaskDetailViewModel(task: .mock, onUpdate: { _ in }, onDelete: { _ in })
        )
    }
    .environment(dependencies)
}
