import SwiftUI
import AuthenticationServices

struct AuthenticationView: View {
    @EnvironmentObject private var authManager: AuthenticationManager
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            // App Logo/Branding
            Image(systemName: "globe.americas.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .foregroundColor(.accentColor)
            
            Text("IBiome")
                .font(.largeTitle)
                .bold()
            
            Text("Track your health in harmony with your environment")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
            
            // Sign In Button
            SignInWithAppleButton { request in
                request.requestedScopes = [.fullName, .email]
            } onCompletion: { result in
                Task {
                    do {
                        try await authManager.signIn()
                    } catch {
                        // Error is handled by AuthenticationManager
                    }
                }
            }
            .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
            .frame(height: 50)
            .padding(.horizontal)
            
            // Loading & Error States
            if authManager.isAuthenticating {
                ProgressView()
                    .padding()
            }
            
            if case .partial(let reason) = authManager.authState {
                PartialAuthView(reason: reason)
            }
            
            if let error = authManager.error {
                AuthErrorView(error: error)
            }
        }
        .padding()
    }
}

struct PartialAuthView: View {
    let reason: AuthenticationManager.PartialAuthReason
    
    var body: some View {
        VStack(spacing: 8) {
            Text(titleForReason)
                .font(.headline)
            
            Text(messageForReason)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            if let action = actionForReason {
                Button(action.title) {
                    action.handler()
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    private var titleForReason: String {
        switch reason {
        case .healthKitDenied:
            return "HealthKit Access Required"
        case .locationDenied:
            return "Location Access Required"
        case .deviceNotSupported:
            return "Device Not Supported"
        case .networkError:
            return "Connection Error"
        }
    }
    
    private var messageForReason: String {
        switch reason {
        case .healthKitDenied:
            return "IBiome needs access to HealthKit to track your health data"
        case .locationDenied:
            return "Location access is required to provide environmental insights"
        case .deviceNotSupported:
            return "Your device doesn't support some required features"
        case .networkError:
            return "Please check your internet connection"
        }
    }
    
    private var actionForReason: (title: String, handler: () -> Void)? {
        switch reason {
        case .healthKitDenied, .locationDenied:
            return ("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
        case .networkError:
            return ("Try Again") {
                // Implement retry logic
            }
        case .deviceNotSupported:
            return nil
        }
    }
}

struct AuthErrorView: View {
    let error: AuthenticationManager.AuthError
    
    var body: some View {
        VStack(spacing: 8) {
            Text(error.localizedDescription)
                .font(.subheadline)
                .foregroundColor(.red)
            
            if let suggestion = error.recoverySuggestion {
                Text(suggestion)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

#Preview {
    AuthenticationView()
        .environmentObject(AuthenticationManager.shared)
}
