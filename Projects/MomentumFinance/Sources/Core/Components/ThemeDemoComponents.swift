import Foundation
import SwiftUI

// MARK: - Theme Demo Components

public struct ThemeSelectorCard: View {
    @Binding public var selectedThemeMode: ThemeMode
    public let theme: Any?

    public init(selectedThemeMode: Binding<ThemeMode>, theme: Any? = nil) {
        _selectedThemeMode = selectedThemeMode
        self.theme = theme
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Theme Selection")
                .font(.headline)
                .fontWeight(.semibold)

            HStack(spacing: 12) {
                ForEach(ThemeMode.allCases, id: \.self) { mode in
                    Button(action: {
                        self.selectedThemeMode = mode
                    }) {
                        VStack(spacing: 8) {
                            Image(systemName: self.themeIcon(for: mode))
                                .font(.title2)
                            Text(mode.displayName)
                                .font(.caption)
                        }
                        .padding()
                        .background(
                            self.selectedThemeMode == mode ? Color.blue : Color.gray.opacity(0.2)
                        )
                        .foregroundColor(self.selectedThemeMode == mode ? .white : .primary)
                        .cornerRadius(8)
                    }
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }

    private func themeIcon(for mode: ThemeMode) -> String {
        switch mode {
        case .light: "sun.max"
        case .dark: "moon"
        case .system: "gearshape"
        }
    }

    public init(selectedThemeMode: Binding<ThemeMode>) {
        _selectedThemeMode = selectedThemeMode
        self.theme = nil
    }
}

public struct ThemeFinancialSummaryCard: View {
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Financial Summary")
                .font(.headline)
                .fontWeight(.semibold)

            HStack {
                VStack(alignment: .leading) {
                    Text("Total Balance")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("$12,345.67")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }

                Spacer()

                VStack(alignment: .trailing) {
                    Text("This Month")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("+$1,234.56")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                }
            }

            Divider()

            HStack {
                Text("Spending")
                    .foregroundColor(.secondary)
                Spacer()
                Text("$2,345.89")
                    .fontWeight(.semibold)
                    .foregroundColor(.red)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }

    public init(theme _: Any = ()) {
        // Accept any theme parameter for compatibility but use static colors
    }
}

public struct ThemeAccountsList: View {
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Accounts")
                .font(.headline)
                .fontWeight(.semibold)

            VStack(spacing: 8) {
                self.accountRow("Checking", "$3,456.78")
                self.accountRow("Savings", "$8,888.89")
                self.accountRow("Credit Card", "-$567.12")
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }

    private func accountRow(_ name: String, _ balance: String) -> some View {
        HStack {
            Circle()
                .fill(Color.blue)
                .frame(width: 32, height: 32)
                .overlay(
                    Text(String(name.prefix(1)))
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text("Account")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text(balance)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(balance.hasPrefix("-") ? .red : .blue)
        }
        .padding(.vertical, 4)
    }

    public init(theme _: Any = ()) {
        // Accept any theme parameter for compatibility but use static colors
    }
}
