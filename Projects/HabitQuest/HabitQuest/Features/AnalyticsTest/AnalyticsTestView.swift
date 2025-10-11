import SwiftData
import SwiftUI

// MARK: - Test Results Structure

struct TestResults {
    private(set) var tests: [TestResult] = []

    var passedCount: Int { self.tests.filter(\.passed).count }
    var failedCount: Int { self.tests.count(where: { !$0.passed }) }
    var totalCount: Int { self.tests.count }
    var allPassed: Bool { self.failedCount == 0 }

    mutating func addResult(name: String, passed: Bool, error: String? = nil, note: String? = nil) {
        self.tests.append(TestResult(name: name, passed: passed, error: error, note: note))
    }

    /// <#Description#>
    /// - Returns: <#description#>
    /// <#Description#>
    /// - Returns: <#description#>
    /// <#Description#>
    /// - Returns: <#description#>
    func printSummary() {
        print("\n📊 Analytics Test Results:")
        print("─────────────────────────")

        for test in self.tests {
            let status = test.passed ? "✅" : "❌"
            print("\(status) \(test.name)")
            if let error = test.error {
                print("   Error: \(error)")
            }
            if let note = test.note {
                print("   Note: \(note)")
            }
        }

        print("─────────────────────────")
        print("Total: \(self.totalCount) | Passed: \(self.passedCount) | Failed: \(self.failedCount)")
        print(self.allPassed ? "🎉 All tests passed!" : "⚠️  Some tests failed")
    }
}

struct TestResult {
    let name: String
    let passed: Bool
    let error: String?
    let note: String?
}

/// Live analytics test runner that can be accessed from within the app
public struct AnalyticsTestView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var testResults: TestResults?
    @State private var isRunning = false

    public var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if let results = testResults {
                    TestResultsView(results: results)
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)

                        Text("Analytics Test Suite")
                            .font(.title)
                            .fontWeight(.bold)

                        Text("Verify all analytics functions are working properly")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                }

                Spacer()

                Button(action: self.runTests) {
                    HStack {
                        if self.isRunning {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "play.circle.fill")
                        }
                        Text(self.isRunning ? "Running Tests..." : "Run Analytics Tests")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .accessibilityLabel("Button")
                .disabled(self.isRunning)
                .padding(.horizontal)
            }
            .navigationTitle("Analytics Tests")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
        }
    }

    private func runTests() {
        self.isRunning = true

        Task {
            let results = await runAnalyticsTests(with: modelContext)

            await MainActor.run {
                self.testResults = results
                self.isRunning = false
                results.printSummary()
            }
        }
    }

    /// Simple analytics test runner for the live app
    private func runAnalyticsTests(with modelContext: ModelContext) async -> TestResults {
        // First, ensure we have some test data
        await self.createSampleDataIfNeeded(with: modelContext)

        let analyticsService = AnalyticsService(modelContext: modelContext)
        var results = TestResults()

        // Test 1: Basic Analytics Functionality
        let analytics = await analyticsService.getAnalytics()
        results.addResult(name: "Basic Analytics", passed: analytics.overallStats.totalHabits >= 0)

        // Test 2: Category Insights
        let insights = await analyticsService.getCategoryInsights()
        results.addResult(name: "Category Insights", passed: !insights.isEmpty)

        // Test 3: Productivity Metrics
        let metrics = await analyticsService.getProductivityMetrics(for: .week)
        let validMetrics =
            metrics.completionRate >= 0.0 && metrics.completionRate <= 1.0
            && metrics.streakCount >= 0
        results.addResult(name: "Productivity Metrics", passed: validMetrics)

        // Test 4: Data Consistency
        let categoryHabitSum = analytics.categoryBreakdown.reduce(0) { $0 + $1.habitCount }
        let consistent = analytics.overallStats.totalHabits == categoryHabitSum
        results.addResult(name: "Data Consistency", passed: consistent)

        // Test 5: Analytics Data Structure Validation
        let hasValidStructure =
            analytics.overallStats.totalCompletions >= 0
            && analytics.overallStats.completionRate >= 0.0
            && analytics.overallStats.completionRate <= 1.0
            && analytics.streakAnalytics.longestStreak >= 0
        results.addResult(name: "Analytics Structure", passed: hasValidStructure)

        return results
    }

    /// Create sample data for testing if the database is empty
    private func createSampleDataIfNeeded(with modelContext: ModelContext) async {
        // Check if we already have habits
        let descriptor = FetchDescriptor<Habit>()
        let existingHabits = (try? modelContext.fetch(descriptor)) ?? []

        if !existingHabits.isEmpty {
            return // Data already exists
        }

        // Create sample habits
        let sampleHabits = [
            Habit(
                name: "Morning Exercise",
                habitDescription: "30 minutes of exercise",
                frequency: .daily,
                xpValue: 20,
                category: .fitness,
                difficulty: .medium
            ),
            Habit(
                name: "Read for 30 minutes",
                habitDescription: "Reading books or educational material",
                frequency: .daily,
                xpValue: 15,
                category: .learning,
                difficulty: .easy
            ),
            Habit(
                name: "Meditate",
                habitDescription: "10 minutes of mindfulness meditation",
                frequency: .daily,
                xpValue: 10,
                category: .mindfulness,
                difficulty: .easy
            )
        ]

        // Add habits to context
        for habit in sampleHabits {
            modelContext.insert(habit)
        }

        // Create some sample logs for the last few days
        let calendar = Calendar.current
        let today = Date()

        // Pre-calculate completion patterns to avoid nested loops
        let completionPatterns: [(habit: Habit, dayOffset: Int, shouldComplete: Bool)] = sampleHabits.flatMap { habit in
            (0 ..< 7).map { dayOffset in
                let shouldComplete = (dayOffset % 2 == 0) || (habit.category == .mindfulness && dayOffset < 3)
                return (habit: habit, dayOffset: dayOffset, shouldComplete: shouldComplete)
            }
        }

        for pattern in completionPatterns {
            guard let logDate = calendar.date(byAdding: .day, value: -pattern.dayOffset, to: today),
                  pattern.shouldComplete
            else {
                continue
            }

            let log = HabitLog(
                habit: pattern.habit,
                completionDate: logDate,
                isCompleted: true,
                notes: "Test completion",
                mood: .good
            )
            modelContext.insert(log)
        }

        // Save the context
        try? modelContext.save()
    }
}

