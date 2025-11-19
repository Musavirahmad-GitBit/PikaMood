import Foundation
import CloudKit

struct HugEvent: Identifiable {
    let id: CKRecord.ID
    let senderId: String
    let receiverId: String
    let timestamp: Date
}
