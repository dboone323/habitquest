//
// ThemeManager.swift
// AvoidObstaclesGame
//
// Manages theme switching between light and dark modes with system preference detection
// and customizable theme overrides.
//

@preconcurrency import SpriteKit
#if os(iOS) || os(tvOS)
    import UIKit
#endif

/// Available theme modes
public enum ThemeMode: String, Codable, Sendable {
    case system // Follow system preference
    case light // Force light mode
    case dark // Force dark mode
    case custom // Custom theme settings
    case blue // Blue theme
    case purple // Purple theme
    case green // Green theme
    case highContrast // High contrast theme

    var displayName: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        case .custom: return "Custom"
        case .blue: return "Blue"
        case .purple: return "Purple"
        case .green: return "Green"
        case .highContrast: return "High Contrast"
        }
    }
}

/// Color scheme for the theme
public struct ColorScheme: Sendable {
    // Background colors
    public var backgroundPrimary: SKColor
    public var backgroundSecondary: SKColor
    public var backgroundSurface: SKColor

    // Text colors
    public var textPrimary: SKColor
    public var textSecondary: SKColor
    public var textMuted: SKColor

    // Accent colors
    public var primaryColor: SKColor
    public var secondaryColor: SKColor
    public var accentColor: SKColor
    public var successColor: SKColor
    public var warningColor: SKColor
    public var dangerColor: SKColor

    // UI element colors
    public var borderColor: SKColor
    public var shadowColor: SKColor

    public init(
        backgroundPrimary: SKColor,
        backgroundSecondary: SKColor,
        backgroundSurface: SKColor,
        textPrimary: SKColor,
        textSecondary: SKColor,
        textMuted: SKColor,
        primaryColor: SKColor,
        secondaryColor: SKColor,
        accentColor: SKColor,
        successColor: SKColor,
        warningColor: SKColor,
        dangerColor: SKColor,
        borderColor: SKColor,
        shadowColor: SKColor
    ) {
        self.backgroundPrimary = backgroundPrimary
        self.backgroundSecondary = backgroundSecondary
        self.backgroundSurface = backgroundSurface
        self.textPrimary = textPrimary
        self.textSecondary = textSecondary
        self.textMuted = textMuted
        self.primaryColor = primaryColor
        self.secondaryColor = secondaryColor
        self.accentColor = accentColor
        self.successColor = successColor
        self.warningColor = warningColor
        self.dangerColor = dangerColor
        self.borderColor = borderColor
        self.shadowColor = shadowColor
    }
}

/// Complete theme definition
public struct Theme: Sendable {
    public var name: String
    public var mode: ThemeMode
    public var colors: ColorScheme

    // Typography
    public var fontName: String
    public var fontBoldName: String

    // Spacing and sizing
    public var cornerRadius: CGFloat
    public var borderWidth: CGFloat
    public var shadowOpacity: Float
    public var shadowRadius: CGFloat

    public init(
        name: String,
        mode: ThemeMode,
        colors: ColorScheme,
        fontName: String = "SFProDisplay-Regular",
        fontBoldName: String = "SFProDisplay-Bold",
        cornerRadius: CGFloat = 12,
        borderWidth: CGFloat = 2,
        shadowOpacity: Float = 0.3,
        shadowRadius: CGFloat = 4
    ) {
        self.name = name
        self.mode = mode
        self.colors = colors
        self.fontName = fontName
        self.fontBoldName = fontBoldName
        self.cornerRadius = cornerRadius
        self.borderWidth = borderWidth
        self.shadowOpacity = shadowOpacity
        self.shadowRadius = shadowRadius
    }
}

/// Protocol for theme change notifications
@MainActor
public protocol ThemeDelegate: AnyObject {
    func themeDidChange(to theme: Theme)
}

/// Manages theme switching and system preference detection
@MainActor
public class ThemeManager {
    // MARK: - Properties

    /// Shared singleton instance
    public static let shared = ThemeManager()

