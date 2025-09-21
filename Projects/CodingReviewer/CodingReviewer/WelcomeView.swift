//
//  WelcomeView.swift
//  CodingReviewer
//
//  Welcome screen shown when no file is selected
//

import SwiftUI

struct WelcomeView: View {
    @Binding var showFilePicker: Bool

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 64))
                .foregroundColor(.secondary)

            Text("Welcome to CodingReviewer")
                .font(.title)
                .fontWeight(.bold)

            Text("Analyze and review your code with AI-powered insights")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button(action: { showFilePicker = true }) {
                Label("Open Code File", systemImage: "doc.badge.plus")
                    .font(.headline)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .buttonStyle(.borderless)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
