# HabitQuest Web - SwiftWasm Deployment

A web-based version of the HabitQuest application built with SwiftWasm, featuring gamified habit tracking with streaks, progress visualization, and motivational elements to help users build lasting habits.

## 🎯 Habit Features

- **Habit Creation**: Custom habits with colors, descriptions, and frequency settings
- **Daily Tracking**: Mark habits complete with visual feedback and streak tracking
- **Gamification**: Streak counters, completion rates, and progress visualization
- **Calendar View**: 7-day habit completion overview with visual indicators
- **Statistics Dashboard**: Active habits, longest streaks, and completion analytics
- **Responsive Design**: Works on desktop and mobile devices

## 📊 Dashboard Overview

### Key Metrics
- **Active Habits**: Total number of habits being tracked
- **Longest Streak**: Highest consecutive completion streak across all habits
- **Completion Rate**: Overall success rate across all habits and time periods
- **Habits Completed Today**: Number of habits completed in the current day

### Habit Management
- **Custom Colors**: Personalize habits with color coding
- **Flexible Frequency**: Daily, weekly, or custom tracking schedules
- **Progress Tracking**: Visual progress bars showing completion rates
- **Streak Rewards**: Motivational streak counters with fire emoji indicators

### Calendar Visualization
- **7-Day View**: Recent habit completion history
- **Visual Indicators**: Color-coded dots showing completion status
- **Today Highlighting**: Current day prominently displayed
- **Quick Overview**: Rapid assessment of habit consistency

## 🛠️ Technology Stack

- **SwiftWasm**: Compiles Swift habit logic to WebAssembly
- **JavaScriptKit**: DOM manipulation and browser API access
- **SwiftWebAPI**: Web-specific Swift APIs for local storage
- **HTML5 Canvas**: Optional chart rendering (future enhancement)
- **Local Storage**: Client-side data persistence for habits and entries

## 📁 Project Structure

```
HabitQuest/WebInterface/
├── Package.swift              # SwiftWasm package configuration
├── Sources/
│   └── HabitQuestWeb/
│       └── main.swift        # Habit tracking logic and gamification
├── index.html                # Gamified habit tracking interface
├── build.sh                  # Build script for compilation
└── README.md                 # This documentation
```

## 🏗️ Building and Running

### Prerequisites

1. **SwiftWasm Toolchain**: Install the SwiftWasm compiler
   ```bash
   # Option 1: Using installer script (recommended)
   curl -sL https://github.com/swiftwasm/swiftwasm-install/releases/download/0.1.0/swiftwasm-install.sh | bash

   # Option 2: Manual installation
   wget https://github.com/swiftwasm/swiftwasm-install/releases/download/0.1.0/swiftwasm-install.sh
   chmod +x swiftwasm-install.sh
   ./swiftwasm-install.sh
   ```

