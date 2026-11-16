import Foundation

/// Generic failure injected into stubs.
enum TestError: Error, LocalizedError {
    case stub

    var errorDescription: String? { "Stub failure" }
}
