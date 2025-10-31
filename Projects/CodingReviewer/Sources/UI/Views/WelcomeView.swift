import SharedKit
import SwiftUI

@MainActor
struct WelcomeView: View {

    @Binding var showFilePicker: Bool

    var body: some View {
        ZStack {
            // Background
            Color.clear
                .ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                // Header Section
                VStack(spacing: 20) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)

                    VStack(spacing: 8) {
                        Text("Welcome to Code Reviewer")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)

                        Text("Analyze your code for quality, performance, and best practices")
                            .font(.title3)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }

                // Features Grid
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 20),
                    GridItem(.flexible(), spacing: 20),
                ], spacing: 20) {
                    FeatureCard(
                        icon: "exclamationmark.triangle",
                        title: "Issue Detection",
                        description: "Identify bugs, warnings, and code smells"
                    )

                    FeatureCard(
                        icon: "chart.bar",
                        title: "Quality Metrics",
                        description: "Track complexity, coverage, and maintainability"
                    )

                    FeatureCard(
                        icon: "checkmark.circle",
                        title: "Best Practices",
                        description: "Ensure compliance with coding standards"
                    )

                    FeatureCard(
                        icon: "speedometer",
                        title: "Performance Analysis",
                        description: "Optimize for speed and efficiency"
                    )
                }
                .padding(.horizontal)

                // Action Section
                VStack(spacing: 16) {
                    PrimaryActionButton(
                        title: "Select File to Analyze",
                        icon: "folder",
                        action: { showFilePicker = true }
                    )

                    SecondaryActionButton(
                        title: "View Recent Projects",
                        icon: "clock",
                        action: { /* TODO: Show recent projects */ }
                    )
                }

                Spacer()

                // Footer
                VStack(spacing: 8) {
                    Text("Powered by AI and Advanced Analysis")
                        .font(.caption)
                        .foregroundColor(.secondary.opacity(0.7))

                    HStack(spacing: 16) {
                        FooterLink(title: "Documentation", icon: "book")
                        FooterLink(title: "Settings", icon: "gear")
                        FooterLink(title: "About", icon: "info.circle")
                    }
                }
                .padding(.bottom, 20)
            }
            .padding()
        }
    }
}

@MainActor
private struct FeatureCard: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(.blue.opacity(0.1))
                    .frame(width: 60, height: 60)

                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(.blue)
            }

            VStack(spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)

                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
        }
        .padding()
        .frame(height: 140)
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

@MainActor
private struct PrimaryActionButton: View {
    let title: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))

                Text(title)
                    .font(.system(size: 18, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(.blue)
            .cornerRadius(12)
            .shadow(color: .blue.opacity(0.3), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}

@MainActor
private struct SecondaryActionButton: View {
    let title: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16))

                Text(title)
                    .font(.system(size: 16, weight: .medium))
            }
            .foregroundColor(.primary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.secondary.opacity(0.1))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.primary.opacity(0.2), lineWidth: 1)
            )
            .cornerRadius(10)
        }
        .buttonStyle(.plain)
    }
}

@MainActor
private struct FooterLink: View {
    let title: String
    let icon: String

    var body: some View {
        Button(action: { /* TODO: Handle navigation */ }) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)

                Text(title)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .buttonStyle(.plain)
    }
}

@MainActor
struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView(showFilePicker: .constant(false))
    }
}
