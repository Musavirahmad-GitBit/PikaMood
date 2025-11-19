//
//  CloudKitService.swift
//  PikaMood
//
//  Created by Musawwir Ahmad  on 2025-11-17.
//
import Foundation
import CloudKit

final class CloudKitService {
    static let shared = CloudKitService()
    private init() {}

    let container = CKContainer(identifier: "iCloud.com.brackits.PikaMood")

    var database: CKDatabase {
        container.privateCloudDatabase
    }

    // MARK: - Update Single Field
    func updateUserField(
        recordID: CKRecord.ID,
        key: String,
        value: Any,
        completion: @escaping (Bool) -> Void
    ) {
        database.fetch(withRecordID: recordID) { record, error in
            guard let record = record else {
                completion(false)
                return
            }

            if let ckValue = value as? CKRecordValue {
                record[key] = ckValue
            } else {
                print("❌ Value does NOT conform to CKRecordValue")
                completion(false)
                return
            }

            self.database.save(record) { _, error in
                completion(error == nil)
            }
        }
    }

    // MARK: - Find user by share code
    func findUserByShareCode(_ code: String, completion: @escaping (PMUser?) -> Void) {
        let predicate = NSPredicate(format: "shareCode == %@", code)
        let query = CKQuery(recordType: PMUser.recordType, predicate: predicate)

        database.perform(query, inZoneWith: nil) { records, error in
            if let record = records?.first {
                completion(self.recordToUser(record))
            } else {
                completion(nil)
            }
        }
    }



    // MARK: - Link partners (two-way)
    func linkPartners(userA: PMUser, userB: PMUser, completion: @escaping (Bool) -> Void) {

        let idA = userA.id
        let idB = userB.id

        let group = DispatchGroup()
        var success = true

        // A.partnerId = B.recordName
        group.enter()
        updateUserField(recordID: idA, key: "partnerId", value: idB.recordName) { ok in
            if !ok { success = false }
            group.leave()
        }

        // B.partnerId = A.recordName
        group.enter()
        updateUserField(recordID: idB, key: "partnerId", value: idA.recordName) { ok in
            if !ok { success = false }
            group.leave()
        }

        group.notify(queue: .main) {
            completion(success)
        }
    }
}


// MARK: - User Handling
extension CloudKitService {

    func getOrCreateUser(completion: @escaping (PMUser?) -> Void) {

        container.fetchUserRecordID { appleRecordID, error in
            if let error = error {
                print("❌ fetchUserRecordID FAILED:", error)
                completion(nil)
                return
            }

            guard let appleRecordID = appleRecordID else {
                print("⚠️ No Apple user record ID returned")
                completion(nil)
                return
            }

            let appleID = appleRecordID.recordName  // this can start with "_"

            print("📌 Apple CK userId:", appleID)

            // Query: does a UserProfile exist with this userId?
            let predicate = NSPredicate(format: "userId == %@", appleID)
            let query = CKQuery(recordType: PMUser.recordType, predicate: predicate)

            self.database.perform(query, inZoneWith: nil) { records, error in
                if let existing = records?.first {
                    print("✅ Existing user found:", existing.recordID.recordName)
                    completion(self.recordToUser(existing))
                } else {
                    // Create a NEW record with SAFE ID
                    self.createNewUser(appleID: appleID, completion: completion)
                }
            }
        }
    }
        


    private func createNewUser(
        appleID: String,
        completion: @escaping (PMUser?) -> Void
    ) {
        // 1. Generate a valid CloudKit-safe recordID
        let recordID = CKRecord.ID(recordName: UUID().uuidString)

        // 2. Create a UserProfile record
        let record = CKRecord(recordType: PMUser.recordType, recordID: recordID)

        // ✅ Store the RAW appleID as userId (field values can contain "_", the problem was recordName)
        record["userId"] = appleID as CKRecordValue
        record["partnerMoodSeenDate"] = nil

        // 3. Save fields (schema exact match)
        record["displayName"] = "PikaMood User" as CKRecordValue
        record["partnerId"] = "" as CKRecordValue

        // Make shareCode from recordID, more on this below
        let cleanRecordName = recordID.recordName.replacingOccurrences(of: "-", with: "")
        let share = String(cleanRecordName.prefix(8)).uppercased()
        record["shareCode"] = share as CKRecordValue

        print("🆕 Creating new UserProfile with safe ID:", recordID.recordName)

        database.save(record) { saved, error in
            if let error = error {
                print("❌ ERROR saving user:", error)
                completion(nil)
                return
            }

            print("✅ UserProfile CREATED:", saved!.recordID.recordName)
            completion(self.recordToUser(saved!))
        }
    }

