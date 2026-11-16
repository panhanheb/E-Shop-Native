import SwiftUI

/// Rounded search field with a round filter button that opens the sort options.
struct HomeSearchBar: View {
    @Binding var text: String
    @Binding var sort: ProductSort

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: AppImages.search)
                    .foregroundStyle(AppColors.textSecondary)
                    .accessibilityHidden(true)
                TextField("Search for products…", text: $text)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .submitLabel(.search)
                    .accessibilityIdentifier("home.search")
                if !text.isEmpty {
                    Button {
                        text = ""
                    } label: {
                        Image(systemName: AppImages.clear)
                            .foregroundStyle(AppColors.textTertiary)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(Text("Clear Search"))
                }
            }
            .font(AppFont.callout)
            .padding(.horizontal, AppSpacing.md)
            .frame(height: 50)
            .background(AppColors.surface, in: Capsule())
            .shadow(color: AppColors.shadow, radius: 6, y: 2)

            Menu {
                Picker("Sort By", selection: $sort) {
                    ForEach(ProductSort.allCases) { option in
                        Text(option.title).tag(option)
                    }
                }
            } label: {
                Image(systemName: AppImages.filter)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(sort == .featured ? AppColors.textPrimary : AppColors.onPrimary)
                    .frame(width: 50, height: 50)
                    .background(sort == .featured ? AppColors.surface : AppColors.primary, in: Circle())
                    .shadow(color: AppColors.shadow, radius: 6, y: 2)
            }
            .accessibilityLabel(Text("Sort By"))
        }
    }
}

#Preview {
    VStack(spacing: AppSpacing.lg) {
        HomeSearchBar(text: .constant(""), sort: .constant(.featured))
        HomeSearchBar(text: .constant("serum"), sort: .constant(.priceLowToHigh))
    }
    .padding()
    .background(AppColors.background)
}
