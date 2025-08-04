import Foundation
import Supabase
import Auth
import PostgREST
import Storage

enum AuthError: Error {
    case sessionNotFound
}

class SupabaseService: ObservableObject {
    static let shared = SupabaseService()
    
    private let client: SupabaseClient
    
    // MARK: - Configuration
    // Supabase project credentials
    private let supabaseURL = "https://paafbaftnlwhboshwwxf.supabase.co"
    private let supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBhYWZiYWZ0bmx3aGJvc2h3d3hmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM0NTA1NzYsImV4cCI6MjA2OTAyNjU3Nn0.9-gYkEgzmRB6TX-shu9S0qz2cNlyEb_XqCW-QfSfp2k"
    
    private init() {
        self.client = SupabaseClient(
            supabaseURL: URL(string: supabaseURL)!,
            supabaseKey: supabaseAnonKey
        )
        print("🔧 Supabase client initialized")
        print("🔧 Supabase URL: \(supabaseURL)")
        print("🔧 Supabase Key: \(supabaseAnonKey.prefix(20))...")
        
        // Test the connection
        Task {
            do {
                let response = try await client.database.from("profiles").select().limit(1).execute()
                print("✅ Supabase connection test successful")
            } catch {
                print("❌ Supabase connection test failed: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Authentication Methods
    
    // Email Sign Up
    func signUp(email: String, password: String, username: String) async throws -> Session {
        print("📧 Supabase: Signing up with email: \(email)")
        print("👤 Username: \(username)")
        print("🔧 Supabase client URL: \(supabaseURL)")
        
        do {
            print("🔗 Calling client.auth.signUp...")
            let response = try await client.auth.signUp(
                email: email,
                password: password
                // Temporarily removed data parameter to isolate the issue
            )
            
            print("✅ Supabase: Sign up response received")
            print("📧 User email: \(response.user.email)")
            print("🆔 User ID: \(response.user.id.uuidString)")
            print("📧 Session exists: \(response.session != nil)")
            print("📧 User confirmed: \(response.user.emailConfirmedAt != nil)")
            
            guard let session = response.session else {
                print("❌ Supabase: No session in response")
                throw AuthError.sessionNotFound
            }
            
            print("✅ Supabase: Sign up successful with session")
            return session
        } catch {
            print("❌ Supabase: Sign up failed with error: \(error.localizedDescription)")
            print("❌ Error type: \(type(of: error))")
            print("❌ Error details: \(error)")
            
            // Try to get more specific error information
            if let authError = error as? AuthError {
                print("❌ AuthError: \(authError)")
            }
            
            throw error
        }
    }
    
    // Email Sign In
    func signIn(email: String, password: String) async throws -> Session {
        print("📧 Supabase: Signing in with email: \(email)")
        
        let session = try await client.auth.signIn(
            email: email,
            password: password
        )
        
        print("✅ Supabase: Sign in successful")
        return session
    }
    
    // Google Sign In
    func signInWithGoogle(accessToken: String) async throws -> Session {
        print("🔵 Supabase: Signing in with Google")
        
        let session = try await client.auth.signInWithIdToken(
            credentials: .init(
                provider: .google,
                idToken: accessToken
            )
        )
        
        print("✅ Supabase: Google sign in successful")
        return session
    }
    
    // Apple Sign In
    func signInWithApple(identityToken: String, nonce: String) async throws -> Session {
        print("🍎 Supabase: Signing in with Apple")
        
        let session = try await client.auth.signInWithIdToken(
            credentials: .init(
                provider: .apple,
                idToken: identityToken,
                nonce: nonce
            )
        )
        
        print("✅ Supabase: Apple sign in successful")
        return session
    }
    
    // Sign Out
    func signOut() async throws {
        print("🚪 Supabase: Signing out")
        
        try await client.auth.signOut()
        
        print("✅ Supabase: Sign out successful")
    }
    
    // Get Current User
    func getCurrentUser() async -> User? {
        do {
            let session = try await client.auth.session
            return session.user
        } catch {
            return nil
        }
    }
    
    // Check if user is authenticated
    func isAuthenticated() async -> Bool {
        do {
            _ = try await client.auth.session
            return true
        } catch {
            return false
        }
    }
    
    // MARK: - User Profile Methods
    
    // Create or update user profile
    func upsertUserProfile(userId: String, username: String, email: String, authProvider: String) async throws {
        print("👤 Supabase: Upserting user profile for \(userId)")
        
        let profileData: [String: AnyJSON] = [
            "id": .string(userId),
            "username": .string(username),
            "email": .string(email),
            "auth_provider": .string(authProvider)
            // Removed updated_at - let the database handle it with default value
        ]
        
        print("📊 Profile data to insert: \(profileData)")
        
        try await client
            .from("profiles")
            .upsert(profileData)
            .execute()
        
        print("✅ Supabase: User profile upserted successfully")
    }
    
    // Get user profile
    func getUserProfile(userId: String) async throws -> [String: Any]? {
        print("👤 Supabase: Getting user profile for \(userId)")
        
        let response = try await client
            .from("profiles")
            .select()
            .eq("id", value: userId)
            .single()
            .execute()
        
        print("✅ Supabase: User profile retrieved successfully")
        
        // Convert response data to dictionary
        let data = response.data
        return try JSONSerialization.jsonObject(with: data) as? [String: Any]
    }
    
    // MARK: - Password Reset
    
    func resetPassword(email: String) async throws {
        print("🔐 Supabase: Sending password reset email to \(email)")
        
        try await client.auth.resetPasswordForEmail(
            email,
            redirectTo: nil
        )
        
        print("✅ Supabase: Password reset email sent")
    }
    
    // MARK: - Session Management
    
    // Get current session
    func getCurrentSession() async -> Session? {
        do {
            return try await client.auth.session
        } catch {
            return nil
        }
    }
    
    // Refresh session
    func refreshSession() async throws {
        print("🔄 Supabase: Refreshing session")
        
        try await client.auth.refreshSession()
        
        print("✅ Supabase: Session refreshed successfully")
    }
} 