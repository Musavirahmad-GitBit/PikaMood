//
//  PikaMoodApp.swift
//  PikaMood
//
//  Created by Musawwir Ahmad  on 2025-11-16.
//

import SwiftUI

@main
struct PikaMoodApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @StateObject private var authManager = LocalAuthManager.shared
    @StateObject private var moodStore = MoodStore()
    @StateObject private var userVM = UserViewModel()

    var body: some Scene {
        WindowGroup {
            ZStack {
                if !userVM.isICloudAvailable {
                    // 👉 Show iCloud setup full screen
                    ICloudSetupView()
                } else if authManager.isLockEnabled == false || authManager.isUnlocked {
                    // 👉 Normal app
                    RootView()
                        .environmentObject(moodStore)
                        .environmentObject(userVM)
                        .onAppear {
                            loadCurrentUser()
                        }
                }

                if authManager.isLockEnabled && !authManager.isUnlocked {
                    LockScreenView()
                }
            }
            .onAppear {
                // iCloud check FIRST
                userVM.checkICloudStatus()
                // FaceID / lock
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    authManager.authenticate()
                }
                // Notifications
                    NotificationManager.shared.requestPermission()
            }
            .onReceive(NotificationCenter.default.publisher(for: .didReceiveCloudKitNotification)) { _ in
                print("🔔 Push received → refreshing partner mood")
                userVM.refreshPartnerMood()
            }

        }
    }

    private func loadCurrentUser() {
        CloudKitService.shared.getOrCreateUser { user in
            userVM.setUser(user)

            // 🔔 CREATE CLOUDKIT SUBSCRIPTION
            if let appleID = user?.appleID {
                CloudKitSubscriptionManager.shared.createMoodSubscription(for: appleID)
            }
        }
    }


}
extension Notification.Name {
    static let didReceiveCloudKitNotification = Notification.Name("didReceiveCloudKitNotification")
}
