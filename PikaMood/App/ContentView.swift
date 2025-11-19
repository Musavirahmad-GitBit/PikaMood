import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            NavigationStack {
                TodayView()
            }
            .tabItem {
                Label("今日", systemImage: "sun.max.fill")
            }

            NavigationStack {
                CalendarView()
            }
            .tabItem {
                Label("カレンダー", systemImage: "calendar")
            }

            NavigationStack {
                AnalyticsView()
            }
            .tabItem {
                Label("分析", systemImage: "chart.pie.fill")
            }

            NavigationStack {
                YearInPixelsView()
            }
            .tabItem {
                Label("ピクセル", systemImage: "square.grid.3x3.fill")
            }

            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("設定", systemImage: "gearshape.fill")
            }
        }
        .tint(.pink)
    }
}
