// Momentum Finance - Drag & Drop Support for macOS
// Copyright © 2025 Momentum Finance. All rights reserved.

import OSLog
import SwiftUI
import UniformTypeIdentifiers

#if os(macOS)
/// Implements drag and drop functionality for the macOS version of Momentum Finance
/// This enhances desktop productivity by allowing users to drag items between lists and views

// MARK: - Draggable Item Protocol

/// Protocol for items that can be dragged in the app
protocol DraggableFinanceItem: Identifiable, Codable {
    var dragItemType: FinanceDragItemType { get }
    var dragItemTitle: String { get }
    var dragItemIconName: String { get }
}

// MARK: - Drag Item Types

/// Types of items that can be dragged in the app
enum FinanceDragItemType: String, Codable {
    case account
    case transaction
    case budget
    case subscription
    case goal

    var uniformType: UTType {
        switch self {
        case .account:
            UTType("com.momentumfinance.account")!
        case .transaction:
            UTType("com.momentumfinance.transaction")!
        case .budget:
            UTType("com.momentumfinance.budget")!
        case .subscription:
            UTType("com.momentumfinance.subscription")!
        case .goal:
            UTType("com.momentumfinance.goal")!
        }
    }
}

// MARK: - Model Extensions

extension FinancialAccount: DraggableFinanceItem {
    var dragItemType: FinanceDragItemType { .account }
    var dragItemTitle: String { name }
    var dragItemIconName: String { type == .checking ? "banknote" : "creditcard" }
}

extension FinancialTransaction: DraggableFinanceItem {
    var dragItemType: FinanceDragItemType { .transaction }
    var dragItemTitle: String { name }
    var dragItemIconName: String { amount < 0 ? "arrow.down" : "arrow.up" }
}

extension Budget: DraggableFinanceItem {
    var dragItemType: FinanceDragItemType { .budget }
    var dragItemTitle: String { name }
    var dragItemIconName: String { "chart.pie" }
}

extension Subscription: DraggableFinanceItem {
    var dragItemType: FinanceDragItemType { .subscription }
    var dragItemTitle: String { name }
    var dragItemIconName: String { "calendar.badge.clock" }
}

extension SavingsGoal: DraggableFinanceItem {
    var dragItemType: FinanceDragItemType { .goal }
    var dragItemTitle: String { name }
    var dragItemIconName: String { "target" }
}

// MARK: - Drag & Drop Support Extensions for Models

// Extension for FinancialAccount
extension FinancialAccount {
    /// Custom NSItemProvider representation
    /// <#Description#>
    /// - Returns: <#description#>
    func asItemProvider() -> NSItemProvider {
        let provider = NSItemProvider()

        // Add representation for dragItemType
        provider.registerDataRepresentation(forTypeIdentifier: self.dragItemType.uniformType.identifier, visibility: .all) { completion in
            do {
                let encoder = JSONEncoder()
                let data = try encoder.encode(self)
                completion(data, nil)
                return nil
            } catch {
                completion(nil, error)
                return nil
            }
        }

        // Add plain text representation
        provider.registerDataRepresentation(forTypeIdentifier: UTType.plainText.identifier, visibility: .all) { completion in
            let text = "Account: \(self.name) - \(self.balance) \(self.currencyCode)"
            completion(text.data(using: .utf8), nil)
            return nil
        }

        return provider
    }
}

// Extension for FinancialTransaction
extension FinancialTransaction {
    /// Custom NSItemProvider representation
    /// <#Description#>
    /// - Returns: <#description#>
    func asItemProvider() -> NSItemProvider {
        let provider = NSItemProvider()

        // Add representation for dragItemType
        provider.registerDataRepresentation(forTypeIdentifier: self.dragItemType.uniformType.identifier, visibility: .all) { completion in
            do {
                let encoder = JSONEncoder()
                let data = try encoder.encode(self)
                completion(data, nil)
                return nil
            } catch {
                completion(nil, error)
                return nil
            }
        }

        // Add plain text representation
        provider.registerDataRepresentation(forTypeIdentifier: UTType.plainText.identifier, visibility: .all) { completion in
            let text = "Transaction: \(self.name) - \(self.amount) \(self.date.formatted(date: .abbreviated, time: .shortened))"
            completion(text.data(using: .utf8), nil)
            return nil
        }

        return provider
    }
}

// Similar implementations for other model types...

// MARK: - UTType Extensions

extension UTType {
    static var financeAccount: UTType { UTType("com.momentumfinance.account")! }
    static var financeTransaction: UTType { UTType("com.momentumfinance.transaction")! }
    static var financeBudget: UTType { UTType("com.momentumfinance.budget")! }
    static var financeSubscription: UTType { UTType("com.momentumfinance.subscription")! }
    static var financeGoal: UTType { UTType("com.momentumfinance.goal")! }
}

