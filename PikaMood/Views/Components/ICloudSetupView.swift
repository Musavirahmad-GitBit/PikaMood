import SwiftUI

struct ICloudSetupView: View {
    var body: some View {
        VStack(spacing: 20) {

            Image(systemName: "icloud.slash")
                .font(.system(size: 60))
                .foregroundColor(.blue)

            Text("iCloudにサインインしてください")
                .font(.title2.bold())
                .multilineTextAlignment(.center)

            Text("""
このアプリはCloudKitを使用します。

ご利用いただくには、iPhoneでiCloudにサインインする必要があります。
""")
                .font(.body)
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
            .padding(.top)
        }
        .padding()
    }
}
