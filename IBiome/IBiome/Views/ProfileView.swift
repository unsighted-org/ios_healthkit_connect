import SwiftUI
import HealthKit

struct ProfileView: View {
    @ObservedObject private var healthKitManager = HealthKitManager.shared
    @ObservedObject private var authManager = AuthenticationManager.shared
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Health Data")) {
                    ForEach(healthKitManager.availableTypes, id: \.identifier) { type in
                        HStack {
                            Text(type.name)
                            Spacer()
                            if type.isAuthorized {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            }
                        }
                    }
                }
                
                Section {
                    Button(action: {
                        authManager.signOut()
                    }) {
                        Text("Sign Out")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Profile")
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
