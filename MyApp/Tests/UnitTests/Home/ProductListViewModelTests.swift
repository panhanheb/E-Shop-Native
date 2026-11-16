import Testing
@testable import MyApp

@MainActor
struct ProductListViewModelTests {
    @Test func loadProductsPopulatesCatalog() async {
        let sut = ProductListViewModel(productService: StubProductService())

        await sut.loadProducts()

        #expect(sut.products == Product.mocks)
        #expect(sut.visibleProducts == Product.mocks)
        #expect(sut.hasLoaded)
        #expect(!sut.isLoading)
    }

    @Test func loadFailureSetsErrorWithoutAlert() async {
        let service = StubProductService()
        service.fetchError = TestError.stub
        let sut = ProductListViewModel(productService: service)

        await sut.loadProducts()

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

    @Test(arguments: ProductCategory.allCases)
    func categoryFilterShowsOnlyThatCategory(_ category: ProductCategory) async {
        let sut = ProductListViewModel(productService: StubProductService())
        await sut.loadProducts()

        sut.selectedCategory = category

        #expect(sut.visibleProducts == Product.mocks.filter { $0.category == category })
    }

    @Test func togglingSelectedCategoryClearsFilter() async {
        let sut = ProductListViewModel(productService: StubProductService())
        await sut.loadProducts()

        sut.toggleCategory(.fashion)
        #expect(sut.selectedCategory == .fashion)

        sut.toggleCategory(.fashion)
        #expect(sut.selectedCategory == nil)
    }

    @Test func searchMatchesNameCaseInsensitively() async {
        let sut = ProductListViewModel(productService: StubProductService())
        await sut.loadProducts()

        sut.searchText = "  YOGA "

        #expect(sut.visibleProducts.map(\.name) == ["Non-Slip Yoga Mat"])
    }

    @Test func sortByPriceAscending() async {
        let sut = ProductListViewModel(productService: StubProductService())
        await sut.loadProducts()

        sut.sort = .priceLowToHigh

        let prices = sut.visibleProducts.map(\.price)
        #expect(prices == prices.sorted())
    }

    @Test func sortByPriceDescending() async {
        let sut = ProductListViewModel(productService: StubProductService())
        await sut.loadProducts()

        sut.sort = .priceHighToLow

        let prices = sut.visibleProducts.map(\.price)
        #expect(prices == prices.sorted(by: >))
    }

    @Test func sortByTopRated() async {
        let sut = ProductListViewModel(productService: StubProductService())
        await sut.loadProducts()

        sut.sort = .topRated

        let ratings = sut.visibleProducts.map(\.rating)
        #expect(ratings == ratings.sorted(by: >))
    }

    @Test func refreshFailureAfterLoadShowsAlert() async {
        let service = StubProductService()
        let sut = ProductListViewModel(productService: service)
        await sut.loadProducts()
        service.fetchError = TestError.stub

        await sut.loadProducts()

        #expect(sut.products == Product.mocks)
        #expect(sut.isErrorAlertPresented)

        sut.isErrorAlertPresented = false
        #expect(sut.errorMessage == nil)
    }
}
