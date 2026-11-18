import SwiftUI

/// SF Symbol on a softly tinted rounded square, used at the start of list rows and cards.
struct IconTile: View {
    let systemImage: String
    var tint: Color = AppColors.primary
    var size: CGFloat = 36

    var body: some View {
        Image(systemName: systemImage)
            .font(.system(size: size * 0.45, weight: .semibold))
            .foregroundStyle(tint)
            .frame(width: size, height: size)
            .background(tint.opacity(0.12), in: RoundedRectangle(cornerRadius: size * 0.28, style: .continuous))
            .accessibilityHidden(true)
    }
}

#Preview {
    HStack(spacing: AppSpacing.md) {
        IconTile(systemImage: AppImages.orders)
        IconTile(systemImage: AppImages.settings, tint: AppColors.accentBlue)
        IconTile(systemImage: AppImages.categorySkincare, tint: AppColors.accentAmber, size: 52)
    }
    .padding()
}
