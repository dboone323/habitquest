import SwiftUI

//
//  WelcomeView.swift
//  CodingReviewer
//
//  Welcome screen displayed when no file is selected
//

public struct WelcomeView: View {
    @Binding var showFilePicker: Bool

    public var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Main welcome content
            VStack(spacing: 24) {
                // Icon
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: 120, height: 120)

                    Image(systemName: "magnifyingglass.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                        .foregroundColor(.blue)
                }

                // Title and description
                VStack(spacing: 12) {
                    Text("Welcome to CodingReviewer")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)

                    Text("AI-powered code analysis and improvement tool")
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)

                    Text("Analyze your code for issues, generate documentation, and create comprehensive test suites with the power of artificial intelligence.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
            }

            // Feature highlights
            VStack(spacing: 16) {
                FeatureRow(
                    icon: "shield.checkerboard",
                    title: "Security Analysis",
                    description: "Identify potential security vulnerabilities and best practices"
                )

                FeatureRow(
                    icon: "speedometer",
                    title: "Performance Review",
                    description: "Optimize code performance and identify bottlenecks"
                )

                FeatureRow(
                    icon: "doc.text.magnifyingglass",
                    title: "Documentation Generation",
                    description: "Automatically generate comprehensive documentation"
                )

                FeatureRow(
                    icon: "testtube.2",
                    title: "Test Generation",
                    description: "Create thorough test suites for your code"
                )
            }
            .padding(.horizontal, 32)

            // Get started button
            VStack(spacing: 16) {
                Button(action: { showFilePicker = true }) {
                    HStack(spacing: 12) {
                        Image(systemName: "doc.badge.plus")
                        Text("Select a File to Get Started")
                            .fontWeight(.semibold)
                    }
                    .frame(minWidth: 250)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 24)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .buttonStyle(.plain)

                Text("Supports Swift, Objective-C, C, and C++ files")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
                .foregroundColor(.blue)
                .frame(width: 40, height: 40)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }

            Spacer()
        }
    }
}

// MARK: - Preview

public struct WelcomeView_Previews: PreviewProvider {
    public static var previews: some View {
        WelcomeView(showFilePicker: .constant(false))
            .frame(width: 800, height: 600)
    }
}
