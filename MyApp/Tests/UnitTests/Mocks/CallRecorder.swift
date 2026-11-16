import Foundation

/// Records values passed to callbacks so tests can assert on them.
@MainActor
final class CallRecorder<Value> {
    private(set) var values: [Value] = []

    var count: Int { values.count }
    var last: Value? { values.last }

    func record(_ value: Value) {
        values.append(value)
    }
}
