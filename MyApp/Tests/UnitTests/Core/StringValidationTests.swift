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

    @Test(arguments: ["+855 12 345 678", "012-345-678", "(012) 345 6789", "85512345678"])
    func acceptsValidPhoneNumbers(_ phone: String) {
        #expect(phone.isValidPhoneNumber)
    }

    @Test(arguments: ["", "123", "phone", "+855 12 abc 678", "1234567890123456"])
    func rejectsInvalidPhoneNumbers(_ phone: String) {
        #expect(!phone.isValidPhoneNumber)
    }

    @Test func trimmedRemovesSurroundingWhitespace() {
        #expect("  hello \n".trimmed == "hello")
    }
}
