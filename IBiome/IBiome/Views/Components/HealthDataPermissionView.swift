import SwiftUI
import HealthKit

struct HealthDataPermissionView: View {
    let dataType: HKSampleType
    let description: String
    @Binding var isAuthorized: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(dataType.identifier.components(separatedBy: ".").last ?? "")
                    .font(.headline)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: isAuthorized ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(isAuthorized ? .green : .red)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    HealthDataPermissionView(
        dataType: HKObjectType.quantityType(forIdentifier: .stepCount)!,
        description: "Track your daily steps",
        isAuthorized: .constant(true)
    )
}
