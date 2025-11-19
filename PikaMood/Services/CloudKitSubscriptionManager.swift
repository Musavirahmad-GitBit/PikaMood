import CloudKit

final class CloudKitSubscriptionManager {

    static let shared = CloudKitSubscriptionManager()

    private init() {}

    /// Create subscription so we receive pushes when partner updates mood
    func createMoodSubscription(for ownerAppleID: String) {
        let predicate = NSPredicate(format: "ownerId == %@", ownerAppleID)

        let subscription = CKQuerySubscription(
            recordType: "MoodEntry",
            predicate: predicate,
            subscriptionID: "partner-mood-updates",
            options: [.firesOnRecordCreation, .firesOnRecordUpdate]
        )

        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.shouldSendContentAvailable = true   // silent push
        notificationInfo.soundName = "default"

        subscription.notificationInfo = notificationInfo

        CKContainer.default().publicCloudDatabase.save(subscription) { _, error in
            if let error = error {
                print("❌ Subscription error: \(error)")
            } else {
                print("✅ Mood subscription created successfully")
            }
        }
    }
}
