import SwiftUI
import GoogleSignIn
import Supabase

struct AuthenticationView: View {
    @Binding var showAuthentication: Bool
    @State private var currentStep: AuthStep = .createAccount
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    // Form fields
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var useAI = true
    
    enum AuthStep {
        case createAccount
        case login
        case signup
        case confirmation
    }
    
    var body: some View {
        ZStack {
            Color(red: 0.97, green: 0.97, blue: 0.97).ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Navigation bar
                HStack {
                    if currentStep != .createAccount {
                        Button(action: goBack) {
                            Image("arrow-left")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.black)
                        }
                    }
                    
                    Spacer()
                    
                    Text(navigationTitle)
                        .font(.custom("Inter-Bold", size: 18))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    if currentStep != .createAccount {
                        // Invisible spacer to center the title
                        Image("arrow-left")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .opacity(0)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                
                // Main content
                ScrollView {
                    VStack(spacing: 32) {
                        switch currentStep {
                        case .createAccount:
                            createAccountView
                        case .login:
                            loginView
                        case .signup:
                            signupView
                        case .confirmation:
                            confirmationView
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 32)
                }
            }
        }
        .overlay(
            // Loading overlay
            Group {
                if isLoading {
                    ZStack {
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()
                        
                        VStack(spacing: 16) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(1.2)
                            
                            Text("Signing in...")
                                .font(.custom("Inter-Regular", size: 16))
                                .foregroundColor(.white)
                        }
                    }
                }
            }
        )
    }
    
    // MARK: - Navigation
    
    private var navigationTitle: String {
        switch currentStep {
        case .createAccount:
            return "Create account"
        case .login:
            return "Login"
        case .signup:
            return "Sign up"
        case .confirmation:
            return "Confirm email"
        }
    }
    
    private func goBack() {
        switch currentStep {
        case .createAccount:
            break
        case .login, .signup:
            currentStep = .createAccount
        case .confirmation:
            currentStep = .signup
        }
    }
    
    // MARK: - Create Account View
    
    private var createAccountView: some View {
        VStack(spacing: 32) {
            // Profile icon
            ZStack {
                Circle()
                    .fill(Color(red: 0.9, green: 0.9, blue: 0.9))
                    .frame(width: 80, height: 80)
                
                Image("user")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.gray)
            }
            
            // Title and description
            VStack(spacing: 16) {
                Text("Save your plan and start feeling better")
                    .font(.custom("Inter-Bold", size: 24))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                
                Text("Create an account to access your personalized meals and track your progress.")
                    .font(.custom("Inter-Regular", size: 16))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            
            // AI option
            HStack {
                Button(action: { useAI.toggle() }) {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .stroke(useAI ? Color(red: 1, green: 0.478, blue: 0.18) : Color.gray, lineWidth: 2)
                                .frame(width: 20, height: 20)
                            
                            if useAI {
                                Circle()
                                    .fill(Color(red: 1, green: 0.478, blue: 0.18))
                                    .frame(width: 12, height: 12)
                            }
                        }
                        
                        Text("Generate meals using AI")
                            .font(.custom("Inter-Regular", size: 16))
                            .foregroundColor(.black)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
            }
            
            // Action buttons
            VStack(spacing: 16) {
                // Apple Sign In
                Button(action: signInWithApple) {
                    HStack {
                        Image(systemName: "applelogo")
                            .foregroundColor(.white)
                        Text("Continue with Apple")
                            .font(.custom("Inter-Medium", size: 16))
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.black)
                    .cornerRadius(12)
                }
                
                // Google Sign In
                Button(action: {
                    print("🔵 Google Sign In button tapped!")
                    print("🔍 Google Sign-In configured: \(GoogleSignInService.shared.isConfigured())")
                    signInWithGoogle()
                }) {
                    HStack {
                        Image(systemName: "globe")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.blue)
                        Text("Continue with Google")
                            .font(.custom("Inter-Medium", size: 16))
                            .foregroundColor(.black)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                }
                
                // Email Sign In
                Button(action: { currentStep = .signup }) {
                    HStack {
                        Image(systemName: "envelope")
                            .foregroundColor(.white)
                        Text("Continue with Email")
                            .font(.custom("Inter-Medium", size: 16))
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color(red: 1, green: 0.478, blue: 0.18))
                    .cornerRadius(12)
                }
                
                // DEBUG: Manual authentication bypass
                Button(action: debugManualAuth) {
                    HStack {
                        Image(systemName: "wrench.and.screwdriver")
                            .foregroundColor(.white)
                        Text("Debug: Manual Auth")
                            .font(.custom("Inter-Medium", size: 16))
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.red)
                    .cornerRadius(12)
                }

            }
            
            Spacer()
            
            // Footer
            HStack {
                Text("Already have an account?")
                    .font(.custom("Inter-Regular", size: 14))
                    .foregroundColor(.gray)
                
                Button(action: { currentStep = .login }) {
                    Text("Login")
                        .font(.custom("Inter-Medium", size: 14))
                        .foregroundColor(.black)
                        .underline()
                }
            }
        }
    }
    
