import Foundation
import StoreKit
import Stripe

final class PaymentManager {
    static let shared = PaymentManager()
    
    private let subscriptionManager = SubscriptionManager.shared
    private var stripeClient: STPAPIClient?
    
    // MARK: - Configuration
    
    private enum PaymentMethod {
        case storeKit
        case stripe
    }
    
    private var preferredPaymentMethod: PaymentMethod {
        // Use StoreKit for individual subscriptions, Stripe for enterprise
        switch subscriptionManager.currentSubscription {
        case .free, .personal:
            return .storeKit
        case .enterprise, .research:
            return .stripe
        }
    }
    
    // MARK: - Initialization
    
    func initialize() {
        setupStripe()
        setupStoreKit()
    }
    
    private func setupStripe() {
        #if DEBUG
        let stripeKey = "pk_test_..."
        #else
        let stripeKey = "pk_live_..."
        #endif
        
        STPAPIClient.shared.publishableKey = stripeKey
        stripeClient = STPAPIClient.shared
    }
    
    private func setupStoreKit() {
        // StoreKit configuration happens in SubscriptionManager
    }
    
    // MARK: - Payment Processing
    
    func subscribe(
        to tier: SubscriptionManager.SubscriptionTier,
        paymentMethod: PaymentMethod? = nil
    ) async throws {
        let method = paymentMethod ?? preferredPaymentMethod
        
        switch method {
        case .storeKit:
            try await handleStoreKitSubscription(tier)
        case .stripe:
            try await handleStripeSubscription(tier)
        }
    }
    
    // MARK: - StoreKit Handling
    
    private func handleStoreKitSubscription(
        _ tier: SubscriptionManager.SubscriptionTier
    ) async throws {
        guard let product = await fetchStoreKitProduct(for: tier) else {
            throw PaymentError.productNotFound
        }
        
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                try await subscriptionManager.validateSubscription()
                
            case .userCancelled:
                throw PaymentError.cancelled
                
            case .pending:
                throw PaymentError.pending
                
            @unknown default:
                throw PaymentError.unknown
            }
        } catch {
            throw PaymentError.purchaseFailed(error)
        }
    }
    
    private func fetchStoreKitProduct(
        for tier: SubscriptionManager.SubscriptionTier
    ) async -> Product? {
        // Fetch product from StoreKit
        let products = try? await Product.products(for: [tier.rawValue])
        return products?.first
    }
    
    // MARK: - Stripe Handling
    
    private func handleStripeSubscription(
        _ tier: SubscriptionManager.SubscriptionTier
    ) async throws {
        guard let client = stripeClient else {
            throw PaymentError.configurationError
        }
        
        // Create payment intent
        let paymentIntent = try await createPaymentIntent(for: tier)
        
        // Handle payment
        try await handleStripePayment(
            paymentIntent: paymentIntent,
            client: client
        )
        
        // Validate subscription
        try await subscriptionManager.validateSubscription()
    }
    
    private func createPaymentIntent(
        for tier: SubscriptionManager.SubscriptionTier
    ) async throws -> STPPaymentIntent {
        let params = paymentIntentParams(for: tier)
        return try await stripeClient?.paymentIntent(with: params) ?? 
            throw PaymentError.stripeError
    }
    
    private func handleStripePayment(
        paymentIntent: STPPaymentIntent,
        client: STPAPIClient
    ) async throws {
        // Handle Stripe payment flow
        // This would typically involve presenting Stripe's payment UI
        // and handling the payment confirmation
    }
    
    // MARK: - Helper Methods
    
    private func paymentIntentParams(
        for tier: SubscriptionManager.SubscriptionTier
    ) -> STPPaymentIntentParams {
        let params = STPPaymentIntentParams()
        
        // Set amount based on tier
        params.amount = amount(for: tier)
        params.currency = "usd"
        
        // Add metadata
        params.metadata = [
            "tier": tier.rawValue,
            "platform": "ios",
            "environment": isProduction ? "production" : "development"
        ]
        
        return params
    }
    
    private func amount(for tier: SubscriptionManager.SubscriptionTier) -> Int {
        switch tier {
        case .free:
            return 0
        case .personal:
            return 999 // $9.99
        case .enterprise:
            return 9999 // $99.99
        case .research:
            return 4999 // $49.99
        }
    }
    
    private var isProduction: Bool {
        #if DEBUG
        return false
        #else
        return true
        #endif
    }
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw PaymentError.verificationFailed
        case .verified(let safe):
            return safe
        }
    }
}

// MARK: - Errors

enum PaymentError: Error {
    case productNotFound
    case purchaseFailed(Error)
    case cancelled
    case pending
    case unknown
    case configurationError
    case stripeError
    case verificationFailed
}

// MARK: - Extensions

extension SubscriptionManager.SubscriptionTier {
    var productIdentifier: String {
        switch self {
        case .free:
            return "com.ibiome.free"
        case .personal:
            return "com.ibiome.personal.monthly"
        case .enterprise:
            return "com.ibiome.enterprise.monthly"
        case .research:
            return "com.ibiome.research.monthly"
        }
    }
}
