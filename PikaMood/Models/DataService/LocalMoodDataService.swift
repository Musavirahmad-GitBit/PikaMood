import Foundation

final class LocalMoodDataService: MoodDataService {

    private let storageKey = "PikaMoodEntries"

    // Load full list
    func loadAll() throws -> [MoodEntry] {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else {
            return []
        }
        return try JSONDecoder().decode([MoodEntry].self, from: data)
    }

    // Save full list
    func saveAll(_ entries: [MoodEntry]) throws {
        let data = try JSONEncoder().encode(entries)
        UserDefaults.standard.set(data, forKey: storageKey)
    }
}
