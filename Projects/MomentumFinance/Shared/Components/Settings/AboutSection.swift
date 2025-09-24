import SwiftUI

public struct AboutSection: View {
    var body: some View {
        Section(header: Text("About")) {
            HStack {
                Text("Version")
                Spacer()
                Text("1.0.0")
                    .foregroundColor(.secondary)
            }

            HStack {
                Text("Build")
                Spacer()
                Text("2024.1")
                    .foregroundColor(.secondary)
            }

            Button(action: {
                // Handle privacy policy
            }) {
                HStack {
                    Text("Privacy Policy")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
            }

            Button(action: {
                // Handle terms of service
            }) {
                HStack {
                    Text("Terms of Service")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}
