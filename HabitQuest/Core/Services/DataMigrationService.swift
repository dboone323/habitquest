import Foundation

enum DataMigrationService {
    private static let migrationBuildKey = "habitquest.last_migrated_build"

    static func runIfNeeded() {
        let defaults = UserDefaults.standard
        let currentBuild = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "0"
        let lastMigratedBuild = defaults.string(forKey: migrationBuildKey)

        guard lastMigratedBuild != currentBuild else { return }

        migrateLegacyNotificationFlags(defaults: defaults)
        migrateLegacyThemeSetting(defaults: defaults)

        defaults.set(currentBuild, forKey: migrationBuildKey)
    }

    private static func migrateLegacyNotificationFlags(defaults: UserDefaults) {
        if defaults.object(forKey: "notifications_enabled") == nil,
           let legacyValue = defaults.object(forKey: "hq_notifications_enabled") as? Bool
        {
            defaults.set(legacyValue, forKey: "notifications_enabled")
        }
    }

    private static func migrateLegacyThemeSetting(defaults: UserDefaults) {
        if defaults.string(forKey: "theme_preference") == nil,
           let legacyTheme = defaults.string(forKey: "theme")
        {
            defaults.set(legacyTheme, forKey: "theme_preference")
        }
    }
}
