import SwiftUI

/// Section title with an optional trailing "See All" link.
struct SectionHeaderView<Destination: Hashable>: View {
    let title: LocalizedStringKey
    /// Navigation value pushed by "See All", or `nil` to hide the link.
    var destination: Destination?

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(AppFont.sectionTitle)
                .foregroundStyle(AppColors.textPrimary)
                .accessibilityAddTraits(.isHeader)
            Spacer()
            if let destination {
                NavigationLink(value: destination) {
                    HStack(spacing: AppSpacing.xxs) {
                        Text("See All")
                        Image(systemName: AppImages.chevronRight)
                            .font(.system(size: 11, weight: .bold))
                    }
                    .font(AppFont.subheadline.weight(.semibold))
                    .foregroundStyle(AppColors.primary)
                    .frame(minHeight: 44)
                    .contentShape(Rectangle())
                }
                .accessibilityIdentifier("section.viewAll")
            }
        }
        .frame(minHeight: 44)
    }
}

#Preview {
    NavigationStack {
        SectionHeaderView(title: "Best Sellers", destination: ProductCollection.bestSellers)
            .padding()
    }
}
