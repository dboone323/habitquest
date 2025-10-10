//
//  WelcomeView.swift
//  CodingReviewer
//
//  Welcome screen shown when no file is selected
//

import SwiftUI

public struct WelcomeView: View {
    @Binding var showFilePicker: Bool
    private let presenter: WelcomeViewPresenter

    init(showFilePicker: Binding<Bool>, presenter: WelcomeViewPresenter = WelcomeViewPresenter()) {
        _showFilePicker = showFilePicker
        self.presenter = presenter
    }

    public var body: some View {
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

            Button(action: self.presenter.openFileAction(binding: self.$showFilePicker)) {
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

struct WelcomeViewPresenter {
    func openFileAction(binding: Binding<Bool>) -> () -> Void {
        {
            binding.wrappedValue = true
        }
    }
}
