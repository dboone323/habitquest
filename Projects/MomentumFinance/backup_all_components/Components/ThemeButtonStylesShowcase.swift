import SwiftUI

struct ThemeButtonStylesShowcase: View {
    let theme: ColorTheme

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Button Styles")
                .font(.headline)
                .foregroundStyle(theme.primaryText)

            Divider()
                .background(theme.secondaryText.opacity(0.3))

            // Primary Button
            Button(action: {}) {
                Text("Primary Button")
                    .font(.body.weight(.medium))
                    .frame(maxWidth: .infinity)
            }
            .padding(.vertical, 12)
            .background(theme.accentPrimary)
            .foregroundStyle(.white)
            .cornerRadius(8)

            // Secondary Button
            Button(action: {}) {
                Text("Secondary Button")
                    .font(.body.weight(.medium))
                    .frame(maxWidth: .infinity)
            }
            .padding(.vertical, 12)
            .background(theme.secondaryBackground)
            .foregroundStyle(theme.accentPrimary)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(theme.accentPrimary, lineWidth: 1)
            )
            .cornerRadius(8)

            // Destructive Button
            Button(action: {}) {
                Text("Destructive Button")
                    .font(.body.weight(.medium))
                    .frame(maxWidth: .infinity)
            }
            .padding(.vertical, 12)
            .background(theme.critical)
            .foregroundStyle(.white)
            .cornerRadius(8)

            // Text Button
            Button(action: {}) {
                Text("Text Button")
                    .font(.body.weight(.medium))
            }
            .foregroundStyle(theme.accentPrimary)
            .padding(.top, 8)
        }
        .padding()
        .background(theme.cardBackground)
        .cornerRadius(12)
    }
}

#Preview {
    ThemeButtonStylesShowcase(theme: ColorTheme.shared)
}
