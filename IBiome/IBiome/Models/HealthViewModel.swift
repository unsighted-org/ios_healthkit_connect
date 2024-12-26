import SwiftUI
import HealthKit

@MainActor
class HealthViewModel: ObservableObject {
    private let healthService = HealthKitManager.shared
    
    @Published var steps: Double = 0
    @Published var heartRates: [Double] = []
    @Published var weights: [Double] = []
    @Published var isAuthorized = false
    @Published var errorMessage: String?
    
    func requestAuthorization() {
        Task {
            do {
                try await healthService.requestAuthorization()
                self.isAuthorized = healthService.isAuthorized
                await fetchHealthData()
            } catch {
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    func fetchHealthData() async {
        do {
            try await healthService.refreshHealthData()
            if let latestData = healthService.healthData.first {
                self.steps = Double(latestData.steps)
                self.heartRates = [latestData.heartRate]
                if latestData.weight > 0 {
                    self.weights = [latestData.weight]
                }
            }
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    func saveWeight(_ weight: Double) {
        Task {
            do {
                try await healthService.saveWeight(weight, unit: .pound())
                await fetchHealthData()
            } catch {
                self.errorMessage = error.localizedDescription
            }
        }
    }
}