/// Display test results in a clean UI
public struct TestResultsView: View {
    let results: TestResults

    public var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Summary Card
                VStack(spacing: 12) {
                    HStack {
                        Text("Test Summary")
                            .font(.headline)
                        Spacer()
                        Image(
                            systemName: self.results.allPassed
                                ? "checkmark.circle.fill" : "exclamationmark.triangle.fill"
                        )
                        .foregroundColor(self.results.allPassed ? .green : .orange)
                    }

                    HStack(spacing: 20) {
                        StatItem(title: "Total", value: "\(self.results.totalCount)", color: .blue)
                        StatItem(title: "Passed", value: "\(self.results.passedCount)", color: .green)
                        StatItem(title: "Failed", value: "\(self.results.failedCount)", color: .red)
                    }
                }
                .padding()
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(12)

                // Individual Test Results
                LazyVStack(spacing: 8) {
                    ForEach(Array(self.results.tests.enumerated()), id: \.offset) { _, test in
                        TestResultRow(test: test)
                    }
                }
            }
            .padding()
        }
    }
}

/// Individual test result row
public struct TestResultRow: View {
    let test: TestResult

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: self.test.passed ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(self.test.passed ? .green : .red)

                Text(self.test.name)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Spacer()
            }

            if let error = test.error {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.leading, 24)
            }

            if let note = test.note {
                Text(note)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.leading, 24)
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.05))
        .cornerRadius(8)
    }
}

/// Stat item component
public struct StatItem: View {
    let title: String
    let value: String
    let color: Color

    public var body: some View {
        VStack(spacing: 4) {
            Text(self.value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(self.color)

            Text(self.title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    AnalyticsTestView()
}
