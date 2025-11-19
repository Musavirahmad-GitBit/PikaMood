import Foundation
import CloudKit


struct SupportMessage: Identifiable {
    let id: CKRecord.ID
    let senderId: String
    let receiverId: String
    let text: String
    let timestamp: Date
}
