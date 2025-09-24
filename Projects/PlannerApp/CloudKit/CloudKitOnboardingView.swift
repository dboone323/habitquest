// PlannerApp/CloudKit/CloudKitOnboardingView.swift
import CloudKit
import Foundation
import SwiftUI

public struct CloudKitOnboardingView: View {
    @StateObject private var cloudKit = EnhancedCloudKitManager.shared // Changed to EnhancedCloudKitManager
    @Environment(\.dismiss) private var dismiss
    @State private var isRequestingPermission = false
    @State private var showingMergeOptions = false

    @AppStorage("hasCompletedCloudKitOnboarding") private var hasCompletedOnboarding = false

    public var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Header image
                Image(systemName: "icloud")
                    .font(.system(size: 80))
                    .foregroundStyle(
                        .linearGradient(
                            colors: [.blue.opacity(0.7), .blue], startPoint: .top, endPoint: .bottom
                        )
                    )
                    .padding(.top, 30)

                Text("Sync With iCloud")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                // Benefits explanation
                VStack(alignment: .leading, spacing: 16) {
                    self.benefitRow(
                        icon: "iphone.and.arrow.forward", title: "Sync Across Devices",
                        description:
                        "Access your tasks, goals, and events on all your Apple devices."
                    )

                    self.benefitRow(
                        icon: "lock.shield", title: "Private & Secure",
                        description: "Your data is encrypted and protected by your Apple ID."
                    )

                    self.benefitRow(
                        icon: "arrow.clockwise.icloud", title: "Automatic Backup",
                        description: "Never lose your important information with automatic backups."
                    )

                    self.benefitRow(
                        icon: "person.crop.circle", title: "Just for You",
                        description: "Your data is only visible to you, never shared with others."
                    )
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.secondary.opacity(0.1))
                )
                .padding(.horizontal)

                Spacer()

                // Action buttons
                VStack(spacing: 12) {
                    Button {
                        self.requestiCloudAccess()
                    } label: {
                        Text("Enable iCloud Sync")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(self.isRequestingPermission)
                    .overlay {
                        if self.isRequestingPermission {
                            ProgressView()
                                .tint(.white)
                        }
                    }

                    Button {
                        self.skipOnboarding()
                    } label: {
                        Text("Maybe Later")
                            .padding()
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 30)
            }
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .alert("This is a New Device", isPresented: self.$showingMergeOptions) {
                Button("Merge from iCloud", action: {
                    self.mergeFromiCloud()
                })
                .accessibilityLabel("Button")

                Button("Start Fresh", action: {
                    self.startFresh()
                })
                .accessibilityLabel("Button")
            } message: {
                Text("Do you want to merge existing iCloud data with this device, or start fresh?")
            }
        }
    }

    private func benefitRow(icon: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)

                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func requestiCloudAccess() {
        self.isRequestingPermission = true

        _Concurrency.Task {
            await self.cloudKit.requestiCloudAccess()
            await self.cloudKit.checkAccountStatus()

            DispatchQueue.main.async {
                self.isRequestingPermission = false

                if self.cloudKit.isSignedInToiCloud {
                    self.showingMergeOptions = true
                }
            }
        }
    }

    private func mergeFromiCloud() {
        _Concurrency.Task {
            await self.cloudKit.handleNewDeviceLogin()
            self.completeOnboarding()
        }
    }

    private func startFresh() {
        UserDefaults.standard.set(true, forKey: "HasCompletedInitialSync")
        self.completeOnboarding()
    }

    private func skipOnboarding() {
        self.completeOnboarding()
    }

    private func completeOnboarding() {
        self.hasCompletedOnboarding = true
        self.dismiss()
    }
}

#Preview {
    CloudKitOnboardingView()
}
