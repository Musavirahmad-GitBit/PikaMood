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
        Section(header: Text(NSLocalizedString("profile_header", comment: ""))) {

            if let user = userVM.user {

                HStack {
                    Text(NSLocalizedString("profile_name", comment: ""))
                    Spacer()

                    if editingName {
                        TextField("", text: $tempName)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 150)

                        Button(NSLocalizedString("profile_save", comment: "")) {
                            guard !tempName.isEmpty else { return }
                            userVM.updateDisplayName(tempName)
                            editingName = false
                        }
                        .foregroundColor(.blue)

                    } else {
                        Text(user.displayName)
                            .foregroundColor(.gray)

                        Button(NSLocalizedString("profile_edit", comment: "")) {
                            tempName = user.displayName
                            editingName = true
                        }
                        .padding(.leading, 8)
                    }
                }

                HStack {
                    Text(NSLocalizedString("profile_your_code", comment: ""))
                    Spacer()
                    Text(user.shareCode)
                        .font(.system(.body, design: .monospaced))
                        .padding(6)
                        .background(Color.pink.opacity(0.2))
                        .cornerRadius(8)
                }

            } else {
                Text(NSLocalizedString("profile_loading", comment: ""))
            }
        }
    }
}
