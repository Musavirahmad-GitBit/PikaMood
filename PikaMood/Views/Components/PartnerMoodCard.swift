import SwiftUI

struct PartnerMoodCard: View {
    var partner: PMUser
    var mood: MoodEntry?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            HStack {
                Text("💞 パートナーの気分")
                    .font(.headline)

                Spacer()
                Text(partner.displayName)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            if let mood = mood {
                HStack(spacing: 14) {
                    Text(mood.moodType.emoji)
                        .font(.system(size: 42))

                    VStack(alignment: .leading, spacing: 4) {
                        Text(mood.moodType.label)
                            .font(.title3)
                            .bold()

                        // TIME AGO
                        Text(timeAgo(from: mood.date))
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }

                // WEATHER + TAG
                HStack(spacing: 10) {
                    if let w = mood.weather {
                        Text(w.emoji)
                            .font(.title2)
                    }

                    if let t = mood.tag {
                        Text(t.emoji)
                            .font(.title2)
                    }
                }

                // INTENSITY BAR
                if let intensity = mood.intensity {
                    ProgressView(value: intensity)
                        .progressViewStyle(.linear)
                        .tint(.pink)
                }

                // MEANING / SUGGESTION
                Text(moodMeaning(for: mood.moodType))
                    .font(.footnote)
                    .foregroundColor(.purple)
                    .padding(.top, 4)

            } else {
                Text("まだ今日の気分は記録されていません。")
                    .font(.caption)
                    .foregroundColor(.gray)
            }

        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 18).fill(Color.white))
        .shadow(radius: 3, y: 2)
        .padding(.horizontal)
    }

    // MARK: - Time Ago Helper
    func timeAgo(from date: Date) -> String {
        let seconds = Int(Date().timeIntervalSince(date))

        if seconds < 60 { return "たった今" }
        if seconds < 3600 { return "\(seconds / 60) 分前" }
        if seconds < 86400 { return "\(seconds / 3600) 時間前" }
        return "昨日"
    }

    // MARK: - Mood Meaning
    func moodMeaning(for mood: MoodType) -> String {
        switch mood {
        case .happy: return "💖 パートナーは幸せそう！やさしい言葉を送ってみる？"
        case .sad: return "💙 少し落ち込んでるかも。温かいメッセージを送ろう。"
        case .angry: return "❤️‍🔥 ストレスを感じているかも。そっと支えてあげて。"
        case .okay: return "💛 穏やかな気分みたい。小さな応援メッセージはどう？"
        default: return "🧸 パートナーの気分を大切にしよう。"
        }
    }
}
