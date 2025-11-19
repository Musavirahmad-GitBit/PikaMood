import SwiftUI

struct LockScreenView: View {
    @ObservedObject var authManager = LocalAuthManager.shared

    var body: some View {
        ZStack {
            LinearGradient(colors: [
                Color(red: 1.0, green: 0.95, blue: 0.98),
                Color(red: 0.95, green: 0.98, blue: 1.0)
            ], startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("🔒 PikaMood")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.purple)

                Text("Face IDでロック解除 💖")
                    .font(.headline)
                    .foregroundColor(.pink)

                Text("ฅ^•ﻌ•^ฅ")
                    .font(.system(size: 60))
                    .padding(.top, 16)

                Button(action: {
                    authManager.authenticate()
                }) {
                    Text("認証する")
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
