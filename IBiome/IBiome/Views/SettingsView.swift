import SwiftUI
import HealthKit

struct SettingsView: View {
    @EnvironmentObject private var healthKitManager: HealthKitManager
    @EnvironmentObject private var authManager: AuthenticationManager
    @State private var isHealthKitAuthorizing = false
    @State private var showingHealthKitError = false
    @State private var showingOuraError = false
    @State private var healthKitError: Error?
    @State private var ouraError: Error?
    @State private var showingSuccessToast = false
    
    var body: some View {
        List {
            Section(header: Text("Health Integrations")) {
                // Apple Health
                HStack {
                    Label {
                        VStack(alignment: .leading) {
                            Text("Apple Health")
                                .font(.headline)
                            Text("Sync health and activity data")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    } icon: {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                    }
                    
                    Spacer()
                    
                    if isHealthKitAuthorizing {
                        ProgressView()
                    } else {
                        Button(healthKitManager.isAuthorized ? "Connected" : "Connect") {
                            handleHealthKitToggle()
                        }
                        .buttonStyle(.bordered)
                        .disabled(healthKitManager.isAuthorized)
                        .tint(healthKitManager.isAuthorized ? .gray : .blue)
                    }
                }
                
                // Oura Ring
                HStack {
                    Label {
                        VStack(alignment: .leading) {
                            Text("Oura Ring")
                                .font(.headline)
                            Text("Sync sleep and recovery data")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    } icon: {
                        Image(systemName: "circle.circle.fill")
                            .foregroundColor(.purple)
                    }
                    
                    Spacer()
                    
                    Button(healthKitManager.isOuraConnected ? "Connected" : "Connect") {
                        handleOuraRingConnect()
                    }
                    .buttonStyle(.bordered)
                    .disabled(healthKitManager.isOuraConnected)
                    .tint(healthKitManager.isOuraConnected ? .gray : .blue)
                }
            }
            
            Section(header: Text("Data Sync")) {
                HStack {
                    Text("Last synced")
                    Spacer()
                    Text(healthKitManager.lastSyncDate?.formatted() ?? "Never")
                        .foregroundColor(.secondary)
                }
                
                Button("Sync Now") {
                    Task {
                        await healthKitManager.refreshHealthData()
                    }
                }
            }
            
            Section(header: Text("Account")) {
                Button("Sign Out", role: .destructive) {
                    authManager.signOut()
                }
            }
        }
        .alert("HealthKit Error", isPresented: $showingHealthKitError) {
            Button("OK", role: .cancel) {}
            Button("Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
        } message: {
            Text(healthKitError?.localizedDescription ?? "Failed to connect to HealthKit")
        }
        .alert("Oura Ring Error", isPresented: $showingOuraError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(ouraError?.localizedDescription ?? "Failed to connect to Oura Ring")
        }
        .overlay {
            if showingSuccessToast {
                ToastView(message: "Successfully connected")
                    .transition(.move(edge: .top))
            }
        }
    }
    
    private func handleHealthKitToggle() {
        isHealthKitAuthorizing = true
        
        Task {
            do {
                try await healthKitManager.requestAuthorization()
                await MainActor.run {
                    showingSuccessToast = true
                    withAnimation {
                        isHealthKitAuthorizing = false
                    }
                }
                
                // Hide success toast after delay
                try await Task.sleep(nanoseconds: 2_000_000_000)
                await MainActor.run {
                    withAnimation {
                        showingSuccessToast = false
                    }
                }
            } catch {
                await MainActor.run {
                    healthKitError = error
                    showingHealthKitError = true
                    isHealthKitAuthorizing = false
                }
            }
        }
    }
    
    private func handleOuraRingConnect() {
        Task {
            do {
                try await healthKitManager.authorizeOuraRing()
            } catch {
                await MainActor.run {
                    ouraError = error
                    showingOuraError = true
                }
            }
        }
    }
}

struct ToastView: View {
    let message: String
    
    var body: some View {
        Text(message)
            .padding()
            .background(.thinMaterial)
            .cornerRadius(10)
            .padding(.top, 20)
    }
}

#Preview {
    SettingsView()
        .environmentObject(HealthKitManager.shared)
        .environmentObject(AuthenticationManager.shared)
}
