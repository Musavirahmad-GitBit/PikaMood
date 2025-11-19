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
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["dailyMoodReminder"])

        let content = UNMutableNotificationContent()
        content.title = "今日の気分は？ 💖"
        content.body = "ムードを記録しましょう 🌸"
        content.sound = .default

        var components = DateComponents()
        components.hour = hour
        components.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        let request = UNNotificationRequest(
            identifier: "dailyMoodReminder",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }
    
    func sendPartnerMoodChanged(mood: MoodType) {
        let content = UNMutableNotificationContent()
        content.title = "パートナーの気分が更新されました 🌸"
        content.body = mood.notificationText
        content.sound = .default

        let req = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(req)
    }

}
