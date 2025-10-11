import Foundation
import SwiftUI

// MARK: - Animation Components

public enum AnimatedCardComponent {
    public struct AnimatedCard: View {
        public var body: some View {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.1))
        }

        public init() {}
    }
}

public enum AnimatedButtonComponent {
    public struct AnimatedButton: View {
        let action: () -> Void
        let label: String

        public var body: some View {
            Button(action: self.action) {
                Text(self.label)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .accessibilityLabel("Button")
        }

        public init(label: String, action: @escaping () -> Void) {
            self.label = label
            self.action = action
        }
    }
}

public enum AnimatedTransactionComponent {
    public struct AnimatedTransactionItem: View {
        public var body: some View {
            HStack {
                Circle()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.blue)
                VStack(alignment: .leading) {
                    Text("Transaction")
                        .font(.headline)
                    Text("Details")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Text("$0.00")
                    .font(.headline)
            }
            .padding()
        }

        public init() {}
    }
}

public enum AnimatedProgressComponents {
    public struct AnimatedBudgetProgress: View {
        let progress: Double

        public var body: some View {
            ProgressView(value: self.progress)
                .progressViewStyle(LinearProgressViewStyle())
        }

        public init(progress: Double) {
            self.progress = progress
        }
    }

    public struct AnimatedCounter: View {
        let value: Double

        public var body: some View {
            Text("\(self.value, specifier: "%.2f")")
                .font(.title)
                .fontWeight(.bold)
        }

        public init(value: Double) {
            self.value = value
        }
    }
}

public enum FloatingActionButtonComponent {
    public struct FloatingActionButton: View {
        let action: () -> Void
        let icon: String

        public var body: some View {
            Button(action: self.action) {
                Image(systemName: self.icon)
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 56, height: 56)
                    .background(Color.blue)
                    .clipShape(Circle())
                    .shadow(radius: 4)
            }
            .accessibilityLabel("Button")
        }

        public init(icon: String, action: @escaping () -> Void) {
            self.icon = icon
            self.action = action
        }
    }
}
