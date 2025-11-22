import SwiftUI

struct MoodEditorView: View {
    @EnvironmentObject var moodStore: MoodStore
    @EnvironmentObject var userVM: UserViewModel

    // Mood
    @State private var selectedMood: MoodType = .happy

    // Journal
    @State private var journalText: String = ""

    // Weather
    @State private var selectedWeather: WeatherType? = nil

    // Tags
    @State private var selectedTag: TagType? = nil

    // Intensity
    @State private var intensity: Double = 0.5

    // UI States
    @State private var showSavedToast = false
    @State private var savePressed = false
    @State private var catBounce = false
    
    private var intensityEmoji: String {
        switch intensity {
        case 0.0..<0.25: return "😐"
        case 0.25..<0.5: return "🙂"
        case 0.5..<0.75: return "😄"
        default: return "🤩"
        }
    }

    private var intensityColor: Color {
        switch intensity {
        case 0.0..<0.25: return Color.gray.opacity(0.4)
        case 0.25..<0.5: return Color.blue.opacity(0.7)
        case 0.5..<0.75: return Color.orange.opacity(0.8)
        default: return Color.pink
        }
    }

    var date: Date

    var body: some View {
        ScrollView {
            VStack(spacing: 22) {

                headerSection
                moodGridSection
                intensitySection
                weatherSection
                tagSection
                journalSection
                saveButtonSection

                Spacer(minLength: 40)
            }
            .padding()
        }
        .background(
            LinearGradient(
                colors: [
                    Color(red: 1.0, green: 0.95, blue: 0.98),
                    Color(red: 0.96, green: 0.97, blue: 1.0)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .preferredColorScheme(.light)
        .onAppear { loadExistingEntry() }
        .overlay(savedToast, alignment: .bottom)
    }
    private var headerSection: some View {
        VStack(spacing: 8) {
            // Date stays formatted in localized style
            Text(formattedDate(date))
                .font(.caption)
                .foregroundColor(.gray)

            // 🔥 Localized title
            Text(NSLocalizedString("mood_today_title", comment: "Header asking user's mood"))
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.pink)

            // 🔥 Localized subtitle
            Text(NSLocalizedString("mood_diary_subtitle", comment: "Cute mood diary subtitle"))
                .font(.subheadline)
                .foregroundColor(.gray)

            // Cat emoji (universal)
            Text("ฅ^•ﻌ•^ฅ")
                .font(.system(size: 48))
                .foregroundColor(.black)
                .scaleEffect(catBounce ? 1.08 : 1.0)
                .animation(
                    .easeInOut(duration: 0.9).repeatForever(autoreverses: true),
                    value: catBounce
                )
                .onAppear { catBounce = true }
        }
    }

    private var moodGridSection: some View {
        let columns = [
            GridItem(.flexible()),
            GridItem(.flexible())
        ]

        return VStack(alignment: .leading, spacing: 12) {
            Text(NSLocalizedString("today_pick_mood", comment: ""))
                .font(.headline)
                .foregroundColor(.purple)

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(MoodType.allCases) { mood in
                    moodCard(for: mood)
                }
            }
            .padding(12)
            .background(RoundedRectangle(cornerRadius: 20).fill(Color.white))
            .shadow(radius: 2, y: 1)
        }
    }
    private func moodCard(for mood: MoodType) -> some View {
        let isSelected = (mood == selectedMood)

        return Button {
            Haptics.light()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedMood = mood
            }
        } label: {
            VStack(spacing: 6) {
                Text(mood.emoji)
                    .font(.system(size: 32))

                Text(mood.label)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.black)
            }
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(isSelected ? Color(hex: mood.colorHex).opacity(0.3) : Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(isSelected ? Color.pink : Color.clear, lineWidth: 2)
            )
            .shadow(color: .black.opacity(isSelected ? 0.15 : 0.05),
                    radius: isSelected ? 6 : 2, y: 2)
            .scaleEffect(isSelected ? 1.05 : 1.0)
        }
        .buttonStyle(.plain)
    }
    private var intensitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(NSLocalizedString("today_mood_strength", comment: ""))
                .font(.headline)
                .foregroundColor(.purple)

            HStack {
                Text(intensityEmoji)
                    .font(.system(size: 36))
                    .padding(.trailing, 8)

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.gray.opacity(0.2))

                        Capsule()
                            .fill(intensityColor)
                            .frame(width: geometry.size.width * intensity)
                            .animation(.spring(response: 0.4, dampingFraction: 0.6), value: intensity)
                    }
                }
                .frame(height: 22)
            }
            .padding(.vertical, 6)

            Slider(value: $intensity)
                .tint(intensityColor)
                .onChange(of: intensity) { _ in
                    Haptics.light()
                }
        }
    }

    private var weatherSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(NSLocalizedString("today_weather_optional", comment: ""))
                .font(.headline)
                .foregroundColor(.purple)

            HStack(spacing: 10) {
                ForEach(WeatherType.allCases) { weather in
                    let isSelected = (weather == selectedWeather)

                    Button {
                        Haptics.light()
                        selectedWeather = weather
                    } label: {
                        Text(weather.emoji)
                            .font(.largeTitle)
                            .padding(8)
                            .background(isSelected ? Color.pink.opacity(0.3) : Color.white)
                            .cornerRadius(12)
                            .shadow(radius: 1, y: 1)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 20).fill(Color.white))
        .shadow(radius: 2, y: 1)
    }
    private var tagSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(NSLocalizedString("today_tag_optional", comment: ""))
                .font(.headline)
                .foregroundColor(.purple)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(TagType.allCases) { tag in
                        let selected = tag == selectedTag

                        Button {
                            Haptics.light()
                            selectedTag = tag
                        } label: {
                            HStack(spacing: 6) {
                                Text(tag.emoji)
                                Text(tag.rawValue)
                                    .font(.system(size: 14))
                            }
                            .padding(.vertical, 6)
                            .padding(.horizontal, 12)
                            .background(
                                Capsule()
                                    .fill(selected ? Color.pink.opacity(0.3) : Color.white)
                            )
                            .shadow(radius: 1, y: 1)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 20).fill(Color.white))
        .shadow(radius: 2, y: 1)
    }
    private var journalSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(NSLocalizedString("today_journal_title", comment: ""))
                .font(.headline)
                .foregroundColor(.purple)

            TextEditor(text: $journalText)
                .scrollContentBackground(.hidden)
                .background(Color.white)
                .frame(minHeight: 120, maxHeight: 160)
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 16).fill(Color.white)
                )
                .shadow(radius: 1, y: 1)
                .overlay(
                    Group {
                        if journalText.isEmpty {
                            Text(NSLocalizedString("today_journal_placeholder", comment: ""))
                                .foregroundColor(.gray.opacity(0.6))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .allowsHitTesting(false)
                        }
                    }
                )
        }
    }
    private var saveButtonSection: some View {
        Button {
            Haptics.success()

            savePressed = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { savePressed = false }

            saveEntry()

            withAnimation {
                showSavedToast = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                withAnimation { showSavedToast = false }
            }

        } label: {
            Text(NSLocalizedString("today_save_button", comment: ""))
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
                .padding(.vertical, 14)
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(colors: [.pink, .orange.opacity(0.9)],
                                   startPoint: .leading,
                                   endPoint: .trailing)
                )
                .cornerRadius(22)
                .shadow(radius: 3, y: 2)
                .scaleEffect(savePressed ? 0.92 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: savePressed)
        }
        .padding(.top, 8)
    }
    private var savedToast: some View {
        Group {
            if showSavedToast {
                Text(NSLocalizedString("today_saved_toast", comment: ""))
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Capsule().fill(Color.black.opacity(0.8)))
                    .padding(.bottom, 40)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.autoupdatingCurrent
        formatter.calendar = Calendar.autoupdatingCurrent
        formatter.dateStyle = .full
        return formatter.string(from: date)
    }


    private func saveEntry() {
        // 1) Save locally
        moodStore.addOrUpdate(
            date: date,
            moodType: selectedMood,
            journalText: journalText.isEmpty ? nil : journalText,
            weather: selectedWeather,
            tag: selectedTag,
            intensity: intensity
        )

        // 2) Save to CloudKit if logged-in user exists
        if let user = userVM.user {
            let entry = MoodEntry(
                date: date,
                moodType: selectedMood,
                journalText: journalText.isEmpty ? nil : journalText,
                weather: selectedWeather,
                tag: selectedTag,
                intensity: intensity,
                ownerId: user.appleID  // IMPORTANT
            )

            CloudKitService.shared.saveMoodToCloud(
                entry: entry,
                ownerAppleID: user.appleID
            ) { success in
                if !success {
                    print("⚠️ Failed to sync mood to CloudKit")
                } else {
                    print("✅ Synced mood to CloudKit")
                }
            }
        }
    }

    private func loadExistingEntry() {
        if let entry = moodStore.entries.first(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }) {
            selectedMood = entry.moodType
            journalText = entry.journalText ?? ""
            selectedWeather = entry.weather
            selectedTag = entry.tag
            intensity = entry.intensity ?? 0.5
        }
    }
}

#Preview {
    MoodEditorView(date: Date())
        .environmentObject(MoodStore())
}
