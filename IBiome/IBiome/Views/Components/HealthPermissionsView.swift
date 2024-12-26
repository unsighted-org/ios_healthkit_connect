import SwiftUI
import HealthKit

struct HealthPermissionsView: View {
    @EnvironmentObject private var healthKitManager: HealthKitManager
    @State private var authorizedTypes: Set<HKSampleType> = []
    
    private let permissionDescriptions: [(HKSampleType, String)] = [
        (HKObjectType.quantityType(forIdentifier: .stepCount)!, "Track your daily steps"),
        (HKObjectType.quantityType(forIdentifier: .heartRate)!, "Monitor your heart rate"),
        (HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!, "Track calories burned"),
        (HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!, "Monitor your sleep patterns"),
        (HKObjectType.quantityType(forIdentifier: .oxygenSaturation)!, "Track blood oxygen levels"),
        (HKObjectType.quantityType(forIdentifier: .respiratoryRate)!, "Monitor breathing rate"),
        (HKObjectType.quantityType(forIdentifier: .bodyMass)!, "Track your weight"),
        (HKObjectType.quantityType(forIdentifier: .height)!, "Record your height")
    ]
    
    var body: some View {
        List {
            ForEach(permissionDescriptions, id: \.0.identifier) { dataType, description in
                HealthDataPermissionView(
                    dataType: dataType,
                    description: description,
                    isAuthorized: .init(
                        get: { authorizedTypes.contains(dataType) },
                        set: { _ in }
                    )
                )
            }
        }
        .onAppear {
            Task {
                await updateAuthorizedTypes()
            }
        }
    }
    
    private func updateAuthorizedTypes() async {
        for (dataType, _) in permissionDescriptions {
            let authorized = await healthKitManager.isAuthorized(for: dataType)
            if authorized {
                await MainActor.run {
                    authorizedTypes.insert(dataType)
                }
            }
        }
    }
}

#Preview {
    HealthPermissionsView()
        .environmentObject(HealthKitManager.shared)
}
