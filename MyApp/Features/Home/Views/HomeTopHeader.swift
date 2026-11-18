import SwiftUI

/// Red curved header at the top of Home: delivery location, logo, search with sort,
/// profile menu, and a row of quick actions (Favorites, My Bag, Orders, Coupons).
struct HomeTopHeader: View {
    /// City shown under "Your location".
    let locationName: String
    /// Signed-in user's name, used for the avatar initials.
    let userName: String
    let cartCount: Int
    @Binding var searchText: String
    @Binding var sort: ProductSort
    let onOpenFavorites: () -> Void
    let onOpenCart: () -> Void
    let onOpenOrders: () -> Void
    let onOpenCoupons: () -> Void
    let onOpenNotifications: () -> Void
    let onOpenSettings: () -> Void
    let onOpenProfile: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack(alignment: .top) {
                location
                Spacer(minLength: AppSpacing.sm)
                Image(AppImages.logo)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 52)
                    .accessibilityHidden(true)
            }

            HStack(spacing: AppSpacing.sm + AppSpacing.xs) {
                searchField
                profileMenu
            }

            quickActions
                .padding(.top, AppSpacing.xs)
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.top, AppSpacing.sm)
        .padding(.bottom, AppSpacing.md + AppSpacing.xs)
        .background {
            HomeHeaderBackground()
                .ignoresSafeArea(edges: .top)
        }
    }

    // MARK: Location

    private var location: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xxs) {
            Text("Your location")
                .font(AppFont.callout)
                .foregroundStyle(.white.opacity(0.85))
            Text(locationName)
                .font(AppFont.headline.weight(.bold))
                .foregroundStyle(.white)
                .accessibilityIdentifier("home.title")
        }
        .accessibilityElement(children: .combine)
    }

    // MARK: Search

    private var searchField: some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: AppImages.search)
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(AppColors.textSecondary)
                .accessibilityHidden(true)

            TextField("What are you looking for?", text: $searchText)
                .font(AppFont.callout)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(.search)
                .accessibilityIdentifier("home.search")

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: AppImages.clear)
                        .foregroundStyle(AppColors.textTertiary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Text("Clear Search"))
            }

            Rectangle()
                .fill(AppColors.border)
                .frame(width: 1, height: 22)
                .accessibilityHidden(true)

            Menu {
                Picker("Sort By", selection: $sort) {
                    ForEach(ProductSort.allCases) { option in
                        Text(option.title).tag(option)
                    }
                }
            } label: {
                Image(systemName: AppImages.filter)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(sort == .featured ? AppColors.textSecondary : AppColors.primary)
                    .frame(width: 28, height: 28)
            }
            .accessibilityLabel(Text("Sort By"))
        }
        .padding(.leading, AppSpacing.md)
        .padding(.trailing, AppSpacing.sm + AppSpacing.xs)
        .frame(height: 48)
        // Always white, even in Dark Mode, so it stands out on the red header.
        .background(Color.white, in: Capsule())
        .environment(\.colorScheme, .light)
    }

    private var profileMenu: some View {
        Menu {
            Button(action: onOpenProfile) {
                Label("Profile", systemImage: AppImages.profile)
            }
            Button(action: onOpenNotifications) {
                Label("Notifications", systemImage: AppImages.notifications)
            }
            Button(action: onOpenSettings) {
                Label("Settings", systemImage: AppImages.settings)
            }
        } label: {
            AvatarView(name: userName, size: 40)
                .padding(AppSpacing.xxs)
                .background(Color.white, in: Circle())
        }
        .accessibilityLabel(Text("Account"))
    }

    // MARK: Quick actions

    private var quickActions: some View {
        HStack(alignment: .top, spacing: 0) {
            quickAction("Favorites", systemImage: AppImages.favorite, action: onOpenFavorites)
            quickAction("My Bag", systemImage: AppImages.cart, badgeCount: cartCount, action: onOpenCart)
                .accessibilityIdentifier("home.cart")
            quickAction("Orders", systemImage: AppImages.orders, action: onOpenOrders)
            quickAction("Coupons", systemImage: AppImages.coupon, action: onOpenCoupons)
        }
    }

    private func quickAction(
        _ title: LocalizedStringKey,
        systemImage: String,
        badgeCount: Int = 0,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: AppSpacing.xs + AppSpacing.xxs) {
                Image(systemName: systemImage)
                    .font(.system(size: 20, weight: .regular))
                    .frame(height: 24)
                    .overlay(alignment: .topTrailing) {
                        if badgeCount > 0 {
                            Text(badgeCount, format: .number)
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(AppColors.primary)
                                .padding(.horizontal, 5)
                                .frame(minWidth: 17, minHeight: 17)
                                .background(Color.white, in: Capsule())
                                .offset(x: 10, y: -6)
                        }
                    }
                Text(title)
                    .font(AppFont.footnote.weight(.medium))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(title))
        .accessibilityValue(badgeCount > 0 ? Text("\(badgeCount) items") : Text(verbatim: ""))
        .accessibilityAddTraits(.isButton)
    }
}

/// Brand-colored background with rounded bottom corners and soft curved lines.
struct HomeHeaderBackground: View {
    private let shape = UnevenRoundedRectangle(
        bottomLeadingRadius: AppRadius.xLarge + AppSpacing.xs,
        bottomTrailingRadius: AppRadius.xLarge + AppSpacing.xs,
        style: .continuous
    )

    var body: some View {
        shape
            .fill(AppColors.primary.gradient)
            .overlay {
                Canvas { context, size in
                    // Concentric arcs sweeping from beyond the top-right corner.
                    let center = CGPoint(x: size.width * 1.1, y: -size.height * 0.15)
                    for index in 0..<18 {
                        let radius = 60 + CGFloat(index) * 22
                        let path = Path { path in
                            path.addArc(
                                center: center,
                                radius: radius,
                                startAngle: .degrees(90),
                                endAngle: .degrees(200),
                                clockwise: false
                            )
                        }
                        context.stroke(path, with: .color(.white.opacity(0.08)), lineWidth: 1.5)
                    }
                }
                .clipShape(shape)
            }
            .accessibilityHidden(true)
    }
}

#Preview {
    VStack {
        HomeTopHeader(
            locationName: "Phnom Penh",
            userName: "Alex Morgan",
            cartCount: 3,
            searchText: .constant(""),
            sort: .constant(.featured),
            onOpenFavorites: {},
            onOpenCart: {},
            onOpenOrders: {},
            onOpenCoupons: {},
            onOpenNotifications: {},
            onOpenSettings: {},
            onOpenProfile: {}
        )
        Spacer()
    }
    .background(AppColors.background)
}
