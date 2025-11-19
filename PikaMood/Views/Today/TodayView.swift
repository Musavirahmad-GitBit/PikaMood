import SwiftUI
struct TodayView: View {
    @EnvironmentObject var userVM: UserViewModel
    @State private var showingMessageInput: Bool = false


    var body: some View {
        ScrollView {
            VStack(spacing: 20) {

                // 👉 Add partner mood here
                if let p = userVM.partner {
                    NavigationLink {
                        PartnerMoodHistoryView(partner: p)
                    } label: {
                        PartnerMoodCard(partner: p, mood: userVM.partnerLatestMood)
                    }
                    .buttonStyle(.plain)
                }

                // Your own mood UI
                MoodEditorView(date: Date())
            }
            .padding()
        }
//        .onAppear {
//            userVM.refreshPartnerMood()
//        }
        .overlay(
            Group {
                if userVM.showPartnerMoodPopup,
                   let partner = userVM.partner,
                   let mood = userVM.partnerNewMood {

                    PartnerMoodPopup(
                        showingMessageInput: $showingMessageInput,
                        partner: partner,
                        mood: mood,
                        suggestion: SuggestionEngine.suggestion(for: mood.moodType),
                        dismiss: {
                            userVM.showPartnerMoodPopup = false
                        }
                    )
                }
            }
        )

    }
}
