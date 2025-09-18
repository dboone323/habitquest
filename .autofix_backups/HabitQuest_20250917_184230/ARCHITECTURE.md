# HabitQuest Architecture Documentation

## Overview

HabitQuest is a modern iOS application built with SwiftUI and SwiftData that gamifies habit tracking through an intuitive, engaging user experience. The application employs MVVM architecture patterns with component-based design for scalability and maintainability.

## System Architecture

### Core Components

```
HabitQuest/
├── ContentView.swift                   # Main UI orchestration
├── Core/
│   ├── ViewModels/
│   │   ├── HabitViewModel.swift       # Habit management logic
│   │   └── ItemViewModel.swift        # Item state management
│   ├── Models/
│   │   ├── HabitModel.swift          # SwiftData habit entity
│   │   ├── Item.swift                # Core data model
│   │   └── Category.swift            # Habit categorization
│   └── Services/
│       ├── DataService.swift         # SwiftData management
│       └── NotificationService.swift # Local notifications
├── Views/
│   ├── Components/
│   │   ├── HeaderView.swift          # App header component
│   │   ├── ItemListView.swift        # Habit list display
│   │   ├── FooterStatsView.swift     # Statistics footer
│   │   └── HabitRowView.swift        # Individual habit row
│   ├── Screens/
│   │   ├── AddHabitView.swift        # New habit creation
│   │   ├── HabitDetailView.swift     # Detailed habit view
│   │   └── StatisticsView.swift      # Progress analytics
│   └── Modifiers/
│       ├── HabitCardModifier.swift   # Custom styling
│       └── AnimationModifiers.swift  # Smooth animations
└── Resources/
    ├── Colors.swift                  # Brand color palette
    └── Assets.xcassets              # Images and icons
```

## Architecture Patterns

### MVVM Implementation

```swift
// ViewModel: Business logic and data management
class HabitViewModel: ObservableObject {
    @Published var habits: [Habit] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let dataService: DataService

    init(dataService: DataService = DataService.shared) {
        self.dataService = dataService
        loadHabits()
    }

    // Business logic methods
    func addHabit(_ habit: Habit) { ... }
    func toggleHabitCompletion(_ habit: Habit) { ... }
    func deleteHabit(_ habit: Habit) { ... }
}

// View: SwiftUI interface with component separation
struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    @StateObject private var viewModel = HabitViewModel()

    var body: some View {
        NavigationView {
            VStack {
                HeaderView()
                ItemListView(items: items)
                FooterStatsView(totalItems: items.count)
            }
        }
        .environmentObject(viewModel)
    }
}
```

### Component-Based Architecture

#### 1. HeaderView Component
```swift
struct HeaderView: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("HabitQuest")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text("Build better habits")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button(action: {}) {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
        }
        .padding()
    }
}
```

#### 2. ItemListView Component
```swift
struct ItemListView: View {
    let items: [Item]
    @EnvironmentObject var viewModel: HabitViewModel

    var body: some View {
        LazyVStack(spacing: 12) {
            ForEach(items) { item in
                HabitRowView(item: item)
                    .onTapGesture {
                        viewModel.toggleCompletion(for: item)
                    }
            }
        }
        .padding(.horizontal)
    }
}
```

#### 3. FooterStatsView Component
```swift
struct FooterStatsView: View {
    let totalItems: Int

    var body: some View {
        HStack {
            StatCard(title: "Total Habits", value: "\(totalItems)")
            StatCard(title: "Completed Today", value: "\(completedToday)")
            StatCard(title: "Streak", value: "\(currentStreak) days")
        }
        .padding()
    }
}
```

## SwiftData Integration

### Data Models

