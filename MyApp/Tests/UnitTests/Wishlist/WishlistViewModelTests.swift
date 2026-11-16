import Testing
@testable import MyApp

@MainActor
struct WishlistViewModelTests {
    @Test func toggleAddsThenRemoves() {
        let sut = WishlistViewModel()

        sut.toggle(.mock)
        #expect(sut.contains(.mock))
        #expect(sut.count == 1)

        sut.toggle(.mock)
        #expect(!sut.contains(.mock))
        #expect(sut.isEmpty)
    }

    @Test func newestItemIsFirst() {
        let sut = WishlistViewModel()

        sut.toggle(Product.mocks[0])
        sut.toggle(Product.mocks[1])

        #expect(sut.products.map(\.id) == [Product.mocks[1].id, Product.mocks[0].id])
    }

    @Test func removeAndClear() {
        let sut = WishlistViewModel(products: [Product.mocks[0], Product.mocks[1], Product.mocks[2]])

        sut.remove(Product.mocks[1])
        #expect(sut.count == 2)
        #expect(!sut.contains(Product.mocks[1]))

        sut.clear()
        #expect(sut.isEmpty)
    }
}