    /// Current active theme
    public private(set) var currentTheme: Theme {
        didSet {
            saveThemePreference()
            notifyThemeChange()
        }
    }

    /// Current theme mode preference
    public private(set) var preferredMode: ThemeMode {
        didSet {
            updateCurrentTheme()
        }
    }

    /// Delegate for theme change notifications
    public weak var delegate: ThemeDelegate?

    /// System appearance observer
    #if os(iOS) || os(tvOS)
        private var appearanceObserver: NSObjectProtocol?
    #endif

    // MARK: - Predefined Themes

    /// Light theme definition
    public static let lightTheme = Theme(
        name: "Light",
        mode: .light,
        colors: ColorScheme(
            backgroundPrimary: SKColor.white,
            backgroundSecondary: SKColor(white: 0.95, alpha: 1.0),
            backgroundSurface: SKColor(white: 0.9, alpha: 0.9),
            textPrimary: SKColor.black,
            textSecondary: SKColor.darkGray,
            textMuted: SKColor.gray,
            primaryColor: SKColor.systemBlue,
            secondaryColor: SKColor.systemGray,
            accentColor: SKColor.systemGreen,
            successColor: SKColor.systemGreen,
            warningColor: SKColor.systemOrange,
            dangerColor: SKColor.systemRed,
            borderColor: SKColor(white: 0.8, alpha: 1.0),
            shadowColor: SKColor.black.withAlphaComponent(0.2)
        )
    )

    /// Dark theme definition
    public static let darkTheme = Theme(
        name: "Dark",
        mode: .dark,
        colors: ColorScheme(
            backgroundPrimary: SKColor(white: 0.1, alpha: 1.0),
            backgroundSecondary: SKColor(white: 0.15, alpha: 1.0),
            backgroundSurface: SKColor(white: 0.2, alpha: 0.9),
            textPrimary: SKColor.white,
            textSecondary: SKColor.lightGray,
            textMuted: SKColor.gray,
            primaryColor: SKColor.systemBlue,
            secondaryColor: SKColor.systemGray,
            accentColor: SKColor.systemGreen,
            successColor: SKColor.systemGreen,
            warningColor: SKColor.systemOrange,
            dangerColor: SKColor.systemRed,
            borderColor: SKColor(white: 0.3, alpha: 1.0),
            shadowColor: SKColor.black.withAlphaComponent(0.5)
        )
    )

    /// Blue theme definition
    public static let blueTheme = Theme(
        name: "Blue",
        mode: .blue,
        colors: ColorScheme(
            backgroundPrimary: SKColor(red: 0.05, green: 0.1, blue: 0.2, alpha: 1.0),
            backgroundSecondary: SKColor(red: 0.1, green: 0.15, blue: 0.25, alpha: 1.0),
            backgroundSurface: SKColor(red: 0.15, green: 0.2, blue: 0.3, alpha: 0.9),
            textPrimary: SKColor.white,
            textSecondary: SKColor.cyan,
            textMuted: SKColor.blue,
            primaryColor: SKColor.cyan,
            secondaryColor: SKColor.blue,
            accentColor: SKColor.systemBlue,
            successColor: SKColor.green,
            warningColor: SKColor.yellow,
            dangerColor: SKColor.red,
            borderColor: SKColor.cyan.withAlphaComponent(0.5),
            shadowColor: SKColor.blue.withAlphaComponent(0.3)
        )
    )

    /// Purple theme definition
    public static let purpleTheme = Theme(
        name: "Purple",
        mode: .purple,
        colors: ColorScheme(
            backgroundPrimary: SKColor(red: 0.15, green: 0.05, blue: 0.2, alpha: 1.0),
            backgroundSecondary: SKColor(red: 0.2, green: 0.1, blue: 0.25, alpha: 1.0),
            backgroundSurface: SKColor(red: 0.25, green: 0.15, blue: 0.3, alpha: 0.9),
            textPrimary: SKColor.white,
            textSecondary: SKColor.magenta,
            textMuted: SKColor.purple,
            primaryColor: SKColor.magenta,
            secondaryColor: SKColor.purple,
            accentColor: SKColor.systemPurple,
            successColor: SKColor.green,
            warningColor: SKColor.orange,
            dangerColor: SKColor.red,
            borderColor: SKColor.magenta.withAlphaComponent(0.5),
            shadowColor: SKColor.purple.withAlphaComponent(0.3)
        )
    )

