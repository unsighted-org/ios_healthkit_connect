import Foundation
import HealthKit

struct HealthEnvironmentData: Identifiable {
    let id: String
    let timestamp: Date
    let steps: Int
    let heartRate: Double
    let weight: Double
    let height: Double
    let airQualityIndex: Int
    let environmentalImpact: Int
    
    // Computed properties
    var bmi: Double {
        let heightInMeters = height / 100
        return weight / (heightInMeters * heightInMeters)
    }
    
    var activityLevel: ActivityLevel {
        switch steps {
        case 0..<5000:
            return .sedentary
        case 5000..<7500:
            return .lightlyActive
        case 7500..<10000:
            return .moderatelyActive
        default:
            return .veryActive
        }
    }
    
    var airQualityDescription: String {
        switch airQualityIndex {
        case 0..<50:
            return "Good"
        case 50..<100:
            return "Moderate"
        case 100..<150:
            return "Unhealthy for Sensitive Groups"
        case 150..<200:
            return "Unhealthy"
        case 200..<300:
            return "Very Unhealthy"
        default:
            return "Hazardous"
        }
    }
    
    var environmentalImpactDescription: String {
        switch environmentalImpact {
        case 0..<33:
            return "Low Impact"
        case 33..<66:
            return "Medium Impact"
        default:
            return "High Impact"
        }
    }
}

enum ActivityLevel: String {
    case sedentary = "Sedentary"
    case lightlyActive = "Lightly Active"
    case moderatelyActive = "Moderately Active"
    case veryActive = "Very Active"
}
