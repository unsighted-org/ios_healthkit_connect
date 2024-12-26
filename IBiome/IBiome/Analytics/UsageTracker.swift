import Foundation
import CloudKit
import CoreData

final class UsageTracker {
    static let shared = UsageTracker()
    
    private let subscriptionManager = SubscriptionManager.shared
    private let cloudKitContainer = CKContainer.default()
    private let persistenceController = PersistenceController.shared
    
    // MARK: - Usage Categories
    
    enum UsageCategory: String {
        case visualization = "visualization"
        case analytics = "analytics"
        case mlOperations = "ml_operations"
        case dataExport = "data_export"
        case apiCalls = "api_calls"
    }
    
    // MARK: - Usage Tracking
    
    func trackUsage(
        category: UsageCategory,
        operation: String,
        metadata: [String: Any] = [:]
    ) async throws {
        // Check quota
        guard subscriptionManager.checkAnalyticsQuota() else {
            throw UsageError.quotaExceeded
        }
        
        // Create usage record
        let usage = UsageRecord(
            category: category,
            operation: operation,
            timestamp: Date(),
            metadata: metadata
        )
        
        // Store locally
        try await storeLocally(usage)
        
        // Sync to cloud if needed
        if shouldSyncToCloud(category) {
            try await syncToCloud(usage)
        }
        
        // Update subscription manager
        subscriptionManager.trackAnalyticsUsage(operation)
    }
    
    // MARK: - Usage Analysis
    
    func getUsageStats(
        category: UsageCategory,
        timeframe: TimeInterval
    ) async throws -> UsageStats {
        let context = persistenceController.container.viewContext
        let request = NSFetchRequest<UsageEntity>(entityName: "UsageEntity")
        
        // Add predicates
        let startDate = Date().addingTimeInterval(-timeframe)
        request.predicate = NSPredicate(
            format: "category == %@ AND timestamp >= %@",
            category.rawValue, startDate as NSDate
        )
        
        let records = try context.fetch(request)
        return analyzeUsage(records)
    }
    
    // MARK: - Private Methods
    
    private func storeLocally(_ usage: UsageRecord) async throws {
        let context = persistenceController.container.newBackgroundContext()
        
        try await context.perform {
            let entity = UsageEntity(context: context)
            entity.id = UUID()
            entity.category = usage.category.rawValue
            entity.operation = usage.operation
            entity.timestamp = usage.timestamp
            entity.metadata = usage.metadata as? [String: String] ?? [:]
            
            try context.save()
        }
    }
    
    private func syncToCloud(_ usage: UsageRecord) async throws {
        let record = CKRecord(recordType: "Usage")
        record.setValue(usage.category.rawValue, forKey: "category")
        record.setValue(usage.operation, forKey: "operation")
        record.setValue(usage.timestamp, forKey: "timestamp")
        record.setValue(usage.metadata, forKey: "metadata")
        
        try await cloudKitContainer.privateCloudDatabase.save(record)
    }
    
    private func shouldSyncToCloud(_ category: UsageCategory) -> Bool {
        switch subscriptionManager.currentSubscription {
        case .free:
            return false
        case .personal:
            return category != .visualization
        case .enterprise, .research:
            return true
        }
    }
    
    private func analyzeUsage(_ records: [UsageEntity]) -> UsageStats {
        var stats = UsageStats()
        
        // Calculate basic stats
        stats.totalOperations = records.count
        stats.uniqueOperations = Set(records.map { $0.operation }).count
        
        // Calculate time-based metrics
        let timestamps = records.map { $0.timestamp ?? Date() }
        if let first = timestamps.min(), let last = timestamps.max() {
            stats.timespan = last.timeIntervalSince(first)
            stats.operationsPerHour = Double(records.count) / (stats.timespan / 3600)
        }
        
        // Calculate category distribution
        let categories = records.map { $0.category ?? "" }
        stats.categoryDistribution = Dictionary(grouping: categories) { $0 }
            .mapValues { Double($0.count) / Double(categories.count) }
        
        return stats
    }
}

// MARK: - Supporting Types

struct UsageRecord {
    let category: UsageCategory
    let operation: String
    let timestamp: Date
    let metadata: [String: Any]
}

struct UsageStats {
    var totalOperations: Int = 0
    var uniqueOperations: Int = 0
    var timespan: TimeInterval = 0
    var operationsPerHour: Double = 0
    var categoryDistribution: [String: Double] = [:]
}

enum UsageError: Error {
    case quotaExceeded
    case syncFailed
    case analysisError
}

// MARK: - Core Data Model

extension UsageEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<UsageEntity> {
        return NSFetchRequest<UsageEntity>(entityName: "UsageEntity")
    }
    
    @NSManaged public var id: UUID?
    @NSManaged public var category: String?
    @NSManaged public var operation: String
    @NSManaged public var timestamp: Date?
    @NSManaged public var metadata: [String: String]
}
