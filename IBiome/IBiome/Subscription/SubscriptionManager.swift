import Foundation
import StoreKit
import CloudKit

final class SubscriptionManager {
    static let shared = SubscriptionManager()
    
    // MARK: - Subscription Tiers
    enum SubscriptionTier: String {
        case free = "com.ibiome.free"
        case personal = "com.ibiome.personal"
        case enterprise = "com.ibiome.enterprise"
        case research = "com.ibiome.research"
        
        var features: [Feature] {
            switch self {
            case .free:
                return [.basicHealth, .basicVisualization, .standardAnalytics]
            case .personal:
                return [.basicHealth, .advancedVisualization, .personalAnalytics, 
                       .customInsights, .exportData]
            case .enterprise:
                return Feature.allCases
            case .research:
                return [.basicHealth, .advancedVisualization, .researchAnalytics,
                       .exportData, .batchProcessing, .mlPipelines]
            }
        }
        
        var storageLimit: Int {
            switch self {
            case .free: return 100_000 // 100K records
            case .personal: return 1_000_000 // 1M records
            case .enterprise: return 100_000_000 // 100M records
            case .research: return 50_000_000 // 50M records
            }
        }
        
        var analyticsLimit: Int {
            switch self {
            case .free: return 1_000 // Daily analytics operations
            case .personal: return 10_000
            case .enterprise: return 1_000_000
            case .research: return 500_000
            }
        }
    }
    
    // MARK: - Features
    enum Feature: CaseIterable {
        // Basic Features
        case basicHealth
        case basicVisualization
        case standardAnalytics
        
        // Advanced Features
        case advancedVisualization
        case personalAnalytics
        case customInsights
        case exportData
        
        // Enterprise Features
        case insuranceAnalytics
        case urbanPlanning
        case corporateWellness
        case realEstateAnalysis
        case smartCityIntegration
        
        // Research Features
        case researchAnalytics
        case batchProcessing
        case mlPipelines
        
        var requiresSubscription: Bool {
            switch self {
            case .basicHealth, .basicVisualization, .standardAnalytics:
                return false
            default:
                return true
            }
        }
    }
    
    // MARK: - Properties
    private let userDefaults = UserDefaults.standard
    private let cloudKitContainer = CKContainer.default()
    private var currentSubscription: SubscriptionTier = .free
    private var subscriptionProduct: Product?
    
    // MARK: - Analytics Tracking
    private var analyticsUsage: [String: Int] = [:]
    private let analyticsQueue = DispatchQueue(label: "com.ibiome.analytics")
    
    // MARK: - Public Methods
    
    func initialize() async {
        await loadSubscription()
        setupAnalyticsTracking()
    }
    
    func canAccess(_ feature: Feature) -> Bool {
        currentSubscription.features.contains(feature)
    }
    
    func checkAnalyticsQuota() -> Bool {
        let usage = getCurrentAnalyticsUsage()
        return usage < currentSubscription.analyticsLimit
    }
    
    func trackAnalyticsUsage(_ operation: String) {
        analyticsQueue.async {
            self.analyticsUsage[operation, default: 0] += 1
            self.syncAnalyticsUsage()
        }
    }
    
    // MARK: - Subscription Management
    
    func subscribe(to tier: SubscriptionTier) async throws {
        guard let product = await fetchProduct(for: tier) else {
            throw SubscriptionError.productNotFound
        }
        
        do {
            let result = try await purchase(product)
            await processTransaction(result)
        } catch {
            throw SubscriptionError.purchaseFailed
        }
    }
    
    func validateSubscription() async throws {
        guard let subscription = await fetchCurrentSubscription() else {
            currentSubscription = .free
            return
        }
        
        if await subscription.isActive {
            currentSubscription = SubscriptionTier(rawValue: subscription.id) ?? .free
        } else {
            currentSubscription = .free
        }
    }
    
    // MARK: - Private Methods
    
    private func loadSubscription() async {
        do {
            try await validateSubscription()
        } catch {
            currentSubscription = .free
        }
    }
    
    private func setupAnalyticsTracking() {
        // Setup periodic analytics sync
        Timer.scheduledTimer(withTimeInterval: 3600, repeats: true) { [weak self] _ in
            self?.syncAnalyticsUsage()
        }
    }
    
    private func getCurrentAnalyticsUsage() -> Int {
        analyticsQueue.sync {
            analyticsUsage.values.reduce(0, +)
        }
    }
    
    private func syncAnalyticsUsage() {
        // Sync with CloudKit
        let usage = analyticsUsage
        Task {
            await syncToCloud(usage)
        }
    }
    
    private func syncToCloud(_ usage: [String: Int]) async {
        // Implement CloudKit sync
    }
}

// MARK: - Errors

enum SubscriptionError: Error {
    case productNotFound
    case purchaseFailed
    case validationFailed
    case quotaExceeded
}

// MARK: - Extensions

extension SubscriptionManager {
    func getVisualizationStrategy(
        for dataType: VisualizationDataType,
        context: VisualizationContext
    ) -> any VisualizationStrategy {
        // Apply subscription-based limitations
        var limitedContext = context
        
        switch currentSubscription {
        case .free:
            limitedContext.interactionLevel = .basic
            limitedContext.renderingPreference = [.performance, .mobileOptimized]
        case .personal:
            limitedContext.interactionLevel = .advanced
        case .enterprise, .research:
            // No limitations
            break
        }
        
        return VisualizationFactory.createStrategy(
            for: dataType,
            context: limitedContext
        )
    }
    
    func getMLCapabilities() -> MLCapabilities {
        switch currentSubscription {
        case .free:
            return MLCapabilities(
                allowsBatchProcessing: false,
                maxModels: 1,
                customModels: false
            )
        case .personal:
            return MLCapabilities(
                allowsBatchProcessing: true,
                maxModels: 3,
                customModels: false
            )
        case .enterprise:
            return MLCapabilities(
                allowsBatchProcessing: true,
                maxModels: .max,
                customModels: true
            )
        case .research:
            return MLCapabilities(
                allowsBatchProcessing: true,
                maxModels: 10,
                customModels: true
            )
        }
    }
}
