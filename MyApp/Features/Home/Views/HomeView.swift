import SwiftUI

/// The task list screen with search, filtering, and navigation to details.
struct HomeView: View {
    @State private var viewModel: TaskListViewModel
    @State private var isPresentingAddTask = false
    @Environment(AppDependencies.self) private var dependencies

    /// Creates the view with its view model.
    init(viewModel: TaskListViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Tasks")
                .searchable(text: $viewModel.searchText, prompt: "Search tasks")
                .toolbar { toolbarContent }
                .navigationDestination(for: TaskItem.self) { task in
                    TaskDetailView(
                        viewModel: dependencies.makeTaskDetailViewModel(
                            task: task,
                            onUpdate: { viewModel.didUpdate($0) },
                            onDelete: { viewModel.didDelete($0) }
                        )
                    )
                }
                .sheet(isPresented: $isPresentingAddTask) {
                    AddTaskView(viewModel: dependencies.makeAddTaskViewModel { viewModel.didCreate($0) })
                }
                .alert("Something Went Wrong", isPresented: $viewModel.isErrorAlertPresented) {
                    Button("OK", role: .cancel) {}
                } message: {
                    Text(viewModel.errorMessage ?? "")
                }
                .task { await viewModel.loadIfNeeded() }
        }
    }

    @ViewBuilder
    private var content: some View {
        if !viewModel.hasLoaded, let errorMessage = viewModel.errorMessage {
            ErrorStateView(message: errorMessage) {
                Task { await viewModel.loadTasks() }
            }
        } else if !viewModel.hasLoaded {
            LoadingView(message: "Loading tasks…")
        } else if viewModel.tasks.isEmpty {
            EmptyStateView(
                title: "No Tasks Yet",
                systemImage: "checklist",
                message: "Tap + to create your first task.",
                actionTitle: "Add Task"
            ) {
                isPresentingAddTask = true
            }
        } else if viewModel.visibleTasks.isEmpty {
            EmptyStateView(
                title: "No Matching Tasks",
                systemImage: "magnifyingglass",
                message: "Try a different search or filter."
            )
        } else {
            taskList
        }
    }

    private var taskList: some View {
        List {
            ForEach(viewModel.visibleTasks) { task in
                NavigationLink(value: task) {
                    TaskRowView(task: task) {
                        Task { await viewModel.toggleCompletion(of: task) }
                    }
                }
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        Task { await viewModel.delete(task) }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .refreshable { await viewModel.loadTasks() }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Menu {
                Picker("Filter", selection: $viewModel.filter) {
                    ForEach(TaskFilter.allCases) { filter in
                        Text(filter.title).tag(filter)
                    }
                }
            } label: {
                Label(
                    "Filter",
                    systemImage: viewModel.filter == .all
                        ? "line.3.horizontal.decrease.circle"
                        : "line.3.horizontal.decrease.circle.fill"
                )
            }
        }

        ToolbarItem(placement: .primaryAction) {
            Button {
                isPresentingAddTask = true
            } label: {
                Label("Add Task", systemImage: "plus")
            }
            .accessibilityIdentifier("tasks.add")
        }
    }
}

#Preview("Tasks") {
    let dependencies = AppDependencies.preview
    HomeView(viewModel: dependencies.makeTaskListViewModel())
        .environment(dependencies)
}

#Preview("Empty") {
    HomeView(viewModel: TaskListViewModel(taskService: MockTaskService(tasks: [], latency: .zero)))
        .environment(AppDependencies.preview)
}
