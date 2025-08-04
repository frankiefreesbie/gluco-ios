import Foundation
import GoogleSignIn
import GoogleSignInSwift

class GoogleSignInService: ObservableObject {
    @Published var isSignedIn = false
    @Published var userProfile: GIDProfileData?
    
    static let shared = GoogleSignInService()
    
    private init() {
        setupGoogleSignIn()
    }
    
    private func setupGoogleSignIn() {
        // Use the new client ID from the fresh OAuth client
        print("📱 Setting up Google Sign-In with new client ID")
        let clientId = "746406833823-t0sgfkdig2tm22m40n187llhv4mui8ck.apps.googleusercontent.com"
        print("📱 New Client ID: \(clientId)")
        
        let config = GIDConfiguration(clientID: clientId)
        GIDSignIn.sharedInstance.configuration = config
        
        print("📱 Google Sign-In configuration completed")
    }
    
    func isConfigured() -> Bool {
        return GIDSignIn.sharedInstance.configuration != nil
    }
    
    @MainActor
    func signIn() async throws -> (accessToken: String, user: GIDGoogleUser) {
        print("🔵 Google Sign-In: Starting on main thread")
        
        // Check if Google Sign-In is configured
        guard isConfigured() else {
            print("❌ Google Sign-In: Not configured")
            throw GoogleSignInError.notConfigured
        }
        
        print("🔵 Google Sign-In: Configuration verified")
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            print("❌ Google Sign-In: No root view controller found")
            throw GoogleSignInError.noRootViewController
        }
        
        print("🔵 Google Sign-In: Root view controller found, starting sign-in")
        print("🔵 Google Sign-In: About to call GIDSignIn.sharedInstance.signIn...")
        
        do {
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
            print("🔵 Google Sign-In: GIDSignIn.sharedInstance.signIn completed")
            
            let accessToken = result.user.accessToken.tokenString
            print("🔵 Google Sign-In: Access token received")
            
            self.isSignedIn = true
            self.userProfile = result.user.profile
            print("🔵 Google Sign-In: Service state updated")
            
            print("✅ Google Sign-In: Successfully completed")
            return (accessToken, result.user)
        } catch {
            print("❌ Google Sign-In: Error during sign-in: \(error.localizedDescription)")
            print("❌ Google Sign-In: Error type: \(type(of: error))")
            throw GoogleSignInError.signInFailed
        }
    }
    
    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        isSignedIn = false
        userProfile = nil
    }
    
    @MainActor
    func restoreSignIn() async throws {
        let result = try await GIDSignIn.sharedInstance.restorePreviousSignIn()
        
        self.isSignedIn = true
        self.userProfile = result.profile
    }
}

enum GoogleSignInError: Error, LocalizedError {
    case noRootViewController
    case noAccessToken
    case noPreviousSignIn
    case notConfigured
    case signInCancelled
    case signInFailed
    
    var errorDescription: String? {
        switch self {
        case .noRootViewController:
            return "No root view controller found"
        case .noAccessToken:
            return "No access token received from Google"
        case .noPreviousSignIn:
            return "No previous sign in found"
        case .notConfigured:
            return "Google Sign-In is not properly configured"
        case .signInCancelled:
            return "Google Sign-In was cancelled by the user"
        case .signInFailed:
            return "Google Sign-In failed"
        }
    }
} 