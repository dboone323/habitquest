//
//  InAppPurchaseManager.swift
//  AvoidObstaclesGame
//
//  Created by Daniel Stevens on 2025
//
//  Manages in-app purchases including consumable items, non-consumable features,
//  and subscription services for premium game content.
//

import SpriteKit
import StoreKit

@MainActor
final class InAppPurchaseManager: NSObject, ObservableObject, Sendable {
    // MARK: - Singleton

    static let shared = InAppPurchaseManager()

    // MARK: - Published Properties

    @Published private(set) var isLoading = false
    @Published private(set) var products: [Product] = []
    @Published private(set) var purchasedProductIDs = Set<String>()
    @Published private(set) var subscriptionStatus: SubscriptionStatus = .notSubscribed

    // MARK: - Private Properties

    private var productIDs: Set<String> = [
        // Consumable Items
        "com.avoidobstacles.extra_lives",
        "com.avoidobstacles.power_up_pack",
        "com.avoidobstacles.coin_pack_small",
        "com.avoidobstacles.coin_pack_medium",
        "com.avoidobstacles.coin_pack_large",

        // Non-Consumable Items
        "com.avoidobstacles.premium_skins",
        "com.avoidobstacles.ad_removal",
        "com.avoidobstacles.unlimited_power_ups",

        // Subscriptions
        "com.avoidobstacles.premium_monthly",
        "com.avoidobstacles.premium_yearly",
        "com.avoidobstacles.vip_monthly",
    ]

    private var updateListenerTask: Task<Void, Never>?

    // MARK: - Enums

    enum PurchaseError: LocalizedError {
        case productNotFound
        case purchaseFailed
        case restoreFailed
        case userCancelled
        case networkError
        case verificationFailed

        var errorDescription: String? {
            switch self {
            case .productNotFound: return "Product not found"
            case .purchaseFailed: return "Purchase failed"
            case .restoreFailed: return "Restore failed"
            case .userCancelled: return "Purchase cancelled"
            case .networkError: return "Network error"
            case .verificationFailed: return "Purchase verification failed"
            }
        }
    }

    enum SubscriptionStatus {
        case notSubscribed
        case subscribed(productID: String, expiryDate: Date)
        case expired
    }

    enum ProductType {
        case consumable
        case nonConsumable
        case subscription
    }

    // MARK: - Initialization

    override private init() {
        super.init()
        setupTransactionListener()
        Task {
            await loadProducts()
            await checkPurchasedProducts()
        }
    }

    deinit {
        updateListenerTask?.cancel()
    }

    // MARK: - Public Methods

