//
//  AboutSection.swift
//  MomentumFinance
//
//  Created by Daniel Stevens on 6/5/25.
//  Copyright © 2025 Daniel Stevens. All rights reserved.
//

import SwiftUI

/// About section with app information and external links
struct AboutSection: View {
    var body: some View {
        Section {
            HStack {
                Label("Version", systemImage: "info.circle")
                Spacer()
                Text("1.0.0")
                    .foregroundColor(.secondary)
            }

            Link(destination: URL(string: "https://momentum-finance.com/privacy")!) {
                Label("Privacy Policy", systemImage: "hand.raised")
            }

            Link(destination: URL(string: "https://momentum-finance.com/terms")!) {
                Label("Terms of Service", systemImage: "doc.text")
            }

            Link(destination: URL(string: "https://momentum-finance.com/support")!) {
                Label("Support", systemImage: "questionmark.circle")
            }
        } header: {
            Text("About")
        }
    }
}