    /// Green theme definition
    public static let greenTheme = Theme(
        name: "Green",
        mode: .green,
        colors: ColorScheme(
            backgroundPrimary: SKColor(red: 0.05, green: 0.15, blue: 0.05, alpha: 1.0),
            backgroundSecondary: SKColor(red: 0.1, green: 0.2, blue: 0.1, alpha: 1.0),
            backgroundSurface: SKColor(red: 0.15, green: 0.25, blue: 0.15, alpha: 0.9),
            textPrimary: SKColor.white,
            textSecondary: SKColor.green,
            textMuted: SKColor(red: 0.5, green: 0.8, blue: 0.5, alpha: 1.0),
            primaryColor: SKColor.green,
            secondaryColor: SKColor(red: 0.2, green: 0.6, blue: 0.2, alpha: 1.0),
            accentColor: SKColor.systemGreen,
            successColor: SKColor.green,
            warningColor: SKColor.yellow,
            dangerColor: SKColor.red,
            borderColor: SKColor.green.withAlphaComponent(0.5),
            shadowColor: SKColor(red: 0.2, green: 0.6, blue: 0.2, alpha: 0.3)
        )
    )

    /// High contrast theme definition
    public static let highContrastTheme = Theme(
        name: "High Contrast",
        mode: .highContrast,
        colors: ColorScheme(
            backgroundPrimary: SKColor.black,
            backgroundSecondary: SKColor(white: 0.1, alpha: 1.0),
            backgroundSurface: SKColor(white: 0.2, alpha: 1.0),
            textPrimary: SKColor.white,
            textSecondary: SKColor.yellow,
            textMuted: SKColor.white,
            primaryColor: SKColor.yellow,
            secondaryColor: SKColor.white,
            accentColor: SKColor.yellow,
            successColor: SKColor.green,
            warningColor: SKColor.yellow,
            dangerColor: SKColor.red,
            borderColor: SKColor.yellow,
            shadowColor: SKColor.white.withAlphaComponent(0.5)
        )
    )

    // MARK: - Initialization

    private init() {
        // Initialize with default values first
        self.preferredMode = .system
        self.currentTheme = Self.lightTheme
        #if os(iOS) || os(tvOS)
        self.appearanceObserver = nil
        #endif
        self.delegate = nil

        // Then load preferences and setup
        self.preferredMode = loadThemePreference()
        self.currentTheme = Self.getThemeForMode(preferredMode)
        setupSystemAppearanceObserver()
    }

    deinit {
        #if os(iOS) || os(tvOS)
            if let observer = appearanceObserver {
                NotificationCenter.default.removeObserver(observer)
            }
        #endif
    }

    // MARK: - Theme Management

    /// Sets the preferred theme mode
    /// - Parameter mode: The theme mode to use
    public func setThemeMode(_ mode: ThemeMode) {
        preferredMode = mode
    }

