import SwiftUI

struct YearInPixelsView: View {
    @EnvironmentObject var moodStore: MoodStore

    @State private var selectedDate: Date? = nil

    private let calendar = Calendar.current
    private let year = Calendar.current.component(.year, from: Date())

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    headerSection
                    gridSection
                }
                .padding()
            }
            .navigationDestination(item: $selectedDate) { date in
                MoodEditorView(date: date)
            }
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        VStack(spacing: 4) {
            Text(
                        String(
                            format: NSLocalizedString("year_pixels_title", comment: ""),
                            year
                        )
                    )
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.purple)

            Text(NSLocalizedString("year_pixels_subtitle", comment: ""))
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }

    // MARK: - Grid
    private var gridSection: some View {
        let days = generateDaysOfYear()

        return LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: 2), count: 15),
            spacing: 2
        ) {
            ForEach(days, id: \.self) { date in
                if let date = date {
                    pixelCell(date)
                } else {
                    Color.clear.frame(width: 10, height: 10)
                }
            }
        }
    }

    // MARK: - Pixel Cell
    private func pixelCell(_ date: Date) -> some View {
        let entry = moodStore.entries.first {
            calendar.isDate($0.date, inSameDayAs: date)
        }

        return Rectangle()
            .fill(pixelColor(entry))
            .frame(width: 18, height: 18)
            .cornerRadius(6)
            .onTapGesture {
                selectedDate = date
            }
    }

    // MARK: - Helpers
    private func generateDaysOfYear() -> [Date?] {
        guard let startOfYear = calendar.date(from: DateComponents(year: year, month: 1, day: 1)) else {
            return []
        }

        var days: [Date?] = []

        let totalDays = calendar.range(of: .day, in: .year, for: startOfYear)!.count

        for offset in 0..<totalDays {
            if let date = calendar.date(byAdding: .day, value: offset, to: startOfYear) {
                days.append(date)
            }
        }

        return days
    }

    private func pixelColor(_ entry: MoodEntry?) -> Color {
        guard let entry else { return Color.gray.opacity(0.15) }

        return entry.moodType.pixelColor(intensity: entry.intensity ?? 0.5)
    }
}
