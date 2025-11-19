//
//  UserViewModel.swift
//  PikaMood
//

import Foundation
import CloudKit

final class UserViewModel: ObservableObject {

    // MARK: - Published state

    @Published var user: PMUser?
    @Published var partner: PMUser?
    @Published var partnerLookupError: String?
    @Published var isLinking: Bool = false
    @Published var isRefreshingPartner: Bool = false
    @Published var partnerLatestMood: MoodEntry?
    @Published var partnerNewMood: MoodEntry?
    @Published var showPartnerMoodPopup: Bool = false
    @Published var isICloudAvailable: Bool = true


    // FIX: Use recordName, not local UUID
    private var lastSeenMoodRecordName: String?

    private let service = CloudKitService.shared


    // MARK: - Load user on app start

    func loadUser() {
        service.getOrCreateUser { user in
            DispatchQueue.main.async {
                self.user = user

                if let user = user {
                    // Subscription for push updates
                    self.service.createMoodSubscription(for: user.appleID)
                }

                // If already partnered, load data
                if let pid = user?.partnerID, !pid.isEmpty {
                    self.refreshPartner()
                }
            }
        }
    }


    func setUser(_ user: PMUser?) {
        DispatchQueue.main.async {
            self.user = user

            if let user = user {
                self.service.createMoodSubscription(for: user.appleID)
            }

            self.refreshPartner()

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.refreshPartnerMood()
            }
        }
    }


    // MARK: - Update display name

    func updateDisplayName(_ newName: String) {
        guard let user else { return }

        service.updateUserField(recordID: user.id, key: "displayName", value: newName) { ok in
            if ok {
                DispatchQueue.main.async {
                    self.user?.displayName = newName
                }
            }
        }
    }


    // MARK: - Link Partner

    func findAndLinkPartner(code: String) {
        isLinking = true
        partnerLookupError = nil

        service.findUserByShareCode(code) { match in
            DispatchQueue.main.async {

                guard let other = match else {
                    self.partnerLookupError = "コードが見つかりませんでした。"
                    self.isLinking = false
                    return
                }

                guard let me = self.user else {
                    self.partnerLookupError = "ユーザー情報が読み込めません。"
                    self.isLinking = false
                    return
                }

                if me.id == other.id {
                    self.partnerLookupError = "自分自身とはリンクできません。"
                    self.isLinking = false
                    return
                }

                self.service.linkPartners(userA: me, userB: other) { ok in
                    DispatchQueue.main.async {
                        self.isLinking = false
                        if ok {
                            self.user?.partnerID = other.id.recordName
                            self.partner = other
                            self.refreshPartnerMood()
                        } else {
                            self.partnerLookupError = "パートナーのリンクに失敗しました。"
                        }
                    }
                }
            }
        }
    }


    // MARK: - Load partner

    func refreshPartner() {
        guard let pid = user?.partnerID, !pid.isEmpty else {
            partner = nil
            partnerLatestMood = nil
            return
        }

        isRefreshingPartner = true

        service.fetchUser(byRecordName: pid) { partner in
            DispatchQueue.main.async {
                self.partner = partner
                self.isRefreshingPartner = false

                if partner != nil {
                    self.refreshPartnerMood()
                }
            }
        }
    }


    // MARK: - Refresh latest partner mood

    func refreshPartnerMood() {
        guard let partner else { return }

        service.fetchLatestMood(forOwnerId: partner.appleID) { [weak self] entry in
            DispatchQueue.main.async {
                guard let self else { return }

                self.partnerLatestMood = entry
                guard let mood = entry else { return }

                // CloudKit record name (yyyyMMdd)
                let recordName = self.makeMoodRecordName(ownerId: partner.appleID, date: mood.date)

                // Only show if new + not seen before
                if recordName != self.lastSeenMoodRecordName,
                   self.shouldShowMoodPopup(for: mood) {

                    self.partnerNewMood = mood
                    self.showPartnerMoodPopup = true
                    self.lastSeenMoodRecordName = recordName
                    self.markPopupSeen()
                }
            }
        }
    }


    // MARK: - Mood record name (same as CloudKit)

    func makeMoodRecordName(ownerId: String, date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyyMMdd"
        return "\(ownerId)_\(f.string(from: date))"
    }


    // MARK: - Popup logic

    func shouldShowMoodPopup(for mood: MoodEntry) -> Bool {
        guard let seen = user?.partnerMoodSeenDate else { return true }
        return mood.date > seen
    }


    func markPopupSeen() {
        let now = Date()
        user?.partnerMoodSeenDate = now

        if let rid = user?.id {
            service.updateUserField(
                recordID: rid,
                key: "partnerMoodSeenDate",
                value: now
            ) { _ in }
        }
    }


    // MARK: - Unlink Partner (kept from your old version)

    func unlinkPartner() {
        guard let user else { return }

        partner = nil
        partnerLatestMood = nil
        self.user?.partnerID = ""

        service.updateUserField(
            recordID: user.id,
            key: "partnerId",
            value: "" as CKRecordValue
        ) { _ in }
    }


    // MARK: - Hugs + Messages

    func sendHugToPartner() {
        guard let user, let partner else { return }

        service.sendHug(from: user.appleID, to: partner.appleID) { _ in }
    }

    func sendSupportMessage(_ text: String) {
        guard let user, let partner else { return }

        service.sendSupportMessage(from: user.appleID, to: partner.appleID, text: text) { _ in }
    }


    // MARK: - Called by push notifications

    func handleIncomingPartnerMood(_ mood: MoodEntry) {
        if shouldShowMoodPopup(for: mood) {
            partnerNewMood = mood
            showPartnerMoodPopup = true
            markPopupSeen()
        }
    }
    
    func checkICloudStatus() {
        CloudKitService.shared.container.accountStatus { status, error in
            DispatchQueue.main.async {
                switch status {
                case .available:
                    print("☁️ iCloud Available")
                    self.isICloudAvailable = true
                default:
                    print("❌ iCloud NOT available")
                    self.isICloudAvailable = false
                }
            }
        }
    }


}
