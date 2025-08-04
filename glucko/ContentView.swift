import SwiftUI
#if os(iOS)
import UIKit
#endif

struct ContentView: View {
    @StateObject private var appState = AppState()
    @State private var selectedTab = 0
    @State private var showOnboarding = true // Start with true, will be updated in onAppear
    @State private var showScanFlow = false
    @State private var showAuthentication = false

    var body: some View {
        ZStack {
            // Main tab content
            VStack(spacing: 0) {
                Group {
                    switch selectedTab {
                    case 0: DiaryView()
                    case 1: RewardSystemView()
                    default: DiaryView()
                    }
                }
                TabBarView(selectedTab: $selectedTab, showScanFlow: $showScanFlow)
            }
            .environmentObject(appState)

            // Scan flow overlay
            if showScanFlow {
                ScanFlowView(selectedTab: $selectedTab, showScanFlow: $showScanFlow)
                    .environmentObject(appState)
                    .zIndex(50)
            }

            // Onboarding overlay
            if showOnboarding {
                OnboardingView(showOnboarding: $showOnboarding)
                    .environmentObject(appState)
                    .zIndex(100)
                    .onAppear {
                        print("🏠 ContentView: Onboarding is being shown")
                    }
                    .onChange(of: showOnboarding) { _, newValue in
                        print("🏠 ContentView: showOnboarding changed to: \(newValue)")
                        if !newValue {
                            // Onboarding completed, check if user is authenticated
                            checkAuthenticationStatus()
                        }
                    }
            }
        }
        .onAppear {
            print("🏠 ContentView appeared, checking initial state...")
            // Force UserDefaults to synchronize to get latest values
            UserDefaults.standard.synchronize()
            
            let isAuthenticated = UserDefaults.standard.bool(forKey: "isAuthenticated")
            let onboardingCompleted = UserDefaults.standard.bool(forKey: "onboardingCompleted")
            
            print("🔍 Initial state check:")
            print("   - isAuthenticated: \(isAuthenticated)")
            print("   - onboardingCompleted: \(onboardingCompleted)")
            
            // Only show onboarding if user is not authenticated OR onboarding not completed
            showOnboarding = !isAuthenticated || !onboardingCompleted
            
            print("📱 Setting showOnboarding to: \(showOnboarding)")
            checkAuthenticationStatus()
        }

        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            // Refresh authentication state when app becomes active
            print("📱 App became active, checking authentication state")
            checkAuthenticationStatus()
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("userDidLogout"))) { _ in
            // Handle user logout - show onboarding/authentication again
            print("📢 Received userDidLogout notification")
            DispatchQueue.main.async {
                showOnboarding = true
                print("🔄 Showing onboarding after logout")
            }
        }
    }
    
    private func checkAuthenticationStatus() {
        // Force UserDefaults to synchronize to get latest values
        UserDefaults.standard.synchronize()
        
        let isAuthenticated = UserDefaults.standard.bool(forKey: "isAuthenticated")
        let onboardingCompleted = UserDefaults.standard.bool(forKey: "onboardingCompleted")
        
        print("🔍 Checking authentication status:")
        print("   - isAuthenticated: \(isAuthenticated)")
        print("   - onboardingCompleted: \(onboardingCompleted)")
        
        if isAuthenticated && onboardingCompleted {
            print("✅ User is authenticated and onboarding completed - showing main app")
            // Ensure onboarding is hidden
            if showOnboarding {
                showOnboarding = false
                print("🚪 Hiding onboarding since user is authenticated")
            }
        } else {
            print("❌ User not authenticated or onboarding not completed")
        }
    }
}

// MARK: - Tab Bar View
struct TabBarView: View {
    @Binding var selectedTab: Int
    @Binding var showScanFlow: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Top border
            Rectangle()
                .fill(Color(red: 0.95, green: 0.95, blue: 0.97))
                .frame(height: 0.5)
            
            // Tab bar content
            HStack(spacing: 0) {
                // Diary Tab
                TabButton(
                    icon: selectedTab == 0 ? "diary-filled" : "diary-outline",
                    title: "Diary",
                    isSelected: selectedTab == 0
                ) {
                    selectedTab = 0
                }
                
                // Scan Tab (interactive)
                Button(action: { showScanFlow = true }) {
                    VStack(spacing: 2) {
                        Image("camera-outline")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .foregroundColor(Color(.systemGray))
                        Text("Scan")
                            .font(.custom("Inter-Regular", size: 10))
                            .foregroundColor(Color(.systemGray))
                    }
                }
                .frame(maxWidth: .infinity)
                
                // Rewards Tab
                TabButton(
                    icon: selectedTab == 1 ? "rewards-filled" : "rewards-outline",
                    title: "Rewards",
                    isSelected: selectedTab == 1
                ) {
                    selectedTab = 1
                }
            }
            .frame(height: 49)
            .background(Color.white)
        }
    }
}

// MARK: - Tab Button
struct TabButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                if title == "UI" && (icon == "line.3.horizontal" || icon == "menu") {
                    Image(systemName: icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.black)
                } else {
                    Image(icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundColor(isSelected ? Color(red: 1, green: 0.478, blue: 0.18) : Color(.systemGray))
                }
                Text(title)
                    .font(.custom("Inter-Regular", size: 10))
                    .foregroundColor(isSelected ? Color(red: 1, green: 0.478, blue: 0.18) : Color(.systemGray))
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(PlainButtonStyle())
    }
}







#Preview {
    ContentView()
} 