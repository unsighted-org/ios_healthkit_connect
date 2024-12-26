import HealthKit

class HealthKitTypesHelper {
    static func printAllAvailableTypes() {
        print("Available HealthKit Types:")
        
        // Quantity Types
        print("\nQuantity Types:")
        let quantityTypes: [HKQuantityTypeIdentifier] = [
            .stepCount,
            .distanceWalkingRunning,
            .heartRate,
            .activeEnergyBurned,
            .basalEnergyBurned,
            .bodyMass,
            .bodyFatPercentage,
            .height,
            .bloodPressureSystolic,
            .bloodPressureDiastolic,
            .oxygenSaturation,
            .bodyTemperature
        ]
        
        quantityTypes.forEach { identifier in
            if let type = HKQuantityType.quantityType(forIdentifier: identifier) {
                print("\(identifier.rawValue): \(type)")
            }
        }
        
        // Category Types
        print("\nCategory Types:")
        let categoryTypes: [HKCategoryTypeIdentifier] = [
            .sleepAnalysis,
            .mindfulSession,
            .highHeartRateEvent,
            .irregularHeartRhythmEvent,
            .audioExposureEvent,
            .toothbrushingEvent
        ]
        
        categoryTypes.forEach { identifier in
            if let type = HKCategoryType.categoryType(forIdentifier: identifier) {
                print("\(identifier.rawValue): \(type)")
            }
        }
        
        // Characteristic Types
        print("\nCharacteristic Types:")
        let characteristicTypes: [HKCharacteristicTypeIdentifier] = [
            .biologicalSex,
            .dateOfBirth,
            .bloodType,
            .fitzpatrickSkinType,
            .wheelchairUse
        ]
        
        characteristicTypes.forEach { identifier in
            if let type = HKCharacteristicType.characteristicType(forIdentifier: identifier) {
                print("\(identifier.rawValue): \(type)")
            }
        }
        
        // Correlation Types
        print("\nCorrelation Types:")
        let correlationTypes: [HKCorrelationTypeIdentifier] = [
            .bloodPressure,
            .food
        ]
        
        correlationTypes.forEach { identifier in
            if let type = HKCorrelationType.correlationType(forIdentifier: identifier) {
                print("\(identifier.rawValue): \(type)")
            }
        }
    }
}
