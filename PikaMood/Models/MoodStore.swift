import Foundation
import SwiftUI

final class MoodStore: ObservableObject {

    @Published var entries: [MoodEntry] = []

    // Inject current backend implementation
    private let dataService: MoodDataService

    init(dataService: MoodDataService = LocalMoodDataService()) {
        self.dataService = dataService
        load()
    }

    // MARK: - Load from backend
    func load() {
        do {
            entries = try dataService.loadAll()
        } catch {
            print("❌ Failed to load mood entries: \(error)")
        }
    }

    // MARK: - Save to backend
    private func save() {
        do {
            try dataService.saveAll(entries)
        } catch {
            print("❌ Failed to save mood entries: \(error)")
        }
    }

    // MARK: - Add or update mood
    func addOrUpdate(
        date: Date,
        moodType: MoodType,
        journalText: String?,
        weather: WeatherType?,
        tag: TagType?,
        intensity: Double?
    ) {
        if let index = entries.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }) {
            // Update existing
            entries[index].moodType = moodType
            entries[index].journalText = journalText
            entries[index].weather = weather
            entries[index].tag = tag
            entries[index].intensity = intensity
        } else {
            // Create new
            let newEntry = MoodEntry(
                date: date,
                moodType: moodType,
                journalText: journalText,
                weather: weather,
                tag: tag,
                intensity: intensity
            )
            entries.append(newEntry)
        }

        save()
    }

    func mood(for date: Date) -> MoodEntry? {
        let cal = Calendar.current
        return entries.first { cal.isDate($0.date, inSameDayAs: date) }
    }
}
