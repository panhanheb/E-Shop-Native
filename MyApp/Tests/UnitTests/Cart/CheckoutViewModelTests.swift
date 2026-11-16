import Foundation
import Testing
@testable import MyApp

@MainActor
struct CheckoutViewModelTests {
    private let service = StubOrderService()
    private let placedOrders = CallRecorder<Order>()
    private let items = [
        CartItem(product: Product.mocks[2], quantity: 2),
        CartItem(product: Product.mocks[4], quantity: 1)
    ]

    private func makeSUT(items: [CartItem]? = nil) -> CheckoutViewModel {
        CheckoutViewModel(
            items: items ?? self.items,
            fullName: User.mock.name,
            orderService: service,
            onOrderPlaced: { [placedOrders] in placedOrders.record($0) }
        )
    }

    private func fillAddress(_ sut: CheckoutViewModel) {
        sut.phone = "+855 12 345 678"
        sut.street = " No. 12, Street 240 "
        sut.city = "Phnom Penh"
    }

    @Test func prefillsNameAndRequiresAddress() {
        let sut = makeSUT()

        #expect(sut.fullName == User.mock.name)
        #expect(!sut.canPlaceOrder)

        fillAddress(sut)
        #expect(sut.canPlaceOrder)
    }

    @Test func invalidPhoneShowsValidationMessage() {
        let sut = makeSUT()
        fillAddress(sut)
        sut.phone = "123"

        #expect(sut.validationMessage != nil)
        #expect(!sut.canPlaceOrder)
    }

    @Test func totalsMatchCart() {
        let sut = makeSUT()
        let expectedSubtotal = Product.mocks[2].price * 2 + Product.mocks[4].price

        #expect(sut.subtotal == expectedSubtotal)
        #expect(sut.shippingFee == ShippingPolicy.fee(forSubtotal: expectedSubtotal))
        #expect(sut.total == expectedSubtotal + sut.shippingFee)
    }

    @Test func placeOrderSendsTrimmedDetailsAndNotifies() async throws {
        let sut = makeSUT()
        fillAddress(sut)
        sut.paymentMethod = .khqr

        await sut.placeOrder()

        let request = try #require(service.placedRequests.first)
        #expect(request.items.map(\.quantity) == [2, 1])
        #expect(request.shippingAddress.street == "No. 12, Street 240")
        #expect(request.paymentMethod == .khqr)
        #expect(sut.placedOrder != nil)
        #expect(placedOrders.count == 1)
        #expect(!sut.canPlaceOrder)
        #expect(!sut.isPlacingOrder)
    }

    @Test func placeOrderFailureShowsError() async {
        service.placeOrderError = TestError.stub
        let sut = makeSUT()
        fillAddress(sut)

        await sut.placeOrder()

        #expect(sut.placedOrder == nil)
        #expect(placedOrders.count == 0)
        #expect(sut.errorMessage == TestError.stub.localizedDescription)
    }

    @Test func emptyCartCannotCheckout() async {
        let sut = makeSUT(items: [])
        fillAddress(sut)

        await sut.placeOrder()

        #expect(!sut.canPlaceOrder)
        #expect(service.placedRequests.isEmpty)
    }
}
