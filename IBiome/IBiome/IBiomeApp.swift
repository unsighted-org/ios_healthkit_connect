import SwiftUI

@main
struct IBiomeApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var authManager = AuthenticationManager.shared
    @StateObject private var healthKitManager = HealthKitManager.shared
    @StateObject private var locationManager = LocationManager.shared
    
    var body: some Scene {
        WindowGroup {
            Group {
                if authManager.isAuthenticated {
                    MainTabView()
                        .environmentObject(authManager)
                        .environmentObject(healthKitManager)
                        .environmentObject(locationManager)
                        .onAppear {
                            healthKitManager.requestAuthorization()
                            locationManager.requestAuthorization()
                        }
                } else {
                    LoginView()
                        .environmentObject(authManager)
                }
            }
            .alert(item: Binding(
                get: { getFirstError() },
                set: { _ in clearErrors() }
            )) { error in
                Alert(
                    title: Text("Error"),
                    message: Text(error.errorDescription ?? "An unknown error occurred"),
                    primaryButton: .default(Text("Settings"), action: openSettings),
                    secondaryButton: .cancel()
                )
            }
        }
    }
    
    private func getFirstError() -> AppError? {
        return healthKitManager.error ?? locationManager.error ?? authManager.error
    }
    
    private func clearErrors() {
        healthKitManager.error = nil
        locationManager.error = nil
        authManager.error = nil
    }
    
    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}