    /// Load available products from App Store
    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let storeProducts = try await Product.products(for: productIDs)
            await MainActor.run {
                self.products = storeProducts.sorted { $0.price < $1.price }
            }
        } catch {
            print("Failed to load products: \(error)")
        }
    }

    /// Purchase a product
    func purchase(_ product: Product) async throws {
        guard let result = try? await product.purchase() else {
            throw PurchaseError.purchaseFailed
        }

        switch result {
        case let .success(verification):
            let transaction = try checkVerified(verification)
            await updatePurchasedProducts()
            await transaction.finish()

        case .userCancelled:
            throw PurchaseError.userCancelled

        case .pending:
            // Transaction is pending, handle in transaction listener
            break

        @unknown default:
            throw PurchaseError.purchaseFailed
        }
    }

    /// Restore previous purchases
    func restorePurchases() async throws {
        try await AppStore.sync()
        await updatePurchasedProducts()
    }

    /// Check if product is purchased
    func isProductPurchased(_ productID: String) -> Bool {
        purchasedProductIDs.contains(productID)
    }

    /// Check if user has active subscription
    func hasActiveSubscription() -> Bool {
        switch subscriptionStatus {
        case .subscribed: return true
        case .notSubscribed, .expired: return false
        }
    }

    /// Get product by ID
    func product(for productID: String) -> Product? {
        products.first { $0.id == productID }
    }

    /// Get products by type
    func products(ofType type: ProductType) -> [Product] {
        products.filter { product in
            switch type {
            case .consumable:
                return product.type == .consumable
            case .nonConsumable:
                return product.type == .nonConsumable
            case .subscription:
                return product.type == .autoRenewable
            }
        }
    }

    // MARK: - Private Methods

    private func setupTransactionListener() {
        updateListenerTask = Task {
            for await result in Transaction.updates {
                do {
                    let transaction = try checkVerified(result)
                    await updatePurchasedProducts()
                    await transaction.finish()
                } catch {
                    print("Transaction verification failed: \(error)")
                }
            }
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case let .unverified(_, error):
            throw error
        case let .verified(safe):
            return safe
        }
    }

    private func updatePurchasedProducts() async {
        var purchasedIDs = Set<String>()
        var latestSubscription: (productID: String, expiryDate: Date)?

        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)

                if transaction.revocationDate == nil {
                    purchasedIDs.insert(transaction.productID)

                    // Check for subscriptions
                    if let expirationDate = transaction.expirationDate,
                       transaction.productType == .autoRenewable
                    {
                        if let currentLatest = latestSubscription?.expiryDate {
                            if expirationDate > currentLatest {
                                latestSubscription = (transaction.productID, expirationDate)
                            }
                        } else {
                            latestSubscription = (transaction.productID, expirationDate)
                        }
                    }
                }
            } catch {
                print("Failed to verify transaction: \(error)")
            }
        }

        await MainActor.run {
            self.purchasedProductIDs = purchasedIDs

            if let subscription = latestSubscription {
                if subscription.expiryDate > Date() {
                    self.subscriptionStatus = .subscribed(
                        productID: subscription.productID,
                        expiryDate: subscription.expiryDate
                    )
                } else {
                    self.subscriptionStatus = .expired
                }
            } else {
                self.subscriptionStatus = .notSubscribed
            }
        }
    }

    private func checkPurchasedProducts() async {
        await updatePurchasedProducts()
    }
}

// MARK: - Product Extensions

extension Product {
    var localizedPrice: String {
        price.formatted()
    }
}

// MARK: - Purchase UI Components

@MainActor
class PurchaseButton: SKNode {
    private let background: SKShapeNode
    private let label: SKLabelNode
    private let size: CGSize
    var onTap: (() -> Void)?

    init(title: String, size: CGSize) {
        self.size = size

        // Background with rounded corners
        self.background = SKShapeNode(rectOf: size, cornerRadius: 8)
        self.background.fillColor = SKColor.systemBlue
        self.background.strokeColor = SKColor.white
        self.background.lineWidth = 1

        // Label
        self.label = SKLabelNode(fontNamed: "SFProDisplay-Bold")
        self.label.text = title
        self.label.fontSize = 16
        self.label.fontColor = .white
        self.label.verticalAlignmentMode = .center

        super.init()

        self.addChild(background)
        self.addChild(label)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setTitle(_ title: String) {
        self.label.text = title
    }

    func simulateTap() {
        // Visual feedback
        self.background.run(SKAction.scale(to: 0.95, duration: 0.1))
        self.background.fillColor = SKColor.systemBlue.withAlphaComponent(0.8)

        // Execute action after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.background.run(SKAction.scale(to: 1.0, duration: 0.1))
            self?.background.fillColor = SKColor.systemBlue
            self?.onTap?()
        }
    }
}

@MainActor
class PurchaseUI {
    private weak var scene: SKScene?

    init(scene: SKScene) {
        self.scene = scene
    }

    func showPurchaseDialog(for product: Product) {
        // Create purchase dialog using SpriteKit
        let dialog = createPurchaseDialog(for: product)
        scene?.addChild(dialog)
    }

    func showStore() {
        // Show full store interface
        let storeView = createStoreView()
        scene?.addChild(storeView)
    }

