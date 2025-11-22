import SwiftUI

struct PartnerMoodPopup: View {
    @Binding var showingMessageInput: Bool
    @EnvironmentObject var userVM: UserViewModel

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
                
                // Title
                Text(NSLocalizedString("partner_popup_title", comment: ""))
                    .font(.headline)
                    .padding(.top, 12)

                // Emoji
                Text(mood.moodType.emoji)
                    .font(.system(size: 60))

                // Journal Text (quoted)
                if let text = mood.journalText, !text.isEmpty {
                    Text(
                        String(
                            format: NSLocalizedString("partner_popup_quote", comment: ""),
                            text
                        )
                    )
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                }

                // Suggestion
                VStack(spacing: 8) {
                    Text(NSLocalizedString("partner_popup_suggestion_title", comment: ""))
                        .font(.subheadline.bold())

                    Text(suggestion)
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                }

                // Buttons
                HStack(spacing: 20) {
                    Button(NSLocalizedString("partner_popup_send_hug", comment: "")) {
                        userVM.sendHugToPartner()
                    }
                    .buttonStyle(.borderedProminent)

                    Button(NSLocalizedString("partner_popup_send_message", comment: "")) {
                        showingMessageInput = true
                    }
                    .buttonStyle(.bordered)
                }

                // Close button
                Button(NSLocalizedString("partner_popup_close", comment: "")) {
                    dismiss()
                }
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
