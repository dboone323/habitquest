//
//  AboutView.swift
//  CodingReviewer
//
//  About window for CodingReviewer application
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 64))
                .foregroundColor(.blue)

            Text("CodingReviewer")
                .font(.title)
                .fontWeight(.bold)

            Text("Version 1.0.0")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Text("An AI-powered code review assistant")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()

            Text("© 2025 Quantum Workspace")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(40)
        .frame(width: 300, height: 250)
    }
}

#Preview {
    AboutView()
}
