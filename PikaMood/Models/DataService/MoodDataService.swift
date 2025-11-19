import Foundation

// MARK: - Protocol for any backend (Local, CloudKit, Firebase)
protocol MoodDataService {
    func loadAll() throws -> [MoodEntry]
    func saveAll(_ entries: [MoodEntry]) throws
}
