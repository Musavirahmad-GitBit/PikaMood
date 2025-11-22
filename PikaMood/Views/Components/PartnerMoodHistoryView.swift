import SwiftUI

struct PartnerMoodHistoryView: View {
    var partner: PMUser
    @State var moods: [MoodEntry] = []
    @State var isLoading = true

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                // LOCALIZED TITLE WITH PARTNER NAME
                Text(
                    String(
                        format: NSLocalizedString("partner_history_title", comment: ""),
                        partner.displayName
                    )
                )
                .font(.title2)
                .bold()
                .padding(.horizontal)

                if isLoading {
                    ProgressView(NSLocalizedString("loading_text", comment: ""))
                        .padding()
                }

                LazyVGrid(columns: columns, spacing: 18) {
                    ForEach(moods.indices, id: \.self) { i in
                        moodTile(moods[i])
                    }
                }
                .padding(.horizontal)
            }
        }

        .navigationTitle(NSLocalizedString("nav_mood_history", comment: ""))
        .onAppear { loadHistory() }
    }

    private func moodTile(_ entry: MoodEntry) -> some View {
        VStack(spacing: 6) {
            Text(entry.moodType.emoji)
                .font(.system(size: 42))

            Text(shortDate(entry.date))
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(radius: 2, y: 1)
        )
    }

    private func shortDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "MM/dd"   // keep as-is (can localize later if needed)
        return f.string(from: date)
    }

    private func loadHistory() {
        CloudKitService.shared.fetchAllMoods(forOwnerId: partner.appleID) { entries in
            DispatchQueue.main.async {
                self.moods = entries
                self.isLoading = false
            }
        }
    }
}
