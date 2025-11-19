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

                Text("\(partner.displayName) さんのムード履歴")
                    .font(.title2)
                    .bold()
                    .padding(.horizontal)

                if isLoading {
                    ProgressView("読み込み中…")
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
        .navigationTitle("気分の歴史")
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
        f.dateFormat = "MM/dd"
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
