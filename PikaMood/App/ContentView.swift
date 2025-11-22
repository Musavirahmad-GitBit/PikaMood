import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            NavigationStack {
                TodayView()
            }
            .tabItem {
                Label(NSLocalizedString("tab_today", comment: ""), systemImage: "sun.max.fill")
            }

            NavigationStack {
                CalendarView()
            }
            .tabItem {
                Label(NSLocalizedString("tab_calendar", comment: ""), systemImage: "calendar")
            }

            NavigationStack {
                AnalyticsView()
            }
            .tabItem {
                Label(NSLocalizedString("tab_analytics", comment: ""), systemImage: "chart.pie.fill")
            }

            NavigationStack {
                YearInPixelsView()
            }
            .tabItem {
                Label(NSLocalizedString("tab_pixels", comment: ""), systemImage: "square.grid.3x3.fill")
            }

            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label(NSLocalizedString("tab_settings", comment: ""), systemImage: "gearshape.fill")
            }
        }
        .tint(.pink)
    }
}
