import Foundation
import Testing
@testable import MyApp

@MainActor
struct CartViewModelTests {
    private func product(price: Decimal, stock: Int = 10) -> Product {
        var product = Product.mock
        product.price = price
        product.stock = stock
        return product
    }

    @Test func addingSameProductMergesLines() {
        let sut = CartViewModel()

        sut.add(.mock, quantity: 1)
        sut.add(.mock, quantity: 2)

        #expect(sut.items.count == 1)
        #expect(sut.items.first?.quantity == 3)
        #expect(sut.itemCount == 3)
    }

    @Test func quantityIsCappedAtStock() {
        let sut = CartViewModel()
        let limited = product(price: 10, stock: 2)

        sut.add(limited, quantity: 5)

        #expect(sut.items.first?.quantity == 2)
        let item = sut.items.first
        #expect(item.map { sut.canIncrement($0) } == false)
    }

    @Test func outOfStockProductIsNotAdded() {
        let sut = CartViewModel()

        sut.add(.mockOutOfStock)

        #expect(sut.isEmpty)
    }

    @Test func decrementToZeroRemovesLine() throws {
        let sut = CartViewModel()
        sut.add(.mock)
        let item = try #require(sut.items.first)

        sut.decrement(item)

        #expect(sut.isEmpty)
    }

    @Test func incrementAndRemove() throws {
        let sut = CartViewModel()
        sut.add(.mock)
        let item = try #require(sut.items.first)

        sut.increment(item)
        #expect(sut.items.first?.quantity == 2)

        sut.remove(item)
        #expect(sut.isEmpty)
    }

    @Test func totalsChargeShippingBelowThreshold() {
        let sut = CartViewModel()

        sut.add(product(price: 10), quantity: 2)

        #expect(sut.subtotal == 20)
        #expect(sut.shippingFee == ShippingPolicy.flatFee)
        #expect(sut.total == 20 + ShippingPolicy.flatFee)
        #expect(sut.amountUntilFreeShipping == ShippingPolicy.freeShippingThreshold - 20)
    }

    @Test func shippingIsFreeAtThreshold() {
        let sut = CartViewModel()

        sut.add(product(price: ShippingPolicy.freeShippingThreshold))

        #expect(sut.shippingFee == 0)
        #expect(sut.total == ShippingPolicy.freeShippingThreshold)
        #expect(sut.amountUntilFreeShipping == nil)
    }

    @Test func emptyCartHasNoShippingFee() {
        let sut = CartViewModel()

        #expect(sut.subtotal == 0)
        #expect(sut.shippingFee == 0)
        #expect(sut.amountUntilFreeShipping == nil)
    }

    @Test func clearEmptiesCart() {
        let sut = CartViewModel()
        sut.add(.mock)
        sut.add(Product.mocks[2])

        sut.clear()

        #expect(sut.isEmpty)
        #expect(sut.itemCount == 0)
    }
}
