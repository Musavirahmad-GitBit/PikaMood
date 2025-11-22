import SwiftUI

struct LockScreenView: View {
    @ObservedObject var authManager = LocalAuthManager.shared

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 1.0, green: 0.95, blue: 0.98),
                    Color(red: 0.95, green: 0.98, blue: 1.0)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {

                // 🔐 App Title
                Text(NSLocalizedString("lock_title", comment: "Lock screen title"))
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.purple)

                // 🔐 Face ID Prompt
                Text(NSLocalizedString("lock_faceid_prompt", comment: "Prompt to unlock with Face ID"))
                    .font(.headline)
                    .foregroundColor(.pink)

                // Cat (not localized)
                Text("ฅ^•ﻌ•^ฅ")
                    .font(.system(size: 60))
                    .padding(.top, 16)

                // 🔐 Authentication Button
                Button(action: {
                    authManager.authenticate()
                }) {
                    Text(NSLocalizedString("lock_auth_button", comment: "Authenticate button text"))
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 14)
                        .background(
                            Capsule().fill(Color.pink.gradient)
                        )
                }
                .padding(.top, 20)
            }
        }
    }
}
