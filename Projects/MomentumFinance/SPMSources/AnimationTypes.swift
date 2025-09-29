import SwiftUI

public enum AnimatedCardComponent {
    public struct AnimatedCard: View {
        public init() {}

        public var body: some View {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.blue.opacity(0.2))
                .shadow(radius: 4)
        }
    }
}

public enum AnimatedButtonComponent {
    public struct AnimatedButton: View {
        public let label: String
        public let action: () -> Void

        public init(label: String, action: @escaping () -> Void) {
            self.label = label
            self.action = action
        }

        public var body: some View {
            Button(self.label, action: self.action)
                .buttonStyle(PrimaryButtonStyle(theme: ColorTheme()))
        }
    }
}

public enum AnimatedProgressComponents {
    public struct AnimatedBudgetProgress: View {
        public let progress: Double

        public init(progress: Double) {
            self.progress = progress
        }

        public var body: some View {
            AnimatedProgressBar(progress: self.progress)
        }
    }

    public struct AnimatedCounter: View {
        public let value: Double

        public init(value: Double) {
            self.value = value
        }

        public var body: some View {
            Text(String(format: "%.0f", self.value))
                .animation(.easeIn, value: self.value)
        }
    }
}

public enum FloatingActionButtonComponent {
    public struct FloatingActionButton: View {
        public let icon: String
        public let action: () -> Void

        public init(icon: String, action: @escaping () -> Void) {
            self.icon = icon
            self.action = action
        }

        public var body: some View {
            Button(action: self.action) {
                Image(systemName: self.icon)
                    .padding()
                    .background(Circle().fill(Color.accentColor))
                    .foregroundColor(.white)
                    .shadow(radius: 3)
            }
        }
    }
}
