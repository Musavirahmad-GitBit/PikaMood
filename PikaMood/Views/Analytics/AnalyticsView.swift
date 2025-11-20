import SwiftUI
import Charts

// Simple struct for daily mood score points (for the trend chart)
private struct DailyMoodPoint: Identifiable {
    let id = UUID()
    let date: Date
    let score: Double
}

// Weekday stats for bar chart
private struct WeekdayMoodStat: Identifiable {
    let id = UUID()
    let weekdayShort: String   // "Mon", "火" etc
    let count: Int
}

struct AnalyticsView: View {
    @EnvironmentObject var moodStore: MoodStore
    @AppStorage("appLanguage") private var appLanguage: String = "ja"

    // MARK: - Computed Data

    /// Last 30 days
    private var recentEntries: [MoodEntry] {
        let now = Date()
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: now)!
        return moodStore.entries.filter { $0.date >= thirtyDaysAgo }
    }

    /// Map mood to numeric score (0–5)
    private func score(for mood: MoodType) -> Double {
        switch mood {
        case .veryHappy: return 5.0
        case .happy:     return 4.0
        case .calm:      return 3.5
        case .okay:      return 3.0
        case .tired:     return 2.5
        case .sad:       return 2.0
        case .angry:     return 1.5
        }
    }

    /// Overall mood score (0–100)
    private var overallScore: Double? {
        let all = recentEntries
        guard !all.isEmpty else { return nil }

        let avg = all
            .map { score(for: $0.moodType) }
            .reduce(0, +) / Double(all.count)

        return (avg / 5.0) * 100.0
    }

    /// Daily points for the last 30 days (trend chart)
    private var trendData: [DailyMoodPoint] {
        guard !recentEntries.isEmpty else { return [] }

        let calendar = Calendar.current
        let now = Date()
        let thirtyDaysAgo = calendar.date(byAdding: .day, value: -29, to: now)! // 30 days including today

        var points: [DailyMoodPoint] = []

        for i in 0..<30 {
            if let day = calendar.date(byAdding: .day, value: i, to: thirtyDaysAgo) {
                let sameDay = recentEntries.filter { calendar.isDate($0.date, inSameDayAs: day) }
                if sameDay.isEmpty {
                    // no mood logged → treat as neutral-ish (optional)
                    points.append(DailyMoodPoint(date: day, score: 0))
                } else {
                    let avg = sameDay.map { score(for: $0.moodType) }.reduce(0, +) / Double(sameDay.count)
                    points.append(DailyMoodPoint(date: day, score: avg))
                }
            }
        }

        return points
    }

    /// Mood counts for pie chart
    private var moodCounts: [(MoodType, Int)] {
        MoodType.allCases.map { mood in
            (mood, moodStore.entries.filter { $0.moodType == mood }.count)
        }
    }

    /// Weekday stats for bar chart
    private var weekdayStats: [WeekdayMoodStat] {
        let calendar = Calendar.current

        let grouped = Dictionary(grouping: moodStore.entries) { entry -> String in
            let formatter = DateFormatter()
            if appLanguage == "ja" {
                formatter.locale = Locale(identifier: "ja_JP")
                formatter.dateFormat = "EEE"
            } else {
                formatter.locale = Locale(identifier: "en_US")
                formatter.dateFormat = "EEE"
            }
            return formatter.string(from: entry.date)
        }

        return grouped.keys.sorted().map { key in
            WeekdayMoodStat(weekdayShort: key, count: grouped[key]?.count ?? 0)
        }
    }

    // MARK: - BODY

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    summaryCard

                    if !trendData.isEmpty {
                        trendChartCard
                    }

                    moodPieCard
                    weeklyBarCard
                    insightCard
                    miniTipsCard
                }
                .padding()
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 4) {
            Text(NSLocalizedString("analytics_title", comment: ""))
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.pink)

            Text(NSLocalizedString("analytics_subtitle", comment: ""))
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Summary Card

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("💗")
                    .font(.system(size: 32))
                VStack(alignment: .leading, spacing: 4) {
                    Text(NSLocalizedString("analytics_summary_title", comment: ""))
                        .font(.headline)

                    if let score = overallScore {
                        Text(summaryText(for: score))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    } else {
                        Text(NSLocalizedString("analytics_summary_no_data", comment: ""))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
            }

            if let score = overallScore {
                // cute progress-like bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.gray.opacity(0.2))

                        Capsule()
                            .fill(Color.pink.opacity(0.7))
                            .frame(width: geo.size.width * CGFloat(min(max(score / 100.0, 0), 1)))
                    }
                }
                .frame(height: 12)

                HStack {
                    Text("0")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("100")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white.opacity(0.95))
                .shadow(color: .black.opacity(0.05), radius: 6, y: 4)
        )
    }

    private func summaryText(for score: Double) -> String {
        if appLanguage == "ja" {
            switch score {
            case 80...:
                return "とても良い一ヶ月でした 💕"
            case 60..<80:
                return "全体的に良い気分の日が多いですね 🌈"
            case 40..<60:
                return "良い日と大変な日が半分ずつくらいかな… 🌤"
            default:
                return "少し大変な日が多かったかも。自分をいたわってあげてくださいね 🤍"
            }
        } else {
            switch score {
            case 80...:
                return "You’ve had a really bright month 💕"
            case 60..<80:
                return "Overall, you’ve had many good days 🌈"
            case 40..<60:
                return "A mix of good and tough days 🌤"
            default:
                return "It’s been a bit hard lately. Be gentle with yourself 🤍"
            }
        }
    }

    // MARK: - Trend Chart

    private var trendChartCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(NSLocalizedString("analytics_trend_title", comment: ""))
                .font(.headline)

            Chart(trendData) { point in
                AreaMark(
                    x: .value("Date", point.date),
                    y: .value("Score", point.score)
                )
                .foregroundStyle(Gradient(colors: [
                    Color.pink.opacity(0.6),
                    Color.pink.opacity(0.1)
                ]))

                LineMark(
                    x: .value("Date", point.date),
                    y: .value("Score", point.score)
                )
                .lineStyle(StrokeStyle(lineWidth: 2, lineCap: .round))
                .foregroundStyle(Color.pink)
            }
            .frame(height: 220)
            .chartXAxis {
                AxisMarks(values: .stride(by: .day, count: 7)) { value in
                    AxisGridLine()
                    AxisValueLabel(formatShortDate(value.as(Date.self)))
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) {
                    AxisGridLine()
                    AxisValueLabel()
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.95))
                .shadow(radius: 5)
        )
    }

    private func formatShortDate(_ date: Date?) -> String {
        guard let date else { return "" }

        let f = DateFormatter()
        if appLanguage == "ja" {
            f.locale = Locale(identifier: "ja_JP")
            f.dateFormat = "M/d"
        } else {
            f.locale = Locale(identifier: "en_US")
            f.dateFormat = "MMM d"
        }
        return f.string(from: date)
    }

    // MARK: - Mood Pie Chart

    private var moodPieCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(NSLocalizedString("analytics_mood_ratio", comment: ""))
                .font(.headline)

            if moodStore.entries.isEmpty {
                Text(NSLocalizedString("analytics_no_data", comment: ""))
                    .foregroundColor(.gray)
                    .font(.footnote)
            } else {
                Chart {
                    ForEach(moodCounts, id: \.0.id) { (mood, count) in
                        if count > 0 {
                            SectorMark(
                                angle: .value("Count", count),
                                innerRadius: .ratio(0.55),
                                angularInset: 1.5
                            )
                            .foregroundStyle(Color(hex: mood.colorHex))
                            .annotation(position: .overlay) {
                                Text(mood.emoji)
                                    .font(.caption)
                            }
                        }
                    }
                }
                .frame(height: 240)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.95))
                .shadow(radius: 4)
        )
    }

    // MARK: - Weekly Bar Chart

    private var weeklyBarCard: some View {
        VStack(alignment: .leading, spacing: 8) {

            Text(NSLocalizedString("analytics_weekly_trend", comment: ""))
                .font(.headline)

            if weekdayStats.isEmpty {
                Text(NSLocalizedString("analytics_no_data", comment: ""))
                    .foregroundColor(.gray)
                    .font(.footnote)
            } else {
                Chart(weekdayStats) { stat in
                    BarMark(
                        x: .value("Day", stat.weekdayShort),
                        y: .value("Count", stat.count)
                    )
                    .foregroundStyle(Color.pink)
                    .cornerRadius(6)
                }
                .frame(height: 200)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.95))
                .shadow(radius: 4)
        )
    }

    // MARK: - Insight Card

    private var insightCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(NSLocalizedString("analytics_insights", comment: ""))
                .font(.headline)

            if moodStore.entries.isEmpty {
                Text(NSLocalizedString("analytics_no_data", comment: ""))
                    .foregroundColor(.gray)
            } else {
                Text(mainInsightText())
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .padding(.bottom, 4)

                Text(secondaryInsightText())
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.96))
                .shadow(radius: 4)
        )
    }

    private func mainInsightText() -> String {
        guard let score = overallScore else {
            return appLanguage == "ja"
            ? "データが集まると、もっと詳しいインサイトをお届けできます 🌱"
            : "Once you log more moods, we’ll show deeper insights 🌱"
        }

        if appLanguage == "ja" {
            if score >= 75 {
                return "最近、ポジティブな日がとても多いですね。自分を大切にできている証拠です 💖"
            } else if score >= 55 {
                return "良い日も大変な日もありながら、ちゃんと前に進んでいます 🌱"
            } else {
                return "少し心が疲れているかもしれません。小さなごほうびや休憩を意識してみましょう ☁️"
            }
        } else {
            if score >= 75 {
                return "You’ve been having many positive days lately. You’re taking care of yourself 💖"
            } else if score >= 55 {
                return "You’re moving forward, even with a mix of good and tough days 🌱"
            } else {
                return "Your heart might be a bit tired. Try small rewards and gentle breaks ☁️"
            }
        }
    }

    private func secondaryInsightText() -> String {
        // simple insight based on most common mood
        let mostCommon = moodCounts.max(by: { $0.1 < $1.1 })

        guard let top = mostCommon, top.1 > 0 else {
            return appLanguage == "ja"
            ? "まずは数日分のムードを記録してみましょう 📅"
            : "Start by logging a few more days of mood 📅"
        }

        if appLanguage == "ja" {
            return "一番多いのは「\(top.0.emoji) \(top.0.label)」。その日には何をしていたか、少し思い出してみましょう。"
        } else {
            return "Your most frequent mood is “\(top.0.emoji) \(top.0.label)”. Think about what those days had in common."
        }
    }

    // MARK: - Mini Tips

    private var miniTipsCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(NSLocalizedString("analytics_tips_title", comment: ""))
                .font(.headline)

            let tips = miniTips()

            ForEach(tips.indices, id: \.self) { idx in
                HStack(alignment: .top, spacing: 8) {
                    Text("•")
                    Text(tips[idx])
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white.opacity(0.95))
                .shadow(radius: 3)
        )
    }

    private func miniTips() -> [String] {
        if appLanguage == "ja" {
            return [
                "1日1つだけでもムードを記録すると、自分の心のパターンが見えてきます。",
                "寝る前に今日の気持ちを振り返ってみるのもおすすめです 🌙",
                "パートナーと同じ日を見て「一緒にがんばったね」と声をかけてみましょう 💕"
            ]
        } else {
            return [
                "Even logging one mood per day helps you see your emotional patterns.",
                "Try reflecting on your mood before going to bed 🌙",
                "Look at the same day with your partner and say, “We did our best today.” 💕"
            ]
        }
    }
}

#Preview {
    AnalyticsView()
        .environmentObject(MoodStore())
    
}
