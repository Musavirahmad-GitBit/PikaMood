import SwiftUI

struct SettingsView: View {

    @EnvironmentObject var userVM: UserViewModel
    @State private var reminderTime: Date = defaultReminderTime()
    @ObservedObject var authManager = LocalAuthManager.shared

    @State private var partnerCodeInput: String = ""

    var body: some View {
        NavigationStack {
            Form {

                // MARK: - Account Section
                Section(header: Text("アカウント 🧸")) {
                    HStack {
                        Text("名前")
                        Spacer()
                        Text(userVM.user?.displayName ?? "読み込み中…")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("あなたのコード")
                        Spacer()
                        Text(userVM.user?.shareCode ?? "------")
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(.pink)
                    }
                }

                // MARK: - Partner Section
                Section(header: Text("パートナー 💞")) {
                    if let partner = userVM.partner {
                        HStack {
                            Text("現在のパートナー")
                            Spacer()
                            Text(partner.displayName)
                                .foregroundColor(.purple)
                        }

                        Text("コード: \(partner.shareCode)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        // 🔥 ADD THIS BLOCK
                        Button {
                            userVM.refreshPartner()
                        } label: {
                            HStack {
                                if userVM.isRefreshingPartner { ProgressView() }
                                Text("パートナー情報を更新")
                            }
                        }
                        .padding(.vertical, 4)
                        // 🔥 END ADD

                    } else {
                        Text("まだパートナーがリンクされていません。")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    TextField("パートナーのコードを入力", text: $partnerCodeInput)
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()

                    Button {
                        let cleaned = partnerCodeInput
                            .trimmingCharacters(in: .whitespacesAndNewlines)
                            .uppercased()

                        guard !cleaned.isEmpty else { return }

                        print("🔍 Looking for partner with code:", cleaned)   // 👈 Add this line

                        userVM.findAndLinkPartner(code: cleaned)

                    } label: {
                        if userVM.isLinking {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("パートナーとリンクする")
                                .frame(maxWidth: .infinity)
                        }
                    }

                    if let error = userVM.partnerLookupError {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }

                // MARK: - App Lock
                Section(header: Text("アプリロック 🔐")) {
                    Toggle("Face ID / パスコードを有効にする",
                           isOn: $authManager.isLockEnabled)
                        .onChange(of: authManager.isLockEnabled) { _ in
                            authManager.setLockEnabled(authManager.isLockEnabled)
                        }
                }

                // MARK: - Daily Reminder
                Section(header: Text("毎日のリマインダー 💖")) {
                    DatePicker(
                        "時間を選択",
                        selection: $reminderTime,
                        displayedComponents: .hourAndMinute
                    )
                    .onChange(of: reminderTime) { _ in
                        scheduleReminder()
                    }
                }
            }
            .navigationTitle("設定")
        }
//        .onAppear {
//            userVM.refreshPartner()
//        }
    }

    // MARK: - Reminder Helpers

    private func scheduleReminder() {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: reminderTime)
        let minute = calendar.component(.minute, from: reminderTime)

        NotificationManager.shared.scheduleDailyReminder(hour: hour, minute: minute)
    }

    static func defaultReminderTime() -> Date {
        var components = DateComponents()
        components.hour = 20 // 8pm default
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }
}
