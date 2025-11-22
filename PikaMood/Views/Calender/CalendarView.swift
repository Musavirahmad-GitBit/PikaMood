import SwiftUI

struct WeekdayStrings {
    static let jp = ["月", "火", "水", "木", "金", "土", "日"]
    static let en = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
}


struct CalendarView: View {
    @EnvironmentObject var moodStore: MoodStore

    @State private var currentDate = Date()
    @State private var selectedDay: CalendarDay? = nil
    @AppStorage("appLanguage") private var appLanguage: String = "ja"



    private let calendar = Calendar.current

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 1.0, green: 0.95, blue: 0.98),
                        Color(red: 0.93, green: 0.97, blue: 1.0)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 16) {
                    header
                    seasonalSticker
                    weekdayLabels
                    calendarGrid
                    Spacer()
                }
                .padding()
            }
            .navigationDestination(item: $selectedDay) { wrapper in
                    MoodDetailView(date: wrapper.date)
                }
        }
    }

    // MARK: - Header (Month + Navigation Buttons)

    private var header: some View {
        HStack {
            Button {
                withAnimation {
                    currentDate = calendar.date(byAdding: .month, value: -1, to: currentDate)!
                }
            } label: {
                Image(systemName: "chevron.left.circle.fill")
                    .font(.largeTitle)
                    .foregroundColor(.pink)
            }

            Spacer()

            Text(formatMonth(currentDate))
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.purple)

            Spacer()

            Button {
                withAnimation {
                    currentDate = calendar.date(byAdding: .month, value: 1, to: currentDate)!
                }
            } label: {
                Image(systemName: "chevron.right.circle.fill")
                    .font(.largeTitle)
                    .foregroundColor(.pink)
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Weekday Labels (Mon–Sun)

    private var weekdayLabels: some View {
        let weekdays = appLanguage == "ja" ? WeekdayStrings.jp : WeekdayStrings.en

        return HStack {
            ForEach(weekdays, id: \.self) { day in
                Text(day)
                    .font(.headline)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var seasonalSticker: some View {
        let month = calendar.component(.month, from: currentDate)

        let sticker: String = switch month {
        case 1: "❄️"
        case 2: "💘"
        case 3: "🌸"
        case 4: "🌷"
        case 5: "🌼"
        case 6: "🌧️"
        case 7: "🍉"
        case 8: "🌻"
        case 9: "🍁"
        case 10: "🎃"
        case 11: "🍂"
        default: "🎄"
        }

        return Text(sticker)
            .font(.system(size: 36))
            .padding(.bottom, -10)
    }

    // MARK: - Calendar Grid

    private var calendarGrid: some View {
        let days = generateCalendarDays(for: currentDate)

        return LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 16) {
            ForEach(days) { item in
                dayCell(item.date)
            }
        }
        .padding(.top, 8)
    }

    // MARK: - Calendar Day Cell

    @ViewBuilder
    private func dayCell(_ date: Date?) -> some View {
        if let date = date {
            let entry = moodStore.entries.first {
                calendar.isDate($0.date, inSameDayAs: date)
            }

            VStack(spacing: 6) {
                Text("\(calendar.component(.day, from: date))")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(
                        isFuture(date) ? .gray.opacity(0.3) :
                        isWeekend(date) ? .purple :
                        .black
                    )

                if let entry = entry {
                    Text(entry.moodType.emoji)
                        .font(.system(size: 22))
                        .padding(.top, 2)
                } else {
                    Circle()
                        .fill(Color.gray.opacity(0.15))
                        .frame(width: 10, height: 10)
                        .padding(.top, 6)
                }
            }
            .frame(height: 58)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isToday(date) ? Color.pink.opacity(0.25) : Color.white.opacity(0.85))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isToday(date) ? Color.pink : .clear, lineWidth: 2)
            )
            .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
            .scaleEffect(isToday(date) ? 1.06 : 1.0)
            .onTapGesture {
                selectedDay = CalendarDay(date: date)
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedDay)

        } else {
            Color.clear.frame(height: 50)
        }
    }

    // MARK: - Helpers

    private func formatMonth(_ date: Date) -> String {
        let f = DateFormatter()
        if appLanguage == "ja" {
            f.locale = Locale(identifier: "ja_JP")
            f.dateFormat = "yyyy年 M月"
        } else {
            f.locale = Locale(identifier: "en_US")
            f.dateFormat = "MMMM yyyy"
        }
        return f.string(from: date)
    }

    private func isToday(_ date: Date) -> Bool {
        calendar.isDate(date, inSameDayAs: Date())
    }

    private func isFuture(_ date: Date) -> Bool {
        date > Date()
    }
    
    private func isWeekend(_ date: Date) -> Bool {
        calendar.isDateInWeekend(date)
    }

    private func generateCalendarDays(for baseDate: Date) -> [CalendarGridItem] {
        var items: [CalendarGridItem] = []

        guard let monthInterval = calendar.dateInterval(of: .month, for: baseDate) else {
            return items
        }

        let startOfMonth = monthInterval.start
        let daysInMonth = calendar.range(of: .day, in: .month, for: baseDate)!.count

        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        let offset = (firstWeekday + 6) % 7   // Monday-first

        // Empty placeholders
        for _ in 0..<offset {
            items.append(CalendarGridItem(date: nil))
        }

        // Actual days
        for day in 1...daysInMonth {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                items.append(CalendarGridItem(date: date))
            }
        }

        return items
    }
}
