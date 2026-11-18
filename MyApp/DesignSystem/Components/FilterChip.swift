import SwiftUI

/// Capsule filter chip with an optional leading icon. Selected chips are filled with the brand color.
struct FilterChip: View {
    let title: LocalizedStringKey
    var systemImage: String?
    var isSelected = false

    var body: some View {
        HStack(spacing: AppSpacing.xs + AppSpacing.xxs) {
            if let systemImage {
                Image(systemName: systemImage)
                    .font(.system(size: 12, weight: .semibold))
            }
            Text(title)
                .lineLimit(1)
        }
        .font(AppFont.subheadline.weight(.medium))
        .foregroundStyle(isSelected ? AppColors.onPrimary : AppColors.textPrimary)
        .padding(.horizontal, AppSpacing.md)
        .frame(height: 36)
        .background(isSelected ? AppColors.primary : AppColors.surface, in: Capsule())
        .overlay(Capsule().strokeBorder(isSelected ? .clear : AppColors.hairline, lineWidth: 1))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    HStack {
        FilterChip(title: "Sort By", systemImage: AppImages.sort)
        FilterChip(title: "On Sale", isSelected: true)
        FilterChip(title: "Skincare")
    }
    .padding()
    .background(AppColors.background)
}