    /// Gets the current system appearance
    /// - Returns: True if system is in dark mode
    public func isSystemInDarkMode() -> Bool {
        #if os(iOS) || os(tvOS)
            if #available(iOS 13.0, tvOS 13.0, *) {
                return UITraitCollection.current.userInterfaceStyle == .dark
            }
            return false
        #elseif os(macOS)
            if #available(macOS 10.14, *) {
                return NSAppearance.currentDrawing().name == .darkAqua
            }
            return false
        #else
            return false
        #endif
    }

    /// Gets all available themes
    /// - Returns: Array of available themes
    public func getAvailableThemes() -> [Theme] {
        return [
            Self.lightTheme,
            Self.darkTheme,
            Self.blueTheme,
            Self.purpleTheme,
            Self.greenTheme,
            Self.highContrastTheme
        ]
    }

    /// Gets theme for a specific mode
    /// - Parameter mode: The theme mode
    /// - Returns: Appropriate theme for the mode
    public static func getThemeForMode(_ mode: ThemeMode) -> Theme {
        switch mode {
        case .light:
            return lightTheme
        case .dark:
            return darkTheme
        case .blue:
            return blueTheme
        case .purple:
            return purpleTheme
        case .green:
            return greenTheme
        case .highContrast:
            return highContrastTheme
        case .system:
            // For system mode, determine based on current system appearance
            let manager = ThemeManager()
            return manager.isSystemInDarkMode() ? darkTheme : lightTheme
        case .custom:
            // For now, return dark theme as fallback
            // In future, this could load custom theme from storage
            return darkTheme
        }
    }

    /// Applies a theme with smooth transition animation
    /// - Parameters:
    ///   - theme: The theme to apply
    ///   - duration: Animation duration in seconds
    public func applyThemeWithTransition(_ theme: Theme, duration: TimeInterval = 0.5) {
        // Store the new theme
        let oldTheme = currentTheme
        currentTheme = theme

        // Notify delegate for immediate UI updates
        notifyThemeChange()

        // Animate the transition if duration > 0
        if duration > 0 {
            animateThemeTransition(from: oldTheme, to: theme, duration: duration)
        }
    }

    /// Animates the transition between two themes
    /// - Parameters:
    ///   - fromTheme: The theme to transition from
    ///   - toTheme: The theme to transition to
    ///   - duration: Animation duration
    private func animateThemeTransition(from fromTheme: Theme, to toTheme: Theme, duration: TimeInterval) {
        // This would animate scene background color changes
        // Implementation depends on how the scene handles background colors
        // For now, the immediate theme change provides the visual update
    }

    /// Creates a custom theme with specified colors
    /// - Parameters:
    ///   - name: Custom theme name
    ///   - baseTheme: Base theme to modify
    ///   - customColors: Custom color overrides
    /// - Returns: Custom theme instance
    public func createCustomTheme(name: String, baseTheme: Theme, customColors: [String: SKColor]) -> Theme {
        var colors = baseTheme.colors

        // Apply custom color overrides
        for (key, color) in customColors {
            switch key {
            case "backgroundPrimary":
                colors.backgroundPrimary = color
            case "backgroundSecondary":
                colors.backgroundSecondary = color
            case "backgroundSurface":
                colors.backgroundSurface = color
            case "textPrimary":
                colors.textPrimary = color
            case "textSecondary":
                colors.textSecondary = color
            case "textMuted":
                colors.textMuted = color
            case "primaryColor":
                colors.primaryColor = color
            case "secondaryColor":
                colors.secondaryColor = color
            case "accentColor":
                colors.accentColor = color
            case "successColor":
                colors.successColor = color
            case "warningColor":
                colors.warningColor = color
            case "dangerColor":
                colors.dangerColor = color
            case "borderColor":
                colors.borderColor = color
            case "shadowColor":
                colors.shadowColor = color
            default:
                break
            }
        }

        return Theme(
            name: name,
            mode: .custom,
            colors: colors,
            fontName: baseTheme.fontName,
            fontBoldName: baseTheme.fontBoldName,
            cornerRadius: baseTheme.cornerRadius,
            borderWidth: baseTheme.borderWidth,
            shadowOpacity: baseTheme.shadowOpacity,
            shadowRadius: baseTheme.shadowRadius
        )
    }

    /// Gets the next theme in the cycle
    /// - Returns: Next theme in available themes
    public func getNextTheme() -> Theme {
        let themes = getAvailableThemes()
        guard let currentIndex = themes.firstIndex(where: { $0.mode == currentTheme.mode }) else {
            return themes.first ?? Self.lightTheme
        }

        let nextIndex = (currentIndex + 1) % themes.count
        return themes[nextIndex]
    }

    /// Cycles to the next available theme
    public func cycleToNextTheme() {
        let nextTheme = getNextTheme()
        setThemeMode(nextTheme.mode)
    }

    /// Gets theme preview colors for UI display
    /// - Parameter theme: Theme to get preview for
    /// - Returns: Array of representative colors
    public func getThemePreviewColors(for theme: Theme) -> [SKColor] {
        return [
            theme.colors.backgroundPrimary,
            theme.colors.primaryColor,
            theme.colors.accentColor,
            theme.colors.textPrimary
        ]
    }

    // MARK: - Private Methods

    private func setupSystemAppearanceObserver() {
        #if os(iOS) || os(tvOS)
            if #available(iOS 13.0, tvOS 13.0, *) {
                appearanceObserver = NotificationCenter.default.addObserver(
                    forName: UIApplication.didBecomeActiveNotification,
                    object: nil,
                    queue: .main
                ) { [weak self] _ in
                    self?.handleSystemAppearanceChange()
                }
            }
        #elseif os(macOS)
            if #available(macOS 10.14, *) {
                // On macOS, we don't need to store the observer since DistributedNotificationCenter
                // handles observer management automatically
                DistributedNotificationCenter.default.addObserver(
                    forName: NSNotification.Name("AppleInterfaceThemeChangedNotification"),
                    object: nil,
                    queue: .main
                ) { [weak self] _ in
                    self?.handleSystemAppearanceChange()
                }
            }
        #endif
    }

    private func handleSystemAppearanceChange() {
        // Only update if we're using system theme mode
        if preferredMode == .system {
            updateCurrentTheme()
        }
    }

    private func updateCurrentTheme() {
        currentTheme = Self.getThemeForMode(preferredMode)
    }

    private func notifyThemeChange() {
        delegate?.themeDidChange(to: currentTheme)
    }

    // MARK: - Persistence

    private func saveThemePreference() {
        let preference = ThemePreference(mode: preferredMode)
        do {
            let data = try JSONEncoder().encode(preference)
            UserDefaults.standard.set(data, forKey: "themePreference")
        } catch {
            print("Failed to save theme preference: \(error)")
        }
    }

    private func loadThemePreference() -> ThemeMode {
        guard let data = UserDefaults.standard.data(forKey: "themePreference") else {
            return .system // Default to system preference
        }

        do {
            let preference = try JSONDecoder().decode(ThemePreference.self, from: data)
            return preference.mode
        } catch {
            print("Failed to load theme preference: \(error)")
            return .system
        }
    }
}

// MARK: - Supporting Types

/// Theme preference for persistence
private struct ThemePreference: Codable {
    let mode: ThemeMode
}

// MARK: - Extensions

extension SKColor {
    /// Creates a color from hex string
    convenience init?(hex: String) {
        let r, g, b, a: CGFloat

        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])

            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xFF00_0000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00FF_0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000_FF00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x0000_00FF) / 255

                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }

        return nil
    }

    /// Gets hex string representation
    var hexString: String {
        guard let components = cgColor.components, components.count >= 3 else {
            return "#000000"
        }

        let r = components[0]
        let g = components[1]
        let b = components[2]
        let a = components.count >= 4 ? components[3] : 1.0

        if a < 1.0 {
            return String(format: "#%02lX%02lX%02lX%02lX",
                          lroundf(Float(r * 255)),
                          lroundf(Float(g * 255)),
                          lroundf(Float(b * 255)),
                          lroundf(Float(a * 255)))
        } else {
            return String(format: "#%02lX%02lX%02lX",
                          lroundf(Float(r * 255)),
                          lroundf(Float(g * 255)),
                          lroundf(Float(b * 255)))
        }
    }
}
