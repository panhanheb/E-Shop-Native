import SwiftUI

/// Top of Home: menu button, greeting, notifications bell, and shopping bag with item count.
struct HomeHeaderView: View {
    /// First name used in "Hello, …!".
    let firstName: String
    let cartCount: Int
    let onOpenSettings: () -> Void
    let onOpenNotifications: () -> Void
    let onOpenCart: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: AppSpacing.md) {
            Menu {
                Button(action: onOpenCart) {
                    Label("My Cart", systemImage: AppImages.cart)
                }
                Button(action: onOpenNotifications) {
                    Label("Notifications", systemImage: AppImages.notifications)
                }
                Button(action: onOpenSettings) {
                    Label("Settings", systemImage: AppImages.settings)
                }
            } label: {
                HeaderIconView(systemImage: AppImages.menu)
            }
            .accessibilityLabel(Text("Menu"))

            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                Text("Hello, \(firstName)! ✨")
                    .font(AppFont.callout)
                    .foregroundStyle(AppColors.textSecondary)
                Text("Discover Beauty")
                    .font(AppFont.title)
                    .foregroundStyle(AppColors.textPrimary)
                    .accessibilityIdentifier("home.title")
                Text("Premium beauty, just for you")
                    .font(AppFont.caption)
                    .foregroundStyle(AppColors.textSecondary)
            }

            Spacer(minLength: 0)

            Button(action: onOpenNotifications) {
                HeaderIconView(systemImage: AppImages.notifications)
            }
            .accessibilityLabel(Text("Notifications"))

            Button(action: onOpenCart) {
                HeaderIconView(systemImage: AppImages.cart, badgeCount: cartCount)
            }
            .accessibilityLabel(Text("My Cart"))
            .accessibilityIdentifier("home.cart")
        }
        .buttonStyle(.plain)
    }
}


#Preview {
    HomeHeaderView(firstName: "Alex", cartCount: 3, onOpenSettings: {}, onOpenNotifications: {}, onOpenCart: {})
        .padding()
        .background(AppColors.background)
}
