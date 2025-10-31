# PlannerApp Web - SwiftWasm Deployment

A web-based version of PlannerApp built with SwiftWasm, enabling cross-platform task management directly in the browser.

## 🚀 Features

- **Dashboard View**: Overview of tasks, statistics, and recent activities
- **Task Management**: View, organize, and track tasks with priority levels
- **Calendar Integration**: Upcoming deadlines and schedule visualization
- **Settings**: App preferences and configuration
- **Responsive Design**: Works on desktop and mobile browsers
- **Cross-Platform**: Runs on Windows, macOS, Linux, and mobile devices

## 🛠️ Technology Stack

- **SwiftWasm**: Compiles Swift code to WebAssembly
- **JavaScriptKit**: DOM manipulation and browser API access
- **SwiftWebAPI**: Web-specific Swift APIs
- **WebAssembly**: High-performance execution in browsers

## 📁 Project Structure

```
PlannerApp/WebInterface/
├── Package.swift              # SwiftWasm package configuration
├── Sources/
│   └── PlannerAppWeb/
│       └── main.swift        # Main web application logic
├── index.html                # Web interface and styling
├── build.sh                  # Build script for compilation
└── README.md                 # This documentation
```

## 🏗️ Building and Running

### Prerequisites

1. **SwiftWasm Toolchain**: Install the SwiftWasm compiler
   ```bash
   curl -sL https://github.com/swiftwasm/swiftwasm-install/releases/download/0.1.0/swiftwasm-install.sh | bash
   ```

2. **Web Server**: For local testing (Python's built-in server works)

### Build Process

1. **Navigate to the web interface directory**:
   ```bash
   cd Projects/PlannerApp/WebInterface
   ```

2. **Run the build script**:
   ```bash
   ./build.sh
   ```

   This will:
   - Compile Swift code to WebAssembly
   - Generate JavaScript wrapper
   - Create deployment-ready files

3. **Start a local web server**:
   ```bash
   python3 -m http.server 8000
   ```

4. **Open in browser**:
   ```
   http://localhost:8000
   ```

## 🎨 User Interface

### Dashboard
- **Statistics Cards**: Total tasks, completed, in-progress, high priority
- **Recent Tasks**: Quick overview of latest activities

### Tasks View
- **Task List**: All tasks with status, priority, and due dates
- **Add Task**: Button to create new tasks (UI ready, functionality expandable)

### Calendar View
- **Upcoming Deadlines**: List of pending tasks with due dates
- **Future Enhancement**: Full calendar integration planned

### Settings
- **Theme Selection**: Light, dark, or auto themes
- **Notifications**: Toggle notification preferences
- **About**: App information and version details

## 🔧 Configuration

### Package.swift
```swift
let package = Package(
    name: "PlannerAppWeb",
    platforms: [.macOS(.v12)],
    dependencies: [
        .package(url: "https://github.com/swiftwasm/JavaScriptKit", from: "0.15.0"),
        .package(url: "https://github.com/swiftwasm/SwiftWebAPI", from: "0.2.0")
    ],
    targets: [
        .executableTarget(
            name: "PlannerAppWeb",
            dependencies: ["JavaScriptKit", "SwiftWebAPI"]
        )
    ]
)
```

### Build Customization

The `build.sh` script can be modified for:
- Different build configurations (`debug` vs `release`)
- Additional compiler flags
- Custom output directories
- Integration with CI/CD pipelines

## 🌐 Browser Compatibility

- **Chrome/Edge**: Full support (Chromium-based)
- **Firefox**: Full support
- **Safari**: Full support (including iOS)
- **Mobile Browsers**: Responsive design tested on iOS Safari and Chrome Mobile

## 🚀 Deployment

### Web Server Requirements

1. **Static File Serving**: Serve WASM, JS, and HTML files
2. **MIME Types**: Ensure `.wasm` files are served with `application/wasm`
3. **HTTPS**: Recommended for production deployments

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

1. **Modify Swift Code**: Edit `Sources/PlannerAppWeb/main.swift`
2. **Rebuild**: Run `./build.sh`
3. **Test**: Refresh browser or restart local server
4. **Debug**: Use browser developer tools for JavaScript console

## 🐛 Troubleshooting

### Build Issues

**SwiftWasm not found**:
```bash
# Install SwiftWasm toolchain
curl -sL https://github.com/swiftwasm/swiftwasm-install/releases/download/0.1.0/swiftwasm-install.sh | bash
```

**Compilation errors**:
- Check Swift version compatibility
- Ensure all dependencies are properly imported
- Verify Package.swift configuration

### Runtime Issues

**WASM won't load**:
- Check browser console for errors
- Ensure all files are served with correct MIME types
- Verify WebAssembly support in browser

**UI not responsive**:
- Check CSS media queries
- Test on different screen sizes
- Verify viewport meta tag in HTML

## 📈 Performance

- **Initial Load**: ~2-3 seconds for WASM compilation
- **Subsequent Loads**: Cached for instant startup
- **Memory Usage**: ~50-100MB depending on task data
- **Execution Speed**: Near-native performance via WebAssembly

## 🔮 Future Enhancements

- **Task Creation**: Full add/edit task functionality
- **Data Persistence**: Local storage or cloud sync
- **Calendar Integration**: Full calendar UI with drag-and-drop
- **Collaboration**: Multi-user task sharing
- **Notifications**: Browser notification API integration
- **PWA Features**: Offline support and app-like experience

## 📚 Related Documentation

- [SwiftWasm Documentation](https://swiftwasm.org/)
- [JavaScriptKit Guide](https://github.com/swiftwasm/JavaScriptKit)
- [SwiftWebAPI Reference](https://github.com/swiftwasm/SwiftWebAPI)
- [WebAssembly MDN](https://developer.mozilla.org/en-US/docs/WebAssembly)

## 🤝 Contributing

This web deployment follows the same contribution guidelines as the main PlannerApp project. Focus areas for web-specific contributions:

- UI/UX improvements for web browsers
- Performance optimizations
- Additional browser API integrations
- Mobile responsiveness enhancements

---

**Built with ❤️ using SwiftWasm**
