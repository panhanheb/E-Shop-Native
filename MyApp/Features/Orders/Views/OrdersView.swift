import SwiftUI

/// Order history with navigation to each order's details.
struct OrdersView: View {
    @State private var viewModel: OrderListViewModel

    /// Creates the view with its view model.
    init(viewModel: OrderListViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            content
                .background(AppColors.background)
                .navigationTitle("My Orders")
                .navigationDestination(for: Order.self) { order in
                    OrderDetailView(order: order)
                }
                .alert("Something Went Wrong", isPresented: $viewModel.isErrorAlertPresented) {
                    Button("OK", role: .cancel) {}
                } message: {
                    Text(viewModel.errorMessage ?? "")
                }
                .task { await viewModel.loadOrders() }
        }
    }

    @ViewBuilder
    private var content: some View {
        if !viewModel.hasLoaded, let errorMessage = viewModel.errorMessage {
            ErrorStateView(message: errorMessage) {
                Task { await viewModel.loadOrders() }
            }
        } else if !viewModel.hasLoaded {
            LoadingView(message: "Loading orders…")
        } else if viewModel.orders.isEmpty {
            EmptyStateView(
                title: "No Orders Yet",
                systemImage: AppImages.orders,
                message: "Orders you place will appear here."
            )
        } else {
            List(viewModel.orders) { order in
                NavigationLink(value: order) {
                    OrderRowView(order: order)
                }
            }
            .refreshable { await viewModel.loadOrders() }
        }
    }
}

#Preview("Orders") {
    OrdersView(viewModel: OrderListViewModel(orderService: MockOrderService(latency: .zero)))
}

#Preview("Empty") {
    OrdersView(viewModel: OrderListViewModel(orderService: MockOrderService(orders: [], latency: .zero)))
}
