You are a senior iOS engineer. Create a professional, production-ready Swift project
using SwiftUI and the MVVM architecture, organized by feature.

## Project details
- App name: [MyApp]
- Purpose: [short description, e.g. "a task manager with login and profile"]
- Features: [Auth (login/register), Home (list + detail), Profile, Settings]
- Minimum iOS version: [iOS 17]
- Backend/API: [REST API at https://api.example.com / mock data for now]
- Persistence: [SwiftData / UserDefaults / none]

## Architecture rules (MVVM)
- Model: plain Swift structs (Codable, Identifiable, Equatable). No UI or business logic.
- View: SwiftUI views only. No networking or business logic. Views read state from
  the ViewModel and send user actions to it.
- ViewModel: an @Observable class marked @MainActor. It holds view state
  (data, isLoading, errorMessage), exposes intent methods (e.g. func login() async),
  and talks to Services through protocols.
- Service/Repository layer: handles networking and persistence behind protocols
  (e.g. protocol AuthServiceProtocol), so it can be mocked in tests.
- Inject dependencies through initializers. No singletons inside ViewModels.

## Folder structure
MyApp/
├── App/                 (MyApp.swift entry point, AppDependencies container)
├── Features/
│   └── <FeatureName>/
│       ├── Views/
│       ├── ViewModels/
│       ├── Models/
│       └── Services/
├── Core/
│   ├── Networking/      (APIClient, Endpoint, NetworkError)
│   ├── Persistence/
│   ├── Models/          (shared models)
│   └── Extensions/
├── DesignSystem/
│   ├── Components/      (reusable buttons, text fields, cards)
│   └── Theme/           (colors, fonts, spacing)
├── Resources/           (Assets, Localizable.xcstrings)
└── Tests/
    ├── UnitTests/       (ViewModel tests with mock services)
    └── UITests/

## Code standards
- Swift 6 with strict concurrency; use async/await and avoid completion handlers.
- One type per file, with the file named after the type.
- Handle loading, empty, and error states in every screen.
- Add a #Preview for every view, using mock data.
- Write unit tests for every ViewModel using Swift Testing (@Test) and mock services.
- Add brief doc comments on public types and methods.
- Follow SwiftLint-friendly style.

## Output
1. Show the full folder tree first.
2. Then give the complete code for every file, each labeled with its file path.
3. Start with Core and DesignSystem, then each feature, then the tests.
4. End with short setup instructions for creating the project in Xcode.