import SwiftUI

/// 4 × 2 grid of white shortcut tiles under the Home header: every category plus Offers,
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
        Shortcut(collection: .all, title: "All", systemImage: AppImages.categories, tint: AppColors.secondary)
    ]

    private let columns = Array(repeating: GridItem(.flexible(), spacing: AppSpacing.sm + AppSpacing.xs), count: 4)

    var body: some View {
        LazyVGrid(columns: columns, spacing: AppSpacing.sm + AppSpacing.xs) {
            ForEach(shortcuts) { shortcut in
                NavigationLink(value: shortcut.collection) {
                    VStack(spacing: AppSpacing.sm) {
                        Image(systemName: shortcut.systemImage)
                            .font(.system(size: 28))
                            .foregroundStyle(shortcut.tint.gradient)
                            .frame(height: 34)
                        Text(shortcut.title)
                            .font(AppFont.footnote.weight(.medium))
                            .foregroundStyle(AppColors.textPrimary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppSpacing.sm + AppSpacing.xs)
                    .background(AppColors.surface, in: RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous))
                    .shadow(color: AppColors.shadow, radius: 6, y: 2)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

/// Bold section title used on Home, with an optional round chevron button on the right.
struct HomeSectionTitle<Destination: Hashable>: View {
    let title: LocalizedStringKey
    /// Navigation value pushed by the chevron, or `nil` to hide it.
    var destination: Destination?

    var body: some View {
        HStack {
            Text(title)
                .font(AppFont.sectionTitle)
                .foregroundStyle(AppColors.textPrimary)
                .accessibilityAddTraits(.isHeader)
            Spacer()
            if let destination {
                NavigationLink(value: destination) {
                    Image(systemName: AppImages.chevronRight)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(AppColors.primary)
                        .frame(width: 24, height: 24)
                        .overlay(Circle().strokeBorder(AppColors.primary, lineWidth: 1.5))
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .accessibilityLabel(Text("View All"))
                .accessibilityIdentifier("section.viewAll")
            }
        }
        .frame(minHeight: 44)
    }
}

#Preview {
    NavigationStack {
        VStack(spacing: AppSpacing.lg) {
            HomeShortcutGrid()
            HomeSectionTitle(title: "Special Offers", destination: ProductCollection.offers)
        }
        .padding()
        .background(AppColors.background)
    }
}
