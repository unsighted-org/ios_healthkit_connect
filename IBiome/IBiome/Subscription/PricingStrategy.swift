import Foundation

struct PricingStrategy {
    // MARK: - Plan Definitions
    
    static let plans: [SubscriptionTier: [BillingInterval: Plan]] = [
        .free: [
            .monthly: Plan(price: 0, interval: .monthly)
        ],
        
        .personal: [
            .monthly: Plan(price: 14.99, interval: .monthly),
            .quarterly: Plan(price: 39.99, interval: .quarterly, savings: 11),
            .yearly: Plan(price: 149.99, interval: .yearly, savings: 17)
        ],
        
        .professional: [
            .monthly: Plan(price: 29.99, interval: .monthly),
            .quarterly: Plan(price: 79.99, interval: .quarterly, savings: 11),
            .yearly: Plan(price: 299.99, interval: .yearly, savings: 17)
        ],
        
        .research: [
            .monthly: Plan(price: 99.99, interval: .monthly),
            .quarterly: Plan(price: 269.99, interval: .quarterly, savings: 10),
            .yearly: Plan(price: 999.99, interval: .yearly, savings: 16)
        ],
        
        .enterprise: [
            .monthly: Plan(
                priceRange: 499.99...4999.99,
                interval: .monthly,
                customizable: true
            ),
            .yearly: Plan(
                priceRange: 4999.99...49999.99,
                interval: .yearly,
                customizable: true
            )
        ]
    ]
    
    // MARK: - Feature Limits
    
    static let limits: [SubscriptionTier: UsageLimits] = [
        .free: UsageLimits(
            storageGB: 1,
            apiCallsPerDay: 100,
            maxDevices: 1,
            maxUsers: 1,
            retentionDays: 30,
            maxExports: 1
        ),
        
        .personal: UsageLimits(
            storageGB: 10,
            apiCallsPerDay: 1000,
            maxDevices: 3,
            maxUsers: 1,
            retentionDays: 90,
            maxExports: 10
        ),
        
        .professional: UsageLimits(
            storageGB: 50,
            apiCallsPerDay: 10000,
            maxDevices: 5,
            maxUsers: 1,
            retentionDays: 365,
            maxExports: 50
        ),
        
        .research: UsageLimits(
            storageGB: 500,
            apiCallsPerDay: 100000,
            maxDevices: 10,
            maxUsers: 5,
            retentionDays: 730,
            maxExports: .unlimited
        ),
        
        .enterprise: UsageLimits(
            storageGB: .unlimited,
            apiCallsPerDay: .unlimited,
            maxDevices: .unlimited,
            maxUsers: .unlimited,
            retentionDays: .unlimited,
            maxExports: .unlimited
        )
    ]
    
    // MARK: - Features
    
    static let features: [SubscriptionTier: Set<Feature>] = [
        .free: [
            .basicHealth,
            .basicVisualization,
            .standardAnalytics
        ],
        
        .personal: [
            .basicHealth,
            .advancedVisualization,
            .personalAnalytics,
            .customInsights,
            .exportData,
            .prioritySupport
        ],
        
        .professional: [
            .basicHealth,
            .advancedVisualization,
            .personalAnalytics,
            .customInsights,
            .exportData,
            .prioritySupport,
            .aiPoweredInsights,
            .customDashboards,
            .advancedAnalytics,
            .apiAccess
        ],
        
        .research: [
            .basicHealth,
            .advancedVisualization,
            .personalAnalytics,
            .customInsights,
            .exportData,
            .prioritySupport,
            .aiPoweredInsights,
            .customDashboards,
            .advancedAnalytics,
            .apiAccess,
            .batchProcessing,
            .mlPipelines,
            .researchApi,
            .dedicatedSupport
        ],
        
        .enterprise: Feature.allCases
    ]
}

// MARK: - Supporting Types

struct Plan {
    let price: Double
    let priceRange: ClosedRange<Double>?
    let interval: BillingInterval
    let savings: Int?
    let customizable: Bool
    
    init(
        price: Double,
        interval: BillingInterval,
        savings: Int? = nil
    ) {
        self.price = price
        self.priceRange = nil
        self.interval = interval
        self.savings = savings
        self.customizable = false
    }
    
    init(
        priceRange: ClosedRange<Double>,
        interval: BillingInterval,
        customizable: Bool = true
    ) {
        self.price = priceRange.lowerBound
        self.priceRange = priceRange
        self.interval = interval
        self.savings = nil
        self.customizable = customizable
    }
}

enum BillingInterval: String, CaseIterable {
    case monthly
    case quarterly
    case yearly
    
    var description: String {
        switch self {
        case .monthly: return "month"
        case .quarterly: return "quarter"
        case .yearly: return "year"
        }
    }
    
    var months: Int {
        switch self {
        case .monthly: return 1
        case .quarterly: return 3
        case .yearly: return 12
        }
    }
}

struct UsageLimits {
    let storageGB: Limit
    let apiCallsPerDay: Limit
    let maxDevices: Limit
    let maxUsers: Limit
    let retentionDays: Limit
    let maxExports: Limit
    
    enum Limit {
        case limited(Int)
        case unlimited
        
        static func unlimited() -> Limit { .unlimited }
    }
    
    init(
        storageGB: Int,
        apiCallsPerDay: Int,
        maxDevices: Int,
        maxUsers: Int,
        retentionDays: Int,
        maxExports: Int
    ) {
        self.storageGB = .limited(storageGB)
        self.apiCallsPerDay = .limited(apiCallsPerDay)
        self.maxDevices = .limited(maxDevices)
        self.maxUsers = .limited(maxUsers)
        self.retentionDays = .limited(retentionDays)
        self.maxExports = .limited(maxExports)
    }
    
    init(
        storageGB: Limit,
        apiCallsPerDay: Limit,
        maxDevices: Limit,
        maxUsers: Limit,
        retentionDays: Limit,
        maxExports: Limit
    ) {
        self.storageGB = storageGB
        self.apiCallsPerDay = apiCallsPerDay
        self.maxDevices = maxDevices
        self.maxUsers = maxUsers
        self.retentionDays = retentionDays
        self.maxExports = maxExports
    }
}

enum Feature: String, CaseIterable {
    // Basic Features
    case basicHealth = "Basic Health Tracking"
    case basicVisualization = "Basic Visualizations"
    case standardAnalytics = "Standard Analytics"
    
    // Personal Features
    case advancedVisualization = "Advanced Visualizations"
    case personalAnalytics = "Personal Analytics"
    case customInsights = "Custom Insights"
    case exportData = "Data Export"
    case prioritySupport = "Priority Support"
    
    // Professional Features
    case aiPoweredInsights = "AI-Powered Insights"
    case customDashboards = "Custom Dashboards"
    case advancedAnalytics = "Advanced Analytics"
    case apiAccess = "API Access"
    
    // Research Features
    case batchProcessing = "Batch Processing"
    case mlPipelines = "ML Pipelines"
    case researchApi = "Research API"
    case dedicatedSupport = "Dedicated Support"
    
    // Enterprise Features
    case customIntegration = "Custom Integration"
    case slaGuarantee = "SLA Guarantee"
    case whiteLabel = "White Label"
    case customFeatures = "Custom Features"
}
