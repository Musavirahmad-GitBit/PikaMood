//
//  PartnerSection.swift
//  PikaMood
//
//  Created by Musawwir Ahmad  on 2025-11-17.
//

import SwiftUI

struct PartnerSection: View {
    @EnvironmentObject var userVM: UserViewModel
    @State private var partnerCode = ""

    var body: some View {
        Section(header: Text("パートナー設定 💞")) {

            if let partner = userVM.partner {
                // Already linked
                VStack(alignment: .leading, spacing: 8) {
                    Text("リンク済みのパートナー")
                    Text(partner.displayName)
                        .font(.headline)
                        .foregroundColor(.pink)
                }

            } else {

                TextField("パートナーコードを入力", text: $partnerCode)
                    .textFieldStyle(.roundedBorder)

                Button("リンクする 💗") {
                    let code = partnerCode.uppercased().trimmingCharacters(in: .whitespaces)
                    userVM.findAndLinkPartner(code: code)
                }
                .buttonStyle(.borderedProminent)
                .tint(.pink)

                if let error = userVM.partnerLookupError {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
        }
    }
}
