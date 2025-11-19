import SwiftUI
import Charts

struct AnalyticsView: View {
    @EnvironmentObject var moodStore: MoodStore

    private var moodCounts: [(MoodType, Int)] {
        MoodType.allCases.map { mood in
            (mood, moodStore.entries.filter { $0.moodType == mood }.count)
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {

                    Text("ムード分析")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.pink)

                    moodPieChart

                    weekBarChart

                    moodInsights
                }
                .padding()
            }
        }
    }

    // MARK: Pie Chart
    private var moodPieChart: some View {
        VStack(alignment: .leading) {
            Text("ムード割合")
                .font(.headline)

            Chart {
                ForEach(moodCounts, id: \.0.id) { (mood, count) in
                    if count > 0 {
                        SectorMark(
                            angle: .value("Count", count),
                            innerRadius: .ratio(0.5),
                            angularInset: 2
                        )
                        .foregroundStyle(Color(hex: mood.colorHex))
                    }
                }
            }
            .frame(height: 260)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.9))
                    .shadow(radius: 5)
            )
        }
    }

    // MARK: Weekly Bar Chart

    private var weekBarChart: some View {
        VStack(alignment: .leading) {
            Text("曜日ごとのムード傾向")
                .font(.headline)

            Chart {
                let grouped = Dictionary(grouping: moodStore.entries) {
                    weekdayName($0.date)
                }

                ForEach(grouped.keys.sorted(), id: \.self) { day in
                    let moods = grouped[day]!

                    BarMark(
                        x: .value("Day", day),
                        y: .value("Count", moods.count)
                    )
                    .foregroundStyle(.pink)
                }
            }
            .frame(height: 240)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.9))
                    .shadow(radius: 5)
            )
        }
    }

    // MARK: Mood Insights (text-based)

    private var moodInsights: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("インサイト")
                .font(.headline)

            if moodStore.entries.isEmpty {
                Text("まだ分析できるデータがありません 🌱")
                    .foregroundColor(.gray)
            } else {
                Text(emojiInsight())
                    .font(.subheadline)
                    .foregroundColor(.black)

                Text(bestDayInsight())
                    .font(.subheadline)
                    .foregroundColor(.black)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.9))
                .shadow(radius: 5)
        )
    }

    // MARK: Helpers

    private func weekdayName(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ja_JP")
        f.dateFormat = "EEE"
        return f.string(from: date)
    }

    private func emojiInsight() -> String {
        let mostCommon = moodCounts.max(by: { $0.1 < $1.1 })!
        return "あなたは最近「\(mostCommon.0.emoji) \(mostCommon.0.label)」の日が多いです。"
    }

    private func bestDayInsight() -> String {
        let grouped = Dictionary(grouping: moodStore.entries) {
            weekdayName($0.date)
        }

        let best = grouped.max { $0.value.count < $1.value.count }
        return "「\(best?.key ?? "不明")」はあなたのムードがよい日が多いです。"
    }
}
