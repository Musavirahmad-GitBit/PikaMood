import Foundation

struct CalendarGridItem: Identifiable, Hashable {
    let id = UUID()
    let date: Date?    // nil = empty cell
}
