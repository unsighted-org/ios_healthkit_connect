import Foundation
import HealthKit
import Combine

@MainActor
class HealthKitManager: ObservableObject {
    static let shared = HealthKitManager()
    private let healthStore = HKHealthStore()
    
    @Published var isAuthorized = false
    @Published var isOuraConnected = false
    @Published var lastSyncDate: Date?
    @Published var error: Error?
    @Published var healthData: [HealthEnvironmentData] = []
    @Published var isLoading = false
    
    private let readTypes: Set<HKSampleType> = [
        .quantityType(forIdentifier: .stepCount)!,
        .quantityType(forIdentifier: .heartRate)!,
        .quantityType(forIdentifier: .activeEnergyBurned)!,
        .categoryType(forIdentifier: .sleepAnalysis)!,
        .quantityType(forIdentifier: .oxygenSaturation)!,
        .quantityType(forIdentifier: .respiratoryRate)!,
        .quantityType(forIdentifier: .bodyMass)!,
        .quantityType(forIdentifier: .height)!
    ]
    
    private init() {}
    
    func requestAuthorization() async throws {
        guard HKHealthStore.isHealthDataAvailable() else {
            throw HealthKitError.notAvailable
        }
        
        do {
            try await healthStore.requestAuthorization(toShare: [], read: readTypes)
            isAuthorized = true
            try await refreshHealthData()
        } catch {
            self.error = error
            throw error
        }
    }
    
    func isAuthorized(for dataType: HKSampleType) async -> Bool {
        return healthStore.authorizationStatus(for: dataType) == .sharingAuthorized
    }
    
    func refreshHealthData() async throws {
        isLoading = true
        defer { isLoading = false }
        
        let calendar = Calendar.current
        let now = Date()
        let startDate = calendar.date(byAdding: .day, value: -7, to: now)!
        
        async let steps = queryHealthData(type: .quantityType(forIdentifier: .stepCount)!, start: startDate, end: now)
        async let heartRate = queryHealthData(type: .quantityType(forIdentifier: .heartRate)!, start: startDate, end: now)
        async let weight = queryHealthData(type: .quantityType(forIdentifier: .bodyMass)!, start: startDate, end: now)
        async let height = queryHealthData(type: .quantityType(forIdentifier: .height)!, start: startDate, end: now)
        
        let (stepsData, heartRateData, weightData, heightData) = try await (steps, heartRate, weight, height)
        
        // Group data by day
        var dailyData: [Date: HealthEnvironmentData] = [:]
        
        for sample in stepsData {
            guard let sample = sample as? HKQuantitySample else { continue }
            let day = calendar.startOfDay(for: sample.startDate)
            if dailyData[day] == nil {
                dailyData[day] = createEmptyHealthData(for: day)
            }
            dailyData[day]?.steps += Int(sample.quantity.doubleValue(for: .count()))
        }
        
        for sample in heartRateData {
            guard let sample = sample as? HKQuantitySample else { continue }
            let day = calendar.startOfDay(for: sample.startDate)
            if dailyData[day] == nil {
                dailyData[day] = createEmptyHealthData(for: day)
            }
            dailyData[day]?.heartRate = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
        }
        
        if let weightSample = weightData.last as? HKQuantitySample {
            let weight = weightSample.quantity.doubleValue(for: .gramUnit(with: .kilo))
            for key in dailyData.keys {
                dailyData[key]?.weight = weight
            }
        }
        
        if let heightSample = heightData.last as? HKQuantitySample {
            let height = heightSample.quantity.doubleValue(for: .meterUnit(with: .centi))
            for key in dailyData.keys {
                dailyData[key]?.height = height
            }
        }
        
        healthData = dailyData.values.sorted { $0.timestamp > $1.timestamp }
        lastSyncDate = Date()
    }
    
    private func queryHealthData(type: HKQuantityType, start: Date, end: Date) async throws -> [HKSample] {
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: type,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [sortDescriptor]
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: samples ?? [])
                }
            }
            
            healthStore.execute(query)
        }
    }
    
    private func createEmptyHealthData(for date: Date) -> HealthEnvironmentData {
        HealthEnvironmentData(
            id: UUID().uuidString,
            timestamp: date,
            steps: 0,
            heartRate: 0,
            weight: 0,
            height: 0,
            airQualityIndex: Int.random(in: 0...500), // Mock data
            environmentalImpact: Int.random(in: 0...100) // Mock data
        )
    }
    
    func authorizeOuraRing() async throws {
        // Implement Oura Ring authorization
        // This would typically involve OAuth flow
        isOuraConnected = true
    }
}

enum HealthKitError: LocalizedError {
    case notAvailable
    case dataNotAvailable
    
    var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "HealthKit is not available on this device"
        case .dataNotAvailable:
            return "No health data available for the requested period"
        }
    }
}