2. **Web Server**: For local testing (Python's built-in server works)

### Build Process

1. **Navigate to the web interface directory**:
   ```bash
   cd Projects/HabitQuest/WebInterface
   ```

2. **Run the build script**:
   ```bash
   ./build.sh
   ```

   This will:
   - Compile Swift habit code to WebAssembly
   - Generate JavaScript wrapper with habit-specific APIs
   - Create deployment-ready files

3. **Start a local web server**:
   ```bash
   python3 -m http.server 8000
   ```

4. **Open in browser**:
   ```
   http://localhost:8000
   ```

## 🎮 Gamification Features

### Core Systems

- **Streak Tracking**: Consecutive completion day counters with visual rewards
- **Progress Visualization**: Color-coded progress bars and completion percentages
- **Achievement System**: Milestones and success indicators
- **Motivational Design**: Fire emojis and encouraging messages for streaks
- **Data Persistence**: Local storage maintains habit history and streaks

### Web-Specific Adaptations

- **Touch Interactions**: Mobile-friendly habit completion buttons
- **Responsive Calendar**: Adapts to different screen sizes
- **Real-time Updates**: Immediate visual feedback for habit completions
- **Offline Capability**: Works without internet connection using local storage

## 🔧 Configuration

### Package.swift
```swift
let package = Package(
    name: "HabitQuestWeb",
    platforms: [.macOS(.v12)],
    dependencies: [
        .package(url: "https://github.com/swiftwasm/JavaScriptKit", from: "0.15.0"),
        .package(url: "https://github.com/swiftwasm/SwiftWebAPI", from: "0.2.0")
    ],
    targets: [
        .executableTarget(
            name: "HabitQuestWeb",
            dependencies: ["JavaScriptKit", "SwiftWebAPI"]
        )
    ]
)
```

### Habit Parameters

The application supports customizable habit settings:

- **Frequency Options**: Daily, Weekly, Custom schedules
- **Target Days**: Configurable weekly completion goals (1-7 days)
- **Color Coding**: Personalization with hex color values
- **Streak Calculation**: Automatic consecutive day tracking

### Data Storage

Habits and completion data are stored locally in the browser:

- **Habit Data**: Name, description, settings, and creation date
- **Completion Entries**: Daily completion records with timestamps
- **Streak Data**: Calculated from completion history
- **Persistence**: Survives browser sessions and device restarts

## 🌐 Browser Compatibility

- **Chrome/Edge**: Full support with WebAssembly and localStorage
- **Firefox**: Full support with WebAssembly optimizations
- **Safari**: Full support including iOS Safari
- **Mobile Browsers**: Touch controls with responsive design

## 🚀 Deployment

### Web Server Requirements

1. **Static File Serving**: Serve WASM, JS, and HTML files
2. **MIME Types**: Ensure `.wasm` files are served with `application/wasm`
3. **HTTPS**: Recommended for production (required for some browser features)

### Example Apache Configuration
```apache
<Files ~ "\.wasm$">
    Header set Content-Type application/wasm
</Files>
```

### Example Nginx Configuration
```nginx
location ~* \.wasm$ {
    add_header Content-Type application/wasm;
}
```

## 🔄 Development Workflow

1. **Design Habit Logic**: Modify habit creation and tracking in `main.swift`
2. **Enhance Gamification**: Add new achievement types and rewards
3. **Improve Calendar**: Add month view or advanced date navigation
4. **Add Analytics**: Implement detailed habit analytics and insights
5. **Test Streaks**: Verify streak calculation and persistence
6. **Validate Mobile**: Test touch interactions and responsive design

## 🐛 Troubleshooting

### Build Issues

**SwiftWasm not found**:
```bash
# Check installation
which swiftwasm

# Reinstall if needed
curl -sL https://github.com/swiftwasm/swiftwasm-install/releases/download/0.1.0/swiftwasm-install.sh | bash
```

**Compilation errors**:
- Verify Package.swift dependencies are accessible
- Check Swift version compatibility with SwiftWasm
- Ensure all JavaScriptKit imports are correct

### Runtime Issues

**Data not saving**:
- Check browser localStorage permissions
- Verify JSON serialization is working
- Inspect browser developer tools for storage errors

**Streaks not updating**:
- Check date string formatting consistency
- Verify completion date recording logic
- Test streak calculation algorithm

**Calendar not displaying**:
- Ensure DOM elements are created before calendar rendering
- Check date calculation functions
- Verify CSS grid layout support

## 📈 Performance

- **Load Time**: ~1-2 seconds for WASM compilation
- **Runtime Performance**: Real-time dashboard updates and streak calculations
- **Memory Usage**: ~20-30MB for habit data and UI state
- **Storage**: Efficient JSON serialization for habit persistence

## 🔮 Future Enhancements

- **Advanced Analytics**: Detailed habit insights and trend analysis
- **Social Features**: Habit sharing and community challenges
- **Reminder System**: Push notifications for habit reminders
- **Goal Setting**: Long-term habit goals with progress tracking
- **Data Export**: CSV/JSON export for habit data analysis
- **Themes**: Multiple visual themes and customization options
- **Achievements**: Badge system for habit milestones
- **Integration**: Calendar app integration and cross-device sync

## 🏆 Gamification Best Practices

### Habit Formation
- **Start Small**: Begin with achievable daily habits
- **Consistency Over Perfection**: Focus on daily completion rather than intensity
- **Stack Habits**: Attach new habits to existing routines
- **Track Progress**: Visual feedback reinforces positive behavior

### Streak Psychology
- **Momentum Building**: Streaks create positive reinforcement
- **Recovery Focus**: Restart quickly after breaking a streak
- **Celebration**: Acknowledge streak milestones
- **Realistic Goals**: Set achievable targets to maintain motivation

### Progress Visualization
- **Clear Metrics**: Easy-to-understand completion indicators
- **Color Coding**: Visual hierarchy for different habit states
- **Trend Analysis**: Historical data shows improvement over time
- **Positive Reinforcement**: Celebrate successes and progress

## 📚 Related Documentation

- [SwiftWasm Documentation](https://swiftwasm.org/)
- [JavaScriptKit Guide](https://github.com/swiftwasm/JavaScriptKit)
- [WebAssembly MDN](https://developer.mozilla.org/en-US/docs/WebAssembly)
- [SwiftWebAPI Reference](https://github.com/swiftwasm/SwiftWebAPI)
- [Habit Formation Research](https://jamesclear.com/atomic-habits)

## 🤝 Contributing

This web habit tracking application follows the same contribution guidelines as the main HabitQuest project. Focus areas for web-specific contributions:

- Gamification mechanics and user motivation
- Data visualization and progress tracking
- Mobile responsiveness and touch interactions
- Performance optimization for large habit datasets
- Accessibility features for habit tracking
- Cross-browser compatibility improvements

---

**Built with ❤️ using SwiftWasm - Making habit formation fun and effective on the web!**
