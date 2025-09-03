import SwiftUI

struct ThemeSettingsSheet: View {
    @Binding var selectedThemeMode: ThemeMode
    @Binding var sliderValue: Double
    @Binding var showSheet: Bool
    let theme: ColorTheme

    var body: some View {
        NavigationStack {
            List {
                // Theme mode options
                Section(
                    header: Text("Theme Mode"),
                    footer: Text("Your preference will be saved automatically.")
                ) {
                    ForEach(Array(ThemeMode.allCases), id: \.self) { mode in
                        Button {
                            selectedThemeMode = mode
                            theme.setThemeMode(mode)
                        } label: {
                            HStack {
                                Label(mode.displayName, systemImage: mode.icon)
                                    .foregroundStyle(theme.primaryText)

                                Spacer()

                                if selectedThemeMode == mode {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(theme.accentPrimary)
                                }
                            }
                        }
                    }
                }

                // Color palette preview
                Section(header: Text("Color Palette")) {
                    colorPaletteGrid
                }

                // Interactive element
                Section(header: Text("Demo Controls")) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Progress Value: \(Int(sliderValue * 100))%")
                            .foregroundStyle(theme.primaryText)

                        // Custom progress circle
                        ZStack {
                            Circle()
                                .stroke(
                                    theme.secondaryBackground,
                                    lineWidth: 10
                                )
                                .frame(width: 100, height: 100)

                            Circle()
                                .trim(from: 0, to: sliderValue)
                                .stroke(
                                    theme.savings,
                                    style: StrokeStyle(
                                        lineWidth: 10,
                                        lineCap: .round
                                    )
                                )
                                .rotationEffect(.degrees(-90))
                                .frame(width: 100, height: 100)
                                .animation(.easeInOut, value: sliderValue)

                            Text("\(Int(sliderValue * 100))%")
                                .font(.headline)
                                .foregroundStyle(theme.primaryText)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 16)

                        Slider(value: $sliderValue)
                            .tint(theme.accentPrimary)
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Theme Settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        showSheet = false
                    }
                }
            }
        }
    }

    private var colorPaletteGrid: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
            ], spacing: 12
        ) {
            colorBlock(theme.background, name: "Background")
            colorBlock(theme.cardBackground, name: "Card")
            colorBlock(theme.accentPrimary, name: "Accent")
            colorBlock(theme.income, name: "Income")
            colorBlock(theme.expense, name: "Expense")
            colorBlock(theme.savings, name: "Savings")
        }
        .padding(.vertical, 8)
    }

    private func colorBlock(_ color: Color, name: String) -> some View {
        VStack {
            Circle()
                .fill(color)
                .frame(height: 50)
                .overlay(
                    Circle()
                        .strokeBorder(Color.gray.opacity(0.2), lineWidth: 1)
                )

            Text(name)
                .font(.caption2)
                .foregroundStyle(theme.secondaryText)
        }
    }
}

#Preview {
    ThemeSettingsSheet(
        selectedThemeMode: .constant(.system),
        sliderValue: .constant(0.75),
        showSheet: .constant(true),
        theme: ColorTheme.shared
    )
}
