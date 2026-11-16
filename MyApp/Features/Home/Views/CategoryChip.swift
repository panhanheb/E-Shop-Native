import SwiftUI

/// Selectable capsule used for the category filter.
struct CategoryChip: View {
    let title: LocalizedStringKey
    let systemImage: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(AppFont.callout)
                .padding(.horizontal, AppSpacing.md)
                .padding(.vertical, AppSpacing.sm)
                .foregroundStyle(isSelected ? AppColors.onPrimary : AppColors.textPrimary)
                .background(isSelected ? AppColors.primary : AppColors.surface, in: Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    HStack {
        CategoryChip(title: "All", systemImage: AppImages.categoryAll, isSelected: true) {}
        CategoryChip(title: "Fashion", systemImage: AppImages.categoryFashion, isSelected: false) {}
    }
    .padding()
    .background(AppColors.background)
}
