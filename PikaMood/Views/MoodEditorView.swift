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

    var date: Date

    // MARK: - Computed helpers

    private var intensityEmoji: String {
        switch intensity {
        case 0.0..<0.25: return "😴"
        case 0.25..<0.5: return "🙂"
        case 0.5..<0.75: return "😊"
        default: return "🤩"
        }
    }

    private var intensityPercentText: String {
        "\(Int(intensity * 100))%"
    }

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {

                headerSection
                moodGridSection
                intensitySection
                weatherSection
                tagSection
                journalSection
                saveButtonSection

                Spacer(minLength: 32)
            }
            .onTapGesture {
                    hideKeyboard()
                }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 8)
        }
        .background(
            ZStack {
                // Soft gradient base (same as before)
//                LinearGradient(
//                    colors: [
//                        Color(red: 1.0, green: 0.95, blue: 0.98),
//                        Color(red: 0.96, green: 0.97, blue: 1.0)
//                    ],
//                    startPoint: .top,
//                    endPoint: .bottom
//                )
//                .ignoresSafeArea()
            }
        )
        .preferredColorScheme(.light)
        .onAppear { loadExistingEntry() }
        .overlay(savedToast, alignment: .bottom)
    }

    // MARK: - Shared Card Style Helpers

    private func cardBackground(cornerRadius: CGFloat = 26) -> some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(Color.white.opacity(0.32))
    }

    private func cardStroke(cornerRadius: CGFloat = 26) -> some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .stroke(Color.pink.opacity(0.22), lineWidth: 1.1)
    }
    // MARK: - Kawaii Ribbon Header
    struct KawaiiRibbonHeader: View {
        let dateString: String
        
        var body: some View {
            ZStack {
                // Background Ribbon
                RoundedRectangle(cornerRadius: 22)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 1.0, green: 0.88, blue: 0.95),
                                Color(red: 1.0, green: 0.92, blue: 0.98)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .pink.opacity(0.15), radius: 10, y: 6)
                
                // Content
                HStack(spacing: 14) {
                    // Mascot Icon
                    Image(systemName: "heart.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.pink.opacity(0.9))
                        .padding(.leading, 8)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("PikaMood")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.pink)
                        
                        Text(dateString)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
            }
            .frame(height: 70)
            .padding(.horizontal)
            .padding(.top, 4)
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 6) {
            KawaiiRibbonHeader(dateString: formattedDate(date))

            Text(NSLocalizedString("today_title", comment: ""))
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.pink.opacity(0.8))
                .padding(.top, 2)
        }
    }



    // MARK: - Mood Grid

    private var moodGridSection: some View {
        let columns = [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ]

        return VStack(alignment: .leading, spacing: 16) {

            Text(NSLocalizedString("today_pick_mood", comment: ""))
                .font(.headline)
                .foregroundColor(.purple.opacity(0.7))
                .padding(.leading, 4)

            LazyVGrid(columns: columns, spacing: 14) {
                ForEach(MoodType.allCases) { mood in
                    moodPill(for: mood)
                }
            }
            .padding(.vertical, 4)
        }
        .padding(14)
        .background(cardBackground())
        .overlay(cardStroke())
        .shadow(color: .black.opacity(0.08), radius: 10, y: 5)
    }

    private func moodPill(for mood: MoodType) -> some View {
        let isSelected = (mood == selectedMood)

        return Button {
            Haptics.light()
            withAnimation(.interactiveSpring(response: 0.35, dampingFraction: 0.7)) {
                selectedMood = mood
            }
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 22)
                    .fill(Color(hex: mood.colorHex).opacity(0.24))
                    .overlay(
                        RoundedRectangle(cornerRadius: 22)
                            .stroke(isSelected ? Color.pink.opacity(0.55) : Color.clear,
                                    lineWidth: 2.4)
                    )
                    .shadow(color: .black.opacity(isSelected ? 0.15 : 0.05),
                            radius: isSelected ? 8 : 3,
                            y: 3)

                VStack(spacing: 4) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.9))
                            .frame(width: 42, height: 42)

                        Text(mood.emoji)
                            .font(.system(size: 26))
                    }

                    Text(mood.label)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.black.opacity(0.85))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                .padding(.vertical, 8)
            }
            .scaleEffect(isSelected ? 1.05 : 1.0)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Intensity

    private var intensitySection: some View {
        VStack(alignment: .leading, spacing: 12) {

            HStack {
                Text(NSLocalizedString("today_mood_strength", comment: ""))
                    .font(.headline)
                    .foregroundColor(.purple.opacity(0.7))

                Spacer()

                HStack(spacing: 4) {
                    Text(intensityEmoji)
                    Text(intensityPercentText)
                        .font(.caption)
                        .foregroundColor(.gray.opacity(0.8))
                }
            }

            HStack(spacing: 12) {

                Text(intensityEmoji)
                    .font(.system(size: 32))

                VStack(spacing: 6) {
                    Slider(value: $intensity)
                        .tint(Color.pink)

                    HStack {
                        Text("Low")
                            .font(.caption2)
                            .foregroundColor(.gray.opacity(0.7))
                        Spacer()
                        Text("High")
                            .font(.caption2)
                            .foregroundColor(.gray.opacity(0.7))
                    }
                }
            }
        }
        .padding(14)
        .background(cardBackground())
        .overlay(cardStroke())
        .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
        .onChange(of: intensity) { _ in
            Haptics.light()
        }
    }

    // MARK: - Weather

    private var weatherSection: some View {
        let columns = [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ]

        return VStack(alignment: .leading, spacing: 10) {
            Text(NSLocalizedString("today_weather_optional", comment: ""))
                .font(.headline)
                .foregroundColor(.purple.opacity(0.7))
                .padding(.leading, 4)

            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(WeatherType.allCases) { weather in
                    let isSelected = (weather == selectedWeather)

                    Button {
                        Haptics.light()
                        selectedWeather = (isSelected ? nil : weather)
                    } label: {
                        VStack(spacing: 4) {
                            Text(weather.emoji)
                                .font(.title2)

                            Text(weather.rawValue)
                                .font(.caption2)
                                .foregroundColor(.gray.opacity(0.8))
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(isSelected
                                      ? Color.pink.opacity(0.25)
                                      : Color.white.opacity(0.9))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(isSelected ? Color.pink : Color.clear, lineWidth: 1.8)
                        )
                        .shadow(color: .black.opacity(isSelected ? 0.12 : 0.04),
                                radius: isSelected ? 5 : 2, y: 2)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.top, 4)
        }
        .padding(14)
        .background(cardBackground())
        .overlay(cardStroke())
        .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
    }

    // MARK: - Tag / With Whom

    // MARK: - With Whom (Cuter, Softer, Kawaii Style)
    private var tagSection: some View {
        let columns = [
            GridItem(.flexible()),
            GridItem(.flexible())
        ]

        return VStack(alignment: .leading, spacing: 10) {
            Text(NSLocalizedString("today_tag_optional", comment: ""))
                .font(.headline)
                .foregroundColor(.purple.opacity(0.65))
                .padding(.leading, 4)

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(TagType.allCases) { tag in
                    let selected = (tag == selectedTag)

                    Button {
                        Haptics.light()
                        selectedTag = (selected ? nil : tag)
                    } label: {
                        HStack(spacing: 6) {
                            Text(tag.emoji)
                                .font(.system(size: 20)) // 🧁 smaller + cuter

                            Text(tag.rawValue)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(
                                    selected
                                    ? Color.white
                                    : Color.purple.opacity(0.7)
                                )
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                        }
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                        .background(
                            ZStack {
                                // Puffy pastel cloud style
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(
                                        selected
                                        ? Color.pink.opacity(0.6)
                                        : Color.white.opacity(0.75)
                                    )

                                // Soft glow only for selected chip
                                if selected {
                                    RoundedRectangle(cornerRadius: 18)
                                        .fill(Color.pink.opacity(0.35))
                                        .blur(radius: 14)
                                }
                            }
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(
                                    selected ? Color.pink.opacity(0.6) : Color.clear,
                                    lineWidth: 1.6
                                )
                        )
                        .shadow(
                            color: .pink.opacity(selected ? 0.25 : 0.08),
                            radius: selected ? 8 : 3,
                            y: selected ? 4 : 2
                        )
                    }
                    .buttonStyle(.plain)
                    .scaleEffect(selected ? 1.06 : 1.0)
                    .animation(.spring(response: 0.35, dampingFraction: 0.7), value: selected)
                }
            }
            .padding(.top, 4)
        }
        .padding(14)
        .background(cardBackground())
        .overlay(cardStroke())
        .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
    }


    // MARK: - Journal

    private var journalSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(NSLocalizedString("today_journal_title", comment: ""))
                .font(.headline)
                .foregroundColor(.purple.opacity(0.7))

            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.95))

                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.pink.opacity(0.18), lineWidth: 1)

                TextEditor(text: $journalText)
                    .scrollContentBackground(.hidden)
                    .padding(12)
                    .font(.system(size: 15))
            }
            .frame(minHeight: 120, maxHeight: 160)
            .overlay(
                Group {
                    if journalText.isEmpty {
                        Text(NSLocalizedString("today_journal_placeholder", comment: ""))
                            .foregroundColor(.gray.opacity(0.6))
                            .padding(.horizontal, 18)
                            .padding(.vertical, 14)
                            .allowsHitTesting(false)
                    }
                },
                alignment: .topLeading
            )
        }
        .padding(14)
        .background(cardBackground())
        .overlay(cardStroke())
        .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
    }

    // MARK: - Save Button

    private var saveButtonSection: some View {
        Button {
            Haptics.success()

            savePressed = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                savePressed = false
            }

            saveEntry()

            withAnimation {
                showSavedToast = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                withAnimation { showSavedToast = false }
            }

        } label: {
            HStack(spacing: 8) {
//                Text("💖")
                Text(NSLocalizedString("today_save_button", comment: ""))
            }
            .font(.system(size: 20, weight: .bold))
            .foregroundColor(.white)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    colors: [
                        Color.pink,
                        Color(red: 1.0, green: 0.6, blue: 0.7)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(24)
            .shadow(color: .pink.opacity(0.35), radius: 8, y: 4)
            .scaleEffect(savePressed ? 0.94 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: savePressed)
        }
        .padding(.top, 4)
    }

    // MARK: - Saved Toast

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

    // MARK: - Date Formatting

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.autoupdatingCurrent
        formatter.calendar = Calendar.autoupdatingCurrent
        formatter.dateStyle = .full
        return formatter.string(from: date)
    }

    // MARK: - Save & Load

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
                ownerId: user.appleID
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
        if let entry = moodStore.entries.first(where: {
            Calendar.current.isDate($0.date, inSameDayAs: date)
        }) {
            selectedMood = entry.moodType
            journalText = entry.journalText ?? ""
            selectedWeather = entry.weather
            selectedTag = entry.tag
            intensity = entry.intensity ?? 0.5
        }
    }
    
    private var topHeader: some View {
        ZStack {
            BlurView(style: .systemUltraThinMaterialDark)
                .frame(height: 55)
                .cornerRadius(0)

            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.pink)

                Text("PikaMood")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))

                Spacer()
            }
            .padding(.horizontal, 20)
        }
        .frame(maxWidth: .infinity)
    }

}

#Preview {
    MoodEditorView(date: Date())
        .environmentObject(MoodStore())
        .environmentObject(UserViewModel())
}
