import SwiftUI

/// 4 × 2 grid of shortcut tiles under the Home header: every category plus Offers,
/// Best Sellers, and All Products. Each tile opens that collection.
struct HomeShortcutGrid: View {
    private struct Shortcut: Identifiable {
        let collection: ProductCollection
        let title: LocalizedStringKey
        let systemImage: String
        let tint: Color

        var id: ProductCollection { collection }
    }

    private let shortcuts: [Shortcut] = ProductCategory.allCases.map { category in
        Shortcut(
            collection: .category(category),
            title: category.title,
            systemImage: category.systemImage,
            tint: category.tint
        )
    } + [
        Shortcut(collection: .offers, title: "Offers", systemImage: AppImages.offers, tint: AppColors.primary),
        Shortcut(collection: .bestSellers, title: "Best Sellers", systemImage: AppImages.star, tint: AppColors.star),
        Shortcut(collection: .all, title: "All", systemImage: AppImages.categories, tint: AppColors.textSecondary)
    ]

    private let columns = Array(repeating: GridItem(.flexible(), spacing: AppSpacing.sm + AppSpacing.xxs), count: 4)

    var body: some View {
        LazyVGrid(columns: columns, spacing: AppSpacing.sm + AppSpacing.xxs) {
            ForEach(shortcuts) { shortcut in
                NavigationLink(value: shortcut.collection) {
                    VStack(spacing: AppSpacing.sm) {
                        IconTile(systemImage: shortcut.systemImage, tint: shortcut.tint, size: 44)
                        Text(shortcut.title)
                            .font(AppFont.caption.weight(.semibold))
                            .foregroundStyle(AppColors.textPrimary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppSpacing.sm + AppSpacing.xs)
                    .cardStyle(cornerRadius: AppRadius.medium)
                }
                .buttonStyle(.pressable)
            }
        }
    }
}

#Preview {
    NavigationStack {
        HomeShortcutGrid()
            .padding()
            .background(AppColors.background)
    }
}
