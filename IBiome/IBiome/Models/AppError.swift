import Foundation

enum AppError: LocalizedError {
    case authenticationFailed(String)
    case healthKitNotAvailable
    case healthKitAuthorizationDenied
    case locationServicesDenied
    case networkError(Error)
    case dataError(String)
    
    var errorDescription: String? {
        switch self {
        case .authenticationFailed(let message):
            return "Authentication failed: \(message)"
        case .healthKitNotAvailable:
            return "HealthKit is not available on this device"
        case .healthKitAuthorizationDenied:
            return "HealthKit access was denied"
        case .locationServicesDenied:
            return "Location services access was denied"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .dataError(let message):
            return "Data error: \(message)"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .authenticationFailed:
            return "Please try signing in again"
        case .healthKitNotAvailable:
            return "This feature requires a device that supports HealthKit"
        case .healthKitAuthorizationDenied:
            return "Please enable HealthKit access in Settings"
        case .locationServicesDenied:
            return "Please enable Location Services in Settings"
        case .networkError:
            return "Please check your internet connection and try again"
        case .dataError:
            return "Please try again later"
        }
    }
}