    private func createPurchaseDialog(for product: Product) -> SKNode {
        let dialog = SKNode()

        // Background
        let background = SKShapeNode(rectOf: CGSize(width: 300, height: 200))
        background.fillColor = .black.withAlphaComponent(0.8)
        background.strokeColor = .white
        dialog.addChild(background)

        // Product title
        let titleLabel = SKLabelNode(text: product.displayName)
        titleLabel.fontSize = 18
        titleLabel.fontColor = .white
        titleLabel.position = CGPoint(x: 0, y: 60)
        dialog.addChild(titleLabel)

        // Price
        let priceLabel = SKLabelNode(text: product.localizedPrice)
        priceLabel.fontSize = 24
        priceLabel.fontColor = .yellow
        priceLabel.position = CGPoint(x: 0, y: 20)
        dialog.addChild(priceLabel)

        // Purchase button
        let purchaseButton = PurchaseButton(title: "Purchase", size: CGSize(width: 120, height: 40))
        purchaseButton.position = CGPoint(x: 0, y: -40)
        purchaseButton.onTap = { [weak self] in
            Task {
                do {
                    try await InAppPurchaseManager.shared.purchase(product)
                    self?.showSuccessMessage()
                } catch {
                    self?.showErrorMessage(error.localizedDescription)
                }
            }
        }
        dialog.addChild(purchaseButton)

        return dialog
    }

    private func createStoreView() -> SKNode {
        let storeView = SKNode()

        // Store background
        let background = SKShapeNode(rectOf: CGSize(width: 350, height: 500))
        background.fillColor = .black.withAlphaComponent(0.9)
        background.strokeColor = .white
        storeView.addChild(background)

        // Title
        let titleLabel = SKLabelNode(text: "Premium Store")
        titleLabel.fontSize = 24
        titleLabel.fontColor = .white
        titleLabel.position = CGPoint(x: 0, y: 220)
        storeView.addChild(titleLabel)

        // Product list
        let products = InAppPurchaseManager.shared.products
        for (index, product) in products.enumerated() {
            let productButton = createProductButton(for: product, at: index)
            storeView.addChild(productButton)
        }

        // Restore purchases button
        let restoreButton = PurchaseButton(title: "Restore Purchases", size: CGSize(width: 150, height: 35))
        restoreButton.position = CGPoint(x: 0, y: -200)
        restoreButton.onTap = {
            Task {
                do {
                    try await InAppPurchaseManager.shared.restorePurchases()
                    // Show success message
                } catch {
                    // Show error message
                }
            }
        }
        storeView.addChild(restoreButton)

        return storeView
    }

    private func createProductButton(for product: Product, at index: Int) -> SKNode {
        let button = PurchaseButton(title: product.displayName, size: CGSize(width: 300, height: 60))
        button.position = CGPoint(x: 0, y: 150 - (index * 70))

        let priceLabel = SKLabelNode(text: product.localizedPrice)
        priceLabel.fontSize = 18
        priceLabel.fontColor = .yellow
        priceLabel.position = CGPoint(x: 80, y: 0)
        button.addChild(priceLabel)

        button.onTap = { [weak self] in
            self?.showPurchaseDialog(for: product)
        }

        return button
    }

    private func showSuccessMessage() {
        let message = SKLabelNode(text: "Purchase Successful!")
        message.fontSize = 20
        message.fontColor = .green
        message.position = CGPoint(x: 0, y: 100)
        scene?.addChild(message)

        // Remove after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            message.removeFromParent()
        }
    }

    private func showErrorMessage(_ message: String) {
        let errorLabel = SKLabelNode(text: message)
        errorLabel.fontSize = 16
        errorLabel.fontColor = .red
        errorLabel.position = CGPoint(x: 0, y: 80)
        scene?.addChild(errorLabel)

        // Remove after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            errorLabel.removeFromParent()
        }
    }
}
