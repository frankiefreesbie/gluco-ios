import Foundation
import AuthenticationServices
import CryptoKit
import UIKit

class AppleSignInService: NSObject, ObservableObject {
    @Published var isSignedIn = false
    @Published var userProfile: PersonNameComponents?
    
    static let shared = AppleSignInService()
    
    private var currentNonce: String?
    
    private override init() {
        super.init()
    }
    
    func signIn() async throws -> (identityToken: String, nonce: String) {
        let nonce = randomNonceString()
        currentNonce = nonce
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        
        return try await withCheckedThrowingContinuation { continuation in
            self.signInContinuation = continuation
            authorizationController.performRequests()
        }
    }
    
    func signOut() {
        isSignedIn = false
        userProfile = nil
    }
    
    // MARK: - Helper Methods
    
    private var signInContinuation: CheckedContinuation<(identityToken: String, nonce: String), Error>?
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
}

// MARK: - ASAuthorizationControllerDelegate

extension AppleSignInService: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let identityToken = appleIDCredential.identityToken,
              let identityTokenString = String(data: identityToken, encoding: .utf8),
              let nonce = currentNonce else {
            signInContinuation?.resume(throwing: AppleSignInError.invalidCredential)
            return
        }
        
        DispatchQueue.main.async {
            self.isSignedIn = true
            self.userProfile = appleIDCredential.fullName
        }
        
        signInContinuation?.resume(returning: (identityToken: identityTokenString, nonce: nonce))
        signInContinuation = nil
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        signInContinuation?.resume(throwing: error)
        signInContinuation = nil
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding

extension AppleSignInService: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            fatalError("No window found")
        }
        return window
    }
}

// MARK: - Error Types

enum AppleSignInError: Error, LocalizedError {
    case invalidCredential
    case noIdentityToken
    
    var errorDescription: String? {
        switch self {
        case .invalidCredential:
            return "Invalid Apple Sign In credential"
        case .noIdentityToken:
            return "No identity token received from Apple"
        }
    }
} 