import Foundation
import Testing
@testable import MyApp

@MainActor
struct ProductDetailViewModelTests {
    private struct Addition {
        let product: Product
        let quantity: Int
    }

    private let additions = CallRecorder<Addition>()

    private func makeSUT(product: Product = .mock, service: StubProductService = StubProductService()) -> ProductDetailViewModel {
        ProductDetailViewModel(product: product, productService: service) { [additions] product, quantity in
            additions.record(Addition(product: product, quantity: quantity))
        }
    }

    @Test func quantityStaysWithinOneAndStock() {
        var product = Product.mock
        product.stock = 2
        let sut = makeSUT(product: product)

        #expect(!sut.canDecreaseQuantity)
        sut.decreaseQuantity()
        #expect(sut.quantity == 1)

        sut.increaseQuantity()
        sut.increaseQuantity()
        #expect(sut.quantity == 2)
        #expect(!sut.canIncreaseQuantity)
    }

    @Test func totalPriceFollowsQuantity() {
        let sut = makeSUT()

        sut.increaseQuantity()

        #expect(sut.totalPrice == Product.mock.price * 2)
    }

    @Test func addToCartSendsQuantityAndResets() {
        let sut = makeSUT()
        sut.increaseQuantity()
        sut.increaseQuantity()

        sut.addToCart()

        #expect(additions.last?.product == .mock)
        #expect(additions.last?.quantity == 3)
        #expect(sut.lastAddedQuantity == 3)
        #expect(sut.quantity == 1)
        #expect(sut.isAddedConfirmationPresented)
    }

    @Test func outOfStockProductCannotBeAdded() {
        let sut = makeSUT(product: .mockOutOfStock)

        sut.addToCart()

        #expect(!sut.isInStock)
        #expect(additions.count == 0)
        #expect(!sut.isAddedConfirmationPresented)
    }

    @Test func refreshPicksUpNewPriceAndCapsQuantity() async {
        var updated = Product.mock
        updated.price = 10
        updated.stock = 1
        let sut = makeSUT(service: StubProductService(products: [updated]))
        sut.increaseQuantity()

        await sut.refresh()

        #expect(sut.product.price == 10)
        #expect(sut.quantity == 1)
        #expect(!sut.isLoading)
    }

    @Test func refreshFailureKeepsProduct() async {
        let service = StubProductService()
        service.fetchError = TestError.stub
        let sut = makeSUT(service: service)

        await sut.refresh()

        #expect(sut.product == .mock)
        #expect(sut.errorMessage == TestError.stub.localizedDescription)
    }
}