```swift
// Primary habit data model
@Model
class Habit {
    @Attribute(.unique) var id: UUID
    var name: String
    var description: String?
    var category: Category
    var createdDate: Date
    var targetFrequency: HabitFrequency
    var isCompleted: Bool
    var completionDates: [Date]

    // Computed properties
    var currentStreak: Int {
        calculateStreak()
    }

    var completionRate: Double {
        calculateCompletionRate()
    }

    init(name: String, category: Category, frequency: HabitFrequency) {
        self.id = UUID()
        self.name = name
        self.category = category
        self.targetFrequency = frequency
        self.createdDate = Date()
        self.isCompleted = false
        self.completionDates = []
    }
}

// Category classification
@Model
class Category {
    var name: String
    var color: String
    var icon: String

    @Relationship(deleteRule: .cascade)
    var habits: [Habit]

    init(name: String, color: String, icon: String) {
        self.name = name
        self.color = color
        self.icon = icon
        self.habits = []
    }
}
```

### Data Service Layer

```swift
class DataService: ObservableObject {
    static let shared = DataService()

    private let modelContainer: ModelContainer
    private let modelContext: ModelContext

    init() {
        do {
            modelContainer = try ModelContainer(for: Habit.self, Category.self)
            modelContext = ModelContext(modelContainer)
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error)")
        }
    }

    // CRUD operations
    func saveHabit(_ habit: Habit) throws {
        modelContext.insert(habit)
        try modelContext.save()
    }

    func fetchHabits() -> [Habit] {
        let descriptor = FetchDescriptor<Habit>(sortBy: [SortDescriptor(\.createdDate)])
        return try? modelContext.fetch(descriptor) ?? []
    }

    func deleteHabit(_ habit: Habit) throws {
        modelContext.delete(habit)
        try modelContext.save()
    }
}
```

## User Interface Architecture

### Design System

#### Color Palette
```swift
extension Color {
    static let habitPrimary = Color("HabitPrimary")
    static let habitSecondary = Color("HabitSecondary")
    static let habitAccent = Color("HabitAccent")
    static let habitSuccess = Color("HabitSuccess")
    static let habitWarning = Color("HabitWarning")
}
```

#### Typography
```swift
extension Font {
    static let habitTitle = Font.largeTitle.weight(.bold)
    static let habitHeadline = Font.headline.weight(.semibold)
    static let habitBody = Font.body
    static let habitCaption = Font.caption.weight(.medium)
}
```

### Animation System

```swift
struct HabitCompletionAnimation: ViewModifier {
    let isCompleted: Bool

    func body(content: Content) -> some View {
        content
            .scaleEffect(isCompleted ? 1.1 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isCompleted)
            .background(
                Circle()
                    .fill(isCompleted ? Color.green : Color.clear)
                    .scaleEffect(isCompleted ? 1.0 : 0.0)
                    .animation(.easeInOut(duration: 0.2), value: isCompleted)
            )
    }
}
```

## State Management

### Reactive Data Flow

```
SwiftData Models ↔ DataService ↔ ViewModels ↔ SwiftUI Views
     ↑                                            ↓
     └────────── User Actions ←───────────────────┘
```

### State Synchronization

- **@Query**: Automatic SwiftData integration
- **@Published**: Reactive property updates
- **@StateObject**: ViewModel lifecycle management
- **@EnvironmentObject**: Shared state across views

## Performance Optimizations

### Efficient List Rendering

```swift
// LazyVStack for large habit lists
LazyVStack(spacing: 12) {
    ForEach(filteredHabits) { habit in
        HabitRowView(habit: habit)
            .onAppear {
                // Preload next batch if needed
                if habit == filteredHabits.last {
                    loadMoreHabits()
                }
            }
    }
}
```

### Memory Management

- **Lazy Loading**: Views created on demand
- **Image Caching**: Efficient asset loading
- **Data Pagination**: Chunked habit loading for large datasets
- **Automatic Cleanup**: SwiftData automatic memory management

## Notification System

### Local Notifications

