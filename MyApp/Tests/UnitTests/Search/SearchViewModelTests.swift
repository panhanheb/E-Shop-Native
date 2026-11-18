import Testing
@testable import MyApp

@MainActor
struct SearchViewModelTests {
    private func makeSUT(searches: [String] = []) -> (SearchViewModel, InMemoryRecentSearchStore) {
        let store = InMemoryRecentSearchStore(searches: searches)
        return (SearchViewModel(store: store), store)
    }

    // MARK: Recent searches

    @Test func loadsSavedSearchesOnInit() {
        let (sut, _) = makeSUT(searches: ["serum", "lipstick"])
        #expect(sut.recentSearches == ["serum", "lipstick"])
    }

    @Test func recordAddsNewestFirstAndSaves() {
        let (sut, store) = makeSUT(searches: ["serum"])

        sut.record("  lipstick ")

        #expect(sut.recentSearches == ["lipstick", "serum"])
        #expect(store.load() == ["lipstick", "serum"])
    }

    @Test func recordIgnoresBlankQueries() {
        let (sut, _) = makeSUT(searches: ["serum"])

        sut.record("   ")

        #expect(sut.recentSearches == ["serum"])
    }

    @Test func recordMovesExistingSearchToTopWithoutDuplicating() {
        let (sut, _) = makeSUT(searches: ["serum", "lipstick", "perfume"])

        sut.record("LIPSTICK")

        #expect(sut.recentSearches == ["LIPSTICK", "serum", "perfume"])
    }

    @Test func recordKeepsOnlyTheMostRecentSearches() {
        let (sut, _) = makeSUT()

        for index in 0...SearchViewModel.maxRecentSearches {
            sut.record("term \(index)")
        }

        #expect(sut.recentSearches.count == SearchViewModel.maxRecentSearches)
        #expect(sut.recentSearches.first == "term \(SearchViewModel.maxRecentSearches)")
        #expect(!sut.recentSearches.contains("term 0"))
    }

    @Test func removeAndClearRecentSearches() {
        let (sut, store) = makeSUT(searches: ["serum", "lipstick"])

        sut.removeRecentSearch("serum")
        #expect(sut.recentSearches == ["lipstick"])

        sut.clearRecentSearches()
        #expect(sut.recentSearches.isEmpty)
        #expect(store.load().isEmpty)
    }

    @Test func recentSearchesMatchingQuery() {
        let (sut, _) = makeSUT(searches: ["rose perfume", "serum", "Rose lipstick"])

        #expect(sut.recentSearches(matching: "rose") == ["rose perfume", "Rose lipstick"])
        #expect(sut.recentSearches(matching: "  ") == ["rose perfume", "serum", "Rose lipstick"])
    }

    // MARK: Filters

    @Test func filterByCategoryKeepsOrder() {
        let (sut, _) = makeSUT()
        let category = Product.mocks[0].category

        sut.toggleCategory(category)

        #expect(sut.filter(Product.mocks) == Product.mocks.filter { $0.category == category })
    }

    @Test func toggleCategoryTwiceClearsIt() {
        let (sut, _) = makeSUT()

        sut.toggleCategory(.makeup)
        sut.toggleCategory(.makeup)

        #expect(sut.selectedCategory == nil)
        #expect(sut.filter(Product.mocks) == Product.mocks)
    }

    @Test func onSaleOnlyKeepsDiscountedProducts() {
        let (sut, _) = makeSUT()

        sut.isOnSaleOnly = true
        let results = sut.filter(Product.mocks)

        #expect(!results.isEmpty)
        #expect(results.allSatisfy { product in
            guard let originalPrice = product.originalPrice else { return false }
            return originalPrice > product.price
        })
    }
}
