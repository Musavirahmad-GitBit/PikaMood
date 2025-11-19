import SwiftUI

struct PartnerMoodPopup: View {
    @Binding var showingMessageInput: Bool         // ✅ Added
    @EnvironmentObject var userVM: UserViewModel   // ✅ Added
    

    let partner: PMUser
    let mood: MoodEntry
    let suggestion: String
    var dismiss: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.45)
                .ignoresSafeArea()
                .onTapGesture { dismiss() }

            VStack(spacing: 16) {
                Text("パートナーが気分を更新しました 💞")
                    .font(.headline)
                    .padding(.top, 12)

                Text(mood.moodType.emoji)
                    .font(.system(size: 60))

                if let text = mood.journalText, !text.isEmpty {
                    Text("「\(text)」")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }

                VStack(spacing: 8) {
                    Text("💡 提案")
                        .font(.subheadline.bold())
                    Text(suggestion)
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                }

                HStack(spacing: 20) {
                    Button("ハグを送る 🤗") {
                        userVM.sendHugToPartner()      // ✅ Now works
                    }
                    .buttonStyle(.borderedProminent)

                    Button("メッセージを送る 💌") {
                        showingMessageInput = true     // ✅ Now works
                    }
                    .buttonStyle(.bordered)
                }

                Button("閉じる") { dismiss() }
                    .font(.footnote)
                    .padding(.bottom, 8)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemBackground))
            )
            .padding(.horizontal, 25)
            .shadow(radius: 10)
        }
    }
}