    // MARK: - Login View
    
    private var loginView: some View {
        VStack(spacing: 32) {
            // Input fields
            VStack(spacing: 16) {
                TextFieldWithIcon(
                    icon: "envelope",
                    placeholder: "Email address",
                    text: $email
                )
                
                TextFieldWithIcon(
                    icon: "lock",
                    placeholder: "Password",
                    text: $password,
                    isSecure: true
                )
            }
            
            // Error message
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .font(.custom("Inter-Regular", size: 14))
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }
            
            // Login button
            Button(action: login) {
                Text("Login")
                    .font(.custom("Inter-Medium", size: 16))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color(red: 1, green: 0.478, blue: 0.18))
                    .cornerRadius(12)
            }
            .disabled(email.isEmpty || password.isEmpty || isLoading)
            
            Spacer()
            
            // Footer
            HStack {
                Text("Are you new?")
                    .font(.custom("Inter-Regular", size: 14))
                    .foregroundColor(.gray)
                
                Button(action: { currentStep = .signup }) {
                    Text("Create an account")
                        .font(.custom("Inter-Medium", size: 14))
                        .foregroundColor(.black)
                        .underline()
                }
            }
        }
    }
    
    // MARK: - Signup View
    
    private var signupView: some View {
        VStack(spacing: 32) {
            // Input fields
            VStack(spacing: 16) {
                TextFieldWithIcon(
                    icon: "person",
                    placeholder: "Username",
                    text: $username
                )
                
                TextFieldWithIcon(
                    icon: "envelope",
                    placeholder: "Email address",
                    text: $email
                )
                
                TextFieldWithIcon(
                    icon: "lock",
                    placeholder: "Password",
                    text: $password,
                    isSecure: true
                )
            }
            
            // Error message
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .font(.custom("Inter-Regular", size: 14))
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }
            
            // Signup button
            Button(action: signup) {
                Text("Sign up")
                    .font(.custom("Inter-Medium", size: 16))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color(red: 1, green: 0.478, blue: 0.18))
                    .cornerRadius(12)
            }
            .disabled(username.isEmpty || email.isEmpty || password.isEmpty || isLoading)
            
            Spacer()
            
            // Footer
            HStack {
                Text("Already have an account?")
                    .font(.custom("Inter-Regular", size: 14))
                    .foregroundColor(.gray)
                
                Button(action: { currentStep = .login }) {
                    Text("Login")
                        .font(.custom("Inter-Medium", size: 14))
                        .foregroundColor(.black)
                        .underline()
                }
            }
        }
    }
    
    // MARK: - Authentication Methods
    
    private func signInWithApple() {
        print("🍎 Apple Sign In button pressed")
        isLoading = true
        errorMessage = nil
        
        print("⏳ Starting real Apple Sign In...")
        
        Task {
            do {
                let (identityToken, nonce) = try await AppleSignInService.shared.signIn()
                
                print("✅ Apple Sign In successful, signing in to Supabase...")
                print("🍎 User signed in with Apple ID")
                
                // Sign in to Supabase with Apple token
                let success = await signInToSupabaseWithApple(identityToken: identityToken, nonce: nonce)
                
                print("🔍 Supabase sign-in result: \(success)")
                isLoading = false
                if success {
                    print("🎉 Calling completeAuthentication()...")
                    completeAuthentication()
                } else {
                    print("❌ Supabase sign-in failed, showing error")
                    errorMessage = "Failed to sign in with Apple"
                }
            } catch {
                print("❌ Apple Sign In failed: \(error.localizedDescription)")
                print("❌ Error type: \(type(of: error))")
                isLoading = false
                errorMessage = error.localizedDescription
            }
        }
    }
    
    // DEBUG: Manual authentication bypass for testing
    private func debugManualAuth() {
        print("🔧 DEBUG: Manual authentication bypass")
        isLoading = true
        
        // Set some test user data for debugging
        UserDefaults.standard.set("debug@test.com", forKey: "userEmail")
        UserDefaults.standard.set("Debug User", forKey: "username")
        UserDefaults.standard.set("Debug", forKey: "authProvider")
        
        // Simulate a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            print("🔧 DEBUG: Completing manual authentication")
            self.isLoading = false
            self.completeAuthentication()
        }
    }
    
    private func signInToSupabaseWithApple(identityToken: String, nonce: String) async -> Bool {
        print("🔗 Signing in to Supabase with Apple...")
        
        do {
                            // Sign in to Supabase with Apple
                let session = try await SupabaseService.shared.signInWithApple(identityToken: identityToken, nonce: nonce)
                
                // For Apple Sign-In, we get limited user data
                // Email and name are only provided on first sign-in
                let email = UserDefaults.standard.string(forKey: "userEmail") ?? "Apple User"
                let name = UserDefaults.standard.string(forKey: "username") ?? "Apple User"
                
                print("📧 Email: \(email)")
                print("👤 Name: \(name)")
                
                // Save user data to UserDefaults
                UserDefaults.standard.set(email, forKey: "userEmail")
                UserDefaults.standard.set(name, forKey: "username")
                UserDefaults.standard.set("Apple", forKey: "authProvider")
                
                // Create/update user profile in Supabase
                let userId = session.user.id.uuidString
                try await SupabaseService.shared.upsertUserProfile(
                    userId: userId,
                    username: name,
                    email: email,
                    authProvider: "Apple"
                )
            
            print("💾 Apple user data saved to app and Supabase")
            return true
            
        } catch {
            print("❌ Supabase Apple sign in failed: \(error.localizedDescription)")
            return false
        }
    }
    
    private func signInWithGoogle() {
        print("🔵 Google Sign In button pressed")
        isLoading = true
        errorMessage = nil
        
        // Check if Google Sign-In is properly configured
        guard GoogleSignInService.shared.isConfigured() else {
            print("❌ Google Sign-In not configured")
            isLoading = false
            errorMessage = "Google Sign-In is not properly configured"
            return
        }
        
        print("⏳ Starting real Google Sign In...")
        
        // Ensure we're on the main thread when starting the Google Sign-In process
        Task { @MainActor in
            do {
                print("🔵 Calling GoogleSignInService.shared.signIn()...")
                let (accessToken, user) = try await GoogleSignInService.shared.signIn()
                
                print("✅ Google Sign In successful, signing in to Supabase...")
                print("👤 User signed in: \(user.profile?.email ?? "Unknown email")")
                print("👤 User name: \(user.profile?.name ?? "Unknown name")")
                print("🔑 Access token received: \(accessToken.prefix(20))...")
                
                // Get the ID token for Supabase authentication
                guard let idToken = user.idToken?.tokenString else {
                    print("❌ No ID token available for Supabase authentication")
                    isLoading = false
                    errorMessage = "Failed to get authentication token"
                    return
                }
                
                print("🆔 ID token received: \(idToken.prefix(20))...")
                
                // Sign in to Supabase with Google ID token
                print("🔗 Starting Supabase sign-in...")
                let success = await signInToSupabaseWithGoogle(idToken: idToken, user: user)
                
                print("🔍 Supabase sign-in result: \(success)")
                isLoading = false
                if success {
                    print("🎉 Calling completeAuthentication()...")
                    completeAuthentication()
                } else {
                    print("❌ Supabase sign-in failed, showing error")
                    errorMessage = "Failed to sign in with Google"
                }
            } catch {
                print("❌ Google Sign In failed: \(error.localizedDescription)")
                print("❌ Error type: \(type(of: error))")
                isLoading = false
                errorMessage = error.localizedDescription
            }
        }
    }
    
    private func signInToSupabaseWithGoogle(idToken: String, user: GIDGoogleUser) async -> Bool {
        print("🔗 Signing in to Supabase with Google...")
        
        do {
            print("🔗 Calling SupabaseService.shared.signInWithGoogle()...")
            // Sign in to Supabase with Google
            let session = try await SupabaseService.shared.signInWithGoogle(accessToken: idToken)
            print("✅ Supabase sign-in successful, session user ID: \(session.user.id.uuidString)")
            
            // Extract user information from Google user
            let email = user.profile?.email ?? ""
            let name = user.profile?.name ?? ""
            let pictureURL = user.profile?.imageURL(withDimension: 120)?.absoluteString ?? ""
            
            print("📧 Email: \(email)")
            print("👤 Name: \(name)")
            print("🖼️ Picture URL: \(pictureURL)")
            
            // Save user data to UserDefaults
            print("💾 Saving user data to UserDefaults...")
            UserDefaults.standard.set(email, forKey: "userEmail")
            UserDefaults.standard.set(name, forKey: "username")
            UserDefaults.standard.set(pictureURL, forKey: "userProfilePicture")
            UserDefaults.standard.set("Google", forKey: "authProvider")
            
                            // Create/update user profile in Supabase
                print("👤 Creating/updating user profile in Supabase...")
                let userId = session.user.id.uuidString
                print("🆔 User ID for profile: \(userId)")
                
                do {
                    try await SupabaseService.shared.upsertUserProfile(
                        userId: userId,
                        username: name,
                        email: email,
                        authProvider: "Google"
                    )
                    print("✅ User profile created/updated in Supabase")
                } catch {
                    print("❌ Failed to create user profile: \(error.localizedDescription)")
                    print("❌ Profile creation error type: \(type(of: error))")
                    // Continue with authentication even if profile creation fails
                }
        
            print("💾 Google user data saved to app and Supabase")
            return true
            
        } catch {
            print("❌ Supabase Google sign in failed: \(error.localizedDescription)")
            print("❌ Error type: \(type(of: error))")
            return false
        }
    }
    
    private func login() {
        print("📧 Email login started")
        isLoading = true
        errorMessage = nil
        
        // Validate inputs
        guard !email.isEmpty, !password.isEmpty else {
            print("❌ Validation failed: missing fields")
            errorMessage = "Please fill in all fields"
            isLoading = false
            return
        }
        
        print("✅ Validation passed, calling Supabase signin...")
        print("📧 Email: \(email)")
        
        Task {
            do {
                print("🔗 Calling SupabaseService.shared.signIn()...")
                // Sign in to Supabase
                let session = try await SupabaseService.shared.signIn(email: email, password: password)
                print("✅ Supabase login successful, session user ID: \(session.user.id.uuidString)")
                
                await MainActor.run {
                    isLoading = false
                    
                    // Get user profile from Supabase
                    let userId = session.user.id.uuidString
                    Task {
                        do {
                            if let profile = try await SupabaseService.shared.getUserProfile(userId: userId) {
                                // Update local data with profile from Supabase
                                UserDefaults.standard.set(profile["username"] as? String ?? email, forKey: "username")
                                UserDefaults.standard.set(profile["email"] as? String ?? email, forKey: "userEmail")
                                UserDefaults.standard.set(profile["auth_provider"] as? String ?? "Email", forKey: "authProvider")
                            }
                        } catch {
                            print("❌ Failed to get user profile: \(error.localizedDescription)")
                            // Continue anyway - we have the basic user data
                        }
                    }
                    
                    print("🎉 Calling completeAuthentication()...")
                    completeAuthentication()
                }
                
            } catch {
                print("❌ Supabase login failed: \(error.localizedDescription)")
                print("❌ Error type: \(type(of: error))")
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Invalid email or password"
                }
            }
        }
    }
    
    private func signup() {
        print("📧 Email signup started")
        isLoading = true
        errorMessage = nil
        
        // Validate inputs
        guard !username.isEmpty, !email.isEmpty, !password.isEmpty else {
            print("❌ Validation failed: missing fields")
            errorMessage = "Please fill in all fields"
            isLoading = false
            return
        }
        
        guard email.contains("@") else {
            print("❌ Validation failed: invalid email")
            errorMessage = "Please enter a valid email address"
            isLoading = false
            return
        }
        
        guard password.count >= 6 else {
            print("❌ Validation failed: password too short")
            errorMessage = "Password must be at least 6 characters"
            isLoading = false
            return
        }
        
        print("✅ Validation passed, calling Supabase signup...")
        print("📧 Email: \(email)")
        print("👤 Username: \(username)")
        
        Task {
            do {
                print("🔗 Calling SupabaseService.shared.signUp()...")
                // Sign up to Supabase
                let session = try await SupabaseService.shared.signUp(email: email, password: password, username: username)
                print("✅ Supabase signup successful, session user ID: \(session.user.id.uuidString)")
                
                await MainActor.run {
                    isLoading = false
                    
                    // Try to create user profile in Supabase
                    let userId = session.user.id.uuidString
                    Task {
                        do {
                            try await SupabaseService.shared.upsertUserProfile(
                                userId: userId,
                                username: username,
                                email: email,
                                authProvider: "Email"
                            )
                            print("✅ User profile created successfully")
                        } catch {
                            print("❌ Failed to create user profile: \(error.localizedDescription)")
                            // Continue anyway - the user is still authenticated
                        }
                    }
                    
                    print("🎉 Calling completeAuthentication()...")
                    completeAuthentication()
                }
                
            } catch {
                print("❌ Supabase signup failed: \(error.localizedDescription)")
                print("❌ Error type: \(type(of: error))")
                print("❌ Full error: \(error)")
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Failed to create account. Please try again."
                }
            }
        }
    }
    

    
    private func completeAuthentication() {
        print("🔐 Authentication completed successfully!")
        
        // Save user authentication status and preferences
        print("💾 Setting authentication flags...")
        UserDefaults.standard.set(true, forKey: "isAuthenticated")
        UserDefaults.standard.set(useAI, forKey: "useAI")
        UserDefaults.standard.set(Date(), forKey: "lastLoginDate")
        
        // Save onboarding completion
        UserDefaults.standard.set(true, forKey: "onboardingCompleted")
        
        // For Google Sign-In, we need to save the user data from the Google service
        if let googleUser = GoogleSignInService.shared.userProfile {
            print("💾 Saving Google user data...")
            UserDefaults.standard.set(googleUser.email ?? "", forKey: "userEmail")
            UserDefaults.standard.set(googleUser.name ?? "", forKey: "username")
            UserDefaults.standard.set("Google", forKey: "authProvider")
            
            // Try to get profile picture URL
            if let pictureURL = googleUser.imageURL(withDimension: 120)?.absoluteString {
                UserDefaults.standard.set(pictureURL, forKey: "userProfilePicture")
            }
        } else {
            // For email authentication, save the form data
            print("💾 Saving email user data...")
            UserDefaults.standard.set(username.isEmpty ? email : username, forKey: "username")
            UserDefaults.standard.set(email, forKey: "userEmail")
            UserDefaults.standard.set("Email", forKey: "authProvider")
            
            // Clear any previous profile picture (email login doesn't have one)
            UserDefaults.standard.removeObject(forKey: "userProfilePicture")
        }
        
        // Force UserDefaults to save immediately
        UserDefaults.standard.synchronize()
        
        print("💾 User preferences and authentication status saved")
        print("🔍 Verifying saved values:")
        print("   - isAuthenticated: \(UserDefaults.standard.bool(forKey: "isAuthenticated"))")
        print("   - onboardingCompleted: \(UserDefaults.standard.bool(forKey: "onboardingCompleted"))")
        print("   - username: \(UserDefaults.standard.string(forKey: "username") ?? "nil")")
        print("   - userEmail: \(UserDefaults.standard.string(forKey: "userEmail") ?? "nil")")
        print("   - userProfilePicture: \(UserDefaults.standard.string(forKey: "userProfilePicture") ?? "nil")")
        print("   - authProvider: \(UserDefaults.standard.string(forKey: "authProvider") ?? "nil")")
        
        print("🚪 Closing authentication view...")
        
        // Close authentication view immediately after UserDefaults are saved
        self.showAuthentication = false
        print("✅ showAuthentication set to false immediately")
        
        print("✅ Authentication flow completed")
    }
    
    // MARK: - Confirmation View
    
    private var confirmationView: some View {
        VStack(spacing: 32) {
            // Email icon
            ZStack {
                Circle()
                    .fill(Color(red: 0.95, green: 0.95, blue: 0.97))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "envelope.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.blue)
            }
            
            // Title and description
            VStack(spacing: 16) {
                Text("Check your email")
                    .font(.custom("Inter-Bold", size: 24))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                
                Text("We've sent a confirmation link to\n\(UserDefaults.standard.string(forKey: "tempEmail") ?? email)")
                    .font(.custom("Inter-Regular", size: 16))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                
                Text("Click the link in your email to verify your account and complete your registration.")
                    .font(.custom("Inter-Regular", size: 14))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)
            }
            
            // Resend button
            Button(action: resendConfirmation) {
                Text("Resend confirmation email")
                    .font(.custom("Inter-Medium", size: 16))
                    .foregroundColor(.blue)
                    .underline()
            }
            
            Spacer()
            
            // Continue button (for demo purposes, simulates email confirmation)
            Button(action: confirmEmail) {
                Text("I've confirmed my email")
                    .font(.custom("Inter-Medium", size: 16))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color(red: 1, green: 0.478, blue: 0.18))
                    .cornerRadius(12)
            }
        }
    }
    
    private func resendConfirmation() {
        print("📧 Resending confirmation email...")
        // TODO: Implement resend confirmation email
        // For now, just show a success message
    }
    
    private func confirmEmail() {
        print("✅ Email confirmed, completing registration...")
        isLoading = true
        
        // Get the saved signup data
        let savedUsername = UserDefaults.standard.string(forKey: "tempUsername") ?? ""
        let savedEmail = UserDefaults.standard.string(forKey: "tempEmail") ?? ""
        let savedPassword = UserDefaults.standard.string(forKey: "tempPassword") ?? ""
        
        Task {
            do {
                // Try to sign in with the saved credentials
                let session = try await SupabaseService.shared.signIn(email: savedEmail, password: savedPassword)
                
                await MainActor.run {
                    isLoading = false
                    
                    // Create user profile in Supabase
                    let userId = session.user.id.uuidString
                    Task {
                        do {
                            try await SupabaseService.shared.upsertUserProfile(
                                userId: userId,
                                username: savedUsername,
                                email: savedEmail,
                                authProvider: "Email"
                            )
                        } catch {
                            print("❌ Failed to create user profile: \(error.localizedDescription)")
                        }
                    }
                    
                    // Save the final user data
                    UserDefaults.standard.set(true, forKey: "isAuthenticated")
                    UserDefaults.standard.set(useAI, forKey: "useAI")
                    UserDefaults.standard.set(Date(), forKey: "lastLoginDate")
                    UserDefaults.standard.set(true, forKey: "onboardingCompleted")
                    UserDefaults.standard.set(savedUsername, forKey: "username")
                    UserDefaults.standard.set(savedEmail, forKey: "userEmail")
                    UserDefaults.standard.set("Email", forKey: "authProvider")
                    UserDefaults.standard.removeObject(forKey: "userProfilePicture")
                    
                    // Clear temporary data
                    UserDefaults.standard.removeObject(forKey: "tempUsername")
                    UserDefaults.standard.removeObject(forKey: "tempEmail")
                    UserDefaults.standard.removeObject(forKey: "tempPassword")
                    
                    UserDefaults.standard.synchronize()
                    
                    print("💾 Email registration completed")
                    print("🔍 Final saved values:")
                    print("   - username: \(UserDefaults.standard.string(forKey: "username") ?? "nil")")
                    print("   - userEmail: \(UserDefaults.standard.string(forKey: "userEmail") ?? "nil")")
                    print("   - authProvider: \(UserDefaults.standard.string(forKey: "authProvider") ?? "nil")")
                    
                    // Close authentication view immediately
                    self.showAuthentication = false
                    print("✅ Email registration flow completed")
                }
                
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Failed to confirm email. Please try again."
                }
            }
        }
    }
}

// MARK: - Custom Text Field Components

struct TextFieldWithIcon: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.gray)
                .frame(width: 20)
            
            if isSecure {
                SecureField(placeholder, text: $text)
                    .disableAutocorrection(true)
            } else {
                TextField(placeholder, text: $text)
                    .disableAutocorrection(true)
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 50)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    AuthenticationView(showAuthentication: .constant(true))
} 