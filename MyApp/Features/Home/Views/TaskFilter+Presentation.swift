import SwiftUI

extension TaskFilter {
    /// Localized display name.
    var title: LocalizedStringKey {
        switch self {
        case .all: "All"
        case .active: "Active"
        case .completed: "Completed"
        }
    }
}
