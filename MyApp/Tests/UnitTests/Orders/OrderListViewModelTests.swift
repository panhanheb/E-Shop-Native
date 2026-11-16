import Testing
@testable import MyApp

@MainActor
struct OrderListViewModelTests {
    @Test func loadOrdersPopulatesList() async {
        let sut = OrderListViewModel(orderService: StubOrderService())

        await sut.loadOrders()

        #expect(sut.orders == Order.mocks)
        #expect(sut.hasLoaded)
        #expect(!sut.isLoading)
    }

    @Test func emptyHistoryLoadsAsEmpty() async {
        let service = StubOrderService()
        service.orders = []
        let sut = OrderListViewModel(orderService: service)

        await sut.loadOrders()

        #expect(sut.orders.isEmpty)
        #expect(sut.hasLoaded)
    }

    @Test func loadFailureSetsError() async {
        let service = StubOrderService()
        service.fetchError = TestError.stub
        let sut = OrderListViewModel(orderService: service)

        await sut.loadOrders()

        #expect(!sut.hasLoaded)
        #expect(sut.errorMessage == TestError.stub.localizedDescription)
        #expect(!sut.isErrorAlertPresented)
    }

    @Test func reloadPicksUpNewOrders() async {
        let service = StubOrderService()
        let sut = OrderListViewModel(orderService: service)
        await sut.loadOrders()

        service.orders.insert(Order.makeMock(number: "MA-NEW", products: [(Product.mock, 1)]), at: 0)
        await sut.loadOrders()

        #expect(sut.orders.first?.number == "MA-NEW")
    }
}
