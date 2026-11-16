import SwiftUI

/// Tab bar shown once the user is signed in: Shop, Cart, Orders, Profile, Settings.
struct MainTabView: View {
    @Environment(AppDependencies.self) private var dependencies
    @State private var selectedTab: AppTab = .shop

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(viewModel: dependencies.makeProductListViewModel())
                .tabItem { Label("Shop", systemImage: AppImages.shop) }
                .tag(AppTab.shop)

            CartView(cart: dependencies.cartViewModel) {
                selectedTab = .shop
            }
            .tabItem { Label("Cart", systemImage: AppImages.cart) }
            .badge(dependencies.cartViewModel.itemCount)
            .tag(AppTab.cart)

            OrdersView(viewModel: dependencies.makeOrderListViewModel())
                .tabItem { Label("Orders", systemImage: AppImages.orders) }
                .tag(AppTab.orders)

            ProfileView(viewModel: dependencies.makeProfileViewModel())
                .tabItem { Label("Profile", systemImage: AppImages.profile) }
                .tag(AppTab.profile)

            SettingsView(viewModel: dependencies.settingsViewModel)
                .tabItem { Label("Settings", systemImage: AppImages.settings) }
                .tag(AppTab.settings)
        }
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
