import SwiftUI

struct ICloudSetupView: View {

    @AppStorage("appLanguage") private var appLanguage: String = "ja"

    var body: some View {
        VStack(spacing: 20) {

            // 🌐 Very Simple Toggle
            HStack {
                Spacer()
                Button(appLanguage == "en" ? "🇯🇵 日本語" : "🌐 English") {
                    appLanguage = (appLanguage == "ja") ? "en" : "ja"
                }
                .padding(8)
            }

            Image(systemName: "icloud.slash")
                .font(.system(size: 60))
                .foregroundColor(.blue)

            // 📌 LANGUAGE BLOCK
            if appLanguage == "ja" {

                Text("iCloudにサインインしてください")
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)

                Text("""
このアプリはCloudKitを使用します。

ご利用いただくには、iPhoneでiCloudにサインインする必要があります。
""")
                .multilineTextAlignment(.center)
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 12) {
                    Text("📱 設定方法:")
                        .font(.headline)

                    Text("1. 設定アプリを開く")
                    Text("2. 一番上の名前をタップする")
                    Text("3. Apple ID でサインインする")
                    Text("4. iCloud をタップする")
                    Text("5. iCloud Drive をオンにする")
                    Text("6. PikaMood のiCloudをオンにする")
                }

                Button("設定アプリを開く") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                .buttonStyle(.borderedProminent)

            } else {

                // 🌐 ENGLISH VERSION

                Text("Please Sign in to iCloud")
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)

                Text("""
This app uses CloudKit.

To continue, you must be signed in to iCloud on this iPhone.
""")
                .multilineTextAlignment(.center)
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 12) {
                    Text("📱 How to enable:")
                        .font(.headline)

                    Text("1. Open the Settings app")
                    Text("2. Tap your name at the top")
                    Text("3. Sign in with your Apple ID")
                    Text("4. Tap iCloud")
                    Text("5. Turn on iCloud Drive")
                    Text("6. Enable iCloud for PikaMood")
                }

                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
    }
}
