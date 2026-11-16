import SwiftUI

/// Rounded-square white icon used for header buttons, with an optional count badge.
struct HeaderIconView: View {
    let systemImage: String
    var badgeCount = 0

    var body: some View {
        Image(systemName: systemImage)
            .font(.system(size: 18, weight: .medium))
            .foregroundStyle(AppColors.textPrimary)
            .frame(width: 46, height: 46)
            .background(AppColors.surface, in: RoundedRectangle(cornerRadius: AppRadius.medium))
            .shadow(color: AppColors.shadow, radius: 6, y: 2)
            .overlay(alignment: .topTrailing) {
                if badgeCount > 0 {
                    Text(badgeCount, format: .number)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(AppColors.onPrimary)
                        .frame(minWidth: 18, minHeight: 18)
                        .background(AppColors.primary, in: Circle())
                        .offset(x: 5, y: -5)
                }
            }
    }
}

#Preview {
    HStack(spacing: AppSpacing.md) {
        HeaderIconView(systemImage: AppImages.menu)
        HeaderIconView(systemImage: AppImages.notifications, badgeCount: 3)
        HeaderIconView(systemImage: AppImages.cart, badgeCount: 12)
    }
    .padding()
    .background(AppColors.background)
}
