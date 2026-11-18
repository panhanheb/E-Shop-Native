# MyApp

A beauty e-commerce app for iOS 17+ built with SwiftUI, MVVM, and Swift 6 strict concurrency. It has a warm cream and orange theme and runs on iPhone and iPad only; Mac and Apple Vision Pro are turned off.

| Tab | Feature folder | What it does |
| --- | --- | --- |
| Home | `Features/Home` | Greeting header (menu, notifications, bag with item count), swipeable hero banners, search with sort filter, category circles (Skincare, Makeup, Fragrance, Haircare, Tools, Offers), a Best Sellers row, a Special Offer banner, and a "Just For You" grid. Every card has a wishlist heart and an orange + button that adds it to the bag. |
| Categories | `Features/Home` | One card per category, plus Offers, with product counts. Each opens a sortable product grid. |
| Wishlist | `Features/Wishlist` | Hearted products, with the count shown on the tab badge |
| Orders | `Features/Orders` | Order history with status badges, plus order detail |
| Profile | `Features/Profile` | View and edit your name, open Settings (gear button), and sign out (which also empties the cart and wishlist) |

The **cart and checkout** (`Features/Cart`) open from the bag button on Home. Checkout takes a delivery address and a payment method (cash on delivery, KHQR, or card). **Settings** (theme, notifications, haptics, language) open from the Home menu or from Profile.

Sign-in and registration are in `Features/Authentication`. Prices are in USD (`AppCurrency`). Shipping is free from $50; below that it costs $2.50 (`ShippingPolicy`).

## Architecture

| Layer | Rules |
| --- | --- |
| Model | `Codable`, `Equatable`, `Sendable` structs. No UI or business logic. |
| View | SwiftUI only. Reads ViewModel state, forwards user intents. Every view has a `#Preview`. |
| ViewModel | `@Observable @MainActor final class`. Holds `isLoading` / `errorMessage` / data and exposes `async` intents. |
| Service | Protocol + REST implementation + in-memory mock. Injected through initializers. |

`DependencyContainer` (in `App/`) is the composition root: it builds services once and vends view models through factory methods. `SessionStore` owns auth state and the Keychain token. `ProductListViewModel` (the catalog), `CartViewModel`, and `WishlistViewModel` each have a single shared instance there, so every screen shows the same products, bag, and hearts.

## Backend

`AppEnvironment.current.useMockServices` is `true`, so the app runs on in-memory mocks:

- Demo login: `demo@example.com` / `password123`
- Registration creates new in-memory accounts.
- The catalog has 10 sample beauty products (4 on sale, one sold out) and 2 past orders. Orders you place are added to the history.
- Mock data resets when the app relaunches, and the cart is kept in memory only.

To switch to the real API at `https://api.example.com/v1`, set `useMockServices` to `false`. The expected endpoints (paths in `AppEndPoint`) are:

| Method | Path | Purpose |
| --- | --- | --- |
| POST | `auth/login`, `auth/register`, `auth/logout` | Authentication |
| GET / PATCH | `me` | Profile |
| GET | `products` | Catalog (no login needed) |
| GET | `products/{id}` | Latest price and stock for one product |
| GET | `orders` | Order history |
| POST | `orders` | Place an order; the server calculates totals |

Bodies are JSON with ISO-8601 dates and decimal prices.

## Languages: English and Khmer (ខ្មែរ)

All UI text is in `Resources/Localizable.xcstrings`. English is the source language and Khmer (`km`) is fully translated.

- **Switching language:** go to **Settings > Language** in the app, which opens iOS Settings > MyApp > Language. On the simulator you can also use **Edit Scheme > Run > Options > App Language > Khmer**.
- **Adding text:** write it in English in the code (`Text("New label")`, `String(localized: "…")`), build, then open `Localizable.xcstrings` in Xcode and fill in the Khmer column.
- **Previews:** `LoginView`, `HomeView`, `MainTabView`, and `SettingsView` each have a "Khmer" preview that uses `.environment(\.locale, Locale(identifier: "km"))`.

## Setup in Xcode

### Option A: Open the included project (simplest)

The repository includes `MyApp.xcodeproj`, which needs **Xcode 16 or later**. It uses folder-synced groups, so new files you add to the folders are picked up automatically.

1. Open **`MyApp.xcodeproj`**. Do not use File > Open on the `customer_ios` folder itself.
2. In the toolbar, select the **MyApp** scheme and an iPhone simulator.
3. Press ⌘R to run and ⌘U to test.
4. To run on a real iPhone, select the **MyApp** target, go to **Signing & Capabilities**, choose your **Team**, and change the bundle identifier to something unique.

### Option B: Regenerate with XcodeGen

`project.yml` describes the same project. Running XcodeGen replaces `MyApp.xcodeproj` with a freshly generated one.

```bash
brew install xcodegen swiftlint
cd customer_ios
xcodegen generate
open MyApp.xcodeproj
```

### Option C: Manual

1. In Xcode 16 or later, choose **File > New > Project > iOS App**. Name it `MyApp`, set Interface to SwiftUI and Testing System to Swift Testing, and include tests.
2. Delete the generated `ContentView.swift`, `MyAppApp.swift`, and `Assets.xcassets`.
3. Drag the `MyApp/App`, `Core`, `DesignSystem`, `Features`, and `Resources` folders into the **MyApp** target. Choose "Create groups".
4. Add `MyApp/Tests/UnitTests` to the **MyAppTests** target and `MyApp/Tests/UITests` to the **MyAppUITests** target.
5. In Build Settings for every target, set **iOS Deployment Target** to 17.0, **Swift Language Version** to Swift 6, and **Strict Concurrency Checking** to Complete.
   Then, on the **MyApp** target's **General** tab under **Supported Destinations**, keep only **iPhone** and **iPad** and remove **Mac (Designed for iPad)** and **Apple Vision (Designed for iPad)**.
6. Under **Project > Info > Localizations**, click **+** and add **Khmer (km)**.
7. Build and run (⌘R). Run tests with ⌘U.
