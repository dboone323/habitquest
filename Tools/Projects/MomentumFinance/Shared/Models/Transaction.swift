// Momentum Finance - Personal Finance App
// Copyright © 2025 Momentum Finance. All rights reserved.
// #-hidden-code
import CoreData
import SwiftUI

struct Transaction: Identifiable, Codable {
    var id: UUID
    var amount: Double
    var date: Date
    var category: String
    var note: String?
    var type: TransactionType

    enum TransactionType: String, Codable {
        case income
        case expense
    }
}

// #-end-hidden-code
