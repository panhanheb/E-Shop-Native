import Foundation
import Observation

/// Composition root: builds services once and creates view models with their dependencies.
@Observable
@MainActor
final class DependencyContainer {
    let authService: any AuthServiceProtocol
    let productService: any ProductServiceProtocol
    let orderService: any OrderServiceProtocol
    let profileService: any ProfileServiceProtocol
    let sessionStore: SessionStore
    /// Shared catalog so Home, Categories, and product lists load products once.
    let catalogViewModel: ProductListViewModel
    /// Shared so every screen (Home bag badge, cart sheet, product detail) sees the same cart.
    let cartViewModel: CartViewModel
    /// Shared so hearts on every card and the Wishlist tab stay in sync.
    let wishlistViewModel: WishlistViewModel
    /// Shared so the root view can apply the selected appearance.
    let settingsViewModel: SettingsViewModel
    /// Whether the in-memory mock backend is in use.
    let isUsingMockServices: Bool

    /// Creates the container from concrete services.
    init(
        authService: any AuthServiceProtocol,
        productService: any ProductServiceProtocol,
        orderService: any OrderServiceProtocol,
        profileService: any ProfileServiceProtocol,
        settingsService: any SettingsServiceProtocol,
        tokenStore: any TokenStoreProtocol,
        isUsingMockServices: Bool,
        cart: CartViewModel = CartViewModel(),
        wishlist: WishlistViewModel = WishlistViewModel(),
        appVersion: String = Bundle.main.appVersion
    ) {
        self.authService = authService
        self.productService = productService
        self.orderService = orderService
        self.profileService = profileService
        self.isUsingMockServices = isUsingMockServices
        self.sessionStore = SessionStore(
            tokenStore: tokenStore,
            authService: authService,
            profileService: profileService
        )
        self.catalogViewModel = ProductListViewModel(productService: productService)
        self.cartViewModel = cart
        self.wishlistViewModel = wishlist
        self.settingsViewModel = SettingsViewModel(settingsService: settingsService, appVersion: appVersion)
    }

    // MARK: - Factories

    /// Builds the container for `environment`.
    static func make(for environment: AppEnvironment) -> DependencyContainer {
        environment.useMockServices
            ? mock(latency: environment.mockLatency)
            : live(baseURL: environment.baseURL)
    }

    /// Container backed by the REST API and Keychain.
    static func live(baseURL: URL) -> DependencyContainer {
        let tokenStore = KeychainTokenStore()
        let apiClient = APIClient(baseURL: baseURL, tokenStore: tokenStore)
        return DependencyContainer(
            authService: AuthService(apiClient: apiClient),
            productService: ProductService(apiClient: apiClient),
            orderService: OrderService(apiClient: apiClient),
            profileService: ProfileService(apiClient: apiClient),
            settingsService: SettingsService(),
            tokenStore: tokenStore,
            isUsingMockServices: false
        )
    }

    /// Container backed by in-memory mock services.
    static func mock(
        latency: Duration = .milliseconds(600),
        signedInUser: User? = nil,
        settingsService: (any SettingsServiceProtocol)? = nil,
        cart: CartViewModel = CartViewModel(),
        wishlist: WishlistViewModel = WishlistViewModel()
    ) -> DependencyContainer {
        let database = MockUserDatabase(signedInUser: signedInUser)
        return DependencyContainer(
            authService: MockAuthService(database: database, latency: latency),
            productService: MockProductService(latency: latency),
            orderService: MockOrderService(latency: latency),
            profileService: MockProfileService(database: database, latency: latency),
            settingsService: settingsService ?? SettingsService(),
            tokenStore: InMemoryTokenStore(token: signedInUser == nil ? nil : "preview-token"),
            isUsingMockServices: true,
            cart: cart,
            wishlist: wishlist
        )
    }

    /// Instant, signed-in mock container for SwiftUI previews, with items in the cart and wishlist.
    static var preview: DependencyContainer {
        mock(
            latency: .zero,
            signedInUser: .mock,
            settingsService: MockSettingsService(),
            cart: CartViewModel(items: [
                CartItem(product: Product.mocks[0], quantity: 1),
                CartItem(product: Product.mocks[2], quantity: 2)
            ]),
            wishlist: WishlistViewModel(products: [Product.mocks[0], Product.mocks[4]])
        )
    }

    // MARK: - View model factories

    /// Creates the login screen's view model.
    func makeLoginViewModel() -> LoginViewModel {
        LoginViewModel(authService: authService) { [sessionStore] response in
            try await sessionStore.signIn(with: response)
        }
    }

    /// Creates the registration screen's view model.
    func makeRegisterViewModel() -> RegisterViewModel {
        RegisterViewModel(authService: authService) { [sessionStore] response in
            try await sessionStore.signIn(with: response)
        }
    }

    /// Creates a product detail view model that adds to the shared cart.
    func makeProductDetailViewModel(product: Product) -> ProductDetailViewModel {
        ProductDetailViewModel(product: product, productService: productService) { [cartViewModel] product, quantity in
            cartViewModel.add(product, quantity: quantity)
        }
    }

    /// Creates a checkout view model for the current cart; the cart is cleared once the order is placed.
    func makeCheckoutViewModel() -> CheckoutViewModel {
        CheckoutViewModel(
            items: cartViewModel.items,
            fullName: sessionStore.currentUser?.name ?? "",
            orderService: orderService,
            onOrderPlaced: { [cartViewModel] _ in cartViewModel.clear() }
        )
    }

    /// Creates the order history's view model.
    func makeOrderListViewModel() -> OrderListViewModel {
        OrderListViewModel(orderService: orderService)
    }

    /// Creates the profile screen's view model. Signing out also empties the cart and wishlist.
    func makeProfileViewModel() -> ProfileViewModel {
        ProfileViewModel(
            user: sessionStore.currentUser,
            profileService: profileService,
            onProfileUpdated: { [sessionStore] user in sessionStore.updateUser(user) },
            onSignOut: { [sessionStore, cartViewModel, wishlistViewModel] in
                await sessionStore.signOut()
                cartViewModel.clear()
                wishlistViewModel.clear()
            }
        )
    }
    
}
