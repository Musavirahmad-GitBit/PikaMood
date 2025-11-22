import SwiftUI

struct SettingsView: View {

    @EnvironmentObject var userVM: UserViewModel
    @State private var reminderTime: Date = defaultReminderTime()
    @ObservedObject var authManager = LocalAuthManager.shared
    @State private var showRestartAlert = false
    @State private var pendingLanguage: String? = nil
    @AppStorage("appLanguage") private var appLanguage: String = "ja"


    @State private var partnerCodeInput: String = ""

    var body: some View {
        NavigationStack {
            Form {

                // MARK: - Account Section
                Section(header: Text(NSLocalizedString("settings_account_section", comment: ""))) {
                    HStack {
                        Text(NSLocalizedString("settings_name", comment: ""))
                        Spacer()
                        Text(userVM.user?.displayName ?? "読み込み中…")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text(NSLocalizedString("settings_your_code", comment: ""))
                        Spacer()
                        Text(userVM.user?.shareCode ?? "------")
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(.pink)
                    }
                }
                
                Section(header: Text(NSLocalizedString("settings_language", comment: ""))) {

                    HStack(spacing: 16) {

                        LanguageButton(
                            code: "ja",
                            flag: "🇯🇵",
                            label: NSLocalizedString("language_japanese", comment: ""),
                            selected: appLanguage == "ja"
                        ) {
                            if appLanguage != "ja" {
                                pendingLanguage = "ja"
                                showRestartAlert = true
                            }
                        }

                        LanguageButton(
                            code: "en",
                            flag: "🌐",
                            label: NSLocalizedString("language_english", comment: ""),
                            selected: appLanguage == "en"
                        ) {
                            if appLanguage != "en" {
                                pendingLanguage = "en"
                                showRestartAlert = true
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 8)
                }




                // MARK: - Partner Section
                Section(header: Text(NSLocalizedString("settings_partner_section", comment: ""))) {
                    if let partner = userVM.partner {
                        HStack {
                            Text(NSLocalizedString("settings_partner_current", comment: ""))
                            Spacer()
                            Text(partner.displayName)
                                .foregroundColor(.purple)
                        }

                        Text("\(NSLocalizedString("settings_partner_code_label", comment: "")) \(partner.shareCode)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        // 🔥 ADD THIS BLOCK
                        Button {
                            userVM.refreshPartner()
                        } label: {
                            HStack {
                                if userVM.isRefreshingPartner { ProgressView() }
                                Text(NSLocalizedString("settings_partner_refresh_button", comment: ""))
                            }
                        }
                        .padding(.vertical, 4)
                        // 🔥 END ADD

                    } else {
                        Text(NSLocalizedString("settings_partner_none", comment: ""))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    TextField(
                        NSLocalizedString("settings_partner_input_placeholder", comment: ""), text: $partnerCodeInput)
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
                            Text(NSLocalizedString("settings_partner_link_button", comment: ""))
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
                Section(header: Text(NSLocalizedString("settings_lock_section", comment: ""))) {
                    Toggle(NSLocalizedString("settings_lock_toggle", comment: ""),
                           isOn: $authManager.isLockEnabled)
                        .onChange(of: authManager.isLockEnabled) { _ in
                            authManager.setLockEnabled(authManager.isLockEnabled)
                        }
                }

                // MARK: - Daily Reminder
                Section(header: Text(NSLocalizedString("settings_reminder_section", comment: ""))) {
                    DatePicker(
                        NSLocalizedString("settings_reminder_time", comment: ""),
                        selection: $reminderTime,
                        displayedComponents: .hourAndMinute
                    )
                    .onChange(of: reminderTime) { _ in
                        scheduleReminder()
                    }
                }
            }
            .navigationTitle(NSLocalizedString("settings_title", comment: ""))
            .alert(
                // Title based on pending language
                pendingLanguage == "en"
                    ? NSLocalizedString("restart_title", tableName: nil, bundle: .main, value: "", comment: "")
                    : NSLocalizedString("restart_title", tableName: nil, bundle: .main, value: "", comment: ""),
                isPresented: $showRestartAlert,
                actions: {

                    // Restart Button
                    Button(
                        pendingLanguage == "en"
                        ? NSLocalizedString("restart_button", comment: "")
                        : NSLocalizedString("restart_button", comment: "")
                    ) {
                        if let lang = pendingLanguage {
                            appLanguage = lang
                            LanguageManager.setLanguage(lang)

                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                exit(0)
                            }
                        }
                    }

                    // Cancel Button
                    Button(
                        pendingLanguage == "en"
                        ? NSLocalizedString("restart_cancel", comment: "")
                        : NSLocalizedString("restart_cancel", comment: ""),
                        role: .cancel
                    ) {
                        pendingLanguage = nil
                    }
                },

                // Message
                message: {
                    Text(
                        pendingLanguage == "en"
                        ? NSLocalizedString("restart_message", comment: "")
                        : NSLocalizedString("restart_message", comment: "")
                    )
                }
            )



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
    
    struct LanguageButton: View {
        let code: String
        let flag: String
        let label: String
        let selected: Bool
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                HStack(spacing: 6) {
                    Text(flag)
                        .font(.title3)

                    Text(label)
                        .font(.footnote)
                        .foregroundStyle(.primary)
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 14)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(selected ? Color.blue.opacity(0.2) : Color(.systemGray6))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(selected ? Color.blue : Color.clear, lineWidth: 2)
                )
            }
            .buttonStyle(.plain)
        }
    }

}
