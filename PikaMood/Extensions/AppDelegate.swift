import UIKit
import CloudKit
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {

        // 1. Ask for visible push notification permission
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                print("🔔 Notification permission granted:", granted)
            }

        // 2. Register for APNS (device token)
        UIApplication.shared.registerForRemoteNotifications()

        return true
    }

    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        let notification = CKNotification(fromRemoteNotificationDictionary: userInfo)

        if let query = notification as? CKQueryNotification {
            let recordID = query.recordID?.recordName ?? "?"
            print("📩 CloudKit notification received for record:", recordID)

            NotificationCenter.default.post(
                name: .didReceiveCloudKitNotification,
                object: query
            )
        }

        completionHandler(.newData)
    }

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        print("📲 APNS device token registered")
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("❌ Failed to register for notifications:", error)
    }
}
