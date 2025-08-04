import SwiftUI

struct RewardSystemView: View {
    @State private var showProfile = false
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                SharedHeaderView(onUserTap: { showProfile = true })
                // Profile navigation will be handled with custom presentation
                ScrollView {
                    VStack(spacing: 24) {
                        // Gluco Status Section
                        GlucoStatusSection()
                        
                        // XP Section
                        XPSection()
                        
                        // Activity Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("YOUR ACTIVITY")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.gray)
                                .padding(.leading, 8)
                            ActivityCalendarView()
                        }
                        
                        // Badges Section
                        BadgesSection()
                        
                        // Achievements Section
                        AchievementsSection()
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 24)
                    .padding(.bottom, 100) // Space for tab bar
                }
                .background(Color(red: 0.97, green: 0.97, blue: 0.97).ignoresSafeArea())
            }
            
            // Custom Profile view overlay with push animation
            if showProfile {
                ProfileView(showProfile: $showProfile)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .trailing)
                    ))
                    .zIndex(1000)
                    .animation(.easeInOut(duration: 0.3), value: showProfile)
            }
        }
    }
}

// MARK: - Gluco Status Section

struct GlucoStatusSection: View {
    var body: some View {
        VStack(spacing: 0) {
            // Gluco Character
            ZStack {
                // Main character placeholder
                Rectangle()
                    .fill(Color(red: 0.95, green: 0.95, blue: 0.97))
                    .frame(width: 96, height: 96)
                    .cornerRadius(8)
                    .overlay(
                        VStack {
                            Image(systemName: "person")
                                .font(.system(size: 32))
                                .foregroundColor(.secondary)
                            Text("Character")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                                .padding(.top, 4)
                        }
                    )
            }
            .padding(.top, 32) // 32px top gap
            

            
            // Status text
            Text("Gluco needs healthy meals to feel better")
                .font(.custom("Inter-Regular", size: 16))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .padding(.top, 24) // 24px gap from ZzZ symbols to status text
            
            // Progress bar
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text("Progress")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                    Spacer()
                    Text("0/150 XP")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .padding(.top, 24) // 24px gap from status text to Progress label
                
                // Progress bar
                Rectangle()
                    .fill(Color(red: 0.89, green: 0.89, blue: 0.90)) // #E3E4E5
                    .frame(height: 8)
                    .cornerRadius(4)
                    .overlay(
                        Rectangle()
                            .fill(Color(red: 1, green: 0.8, blue: 0.2))
                            .frame(width: 0) // No progress yet
                            .cornerRadius(4),
                        alignment: .leading
                    )
                    .padding(.top, 8) // 8px gap from Progress label to progress bar
            }
            
            // Streak
            HStack {
                Image(systemName: "flame")
                    .font(.system(size: 16))
                    .foregroundColor(.orange)
                Text("Streak")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
                Spacer()
                Text("0 days")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            .padding(.top, 8) // 8px gap from progress bar to Streak
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// MARK: - XP Section

struct XPSection: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("0 XP")
                    .font(.custom("Nunito-Bold", size: 24))
                    .foregroundColor(.primary)
                Text("Total Experience Points")
                    .font(.custom("Inter-Regular", size: 14))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(spacing: 8) {
                // ZzZ icon
                HStack(spacing: 4) {
                    Text("Z")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.black)
                    Text("z")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.black)
                    Text("Z")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.black)
                }
                .padding(12)
                .background(Color(red: 0.9, green: 0.9, blue: 0.9))
                .cornerRadius(12)
                
                Text("Level 1")
                    .font(.custom("Inter-Regular", size: 14))
                    .foregroundColor(.primary)
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Badges Section

struct BadgesSection: View {
    let badges = [
        Badge(title: "First Week", description: "Complete your first week plan", icon: "👏", progress: "20 needed"),
        Badge(title: "Streak Master", description: "Complete your first week plan", icon: "💣", progress: "7 needed"),
        Badge(title: "Glucose Guru", description: "Log 10 low-Gi meals", icon: "😎", progress: "100 needed"),
        Badge(title: "Team Player", description: "Collaborate with partner", icon: "🤝", progress: "10 needed")
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("BADGES")
                .font(Font.custom("SF Pro Display", size: 14))
                .fontWeight(.bold)
                .kerning(1)
                .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.11))
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(badges) { badge in
                    BadgeCard(badge: badge)
                }
            }
        }
    }
}

struct Badge: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
    let progress: String
}

struct BadgeCard: View {
    let badge: Badge
    
    var body: some View {
        VStack(spacing: 0) {
            // Image placeholder (110x110px)
            Rectangle()
                .fill(Color(red: 0.9, green: 0.9, blue: 0.9))
                .frame(width: 110, height: 110)
                .cornerRadius(8)
                .overlay(
                    Text(badge.icon)
                        .font(.system(size: 32))
                        .foregroundColor(.secondary)
                )
                .padding(.top, 30) // 30px top gap
                .padding(.horizontal, 30) // 30px left and right gaps
            
            // Title
            Text(badge.title)
                .font(.custom("Nunito-Bold", size: 16))
                .foregroundColor(.primary)
                .padding(.top, 10) // 10px gap between image and title
                .padding(.horizontal, 30) // 30px left and right gaps
            
            // Description
            Text(badge.description)
                .font(.custom("Inter-Regular", size: 12))
                .foregroundColor(Color(red: 0.31, green: 0.32, blue: 0.33)) // #505154
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .padding(.top, 4)
                .padding(.horizontal, 30) // 30px left and right gaps
            
            Spacer()
            
            // Progress badge
            Text(badge.progress)
                .font(.custom("Inter-Regular", size: 12))
                .foregroundColor(.primary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(red: 0.996, green: 0.949, blue: 0.78)) // Light yellow-beige
                .cornerRadius(12)
                .padding(.horizontal, 30) // 30px left and right gaps
                .padding(.bottom, 20) // Bottom padding
        }
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Achievements Section

struct AchievementsSection: View {
    let achievements = [
        Achievement(title: "Meals logged", progress: "0/20"),
        Achievement(title: "Plans Completed", progress: "0/4"),
        Achievement(title: "Current Streak", progress: "0/14")
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("ACHIEVEMENTS")
                .font(Font.custom("SF Pro Display", size: 14))
                .fontWeight(.bold)
                .kerning(1)
                .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.11))
            
            VStack(spacing: 16) {
                ForEach(achievements) { achievement in
                    AchievementRow(achievement: achievement)
                }
            }
            .padding(20)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
    }
}

struct Achievement: Identifiable {
    let id = UUID()
    let title: String
    let progress: String
}

struct AchievementRow: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(achievement.title)
                    .font(.custom("Inter-Regular", size: 14))
                    .foregroundColor(.primary)
                Spacer()
                Text(achievement.progress)
                    .font(.custom("Inter-Regular", size: 14))
                    .foregroundColor(.secondary)
            }
            
            // Progress bar
            Rectangle()
                .fill(Color(red: 0.89, green: 0.89, blue: 0.90)) // #E3E4E5
                .frame(height: 6)
                .cornerRadius(3)
                .overlay(
                    Rectangle()
                        .fill(Color(red: 1, green: 0.8, blue: 0.2))
                        .frame(width: 0) // No progress yet
                        .cornerRadius(3),
                    alignment: .leading
                )
        }
    }
}

#Preview {
    RewardSystemView()
}