// MARK: - Drag Preview Providers

struct FinanceItemDragPreview<Content: View>: View {
    let content: Content
    let title: String
    let iconName: String

    init(title: String, iconName: String, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.title = title
        self.iconName = iconName
    }

    var body: some View {
        VStack {
            HStack(spacing: 8) {
                Image(systemName: self.iconName)
                    .font(.system(size: 18))

                Text(self.title)
                    .font(.headline)
            }
            .padding(10)
            .background(Color(.windowBackgroundColor).opacity(0.9))
            .cornerRadius(8)
            .shadow(radius: 3)

            self.content
                .frame(maxWidth: 320, maxHeight: 200)
                .cornerRadius(8)
                .shadow(radius: 5)
        }
        .padding(10)
    }
}

// MARK: - Draggable/Droppable ViewModifiers

/// View modifier for making a view draggable with a finance item
struct DraggableFinanceItemModifier<Item: DraggableFinanceItem>: ViewModifier {
    let item: Item
    let onDragStarted: (() -> Void)?
    let onDragEnded: ((Bool) -> Void)?

    init(item: Item, onDragStarted: (() -> Void)? = nil, onDragEnded: ((Bool) -> Void)? = nil) {
        self.item = item
        self.onDragStarted = onDragStarted
        self.onDragEnded = onDragEnded
    }

    /// <#Description#>
    /// - Returns: <#description#>
    func body(content: Content) -> some View {
        content
            .onDrag {
                self.onDragStarted?()
                return self.item.asItemProvider()
            } preview: {
                FinanceItemDragPreview(title: self.item.dragItemTitle, iconName: self.item.dragItemIconName) {
                    content
                }
            }
            .onDrop(
                of: [
                    UTType.financeAccount,
                    UTType.financeTransaction,
                    UTType.financeBudget,
                    UTType.financeSubscription,
                    UTType.financeGoal,
                ],
                isTargeted: nil
            ) { _, _ in
                false // This modifier only handles drag, not drop
            }
    }
}

/// View modifier for making a view accept drops of finance items
struct DroppableFinanceItemModifier<T: DraggableFinanceItem>: ViewModifier {
    let acceptedTypes: [FinanceDragItemType]
    let isTargeted: Binding<Bool>?
    let onDrop: ([T], CGPoint) -> Bool

    @State private var isDraggingOverInternal = false
    private let logger = Logger(subsystem: "com.momentum.finance", category: "DragAndDrop")

    private var isDraggingOver: Binding<Bool> {
        self.isTargeted ?? Binding<Bool>(
            get: { self.isDraggingOverInternal },
            set: { self.isDraggingOverInternal = $0 },
        )
    }

    init(acceptedTypes: [FinanceDragItemType], isTargeted: Binding<Bool>? = nil, onDrop: @escaping ([T], CGPoint) -> Bool) {
        self.acceptedTypes = acceptedTypes
        self.isTargeted = isTargeted
        self.onDrop = onDrop
    }

    /// <#Description#>
    /// - Returns: <#description#>
    func body(content: Content) -> some View {
        content
            .onDrop(of: self.acceptedTypes.map(\.uniformType), isTargeted: self.isDraggingOver) { providers, location in
                Task {
                    var droppedItems: [T] = []

                    for provider in providers {
                        for type in self.acceptedTypes where provider.hasItemConformingToTypeIdentifier(type.uniformType.identifier) {
                            do {
                                let data = try await provider.loadDataRepresentation(forTypeIdentifier: type.uniformType.identifier)
                                let decoder = JSONDecoder()
                                let item = try decoder.decode(T.self, from: data)
                                droppedItems.append(item)
                            } catch {
                                self.logger.error("Error decoding dropped item: \(error)")
                            }
                        }
                    }

                    if !droppedItems.isEmpty {
                        return self.onDrop(droppedItems, location)
                    }

                    return false
                }

                return true
            }
            .onChange(of: self.isDraggingOver.wrappedValue) { _, _ in
                // Apply visual state changes when drag enters/exits
                withAnimation(.easeInOut(duration: 0.2)) {
                    // Visual feedback can be applied in the calling code using the isTargeted binding
                }
            }
    }
}

// MARK: - View Extensions

extension View {
    /// Make a view draggable with a finance item
    func draggable(
        item: some DraggableFinanceItem,
        onDragStarted: (() -> Void)? = nil,
        onDragEnded: ((Bool) -> Void)? = nil
    ) -> some View {
        modifier(DraggableFinanceItemModifier(item: item, onDragStarted: onDragStarted, onDragEnded: onDragEnded))
    }

