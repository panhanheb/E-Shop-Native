import SwiftUI

/// Section title with an optional trailing "View All →" link.
struct SectionHeaderView<Destination: Hashable>: View {
    let title: LocalizedStringKey
    /// Navigation value pushed by "View All", or `nil` to hide the link.
    var destination: Destination?

    var body: some View {
        HStack {
            Text(title)
                .font(AppFont.sectionTitle)
                .foregroundStyle(AppColors.textPrimary)
            Spacer()
            if let destination {
                NavigationLink(value: destination) {
                    HStack(spacing: AppSpacing.xs) {
                        Text("View All")
                        Image(systemName: AppImages.arrowRight)
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .font(AppFont.callout)
                    .foregroundStyle(AppColors.textPrimary)
                }
                .accessibilityIdentifier("section.viewAll")
            }
        }
    }
}

#Preview {
    NavigationStack {
        SectionHeaderView(title: "Best Sellers", destination: ProductCollection.bestSellers)
            .padding()
    }
}
