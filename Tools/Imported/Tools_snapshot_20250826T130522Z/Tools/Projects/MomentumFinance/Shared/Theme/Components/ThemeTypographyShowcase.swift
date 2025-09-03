import SwiftUI

struct ThemeTypographyShowcase: View {
    let theme: ColorTheme

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Typography")
                .font(.headline)
                .foregroundStyle(theme.primaryText)

            Divider()
                .background(theme.secondaryText.opacity(0.3))

            Group {
                Text("Large Title")
                    .font(.largeTitle)

                Text("Title")
                    .font(.title)

                Text("Title 2")
                    .font(.title2)

                Text("Title 3")
                    .font(.title3)

                Text("Headline")
                    .font(.headline)

                Text("Body")
                    .font(.body)

                Text("Callout")
                    .font(.callout)

                Text("Subheadline")
                    .font(.subheadline)

                Text("Footnote")
                    .font(.footnote)

                Text("Caption")
                    .font(.caption)
            }
            .foregroundStyle(theme.primaryText)

            Text("This typography supports dynamic type and respects user accessibility settings")
                .font(.caption)
                .foregroundStyle(theme.secondaryText)
                .padding(.top, 8)
        }
        .padding()
        .background(theme.cardBackground)
        .cornerRadius(12)
    }
}

#Preview {
    ThemeTypographyShowcase(theme: ColorTheme.shared)
}
