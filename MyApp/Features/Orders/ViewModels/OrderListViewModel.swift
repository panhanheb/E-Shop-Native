import Foundation
import Observation

/// State and actions for the order history screen.
@Observable
@MainActor
final class OrderListViewModel {
    private(set) var orders: [Order] = []
    private(set) var isLoading = false
    private(set) var hasLoaded = false
    var errorMessage: String?

    private let orderService: any OrderServiceProtocol

    /// Creates the view model.
    init(orderService: any OrderServiceProtocol) {
        self.orderService = orderService
    }

    /// Whether an error occurred after the first load (shown as an alert over the list).
    var isErrorAlertPresented: Bool {
        get { errorMessage != nil && hasLoaded }
        set { if !newValue { errorMessage = nil } }
    }

    /// Fetches the order history. Called every time the screen appears so new orders show up.
    func loadOrders() async {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            orders = try await orderService.fetchOrders()
            hasLoaded = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
