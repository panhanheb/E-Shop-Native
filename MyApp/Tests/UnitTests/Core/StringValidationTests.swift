import Testing
@testable import MyApp

struct StringValidationTests {
    @Test(arguments: ["user@example.com", "first.last+tag@sub.domain.io", "  padded@example.com  "])
    func acceptsValidEmails(_ email: String) {
        #expect(email.isValidEmail)
    }

    @Test(arguments: ["", "user", "user@", "@example.com", "user@example", "user example@test.com"])
    func rejectsInvalidEmails(_ email: String) {
        #expect(!email.isValidEmail)
    }

    @Test func trimmedRemovesSurroundingWhitespace() {
        #expect("  hello \n".trimmed == "hello")
    }
}
