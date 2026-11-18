import SwiftUI

/// Top of Home: avatar, name with a verified mark, delivery location, and round bag and
/// notification buttons.
struct HomeHeaderView: View {
    let userName: String
    /// City shown under the name.
    let locationName: String
    let cartCount: Int
    let onOpenProfile: () -> Void
    let onOpenCart: () -> Void
    let onOpenNotifications: () -> Void

    var body: some View {
        HStack(spacing: AppSpacing.sm + AppSpacing.xxs) {
            Button(action: onOpenProfile) {
                AvatarView(name: userName, size: 44)
            }
            .buttonStyle(.pressable)
            .accessibilityLabel(Text("Profile"))

            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                HStack(spacing: AppSpacing.xs) {
                    Text(userName)
                        .font(AppFont.headline)
                        .foregroundStyle(AppColors.textPrimary)
                        .lineLimit(1)
                        .accessibilityIdentifier("home.title")
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(AppColors.info)
                        .accessibilityHidden(true)
                }
                HStack(spacing: AppSpacing.xxs) {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundStyle(AppColors.primary)
                        .accessibilityHidden(true)
                    Text(locationName)
                        .lineLimit(1)
                }
                .font(AppFont.caption)
                .foregroundStyle(AppColors.textSecondary)
            }

            Spacer(minLength: AppSpacing.sm)

            CircleIconButton(systemImage: AppImages.cart, badgeCount: cartCount, action: onOpenCart)
                .accessibilityLabel(Text("My Cart"))
                .accessibilityIdentifier("home.cart")

            CircleIconButton(systemImage: AppImages.notifications, action: onOpenNotifications)
                .accessibilityLabel(Text("Notifications"))
        }
    }
}

/// 44-pt round outlined icon button with an optional red count badge.
struct CircleIconButton: View {
    let systemImage: String
    var badgeCount = 0
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(AppColors.textPrimary)
                .frame(width: 44, height: 44)
                .background(AppColors.surface, in: Circle())
                .overlay(Circle().strokeBorder(AppColors.hairline, lineWidth: 1))
                .overlay(alignment: .topTrailing) {
                    if badgeCount > 0 {
                        Text(badgeCount, format: .number)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(AppColors.onPrimary)
                            .padding(.horizontal, 4)
                            .frame(minWidth: 18, minHeight: 18)
                            .background(AppColors.primary, in: Capsule())
                            .overlay(Capsule().strokeBorder(AppColors.surface, lineWidth: 1.5))
                            .offset(x: 4, y: -4)
                    }
                }
        }
        .buttonStyle(.pressable)
        .accessibilityValue(badgeCount > 0 ? Text("\(badgeCount) items") : Text(verbatim: ""))
    }
}

/// Rounded search field with a filter button that opens the sort options.
struct HomeSearchBar: View {
    @Binding var text: String
    @Binding var sort: ProductSort

    var body: some View {
        HStack(spacing: AppSpacing.sm + AppSpacing.xxs) {
            Image(systemName: AppImages.search)
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(AppColors.textSecondary)
                .accessibilityHidden(true)

            TextField("Search for products…", text: $text)
                .font(AppFont.callout)
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

            Menu {
                Picker("Sort By", selection: $sort) {
                    ForEach(ProductSort.allCases) { option in
                        Text(option.title).tag(option)
                    }
                }
            } label: {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(AppColors.primary)
                    .frame(width: 32, height: 32)
                    .contentShape(Rectangle())
            }
            .accessibilityLabel(Text("Sort By"))
        }
        .padding(.leading, AppSpacing.md)
        .padding(.trailing, AppSpacing.sm + AppSpacing.xxs)
        .frame(height: 50)
        .background(AppColors.surface, in: Capsule())
        .overlay(Capsule().strokeBorder(AppColors.hairline, lineWidth: 1))
        .shadow(color: AppColors.shadow, radius: 8, y: 2)
    }
}

#Preview {
    VStack(spacing: AppSpacing.md) {
        HomeHeaderView(
            userName: "Alex Morgan",
            locationName: "Phnom Penh, Cambodia",
            cartCount: 3,
            onOpenProfile: {},
            onOpenCart: {},
            onOpenNotifications: {}
        )
        HomeSearchBar(text: .constant(""), sort: .constant(.featured))
    }
    .padding()
    .background(AppColors.background)
}
