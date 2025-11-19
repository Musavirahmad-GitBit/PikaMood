import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var moodStore: MoodStore

    var sortedEntries: [MoodEntry] {
        moodStore.entries.sorted { $0.date > $1.date }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                LinearGradient(
                    colors: [
                        Color(red: 1.0, green: 0.97, blue: 0.99),
                        Color(red: 0.96, green: 0.98, blue: 1.0)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                if sortedEntries.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(sortedEntries) { entry in
                            moodRow(entry)
                        }
                        .listRowBackground(Color.clear)
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("ムード履歴")
        }
    }

    // MARK: - Components

    private func moodRow(_ entry: MoodEntry) -> some View {
        HStack(alignment: .top, spacing: 12) {

            // Mood Emoji + Color Dot
            VStack {
                Text(entry.moodType.label.split(separator: " ").first ?? "😊")
                    .font(.system(size: 32))

                Circle()
                    .fill(Color(hex: entry.moodType.colorHex))
                    .frame(width: 12, height: 12)
            }
            .padding(.top, 6)

            // Mood information
            VStack(alignment: .leading, spacing: 4) {
                // Japanese mood label
                Text(entry.moodType.label)
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(.black)

                // Date in Japanese style
                Text(formatDate(entry.date))
                    .font(.caption)
                    .foregroundColor(.gray)

                // Journal preview
                if let journal = entry.journalText, !journal.isEmpty {
                    Text(journal)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                        .padding(.top, 2)
                }
            }
            Spacer()
        }
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.9))
                .shadow(radius: 4, y: 3)
        )
        .padding(.vertical, 4)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Text("꒰ᐢ｡•༝•｡ᐢ꒱♡")
                .font(.system(size: 60))
            Text("まだムードが記録されていません")
                .font(.headline)
                .foregroundColor(.gray)
            Text("今日のムードを追加しましょう！")
                .foregroundColor(.pink)
        }
        .padding(.bottom, 80)
    }

    // MARK: - Helpers

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "yyyy年 M月d日 (EEE)"
        return formatter.string(from: date)
    }
}
