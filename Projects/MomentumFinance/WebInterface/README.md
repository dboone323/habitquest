# Momentum Finance Web - SwiftWasm Deployment

A web-based version of the Momentum Finance application built with SwiftWasm, featuring comprehensive personal finance management with transaction tracking, budget monitoring, and financial analytics.

## 💰 Finance Features

- **Transaction Management**: Add, track, and categorize income and expenses
- **Budget Monitoring**: Set spending limits and track progress by category
- **Financial Dashboard**: Real-time overview of income, expenses, and net balance
- **Spending Analytics**: Visual charts showing spending patterns by category
- **Data Persistence**: Local storage for transaction data
- **Responsive Design**: Works on desktop and mobile devices

## 📊 Dashboard Overview

### Key Metrics
- **Total Income**: Sum of all income transactions
- **Total Expenses**: Sum of all expense transactions
- **Net Balance**: Income minus expenses

### Transaction Tracking
- **Categories**: Food, Transportation, Entertainment, Utilities, Healthcare, Income
- **Transaction Types**: Income and Expense classification
- **Date Tracking**: Automatic timestamp for all transactions
- **Recent History**: Display of 10 most recent transactions

### Budget Management
- **Category Limits**: Configurable spending limits per category
- **Progress Tracking**: Visual progress bars showing spending vs. budget
- **Status Indicators**: Color-coded warnings for approaching/over budget
- **Default Budgets**: Pre-configured limits for common categories

## 🛠️ Technology Stack

- **SwiftWasm**: Compiles Swift finance logic to WebAssembly
- **JavaScriptKit**: DOM manipulation and browser API access
- **SwiftWebAPI**: Web-specific Swift APIs for local storage
- **HTML5 Canvas**: Data visualization and charts
- **Local Storage**: Client-side data persistence

## 📁 Project Structure

```
MomentumFinance/WebInterface/
├── Package.swift              # SwiftWasm package configuration
├── Sources/
│   └── MomentumFinanceWeb/
│       └── main.swift        # Finance dashboard logic and UI
├── index.html                # Finance web interface and styling
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
   cd Projects/MomentumFinance/WebInterface
   ```

2. **Run the build script**:
   ```bash
   ./build.sh
   ```

   This will:
   - Compile Swift finance code to WebAssembly
   - Generate JavaScript wrapper with finance-specific APIs
   - Create deployment-ready files

3. **Start a local web server**:
   ```bash
   python3 -m http.server 8000
   ```

4. **Open in browser**:
   ```
   http://localhost:8000
   ```

## 🎨 Finance Dashboard Features

### Core Systems

- **Transaction Processing**: Real-time addition and categorization of financial transactions
- **Budget Calculation**: Dynamic budget tracking with percentage-based progress indicators
- **Data Visualization**: HTML5 Canvas-based charts for spending analysis
- **Local Persistence**: Browser localStorage integration for data retention
- **Responsive UI**: Adaptive layout for desktop and mobile viewing

### Web-Specific Adaptations

- **Form Validation**: Client-side validation for transaction data
- **Dynamic Updates**: Real-time dashboard updates without page refresh
- **Touch Support**: Mobile-friendly input handling
- **Progressive Enhancement**: Graceful degradation for older browsers

## 🔧 Configuration

### Package.swift
```swift
let package = Package(
    name: "MomentumFinanceWeb",
    platforms: [.macOS(.v12)],
    dependencies: [
        .package(url: "https://github.com/swiftwasm/JavaScriptKit", from: "0.15.0"),
        .package(url: "https://github.com/swiftwasm/SwiftWebAPI", from: "0.2.0")
    ],
    targets: [
        .executableTarget(
            name: "MomentumFinanceWeb",
            dependencies: ["JavaScriptKit", "SwiftWebAPI"]
        )
    ]
)
```

### Default Budget Categories

The application includes pre-configured budget limits:

- **Food & Dining**: $500/month
- **Transportation**: $300/month
- **Entertainment**: $200/month
- **Utilities**: $150/month
- **Healthcare**: $100/month

### Data Storage

Transactions are stored locally in the browser using localStorage with JSON serialization. This provides:

- **Persistence**: Data survives browser sessions
- **Privacy**: No server-side data storage required
- **Performance**: Fast local access to transaction data

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

1. **Add Transaction Logic**: Modify transaction processing in `main.swift`
2. **Update Budget Categories**: Customize default budget limits and categories
3. **Enhance Charts**: Improve data visualization with additional chart types
4. **Add Features**: Implement savings goals, recurring transactions, or expense reports
5. **Test Locally**: Run build script and test in browser
6. **Validate Data**: Check localStorage persistence and data integrity

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
- Verify Package.swift dependencies are correct
- Check Swift version compatibility
- Ensure all imports are properly declared

### Runtime Issues

**Data not persisting**:
- Check browser localStorage support
- Verify JSON serialization is working
- Check browser console for storage errors

**Charts not rendering**:
- Ensure Canvas element exists in DOM
- Check Canvas context initialization
- Verify chart data calculations

**Form submission failing**:
- Check form validation requirements
- Verify event listeners are attached
- Check browser console for JavaScript errors

## 📈 Performance

- **Load Time**: ~1-2 seconds for WASM compilation
- **Runtime Performance**: Real-time dashboard updates
- **Memory Usage**: ~15-25MB for transaction data and UI
- **Storage**: Efficient JSON serialization for data persistence

## 🔮 Future Enhancements

- **Advanced Analytics**: Trend analysis and financial forecasting
- **Export Features**: CSV/PDF export for transaction data
- **Multi-Currency**: Support for multiple currencies and exchange rates
- **Recurring Transactions**: Automated recurring income/expense setup
- **Savings Goals**: Track progress toward financial goals
- **Bank Integration**: Connect with financial institutions for automatic transaction import
- **Reports**: Generate monthly/quarterly financial reports
- **Budget Alerts**: Email/SMS notifications for budget limits

## 💡 Finance Best Practices

### Budget Management
- **50/30/20 Rule**: 50% needs, 30% wants, 20% savings
- **Zero-Based Budgeting**: Every dollar has a job
- **Envelope System**: Allocate specific amounts to categories

### Transaction Categories
- **Track Everything**: Record all income and expenses
- **Consistent Categorization**: Use the same categories consistently
- **Regular Review**: Review transactions weekly/monthly

### Financial Goals
- **SMART Goals**: Specific, Measurable, Achievable, Relevant, Time-bound
- **Emergency Fund**: 3-6 months of expenses
- **Debt Reduction**: Focus on high-interest debt first

## 📚 Related Documentation

- [SwiftWasm Documentation](https://swiftwasm.org/)
- [JavaScriptKit Guide](https://github.com/swiftwasm/JavaScriptKit)
- [HTML5 Canvas API](https://developer.mozilla.org/en-US/docs/Web/API/Canvas_API)
- [SwiftWebAPI Reference](https://github.com/swiftwasm/SwiftWebAPI)
- [Personal Finance Best Practices](https://www.investopedia.com/best-personal-finance-apps-5070484)

## 🤝 Contributing

This web finance application follows the same contribution guidelines as the main MomentumFinance project. Focus areas for web-specific contributions:

- Financial calculation algorithms and accuracy
- Data visualization and chart improvements
- Budget management features and automation
- Mobile responsiveness and touch interactions
- Performance optimizations for large transaction datasets
- Export/import functionality for financial data

---

**Built with ❤️ using SwiftWasm - Bringing Swift finance management to the web!**
