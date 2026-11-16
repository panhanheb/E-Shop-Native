import SwiftUI

/// A row in the task list with a completion toggle.
struct TaskRowView: View {
    /// The task to display.
    let task: TaskItem
    /// Called when the completion button is tapped.
    let onToggle: () -> Void

    private var toggleLabel: LocalizedStringKey {
        task.isCompleted ? "Mark as incomplete" : "Mark as complete"
    }

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            Button(action: onToggle) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(task.isCompleted ? AppColor.success : AppColor.textSecondary)
            }
            .buttonStyle(.borderless)
            .accessibilityLabel(toggleLabel)

            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(task.title)
                    .font(AppFont.headline)
                    .strikethrough(task.isCompleted)
                    .foregroundStyle(task.isCompleted ? AppColor.textSecondary : AppColor.textPrimary)
                    .lineLimit(2)

                if let dueDate = task.dueDate {
                    Label {
                        Text(dueDate, format: .dateTime.day().month(.abbreviated))
                    } icon: {
                        Image(systemName: "calendar")
                    }
                    .font(AppFont.caption)
                    .foregroundStyle(AppColor.textSecondary)
                }
            }

            Spacer(minLength: AppSpacing.sm)

            PriorityBadge(priority: task.priority)
        }
        .padding(.vertical, AppSpacing.xs)
    }
}

#Preview {
    List {
        ForEach(TaskItem.mocks) { task in
            TaskRowView(task: task) {}
        }
    }
}
