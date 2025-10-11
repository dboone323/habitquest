// Momentum Finance - Enhanced Account Detail Extensions for macOS
// Copyright © 2025 Momentum Finance. All rights reserved.

import Foundation

#if os(macOS)

// MARK: - Extensions for Enhanced Account Detail View

// Extension to add ordinal suffix to numbers
extension Int {
    var ordinal: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .ordinal
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}
#endif