    /// Make a view accept drops of finance items
    func droppable<T: DraggableFinanceItem>(
        acceptedTypes: [FinanceDragItemType],
        isTargeted: Binding<Bool>? = nil,
        onDrop: @escaping ([T], CGPoint) -> Bool
    ) -> some View {
        modifier(DroppableFinanceItemModifier(acceptedTypes: acceptedTypes, isTargeted: isTargeted, onDrop: onDrop))
    }
}

// MARK: - Example Usage for Transaction Item

struct TransactionItemView: View {
    let transaction: FinancialTransaction
    @State private var isTargeted = false
    private let logger = Logger(subsystem: "com.momentum.finance", category: "TransactionItemView")

    var body: some View {
        HStack {
            Image(systemName: self.transaction.amount < 0 ? "arrow.down" : "arrow.up")
                .foregroundStyle(self.transaction.amount < 0 ? .red : .green)

            VStack(alignment: .leading) {
                Text(self.transaction.name)
                    .font(.headline)

                Text(self.transaction.amount.formatted(.currency(code: "USD")))
                    .font(.subheadline)
            }

            Spacer()

            Text(self.transaction.date.formatted(date: .abbreviated, time: .omitted))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(self.isTargeted ? Color.accentColor.opacity(0.1) : Color.clear)
        .cornerRadius(8)
        .draggable(item: self.transaction)
        .droppable(acceptedTypes: [.budget, .account], isTargeted: self.$isTargeted) { (items: [Budget], _) in
            if let budget = items.first {
                // Associate transaction with this budget
                self.logger.info("Transaction \(self.transaction.name) associated with budget \(budget.name)")
                return true
            }
            return false
        }
    }
}

// MARK: - Handling Drag and Drop in List Views

extension Features.Budgets {
    struct EnhancedBudgetDetailView: View {
        let budgetId: String

        @Query private var budgets: [Budget]
        @Query private var transactions: [FinancialTransaction]
        @State private var isEditing = false
        @State private var isDraggingOver = false
        @State private var associatedTransactionIds: [String] = []

        var budget: Budget? {
            self.budgets.first(where: { $0.id == self.budgetId })
        }

        var associatedTransactions: [FinancialTransaction] {
            self.transactions.filter { self.associatedTransactionIds.contains($0.id) }
        }

        var body: some View {
            VStack(spacing: 0) {
                // Budget details section similar to original implementation
                // ...

                // Enhanced drag-and-drop transaction section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Associated Transactions")
                        .font(.headline)

                    if self.associatedTransactions.isEmpty {
                        VStack {
                            Text("Drag transactions here to associate them with this budget")
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .padding()
                        }
                        .frame(minHeight: 150)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [5]))
                                .foregroundColor(self.isDraggingOver ? .accentColor : .secondary)
                                .animation(.easeInOut, value: self.isDraggingOver),
                        )
                        .contentShape(Rectangle())
                        .droppable(acceptedTypes: [.transaction], isTargeted: self.$isDraggingOver) { (items: [FinancialTransaction], _) in
                            for transaction in items {
                                if !self.associatedTransactionIds.contains(transaction.id) {
                                    self.associatedTransactionIds.append(transaction.id)
                                }
                            }
                            return true
                        }
                    } else {
                        List {
                            ForEach(self.associatedTransactions) { transaction in
                                TransactionItemView(transaction: transaction)
                                    .contextMenu {
                                        Button("Remove from Budget", role: .destructive).accessibilityLabel("Button")
                                            .accessibilityLabel("Button") {
                                                self.removeTransaction(transaction)
                                            }
                                    }
                            }
                            .onDelete(perform: self.deleteTransactions)
                        }
                        .frame(minHeight: 200)
                        .droppable(acceptedTypes: [.transaction], isTargeted: self.$isDraggingOver) { (items: [FinancialTransaction], _) in
                            for transaction in items {
                                if !self.associatedTransactionIds.contains(transaction.id) {
                                    self.associatedTransactionIds.append(transaction.id)
                                }
                            }
                            return true
                        }
                    }
                }
                .padding()
                .background(Color(.windowBackgroundColor).opacity(0.3))
                .cornerRadius(8)
            }
            .padding()
            .onAppear {
                if let budget {
                    // Load associated transactions from the budget
                    // This would be implemented based on your data model
                }
            }
        }

        private func removeTransaction(_ transaction: FinancialTransaction) {
            self.associatedTransactionIds.removeAll { $0 == transaction.id }
        }

        private func deleteTransactions(at offsets: IndexSet) {
            let idsToRemove = offsets.map { self.associatedTransactions[$0].id }
            self.associatedTransactionIds.removeAll { idsToRemove.contains($0) }
        }
    }
}
#endif
