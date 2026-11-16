import SwiftUI

/// Notification inbox. Empty until push notifications are connected to the backend.
struct NotificationsView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            EmptyStateView(
                title: "No Notifications Yet",
                systemImage: AppImages.notifications,
                message: "We'll let you know about new arrivals, special offers, and order updates."
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppColors.background)
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    NotificationsView()
}
