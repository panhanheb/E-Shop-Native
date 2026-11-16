# MyApp

A task manager for iOS 17+ built with SwiftUI, MVVM, and Swift 6 strict concurrency. It runs on iPhone and iPad only; Mac and Apple Vision Pro are turned off.

Features: **Auth** (login/register), **Home** (task list, detail, add), **Profile** (view/edit, sign out), **Settings** (appearance, notifications, haptics).

## Architecture

| Layer | Rules |
| --- | --- |
| Model | `Codable`, `Equatable`, `Sendable` structs. No UI or business logic. |
| View | SwiftUI only. Reads ViewModel state, forwards user intents. Every view has a `#Preview`. |
| ViewModel | `@Observable @MainActor final class`. Holds `isLoading` / `errorMessage` / data and exposes `async` intents. |
| Service | Protocol + REST implementation + in-memory mock. Injected through initializers. |

`AppDependencies` (in `App/`) is the composition root: it builds services once and vends view models through factory methods. `SessionStore` owns auth state and the Keychain token.

## Backend

`AppEnvironment.current.useMockServices` is `true`, so the app runs on in-memory mocks:

- Demo login: `demo@example.com` / `password123`
- Registration creates new in-memory accounts.

To switch to the real API at `https://api.example.com/v1`, set `useMockServices` to `false`. The expected endpoints are `POST auth/login`, `POST auth/register`, `POST auth/logout`, `GET/PATCH me`, `GET/POST tasks`, and `GET/PUT/DELETE tasks/{id}`. Bodies are JSON with ISO-8601 dates.

## Languages: English and Khmer (ខ្មែរ)

All UI text is in `Resources/Localizable.xcstrings`. English is the source language and Khmer (`km`) is fully translated.

- **Switching language:** go to **Settings > Language** in the app, which opens iOS Settings > MyApp > Language. On the simulator you can also use **Edit Scheme > Run > Options > App Language > Khmer**.
- **Adding text:** write it in English in the code (`Text("New label")`, `String(localized: "…")`), build, then open `Localizable.xcstrings` in Xcode and fill in the Khmer column.
- **Previews:** `LoginView` and `SettingsView` each have a "Khmer" preview that uses `.environment(\.locale, Locale(identifier: "km"))`.

## Setup in Xcode

### Option A: XcodeGen (recommended)

```bash
brew install xcodegen swiftlint
cd customer_ios
xcodegen generate
open MyApp.xcodeproj
```

### Option B: Manual

1. In Xcode 16 or later, choose **File > New > Project > iOS App**. Name it `MyApp`, set Interface to SwiftUI and Testing System to Swift Testing, and include tests.
2. Delete the generated `ContentView.swift`, `MyAppApp.swift`, and `Assets.xcassets`.
3. Drag the `MyApp/App`, `Core`, `DesignSystem`, `Features`, and `Resources` folders into the **MyApp** target. Choose "Create groups".
4. Add `MyApp/Tests/UnitTests` to the **MyAppTests** target and `MyApp/Tests/UITests` to the **MyAppUITests** target.
5. In Build Settings for every target, set **iOS Deployment Target** to 17.0, **Swift Language Version** to Swift 6, and **Strict Concurrency Checking** to Complete.
   Then, on the **MyApp** target's **General** tab under **Supported Destinations**, keep only **iPhone** and **iPad** and remove **Mac (Designed for iPad)** and **Apple Vision (Designed for iPad)**.
6. Under **Project > Info > Localizations**, click **+** and add **Khmer (km)**.
7. Build and run (⌘R). Run tests with ⌘U.
