//
//  Untitled.swift
//  PikaMood
//
//  Created by Musawwir Ahmad  on 2025-11-17.
//

import Foundation
import CloudKit

struct PMUser: Identifiable {
    let id: CKRecord.ID
    var appleID: String
    var displayName: String
    var partnerID: String?
    var profilePhoto: CKAsset?
    var shareCode: String       // <-- NEW
    var partnerMoodSeenDate: Date?

    static let recordType = "UserProfile"
}