    private func recordToUser(_ record: CKRecord) -> PMUser {
        var user = PMUser(
            id: record.recordID,
            appleID: record["userId"] as? String ?? "",
            displayName: record["displayName"] as? String ?? "",
            partnerID: record["partnerId"] as? String,
            profilePhoto: record["avatar"] as? CKAsset,
            shareCode: record["shareCode"] as? String ?? ""
        )

        user.partnerMoodSeenDate = record["partnerMoodSeenDate"] as? Date
        return user
    }


    
    func fetchUser(byRecordName recordName: String, completion: @escaping (PMUser?) -> Void) {

        let recordID = CKRecord.ID(recordName: recordName)

        database.fetch(withRecordID: recordID) { record, error in
            guard let record = record else {
                completion(nil)
                return
            }
            completion(self.recordToUser(record))
        }
    }

}
// MARK: - Mood Entries (CloudKit)
extension CloudKitService {

    // Helper: make a stable record name: userId + yyyyMMdd
    private func moodRecordName(ownerId: String, date: Date) -> String {
        let safeId = safeCloudKitString(ownerId)

        let f = DateFormatter()
        f.dateFormat = "yyyyMMdd"
        let dayString = f.string(from: date)

        return "\(safeId)_\(dayString)"
    }

    func saveMoodToCloud(entry: MoodEntry,
                         ownerAppleID: String,
                         completion: @escaping (Bool) -> Void) {

        let calendar = Calendar.current
        let day = calendar.startOfDay(for: entry.date)
        
        let recordName = moodRecordName(ownerId: ownerAppleID, date: day)
        let recordID = CKRecord.ID(recordName: recordName)

        // 1. First fetch the existing record
        database.fetch(withRecordID: recordID) { existingRecord, error in
            
            // If the record exists → UPDATE
            let record = existingRecord ?? CKRecord(recordType: "MoodEntry", recordID: recordID)

            // 2. Update fields
            record["ownerId"] = ownerAppleID as CKRecordValue
            record["date"] = day as CKRecordValue
            record["moodType"] = entry.moodType.rawValue as CKRecordValue
            
            if let intensity = entry.intensity {
                record["intensity"] = intensity as CKRecordValue
            } else {
                record["intensity"] = nil
            }

            if let journal = entry.journalText, !journal.isEmpty {
                record["journalText"] = journal as CKRecordValue
            } else {
                record["journalText"] = nil
            }

            if let weather = entry.weather {
                record["weather"] = weather.rawValue as CKRecordValue
            } else {
                record["weather"] = nil
            }

            if let tag = entry.tag {
                record["tag"] = tag.rawValue as CKRecordValue
            } else {
                record["tag"] = nil
            }

            // 3. Save (CloudKit will treat it as UPDATE if record exists)
            self.database.save(record) { saved, error in
                if let error = error {
                    print("❌ saveMoodToCloud error:", error)
                    completion(false)
                } else {
                    print("✅ MoodEntry saved/updated for", ownerAppleID, "→", recordName)
                    completion(true)
                }
            }
        }
    }

    func fetchLatestMood(forOwnerId ownerId: String,
                         completion: @escaping (MoodEntry?) -> Void) {

        let predicate = NSPredicate(format: "ownerId == %@", ownerId)
        let query = CKQuery(recordType: "MoodEntry", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]

        let op = CKQueryOperation(query: query)
        op.resultsLimit = 1

        var latestRecord: CKRecord?

        op.recordFetchedBlock = { record in
            latestRecord = record
        }

        op.queryResultBlock = { result in
            switch result {
            case .success:
                guard let record = latestRecord else {
                    completion(nil)
                    return
                }
                let mood = self.recordToMoodEntry(record: record)
                completion(mood)

            case .failure(let error):
                print("❌ fetchLatestMood error:", error)
                completion(nil)
            }
        }

        database.add(op)
    }

