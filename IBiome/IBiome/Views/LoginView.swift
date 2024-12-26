import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @ObservedObject private var authManager = AuthenticationManager.shared
    
    var body: some View {
        VStack(spacing: 20) {
            Text("IBiome")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Track your health and environmental impact")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            SignInWithAppleButton(
                .signIn,
                onRequest: { request in
                    request.requestedScopes = [.fullName, .email]
                },
                onCompletion: { result in
                    switch result {
                    case .success(let authResults):
                        print("Authorization successful")
                        if let appleIDCredential = authResults.credential as? ASAuthorizationAppleIDCredential {
                            let userIdentifier = appleIDCredential.user
                            authManager.userID = userIdentifier
                            authManager.isAuthenticated = true
                            
                            // Request HealthKit authorization after successful login
                            HealthKitManager.shared.requestAuthorization()
                        }
                    case .failure(let error):
                        print("Authorization failed: " + error.localizedDescription)
                        authManager.error = error
                    }
                }
            )
            .frame(height: 50)
            .padding(.horizontal, 40)
            
            Spacer()
        }
        .padding()
        .alert(item: Binding(
            get: { authManager.error.map { AuthError(error: $0) } },
            set: { _ in authManager.error = nil }
        )) { authError in
            Alert(
                title: Text("Authentication Error"),
                message: Text(authError.error.localizedDescription),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

struct AuthError: Identifiable {
    let id = UUID()
    let error: Error
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
