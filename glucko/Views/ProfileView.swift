import SwiftUI

struct ProfileView: View {
    @Binding var showProfile: Bool
    @State private var showDesignSystem = false
    @State private var showLogoutAlert = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: { 
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showProfile = false
                    }
                }) {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 44, height: 44)
                        .overlay(
                            Image("chevron-left")
                                .resizable()
                                .renderingMode(.original)
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                        )
                        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 4)
                }
                Spacer()
                Text("Profile")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.black)
                Spacer()
                // Placeholder for alignment
                Color.clear.frame(width: 44, height: 44)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 4)
            
            // Profile Card
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 56, height: 56)
                    
                    // Show user's profile picture if available
                    if let pictureURL = UserDefaults.standard.string(forKey: "userProfilePicture"),
                       !pictureURL.isEmpty {
                        AsyncImage(url: URL(string: pictureURL)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 52, height: 52)
                                .clipShape(Circle())
                        } placeholder: {
                            Image("profile_photo_placeholder")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 52, height: 52)
                                .clipShape(Circle())
                        }
                    } else {
                        Image("profile_photo_placeholder")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 52, height: 52)
                            .clipShape(Circle())
                    }
                }
                VStack(alignment: .leading, spacing: 4) {
                    let username = UserDefaults.standard.string(forKey: "username") ?? "User"
                    let userEmail = UserDefaults.standard.string(forKey: "userEmail") ?? "user@example.com"
                    
                    Text(username)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)
                    Text(userEmail)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                .onAppear {
                    print("👤 ProfileView loaded with:")
                    print("   - username: \(UserDefaults.standard.string(forKey: "username") ?? "nil")")
                    print("   - userEmail: \(UserDefaults.standard.string(forKey: "userEmail") ?? "nil")")
                    print("   - userProfilePicture: \(UserDefaults.standard.string(forKey: "userProfilePicture") ?? "nil")")
                    print("   - authProvider: \(UserDefaults.standard.string(forKey: "authProvider") ?? "nil")")
                }
                Spacer()
                Button(action: { /* Edit action */ }) {
                    Image("edit")
                        .resizable()
                        .renderingMode(.original)
                        .scaledToFit()
                        .frame(width: 22, height: 22)
                        .padding(8)
                        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 4)
                }
            }
            .padding(20)
            .background(Color.white)
            .cornerRadius(24)
            .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 4)
            .padding(.horizontal, 16)
            .padding(.top, 8)
            
            // Options List
            VStack(spacing: 0) {
                ProfileOptionRow(icon: "chat", label: "Q&A history")
                ProfileOptionRow(icon: "bell", label: "Notification Preference")
                ProfileOptionRow(icon: "email", label: "Support & Feedback")
                ProfileOptionRow(icon: "user", label: "Account Security")
                ProfileOptionRow(icon: "setting", label: "Settings")
                ProfileOptionRow(icon: "line.3.horizontal", label: "UI Components") {
                    showDesignSystem = true
                }
            }
            .background(Color.white)
            .cornerRadius(24)
            .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 4)
            .padding(.horizontal, 16)
            .padding(.top, 16)
            
            // Logout Button
            Button(action: logout) {
                HStack {
                    Image("logout")
                        .resizable()
                        .renderingMode(.original)
                        .scaledToFit()
                        .frame(width: 28, height: 28)
                        .foregroundColor(.red)
                    Text("Logout")
                        .font(.system(size: 16))
                        .foregroundColor(.red)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 18)
                .background(Color.white)
            }
            .buttonStyle(PlainButtonStyle())
            .contentShape(Rectangle())
            
            // DEBUG: Quick logout test button
            Button(action: performLogout) {
                HStack {
                    Image(systemName: "wrench.and.screwdriver")
                        .foregroundColor(.orange)
                    Text("DEBUG: Quick Logout")
                        .font(.system(size: 16))
                        .foregroundColor(.orange)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 18)
                .background(Color.white)
            }
            .buttonStyle(PlainButtonStyle())
            .contentShape(Rectangle())
            
            Spacer()
        }
#if os(iOS)
        .background(Color(red: 0.97, green: 0.97, blue: 0.97).ignoresSafeArea())
        .navigationBarHidden(true)
        .sheet(isPresented: $showDesignSystem) {
            DesignSystemView()
        }
        .alert("Logout", isPresented: $showLogoutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Logout", role: .destructive) {
                performLogout()
            }
        } message: {
            Text("Are you sure you want to logout?")
        }
#else
        .background(Color.gray.opacity(0.1))
#endif
    }
    
    private func logout() {
        showLogoutAlert = true
    }
    
    private func performLogout() {
        print("🚪 Logging out user...")
        
        // Clear user authentication data
        UserDefaults.standard.set(false, forKey: "isAuthenticated")
        UserDefaults.standard.set(false, forKey: "onboardingCompleted")
        UserDefaults.standard.removeObject(forKey: "username")
        UserDefaults.standard.removeObject(forKey: "userEmail")
        UserDefaults.standard.removeObject(forKey: "lastLoginDate")
        UserDefaults.standard.removeObject(forKey: "userProfilePicture")
        UserDefaults.standard.removeObject(forKey: "authProvider")
        
        // Force UserDefaults to save immediately
        UserDefaults.standard.synchronize()
        
        // Sign out from Supabase
        Task {
            do {
                try await SupabaseService.shared.signOut()
                print("✅ Supabase sign out successful")
            } catch {
                print("❌ Supabase sign out failed: \(error.localizedDescription)")
            }
        }
        
        // Sign out from Google if signed in
        GoogleSignInService.shared.signOut()
        
        // Sign out from Apple if signed in
        AppleSignInService.shared.signOut()
        
        print("✅ User logged out successfully")
        print("🔄 Resetting app to onboarding...")
        
        // Dismiss the profile view
        withAnimation(.easeInOut(duration: 0.3)) {
            showProfile = false
        }
        
        // Post notification to trigger authentication state refresh
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            NotificationCenter.default.post(name: Notification.Name("userDidLogout"), object: nil)
            print("📢 Posted userDidLogout notification")
        }
    }
}

struct ProfileOptionRow: View {
    let icon: String
    let label: String
    let action: (() -> Void)?
    
    init(icon: String, label: String, action: (() -> Void)? = nil) {
        self.icon = icon
        self.label = label
        self.action = action
    }
    
    var body: some View {
        Button(action: { action?() }) {
            HStack(spacing: 16) {
                Image(icon)
                    .resizable()
                    .renderingMode(.original)
                    .scaledToFit()
                    .frame(width: 28, height: 28)
                    .foregroundColor(.black)
                Text(label)
                    .font(.system(size: 16))
                    .foregroundColor(.black)
                Spacer()
                Image("chevron-right")
                    .resizable()
                    .renderingMode(.original)
                    .scaledToFit()
                    .frame(width: 18, height: 18)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
            .background(Color.white)
        }
        .buttonStyle(PlainButtonStyle())
        .contentShape(Rectangle())
    }
}

#Preview {
    ProfileView(showProfile: .constant(true))
} 
