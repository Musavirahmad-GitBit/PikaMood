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
        Section(header: Text(NSLocalizedString("partner_header", comment: ""))) {

            if let partner = userVM.partner {
                // Already linked
                VStack(alignment: .leading, spacing: 8) {
                    Text(NSLocalizedString("partner_linked_title", comment: ""))
                    Text(partner.displayName)
                        .font(.headline)
                        .foregroundColor(.pink)
                }

            } else {

                TextField(NSLocalizedString("partner_input_placeholder", comment: ""), text: $partnerCode)
                    .textFieldStyle(.roundedBorder)

                Button(NSLocalizedString("partner_link_button", comment: "")) {
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
