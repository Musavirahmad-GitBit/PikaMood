//
//  UserProfileSection.swift
//  PikaMood
//
//  Created by Musawwir Ahmad  on 2025-11-17.
//

import SwiftUI

struct UserProfileSection: View {
    @EnvironmentObject var userVM: UserViewModel
    @State private var editingName = false
    @State private var tempName = ""

    var body: some View {
        Section(header: Text("プロフィール 🧸")) {

            if let user = userVM.user {

                HStack {
                    Text("名前")
                    Spacer()

                    if editingName {
                        TextField("", text: $tempName)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 150)

                        Button("保存") {
                            guard !tempName.isEmpty else { return }
                            userVM.updateDisplayName(tempName)
                            editingName = false
                        }
                        .foregroundColor(.blue)

                    } else {
                        Text(user.displayName)
                            .foregroundColor(.gray)

                        Button("編集") {
                            tempName = user.displayName
                            editingName = true
                        }
                        .padding(.leading, 8)
                    }
                }

                HStack {
                    Text("あなたのコード")
                    Spacer()
                    Text(user.shareCode)
                        .font(.system(.body, design: .monospaced))
                        .padding(6)
                        .background(Color.pink.opacity(0.2))
                        .cornerRadius(8)
                }

            } else {
                Text("ユーザー情報を読み込み中…")
            }
        }
    }
}