    private func recordToMoodEntry(record: CKRecord) -> MoodEntry {
        let date = record["date"] as? Date ?? Date()
        let moodRaw = record["moodType"] as? String ?? MoodType.okay.rawValue
        let moodType = MoodType(rawValue: moodRaw) ?? .okay

        let intensity = record["intensity"] as? Double
        let journal = record["journalText"] as? String

        let weatherRaw = record["weather"] as? String
        let tagRaw = record["tag"] as? String

        let weather = weatherRaw.flatMap { WeatherType(rawValue: $0) }
        let tag = tagRaw.flatMap { TagType(rawValue: $0) }

        return MoodEntry(
            date: date,
            moodType: moodType,
            journalText: journal,
            weather: weather,
            tag: tag,
            intensity: intensity,
            ownerId: record["ownerId"] as? String
        )
    }
    
    private func safeCloudKitString(_ input: String) -> String {
        // Remove ALL characters that are NOT A-Z, a-z, 0-9, or hyphen
        let allowed = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-")
        let filtered = input.unicodeScalars.filter { allowed.contains($0) }
        let result = String(String.UnicodeScalarView(filtered))

        // If empty, fallback to a UUID
        return result.isEmpty ? UUID().uuidString : result
    }
    
    func fetchAllMoods(forOwnerId ownerId: String,
                       completion: @escaping ([MoodEntry]) -> Void) {

        let predicate = NSPredicate(format: "ownerId == %@", ownerId)
        let query = CKQuery(recordType: "MoodEntry", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]

        let op = CKQueryOperation(query: query)
        var results: [CKRecord] = []

        op.recordFetchedBlock = { record in
            results.append(record)
        }

        op.queryResultBlock = { result in
            switch result {
            case .success:
                let moods = results.map { self.recordToMoodEntry(record: $0) }
                completion(moods)
            case .failure(let error):
                print("❌ fetchAllMoods error:", error)
                completion([])
            }
        }

        database.add(op)
    }
    
    func sendHug(from senderId: String, to receiverId: String, completion: @escaping (Bool) -> Void) {

        let record = CKRecord(recordType: "HugEvent")

        record["senderId"] = senderId as CKRecordValue
        record["receiverId"] = receiverId as CKRecordValue
        record["timestamp"] = Date() as CKRecordValue

        database.save(record) { _, error in
            if let error = error {
                print("❌ sendHug error:", error)
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    func sendSupportMessage(
        from senderId: String,
        to receiverId: String,
        text: String,
        completion: @escaping (Bool) -> Void
    ) {
        let record = CKRecord(recordType: "SupportMessage")

        record["senderId"] = senderId as CKRecordValue
        record["receiverId"] = receiverId as CKRecordValue
        record["text"] = text as CKRecordValue
        record["timestamp"] = Date() as CKRecordValue

        database.save(record) { _, error in
            if let error = error {
                print("❌ sendSupportMessage error:", error)
                completion(false)
            } else {
                completion(true)
            }
        }
    }

    func createMoodSubscription(for ownerId: String) {

        let predicate = NSPredicate(format: "ownerId == %@", ownerId)

        let subscription = CKQuerySubscription(
            recordType: "MoodEntry",
            predicate: predicate,
            subscriptionID: "mood_updates_\(ownerId)",
            options: [.firesOnRecordCreation, .firesOnRecordUpdate]
        )

        let info = CKSubscription.NotificationInfo()
        info.title = "パートナーの気分が更新されました 💞"
        info.alertBody  = "今日のムードをチェックしてみてください！"
        info.soundName  = "default"
        info.shouldBadge = true
        info.shouldSendContentAvailable = true

        subscription.notificationInfo = info

        database.save(subscription) { _, error in
            print(error == nil ? "✅ Mood subscription created" : "❌ Subscription error: \(error!)")
        }
    }


}
