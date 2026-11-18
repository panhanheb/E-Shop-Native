import SwiftUI

/// White pill button with a small brand-colored arrow circle, e.g. "Shop Now →".
struct ArrowPillButton: View {
    let title: LocalizedStringKey
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.sm) {
                Text(title)
                    .font(AppFont.caption.weight(.semibold))
                    .foregroundStyle(AppColors.primary)
                Image(systemName: AppImages.arrowRight)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(AppColors.onPrimary)
                    .frame(width: 22, height: 22)
                    .background(AppColors.primary, in: Circle())
            }
            .padding(.leading, AppSpacing.md)
            .padding(.trailing, AppSpacing.xs)
            .padding(.vertical, AppSpacing.xs)
            .background(AppColors.surface, in: Capsule())
            .shadow(color: AppColors.shadow, radius: 4, y: 2)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ArrowPillButton(title: "Shop Now") {}
        .padding()
        .background(AppColors.primarySoft)
}
