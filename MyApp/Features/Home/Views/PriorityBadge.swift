import SwiftUI

/// Capsule badge showing a task's priority.
struct PriorityBadge: View {
    /// The priority to display.
    let priority: TaskPriority

    var body: some View {
        Text(priority.title)
            .font(AppFont.captionEmphasized)
            .foregroundStyle(priority.color)
            .padding(.horizontal, AppSpacing.sm)
            .padding(.vertical, AppSpacing.xs)
            .background(priority.color.opacity(0.15), in: Capsule())
    }
}

#Preview {
    HStack {
        ForEach(TaskPriority.allCases) { PriorityBadge(priority: $0) }
    }
}