```swift
class NotificationService: ObservableObject {
    private let notificationCenter = UNUserNotificationCenter.current()

    func scheduleHabitReminder(for habit: Habit) {
        let content = UNMutableNotificationContent()
        content.title = "Time for \(habit.name)!"
        content.body = "Keep your streak going 🔥"
        content.sound = .default

        // Schedule based on habit frequency
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: habit.reminderTime,
            repeats: true
        )

        let request = UNNotificationRequest(
            identifier: habit.id.uuidString,
            content: content,
            trigger: trigger
        )

        notificationCenter.add(request)
    }
}
```

## Analytics and Progress Tracking

### Habit Analytics

```swift
struct HabitAnalytics {
    let habit: Habit

    // Completion statistics
    var completionRate: Double {
        let totalDays = Calendar.current.dateInterval(
            from: habit.createdDate,
            to: Date()
        )?.duration ?? 0

        let completedDays = habit.completionDates.count
        return Double(completedDays) / Double(totalDays / 86400) // seconds to days
    }

    // Streak calculation
    var currentStreak: Int {
        guard !habit.completionDates.isEmpty else { return 0 }

        let sortedDates = habit.completionDates.sorted(by: >)
        var streak = 0
        var currentDate = Date()

        for completionDate in sortedDates {
            if Calendar.current.isDate(completionDate, inSameDayAs: currentDate) ||
               Calendar.current.isDate(completionDate, inSameDayAs: Calendar.current.date(byAdding: .day, value: -1, to: currentDate)!) {
                streak += 1
                currentDate = Calendar.current.date(byAdding: .day, value: -1, to: currentDate)!
            } else {
                break
            }
        }

        return streak
    }
}
```

## Testing Architecture

### Unit Testing Strategy

```swift
// ViewModel testing
class HabitViewModelTests: XCTestCase {
    var viewModel: HabitViewModel!
    var mockDataService: MockDataService!

    override func setUp() {
        mockDataService = MockDataService()
        viewModel = HabitViewModel(dataService: mockDataService)
    }

    func testAddHabit() {
        let initialCount = viewModel.habits.count
        let newHabit = Habit(name: "Test Habit", category: .health, frequency: .daily)

        viewModel.addHabit(newHabit)

        XCTAssertEqual(viewModel.habits.count, initialCount + 1)
        XCTAssertEqual(viewModel.habits.last?.name, "Test Habit")
    }
}
```

### Integration Testing

- **SwiftData Integration**: Database operations testing
- **UI Flow Testing**: End-to-end user journey validation
- **Notification Testing**: Local notification delivery verification

## Accessibility Implementation

### VoiceOver Support

```swift
struct AccessibleHabitRow: View {
    let habit: Habit

    var body: some View {
        HStack {
            // Habit content
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(habit.name) habit")
        .accessibilityValue(habit.isCompleted ? "Completed" : "Not completed")
        .accessibilityHint("Double tap to toggle completion")
    }
}
```

## Security and Privacy

### Data Protection

- **Local Storage Only**: All data remains on device
- **SwiftData Encryption**: Automatic data encryption at rest
- **Privacy by Design**: No personal data collection or transmission
- **Secure Deletion**: Proper data cleanup on habit removal

## Future Architecture Plans

### Roadmap

1. **Cloud Synchronization**: Optional iCloud sync for multi-device support
2. **Widget Integration**: iOS widgets for quick habit checking
3. **Apple Watch App**: Companion watchOS application
4. **Social Features**: Optional habit sharing and community challenges
5. **Advanced Analytics**: ML-powered habit insights and recommendations

### Scalability Considerations

- **Modular Architecture**: Easy feature addition and removal
- **Protocol-Based Design**: Flexible component interfaces
- **Dependency Injection**: Testable and maintainable code structure
- **SwiftData Migration**: Planned database schema evolution support

---

*Architecture Documentation Last Updated: September 12, 2025*
*HabitQuest Version: 1.0*
*iOS Framework: iOS 17.0+, SwiftUI 5.0+*
