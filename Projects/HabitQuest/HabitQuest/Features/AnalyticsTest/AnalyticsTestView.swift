import SwiftData
import SwiftUI

// MARK: - Test Results Structure

struct TestResults {
    private(set) var tests: [TestResult] = []

    var passedCount: Int { tests.filter { $0.passed }.count }
    var failedCount: Int { tests.filter { !$0.passed }.count }
    var totalCount: Int { tests.count }
    var allPassed: Bool { failedCount == 0 }

    mutating func addResult(name: String, passed: Bool, error: String? = nil, note: String? = nil) {
        tests.append(TestResult(name: name, passed: passed, error: error, note: note))
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

        for test in tests {
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
        print("Total: \(totalCount) | Passed: \(passedCount) | Failed: \(failedCount)")
        print(allPassed ? "🎉 All tests passed!" : "⚠️  Some tests failed")
    }
}

struct TestResult {
    let name: String
    let passed: Bool
    let error: String?
    let note: String?
}

/// Live analytics test runner that can be accessed from within the app
struct AnalyticsTestView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var testResults: TestResults?
    @State private var isRunning = false

    var body: some View {
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

                Button(action: runTests) {
                    HStack {
                        if isRunning {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "play.circle.fill")
                        }
                        Text(isRunning ? "Running Tests..." : "Run Analytics Tests")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(isRunning)
                .padding(.horizontal)
            }
            .navigationTitle("Analytics Tests")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private func runTests() {
        isRunning = true

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
        await createSampleDataIfNeeded(with: modelContext)

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
        let validMetrics = metrics.completionRate >= 0.0 &&
            metrics.completionRate <= 1.0 &&
            metrics.streakCount >= 0
        results.addResult(name: "Productivity Metrics", passed: validMetrics)

        // Test 4: Data Consistency
        let categoryHabitSum = analytics.categoryBreakdown.reduce(0) { $0 + $1.habitCount }
        let consistent = analytics.overallStats.totalHabits == categoryHabitSum
        results.addResult(name: "Data Consistency", passed: consistent)

        // Test 5: Analytics Data Structure Validation
        let hasValidStructure = analytics.overallStats.totalCompletions >= 0 &&
            analytics.overallStats.completionRate >= 0.0 &&
            analytics.overallStats.completionRate <= 1.0 &&
            analytics.streakAnalytics.longestStreak >= 0
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

        for dayOffset in 0..<7 {
            guard let logDate = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { continue }

            for habit in sampleHabits {
                // Create logs with varying completion rates
                let shouldComplete = (dayOffset % 2 == 0) || (habit.category == .mindfulness && dayOffset < 3)

                if shouldComplete {
                    let log = HabitLog(
                        habit: habit,
                        completionDate: logDate,
                        isCompleted: true,
                        notes: "Test completion",
                        mood: .good
                    )
                    modelContext.insert(log)
                }
            }
        }

        // Save the context
        try? modelContext.save()
    }
}

/// Display test results in a clean UI
struct TestResultsView: View {
    let results: TestResults

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Summary Card
                VStack(spacing: 12) {
                    HStack {
                        Text("Test Summary")
                            .font(.headline)
                        Spacer()
                        Image(systemName: results.allPassed ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                            .foregroundColor(results.allPassed ? .green : .orange)
                    }

                    HStack(spacing: 20) {
                        StatItem(title: "Total", value: "\(results.totalCount)", color: .blue)
                        StatItem(title: "Passed", value: "\(results.passedCount)", color: .green)
                        StatItem(title: "Failed", value: "\(results.failedCount)", color: .red)
                    }
                }
                .padding()
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(12)

                // Individual Test Results
                LazyVStack(spacing: 8) {
                    ForEach(Array(results.tests.enumerated()), id: \.offset) { _, test in
                        TestResultRow(test: test)
                    }
                }
            }
            .padding()
        }
    }
}

/// Individual test result row
struct TestResultRow: View {
    let test: TestResult

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: test.passed ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(test.passed ? .green : .red)

                Text(test.name)
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
struct StatItem: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    AnalyticsTestView()
}
