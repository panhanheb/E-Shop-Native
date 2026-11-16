import Testing
@testable import MyApp

@MainActor
struct ProductListViewModelTests {
    private func loadedSUT(_ service: StubProductService = StubProductService()) async -> ProductListViewModel {
        let sut = ProductListViewModel(productService: service)
        await sut.loadProducts()
        return sut
    }

    @Test func loadProductsPopulatesCatalog() async {
        let sut = await loadedSUT()

        #expect(sut.products == Product.mocks)
        #expect(sut.products(in: .all) == Product.mocks)
        #expect(sut.hasLoaded)
        #expect(!sut.isLoading)
    }

    @Test func loadFailureSetsErrorWithoutAlert() async {
        let service = StubProductService()
        service.fetchError = TestError.stub

        let sut = await loadedSUT(service)

        #expect(sut.products.isEmpty)
        #expect(!sut.hasLoaded)
        #expect(sut.errorMessage == TestError.stub.localizedDescription)
        #expect(!sut.isErrorAlertPresented)
    }

    @Test func loadIfNeededOnlyLoadsOnce() async {
        let service = StubProductService()
        let sut = ProductListViewModel(productService: service)

        await sut.loadIfNeeded()
        await sut.loadIfNeeded()

        #expect(service.fetchProductsCallCount == 1)
    }

    @Test func bestSellersAreMostReviewedFirstAndLimited() async {
        let sut = await loadedSUT()

        let counts = sut.bestSellers.map(\.reviewCount)
        #expect(counts == counts.sorted(by: >))
        #expect(sut.bestSellers.count == min(ProductListViewModel.bestSellerLimit, Product.mocks.count))
    }

    @Test func offersContainOnlyDiscountedProducts() async {
        let sut = await loadedSUT()

        #expect(!sut.offers.isEmpty)
        #expect(sut.offers.allSatisfy { ($0.originalPrice ?? 0) > $0.price })
        #expect(sut.products(in: .offers).count == sut.offers.count)
    }

    @Test func maxDiscountIsRoundedLargestDiscount() async {
        let sut = await loadedSUT()

        // Pro Brush Set: $32 instead of $46 = 30.4% → 30.
        #expect(sut.maxDiscountPercent == 30)
    }

    @Test func noOffersMeansNoDiscount() async {
        let fullPrice = Product.mocks.map { product -> Product in
            var copy = product
            copy.originalPrice = nil
            return copy
        }
        let sut = await loadedSUT(StubProductService(products: fullPrice))

        #expect(sut.offers.isEmpty)
        #expect(sut.maxDiscountPercent == nil)
    }

    @Test(arguments: ProductCategory.allCases)
    func categoryCollectionShowsOnlyThatCategory(_ category: ProductCategory) async {
        let sut = await loadedSUT()

        let expected = Product.mocks.filter { $0.category == category }
        #expect(sut.products(in: .category(category)) == expected)
        #expect(sut.productCount(in: category) == expected.count)
    }

    @Test func searchMatchesNameAndTaglineCaseInsensitively() async {
        let sut = await loadedSUT()

        sut.searchText = "  LIPSTICK "
        #expect(sut.isSearching)
        #expect(sut.searchResults.map(\.name) == ["Matte Lipstick"])

        sut.searchText = "frizz"
        #expect(sut.searchResults.map(\.name) == ["Silk Hair Oil"])
    }

    @Test func emptySearchIsNotSearching() async {
        let sut = await loadedSUT()

        sut.searchText = "   "

        #expect(!sut.isSearching)
        #expect(sut.searchResults.isEmpty)
    }

    @Test(arguments: [ProductSort.priceLowToHigh, .priceHighToLow, .topRated])
    func sortAppliesToCollections(_ sort: ProductSort) async {
        let sut = await loadedSUT()

        sut.sort = sort
        let products = sut.products(in: .all)

        switch sort {
        case .priceLowToHigh:
            #expect(products.map(\.price) == products.map(\.price).sorted())
        case .priceHighToLow:
            #expect(products.map(\.price) == products.map(\.price).sorted(by: >))
        case .topRated:
            #expect(products.map(\.rating) == products.map(\.rating).sorted(by: >))
        case .featured:
            break
        }
    }

    @Test func refreshFailureAfterLoadShowsAlert() async {
        let service = StubProductService()
        let sut = await loadedSUT(service)
        service.fetchError = TestError.stub

        await sut.loadProducts()

        #expect(sut.products == Product.mocks)
        #expect(sut.isErrorAlertPresented)

        sut.isErrorAlertPresented = false
        #expect(sut.errorMessage == nil)
    }
}
