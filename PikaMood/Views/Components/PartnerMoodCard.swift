import SwiftUI

struct PartnerMoodCard: View {
    var partner: PMUser
    var mood: MoodEntry?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            HStack {
                Text(NSLocalizedString("partner_mood_title", comment: ""))
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

                        Text(timeAgo(from: mood.date))
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }

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

                if let intensity = mood.intensity {
                    ProgressView(value: intensity)
                        .progressViewStyle(.linear)
                        .tint(.pink)
                }

                Text(moodMeaning(for: mood.moodType))
                    .font(.footnote)
                    .foregroundColor(.purple)
                    .padding(.top, 4)

            } else {
                Text(NSLocalizedString("partner_mood_empty", comment: ""))
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

        if seconds < 60 {
            return NSLocalizedString("time_just_now", comment: "")
        }
        if seconds < 3600 {
            let mins = seconds / 60
            return String(format: NSLocalizedString("time_minutes_ago", comment: ""), mins)
        }
        if seconds < 86400 {
            let hours = seconds / 3600
            return String(format: NSLocalizedString("time_hours_ago", comment: ""), hours)
        }

        return NSLocalizedString("time_yesterday", comment: "")
    }

    // MARK: - Mood Meaning
    func moodMeaning(for mood: MoodType) -> String {
        switch mood {
        case .happy:
            return NSLocalizedString("mood_meaning_happy", comment: "")
        case .sad:
            return NSLocalizedString("mood_meaning_sad", comment: "")
        case .angry:
            return NSLocalizedString("mood_meaning_angry", comment: "")
        case .okay:
            return NSLocalizedString("mood_meaning_okay", comment: "")
        default:
            return NSLocalizedString("mood_meaning_default", comment: "")
        }
    }
}
