import Foundation
import Combine
import OSLog

// MARK: - Metric Types
enum MetricName: String {
    case healthDataProcessed = "health_data_processed"
    case healthDataError = "health_data_error"
    case dataPointsRendered = "data_points_rendered"
    case locationUpdated = "location_updated"
    case environmentalDataFetched = "environmental_data_fetched"
    case performanceMetric = "performance_metric"
    case memoryUsage = "memory_usage"
    case networkLatency = "network_latency"
}

enum MetricType {
    case count
    case gauge
    case histogram
    case summary
}

struct Metric {
    let name: MetricName
    let type: MetricType
    let value: Double
    let metadata: [String: String]
    let timestamp: Date
}

// MARK: - Metrics Engine
final class MetricsEngine {
    static let shared = MetricsEngine()
    
    private let queue = DispatchQueue(label: "com.ibiome.metrics", qos: .utility)
    private let logger = Logger(subsystem: "com.ibiome", category: "Metrics")
    private var metricsBuffer: [Metric] = []
    private let bufferLimit = 100
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        setupPeriodicFlush()
        setupMemoryMonitoring()
    }
    
    // MARK: - Public Interface
    
    func record(
        _ name: MetricName,
        type: MetricType = .count,
        value: Double,
        metadata: [String: String] = [:]
    ) {
        let metric = Metric(
            name: name,
            type: type,
            value: value,
            metadata: metadata,
            timestamp: Date()
        )
        
        queue.async { [weak self] in
            self?.addToBuffer(metric)
        }
    }
    
    func recordPerformanceMetric(
        name: String,
        value: Double,
        context: [String: String] = [:]
    ) {
        var metadata = context
        metadata["performance_context"] = name
        
        record(
            .performanceMetric,
            type: .gauge,
            value: value,
            metadata: metadata
        )
    }
    
    // MARK: - Buffer Management
    
    private func addToBuffer(_ metric: Metric) {
        metricsBuffer.append(metric)
        
        if metricsBuffer.count >= bufferLimit {
            flushMetrics()
        }
    }
    
    private func flushMetrics() {
        guard !metricsBuffer.isEmpty else { return }
        
        let metrics = metricsBuffer
        metricsBuffer.removeAll()
        
        sendMetrics(metrics)
    }
    
    // MARK: - Metric Processing
    
    private func sendMetrics(_ metrics: [Metric]) {
        let aggregated = aggregateMetrics(metrics)
        
        // Log metrics
        aggregated.forEach { metric in
            logger.info("\(metric.name.rawValue): \(metric.value) [\(metric.metadata)]")
        }
        
        // Store metrics for analysis
        storeMetrics(aggregated)
        
        // Send to monitoring system if needed
        sendToMonitoringSystem(aggregated)
    }
    
    private func aggregateMetrics(_ metrics: [Metric]) -> [Metric] {
        Dictionary(grouping: metrics) { $0.name }
            .map { (name, metrics) -> Metric in
                let totalValue = metrics.reduce(0) { $0 + $1.value }
                let avgValue = totalValue / Double(metrics.count)
                
                // Merge metadata
                var combinedMetadata: [String: String] = [:]
                metrics.forEach { metric in
                    combinedMetadata.merge(metric.metadata) { _, new in new }
                }
                
                return Metric(
                    name: name,
                    type: metrics[0].type,
                    value: avgValue,
                    metadata: combinedMetadata,
                    timestamp: Date()
                )
            }
    }
    
    // MARK: - Persistence
    
    private func storeMetrics(_ metrics: [Metric]) {
        // Implement metric storage (Core Data, SQLite, etc.)
    }
    
    // MARK: - Monitoring Integration
    
    private func sendToMonitoringSystem(_ metrics: [Metric]) {
        // Implement integration with external monitoring system
    }
    
    // MARK: - Setup
    
    private func setupPeriodicFlush() {
        Timer.publish(every: 60, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.queue.async {
                    self?.flushMetrics()
                }
            }
            .store(in: &cancellables)
    }
    
    private func setupMemoryMonitoring() {
        Timer.publish(every: 30, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.recordMemoryUsage()
            }
            .store(in: &cancellables)
    }
    
    private func recordMemoryUsage() {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(
                    mach_task_self_,
                    task_flavor_t(MACH_TASK_BASIC_INFO),
                    $0,
                    &count
                )
            }
        }
        
        if kerr == KERN_SUCCESS {
            let usedMB = Double(info.resident_size) / 1024.0 / 1024.0
            record(
                .memoryUsage,
                type: .gauge,
                value: usedMB,
                metadata: ["unit": "MB"]
            )
        }
    }
}

// MARK: - Extensions

extension MetricsEngine {
    func recordNetworkLatency(_ duration: TimeInterval, endpoint: String) {
        record(
            .networkLatency,
            type: .histogram,
            value: duration,
            metadata: [
                "endpoint": endpoint,
                "unit": "seconds"
            ]
        )
    }
    
    func recordDataPoints(_ count: Int, context: String) {
        record(
            .dataPointsRendered,
            type: .gauge,
            value: Double(count),
            metadata: ["context": context]
        )
    }
}
