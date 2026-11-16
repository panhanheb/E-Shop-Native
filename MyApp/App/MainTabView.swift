import SwiftUI

/// Tab bar shown once the user is signed in: Home, Categories, Wishlist, Orders, Profile.
/// The cart opens from the bag button on Home; Settings opens from the Home menu or Profile.
struct MainTabView: View {
    @Environment(AppDependencies.self) private var dependencies
    @State private var selectedTab: AppTab = .home

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(catalog: dependencies.catalogViewModel)
                .tabItem { Label("Home", systemImage: AppImages.home) }
                .tag(AppTab.home)

            CategoriesView(catalog: dependencies.catalogViewModel)
                .tabItem { Label("Categories", systemImage: AppImages.categories) }
                .tag(AppTab.categories)

            WishlistView(wishlist: dependencies.wishlistViewModel) {
                selectedTab = .home
            }
            .tabItem { Label("Wishlist", systemImage: AppImages.wishlist) }
            .badge(dependencies.wishlistViewModel.count)
            .tag(AppTab.wishlist)

            OrdersView(viewModel: dependencies.makeOrderListViewModel())
                .tabItem { Label("Orders", systemImage: AppImages.orders) }
                .tag(AppTab.orders)

            ProfileView(viewModel: dependencies.makeProfileViewModel())
                .tabItem { Label("Profile", systemImage: AppImages.profile) }
                .tag(AppTab.profile)
        }
        .tint(AppColors.primary)
    }
}

#Preview {
    MainTabView()
        .environment(AppDependencies.preview)
}

#Preview("Khmer") {
    MainTabView()
        .environment(AppDependencies.preview)
        .environment(\.locale, Locale(identifier: "km"))
}
