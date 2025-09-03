import SwiftUI

/// Main app view containing the primary TabView navigation
/// This serves as the central hub connecting all feature modules
struct AppMainView: View {
    var body: some View {
        TabView {
            // Today's Quests Tab
            TodaysQuestsView()
                .tabItem {
                    Image(systemName: "list.bullet.circle")
                    Text("Today")
                }

            // Quest Log Tab
            QuestLogView()
                .tabItem {
                    Image(systemName: "book.closed")
                    Text("Log")
                }

            // Profile Tab
            ProfileView()
                .tabItem {
                    Image(systemName: "person.circle")
                    Text("Profile")
                }

            // Analytics Tab - Advanced Streak Analytics Dashboard
            StreakAnalyticsView()
                .tabItem {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                    Text("Analytics")
                }

            // Data Management Tab
            DataManagementView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
        .accentColor(Color.blue)
    }
}

#Preview {
    AppMainView()
}
