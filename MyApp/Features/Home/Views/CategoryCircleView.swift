import SwiftUI

/// Round category shortcut with an icon and a label underneath.
struct CategoryCircleView: View {
    let title: LocalizedStringKey
    let systemImage: String
    let tint: Color
    var isHighlighted = false

    var body: some View {
        VStack(spacing: AppSpacing.sm) {
            Image(systemName: systemImage)
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(tint.gradient)
                .frame(width: 60, height: 60)
                .background(isHighlighted ? AppColors.blush : AppColors.surface, in: Circle())
                .shadow(color: AppColors.shadow, radius: 5, y: 2)
            Text(title)
                .font(AppFont.caption)
                .foregroundStyle(AppColors.textPrimary)
                .lineLimit(1)
        }
        .frame(width: 68)
    }
}

#Preview {
    HStack {
        ForEach(ProductCategory.allCases) { category in
            CategoryCircleView(title: category.title, systemImage: category.systemImage, tint: category.tint, isHighlighted: category == .skincare)
        }
    }
    .padding()
    .background(AppColors.background)
}
