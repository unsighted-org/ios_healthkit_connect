import HealthKit

public class HealthKitService {
    public static let shared = HealthKitService()
    private let healthStore = HKHealthStore()
    
    private init() {}
    
    // Types we want to read from HealthKit
    private let typesToRead: Set<HKSampleType> = [
        HKObjectType.quantityType(forIdentifier: .stepCount)!,
        HKObjectType.quantityType(forIdentifier: .heartRate)!,
        HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
        HKObjectType.quantityType(forIdentifier: .bodyMass)!,
        HKObjectType.quantityType(forIdentifier: .height)!,
        HKObjectType.quantityType(forIdentifier: .bodyMassIndex)!,
        HKObjectType.quantityType(forIdentifier: .dietaryCarbohydrates)!,
        HKObjectType.quantityType(forIdentifier: .dietaryProtein)!,
        HKObjectType.quantityType(forIdentifier: .dietaryFiber)!
    ]
    
    // Types we want to write to HealthKit
    private let typesToWrite: Set<HKSampleType> = [
        HKObjectType.quantityType(forIdentifier: .bodyMass)!,
        HKObjectType.quantityType(forIdentifier: .height)!,
        HKObjectType.quantityType(forIdentifier: .dietaryCarbohydrates)!,
        HKObjectType.quantityType(forIdentifier: .dietaryProtein)!,
        HKObjectType.quantityType(forIdentifier: .dietaryFiber)!
    ]
    
    public func requestAuthorization() async throws {
        try await healthStore.requestAuthorization(toShare: typesToWrite, read: typesToRead)
    }
    
    public func queryStepCount(start: Date, end: Date) async throws -> Double {
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end)
        let sumOption = HKStatisticsOptions.cumulativeSum
        
        let query = HKStatisticsQuery(quantityType: stepType,
                                    quantitySamplePredicate: predicate,
                                    options: sumOption) { _, result, error in
            if let error = error {
                print("Error querying steps: \(error.localizedDescription)")
                return
            }
            
            if let sum = result?.sumQuantity() {
                let steps = sum.doubleValue(for: HKUnit.count())
                print("Steps: \(steps)")
            }
        }
        
        healthStore.execute(query)
        return 0 // This is placeholder, implement proper async/await pattern
    }
    
    public func queryHeartRate(start: Date, end: Date) async throws -> [HKQuantitySample] {
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(sampleType: heartRateType,
                                    predicate: predicate,
                                    limit: HKObjectQueryNoLimit,
                                    sortDescriptors: [sortDescriptor]) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let samples = samples as? [HKQuantitySample] else {
                    continuation.resume(returning: [])
                    return
                }
                
                continuation.resume(returning: samples)
            }
            
            healthStore.execute(query)
        }
    }
    
    public func saveWeight(_ weight: Double, unit: HKUnit) async throws {
        let weightType = HKQuantityType.quantityType(forIdentifier: .bodyMass)!
        let quantity = HKQuantity(unit: unit, doubleValue: weight)
        let sample = HKQuantitySample(type: weightType,
                                    quantity: quantity,
                                    start: Date(),
                                    end: Date())
        
        try await healthStore.save(sample)
    }
    
    public func saveHeight(_ height: Double, unit: HKUnit) async throws {
        let heightType = HKQuantityType.quantityType(forIdentifier: .height)!
        let quantity = HKQuantity(unit: unit, doubleValue: height)
        let sample = HKQuantitySample(type: heightType,
                                    quantity: quantity,
                                    start: Date(),
                                    end: Date())
        
        try await healthStore.save(sample)
    }
    
    public func queryWeight(start: Date, end: Date) async throws -> [HKQuantitySample] {
        let weightType = HKQuantityType.quantityType(forIdentifier: .bodyMass)!
        
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(sampleType: weightType,
                                    predicate: predicate,
                                    limit: HKObjectQueryNoLimit,
                                    sortDescriptors: [sortDescriptor]) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let samples = samples as? [HKQuantitySample] else {
                    continuation.resume(returning: [])
                    return
                }
                
                continuation.resume(returning: samples)
            }
            
            healthStore.execute(query)
        }
    }
}
