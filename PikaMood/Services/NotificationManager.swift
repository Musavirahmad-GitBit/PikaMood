import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()

    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("Error requesting notifications permission: \(error)")
            }
        }
    }

    func scheduleDailyReminder(hour: Int, minute: Int) {
        // Remove old reminders
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: ["dailyMoodReminder"])

        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("notif_daily_title", comment: "Daily reminder title")
        content.body = NSLocalizedString("notif_daily_body", comment: "Daily reminder body")
        content.sound = .default

        var components = DateComponents()
        components.hour = hour
        components.minute = minute

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: components,
            repeats: true
        )

        let request = UNNotificationRequest(
            identifier: "dailyMoodReminder",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    func sendPartnerMoodChanged(mood: MoodType) {
        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("notif_partner_title", comment: "Partner mood changed title")
        content.body = mood.notificationText   // Will localize this next
        content.sound = .default

        let req = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(req)
    }
}
