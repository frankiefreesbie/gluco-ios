import SwiftUI
#if os(iOS)
import UIKit
#endif

struct OnboardingView: View {
    @Binding var showOnboarding: Bool
    @EnvironmentObject var appState: AppState
    @State private var page: Int = 0
    @State private var name: String = ""
    @State private var age: String = ""
    @State private var gender: String? = nil
    @State private var selectedGoals: Set<String> = []
    @State private var selectedReasons: Set<String> = []
    @State private var selectedTime: String? = nil
    @State private var showAuthentication = false
    let healthGoals = [
        "Reduce energy crashes",
        "Improve focus",
        "Support weight loss",
        "Maintain stable mood",
        "Eat healthier with my partner"
    ]
    var body: some View {
        ZStack {
            Color(red: 0.97, green: 0.97, blue: 0.97).ignoresSafeArea()
            if page == 0 {
                OnboardingWelcomePage(onNext: { withAnimation { page = 1 } })
            } else if page == 1 {
                OnboardingHelpPage(
                    onNext: { withAnimation { page = 2 } },
                    onBack: { withAnimation { page = 0 } }
                )
            } else if page == 2 {
                OnboardingGlucoseSpikesPage(
                    onNext: { withAnimation { page = 3 } },
                    onBack: { withAnimation { page = 1 } }
                )
            } else if page == 3 {
                OnboardingNamePage(
                    name: $name,
                    onNext: { withAnimation { page = 4 } },
                    onBack: { withAnimation { page = 2 } }
                )
            } else if page == 4 {
                OnboardingAgePage(
                    age: $age,
                    onNext: { withAnimation { page = 5 } },
                    onBack: { withAnimation { page = 3 } }
                )
            } else if page == 5 {
                OnboardingGenderPage(
                    gender: $gender,
                    onNext: { withAnimation { page = 6 } },
                    onBack: { withAnimation { page = 4 } }
                )
            } else if page == 6 {
                OnboardingGoalsPage(
                    selectedGoals: $selectedGoals,
                    healthGoals: healthGoals,
                    onNext: { withAnimation { page = 7 } },
                    onBack: { withAnimation { page = 5 } }
                )
            } else if page == 7 {
                OnboardingEatingBackPage(
                    selectedReasons: $selectedReasons,
                    onNext: { withAnimation { page = 8 } },
                    onBack: { withAnimation { page = 6 } }
                )
            } else if page == 8 {
                OnboardingMealPlanningTimePage(
                    selectedTime: $selectedTime,
                    onNext: { withAnimation { page = 9 } },
                    onBack: { withAnimation { page = 7 } }
                )
            } else if page == 9 {
                OnboardingReduceSpikesPage(
                    onNext: { withAnimation { page = 10 } },
                    onBack: { withAnimation { page = 8 } }
                )
            } else if page == 10 {
                OnboardingWhatWeDoPage(
                    onNext: { withAnimation { page = 11 } },
                    onBack: { withAnimation { page = 9 } }
                )
            } else if page == 11 {
                OnboardingWithGlucoPage(
                    onNext: { withAnimation { page = 12 } },
                    onBack: { withAnimation { page = 10 } }
                )
            } else if page == 12 {
                OnboardingTestimonialsPage(
                    onNext: { withAnimation { page = 13 } },
                    onBack: { withAnimation { page = 11 } }
                )
            } else if page == 13 {
                WeeklyPlanLoaderPage(onComplete: {
                    print("📱 Weekly Plan Setup completed, checking authentication status...")
                    
                    // Check if user is already authenticated
                    let isAuthenticated = UserDefaults.standard.bool(forKey: "isAuthenticated")
                    let onboardingCompleted = UserDefaults.standard.bool(forKey: "onboardingCompleted")
                    
                    if isAuthenticated && onboardingCompleted {
                        print("✅ User already authenticated, completing onboarding...")
                        showOnboarding = false
                    } else {
                        print("📱 User not authenticated, showing authentication...")
                        showAuthentication = true
                    }
                })
            }
        }
        .onChange(of: showOnboarding) { _, newValue in
            print("📱 OnboardingView: showOnboarding changed to: \(newValue)")
        }
        .onAppear {
            // Check if user was logged out and needs to see authentication
            let isAuthenticated = UserDefaults.standard.bool(forKey: "isAuthenticated")
            let onboardingCompleted = UserDefaults.standard.bool(forKey: "onboardingCompleted")
            
            print("📱 OnboardingView appeared - checking authentication status:")
            print("   - isAuthenticated: \(isAuthenticated)")
            print("   - onboardingCompleted: \(onboardingCompleted)")
            
            // If user is not authenticated but onboarding was completed before,
            // they were logged out and need to see authentication screen
            if !isAuthenticated && onboardingCompleted {
                print("🚪 User was logged out, showing authentication screen...")
                showAuthentication = true
            }
        }
        
        // Authentication overlay
        if showAuthentication {
            AuthenticationView(showAuthentication: $showAuthentication)
                .environmentObject(appState)
                .zIndex(200)
                .onAppear {
                    print("🔐 Authentication overlay is being shown")
                }
                .onChange(of: showAuthentication) { _, newValue in
                    print("🔄 showAuthentication changed to: \(newValue)")
                    if !newValue {
                        print("🎉 Authentication completed, closing onboarding...")
                        
                        // Add a small delay to ensure UserDefaults are saved
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            // Force UserDefaults to synchronize immediately
                            UserDefaults.standard.synchronize()
                            
                            // Check if user is actually authenticated before closing onboarding
                            let isAuthenticated = UserDefaults.standard.bool(forKey: "isAuthenticated")
                            let onboardingCompleted = UserDefaults.standard.bool(forKey: "onboardingCompleted")
                            
                            print("🔍 Auth check - isAuthenticated: \(isAuthenticated), onboardingCompleted: \(onboardingCompleted)")
                            
                            if isAuthenticated && onboardingCompleted {
                                print("🚪 Setting showOnboarding to false...")
                                DispatchQueue.main.async {
                                    showOnboarding = false
                                    print("✅ showOnboarding set to false on main thread")
                                    
                                    // Trigger authentication refresh in ContentView
                                    print("🔄 Authentication completed, onboarding will close")
                                }
                            } else {
                                print("❌ User not properly authenticated, keeping onboarding open")
                                print("🔍 Debug values:")
                                print("   - isAuthenticated: \(UserDefaults.standard.bool(forKey: "isAuthenticated"))")
                                print("   - onboardingCompleted: \(UserDefaults.standard.bool(forKey: "onboardingCompleted"))")
                                print("   - username: \(UserDefaults.standard.string(forKey: "username") ?? "nil")")
                                print("   - userEmail: \(UserDefaults.standard.string(forKey: "userEmail") ?? "nil")")
                            }
                        }
                    }
                }
        }
    }
}

struct OnboardingEatingBackPage: View {
    @Binding var selectedReasons: Set<String>
    var onNext: () -> Void
    var onBack: () -> Void
    let reasons = [
        "🤯 Don’t know where to start",
        "⏰ Busy schedule",
        "🍕 Junk food cravings",
        "🧠 Low energy",
        "💸 Eating healthy is expensive"
    ]
    var body: some View {
        VStack(spacing: 0) {
            OnboardingNavBar(progress: 0.6, onBack: onBack)
            Text("What’s Been Holding You\nBack from Eating Better?")
                .font(.custom("Nunito-Bold", size: 24))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .padding(.top, 24)
                .padding(.horizontal, 24)
            Spacer()
            VStack(spacing: 10) {
                ForEach(reasons, id: \.self) { reason in
                    GoalOptionRow(selected: selectedReasons.contains(reason), label: reason) {
                        if selectedReasons.contains(reason) {
                            selectedReasons.remove(reason)
                        } else {
                            selectedReasons.insert(reason)
                        }
                    }
                }
            }
            Spacer()
            Button(action: onNext) {
                Text("Continue")
                    .font(.custom("Inter-SemiBold", size: 18))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(red: 1, green: 0.478, blue: 0.18)))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
            .disabled(selectedReasons.isEmpty)
            .opacity(selectedReasons.isEmpty ? 0.5 : 1.0)
        }
    }
}

struct OnboardingMealPlanningTimePage: View {
    @Binding var selectedTime: String?
    var onNext: () -> Void
    var onBack: () -> Void
    let times = [
        "5 min/day",
        "30 min/week",
        "1 hr/week"
    ]
    var body: some View {
        VStack(spacing: 0) {
            OnboardingNavBar(progress: 0.65, onBack: onBack)
            Text("How Much Time Can You\nDedicate to Meal Planning?")
                .font(.custom("Nunito-Bold", size: 24))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .padding(.top, 24)
                .padding(.horizontal, 24)
            Spacer()
            VStack(spacing: 10) {
                ForEach(times, id: \.self) { time in
                    GoalOptionRow(selected: selectedTime == time, label: time) {
                        selectedTime = time
                    }
                }
            }
            Spacer()
            Button(action: onNext) {
                Text("Continue")
                    .font(.custom("Inter-SemiBold", size: 18))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(red: 1, green: 0.478, blue: 0.18)))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
            .disabled(selectedTime == nil)
            .opacity(selectedTime == nil ? 0.5 : 1.0)
        }
    }
}

struct OnboardingWelcomePage: View {
    var onNext: () -> Void
    var body: some View {
        ZStack {
            Color(red: 0.97, green: 0.97, blue: 0.97).ignoresSafeArea()
            // Decorative images (absolute positions with specific margins)
            Group {
                Image("teacup-without-handle").resizable().frame(width: 72, height: 72).position(x: 120, y: 40)
                Image("cooking").resizable().frame(width: 72, height: 72).position(x: 272, y: 44)
                Image("lemon").resizable().frame(width: 72, height: 72).position(x: 393, y: 120)
                Image("tomato").resizable().frame(width: 72, height: 72).position(x: 10, y: 140)
                Image("man").resizable().frame(width: 72, height: 72).position(x: 10, y: 287)
                Image("woman").resizable().frame(width: 72, height: 72).position(x: 390, y: 280)
                Image("blowfish").resizable().frame(width: 72, height: 72).position(x: 190, y: 641)
                Image("mushroom").resizable().frame(width: 72, height: 72).position(x: 390, y: 651)
                Image("poultry-leg").resizable().frame(width: 72, height: 72).position(x: 100, y: 739)
                Image("melon").resizable().frame(width: 72, height: 72).position(x: 10, y: 639)
                Image("avocado").resizable().frame(width: 72, height: 72).position(x: 300, y: 735)
            }
            // Main content
            VStack(spacing: 0) {
                Spacer()
                Image("gluco-character")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .padding(.bottom, 8)
                Text("Welcome to")
                    .font(.custom("Nunito-Bold", size: 20))
                    .foregroundColor(.black)
                    .padding(.top, 16)
                    .padding(.bottom, 24)
                    .padding(.horizontal, 24)
                Image("gluco")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 174, height: 48)
                    .clipped()
                    .padding(.bottom, 24)
                Text("We help you stay sharp, energized,\nand healthy, one meal at a time.")
                    .onboardingBodyText()
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 32)
                Button(action: onNext) {
                    Text("Get started")
                        .font(.custom("Inter-SemiBold", size: 18))
                        .foregroundColor(.white)
                        .frame(width: 180)
                        .frame(height: 54)
                        .background(RoundedRectangle(cornerRadius: 16).fill(Color(red: 1, green: 0.478, blue: 0.18)))
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 32)
                Spacer()
            }
        }
    }
}

struct OnboardingHelpPage: View {
    var onNext: () -> Void
    var onBack: () -> Void
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: 0) {
                Button(action: onBack) {
                    Image("chevron-left")
                        .resizable()
                        .renderingMode(.original)
                        .frame(width: 24, height: 24)
                        .padding(10)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 4)
                }
                // Progress bar inside navbar
                ProgressView(value: 0.5)
                    .progressViewStyle(LinearProgressViewStyle(tint: Color(red: 1, green: 0.478, blue: 0.18)))
                    .frame(height: 6)
                    .padding(.leading, 16)
                    .padding(.trailing, 16)
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            Text("Gluco can help you")
                .font(.custom("Nunito-Bold", size: 24)) // Display Small
                .foregroundColor(.black)
                .padding(.top, 8)
            Image("plate-benefits")
                .resizable()
                .scaledToFit()
                .frame(height: 240)
                .padding(.top, 16)
            VStack(alignment: .leading, spacing: 20) {
                HStack(alignment: .top, spacing: 12) {
                    Circle().fill(Color(red: 1, green: 0.478, blue: 0.18)).frame(width: 12, height: 12)
                    Text("**Eat better** without thinking too much")
                        .onboardingBodyText()
                        .foregroundColor(.black)
                }
                HStack(alignment: .top, spacing: 12) {
                    Circle().fill(Color(red: 1, green: 0.8, blue: 0.6)).frame(width: 12, height: 12)
                    Text("Avoid energy dips and **sugar crashes**")
                        .onboardingBodyText()
                        .foregroundColor(.black)
                }
                HStack(alignment: .top, spacing: 12) {
                    Circle().fill(Color(red: 1, green: 0.478, blue: 0.18).opacity(0.5)).frame(width: 12, height: 12)
                    Text("**Track your wins**, big or small")
                        .onboardingBodyText()
                        .foregroundColor(.black)
                }
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "heart.fill")
                        .resizable()
                        .foregroundColor(Color(red: 1, green: 0.478, blue: 0.18))
                        .frame(width: 16, height: 16)
                    Text("**Plan with your partner**, stay on the same plate")
                        .onboardingBodyText()
                        .foregroundColor(.black)
                }
            }
            .padding(.top, 24)
            .padding(.horizontal, 32)
            Spacer()
            Button(action: onNext) {
                Text("Next")
                    .font(.custom("Inter-SemiBold", size: 18))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(RoundedRectangle(cornerRadius: 16).fill(Color(red: 1, green: 0.478, blue: 0.18)))
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 32)
        }
    }
}

struct OnboardingGlucoseSpikesPage: View {
    var onNext: () -> Void
    var onBack: () -> Void
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: 0) {
                Button(action: onBack) {
                    Image("chevron-left")
                        .resizable()
                        .renderingMode(.original)
                        .frame(width: 24, height: 24)
                        .padding(10)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 4)
                }
                // Progress bar inside navbar (step 3/3)
                ProgressView(value: 1.0)
                    .progressViewStyle(LinearProgressViewStyle(tint: Color(red: 1, green: 0.478, blue: 0.18)))
                    .frame(height: 6)
                    .padding(.leading, 16)
                    .padding(.trailing, 16)
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            Text("Ever feel sleepy after lunch or get cravings at 4pm?")
                .font(.custom("Nunito-Bold", size: 24)) // Display Small
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .padding(.top, 8)
                .padding(.horizontal, 24)
            Image("glucose-spikes")
                .resizable()
                .scaledToFit()
                .frame(height: 250)
                .padding(.top, 32)
                .padding(.bottom, 24)
                 .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 4)
            VStack(alignment: .leading, spacing: 24) {
                Text("**That’s a glucose spike.** Each spike accelerates aging, increases fat storage, and affects mood, hormones, and brain health. We help you avoid those.")
                    .onboardingBodyText()
                    .foregroundColor(.black)
                    .multilineTextAlignment(.leading)
            }
            .padding(.horizontal, 24)
            Spacer()
            Button(action: onNext) {
                Text("Start My Journey")
                    .font(.custom("Inter-SemiBold", size: 18))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(RoundedRectangle(cornerRadius: 16).fill(Color(red: 1, green: 0.478, blue: 0.18)))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
    }
}

struct OnboardingNamePage: View {
    @Binding var name: String
    var onNext: () -> Void
    var onBack: () -> Void
    @FocusState private var isFocused: Bool
    var body: some View {
        VStack(spacing: 0) {
            OnboardingNavBar(progress: 0.25, onBack: onBack)
            Text("What's your name?")
                .font(.custom("Nunito-Bold", size: 24))
                .foregroundColor(.black)
                .padding(.top, 24)
                .padding(.horizontal, 24)
            Spacer()
            TextField("Name", text: $name)
                .font(.custom("Nunito-Bold", size: 32))
                .multilineTextAlignment(.center)
                .padding(.vertical, 16)
                .background(Color.clear)
                .padding(.horizontal, 32)
                .focused($isFocused)
                .onAppear { DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { isFocused = true } }
            Spacer()
            Button(action: onNext) {
                Text("Continue")
                    .font(.custom("Inter-SemiBold", size: 18))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(red: 1, green: 0.478, blue: 0.18)))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
            .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .opacity(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1.0)
        }
    }
}

struct OnboardingAgePage: View {
    @Binding var age: String
    var onNext: () -> Void
    var onBack: () -> Void
    var body: some View {
        VStack(spacing: 0) {
            OnboardingNavBar(progress: 0.5, onBack: onBack)
            Text("What's your age?")
                .font(.custom("Nunito-Bold", size: 24))
                .foregroundColor(.black)
                .padding(.top, 24)
                .padding(.horizontal, 24)
            Spacer()
            #if os(iOS)
            NumericTextField(text: $age, placeholder: "Age", autoFocus: true)
                .padding(.vertical, 16)
                .background(Color.clear)
                .padding(.horizontal, 32)
            #else
            TextField("Age", text: $age)
                .font(.custom("Nunito-Bold", size: 32))
                .multilineTextAlignment(.center)
                .padding(.vertical, 16)
                .background(Color.clear)
                .padding(.horizontal, 32)
            #endif
            Spacer()
            Button(action: onNext) {
                Text("Continue")
                    .font(.custom("Inter-SemiBold", size: 18))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(red: 1, green: 0.478, blue: 0.18)))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
            .disabled(age.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .opacity(age.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1.0)
        }
    }
}

struct OnboardingGenderPage: View {
    @Binding var gender: String?
    var onNext: () -> Void
    var onBack: () -> Void
    var body: some View {
        VStack(spacing: 0) {
            OnboardingNavBar(progress: 0.75, onBack: onBack)
            Text("What's your gender?")
                .font(.custom("Nunito-Bold", size: 24))
                .foregroundColor(.black)
                .padding(.top, 24)
                .padding(.horizontal, 24)
            Spacer()
            VStack(spacing: 16) {
                GoalOptionRow(selected: gender == "Female", label: "Female") { gender = "Female" }
                GoalOptionRow(selected: gender == "Male", label: "Male") { gender = "Male" }
                GoalOptionRow(selected: gender == "Prefer not to say", label: "Prefer not to say") { gender = "Prefer not to say" }
            }
            .padding(.horizontal, 24)
            Spacer()
            Button(action: onNext) {
                Text("Continue")
                    .font(.custom("Inter-SemiBold", size: 18))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(red: 1, green: 0.478, blue: 0.18)))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
            .disabled(gender == nil)
            .opacity(gender == nil ? 0.5 : 1.0)
        }
    }
}

struct GenderCard: View {
    let selected: Bool
    let image: String
    let label: String
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(image)
                    .resizable()
                    .frame(width: 72, height: 72)
                Text(label)
                    .font(.custom("Inter-Regular", size: 16))
                    .foregroundColor(.black)
            }
            .padding(12)
            .background(Color.white)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(selected ? Color(red: 1, green: 0.478, blue: 0.18) : Color.clear, lineWidth: 2)
            )
            .shadow(color: selected ? Color.orange.opacity(0.08) : Color.clear, radius: 8, x: 0, y: 2)
        }
    }
}

struct OnboardingGoalsPage: View {
    @Binding var selectedGoals: Set<String>
    let healthGoals: [String]
    var onNext: () -> Void
    var onBack: () -> Void
    var body: some View {
        VStack(spacing: 0) {
            OnboardingNavBar(progress: 1.0, onBack: onBack)
            Text("What's your health goals?")
                .font(.custom("Nunito-Bold", size: 24))
                .foregroundColor(.black)
                .padding(.top, 24)
                .padding(.horizontal, 24)
            Spacer()
            VStack(spacing: 10) {
                ForEach(healthGoals, id: \.self) { goal in
                    GoalOptionRow(selected: selectedGoals.contains(goal), label: goal) {
                        if selectedGoals.contains(goal) {
                            selectedGoals.remove(goal)
                        } else {
                            selectedGoals.insert(goal)
                        }
                    }
                }
            }
            .padding(.horizontal, 24)
            Spacer()
            Button(action: onNext) {
                Text("Continue")
                    .font(.custom("Inter-SemiBold", size: 18))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(red: 1, green: 0.478, blue: 0.18)))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
            .disabled(selectedGoals.isEmpty)
            .opacity(selectedGoals.isEmpty ? 0.5 : 1.0)
        }
    }
}

struct GoalOptionRow: View {
    let selected: Bool
    let label: String
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(alignment: .center, spacing: 19) {
                if selected {
                    Image("tick-circle-filled")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(Color(red: 1, green: 0.478, blue: 0.18))
                        .frame(width: 24, height: 24)
                } else {
                    Circle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 24, height: 24)
                }
                Text(label)
                    .font(.custom("Inter-Regular", size: 16))
                    .foregroundColor(.black)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 0)
            .frame(width: 343, height: 64, alignment: .leading)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 4)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(selected ? Color(red: 1, green: 0.478, blue: 0.18) : Color.clear, lineWidth: 2)
            )
        }
    }
}

struct OnboardingNavBar: View {
    let progress: Double
    let onBack: () -> Void
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            Button(action: onBack) {
                Image("chevron-left")
                    .resizable()
                    .renderingMode(.original)
                    .frame(width: 24, height: 24)
                    .padding(10)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 4)
            }
            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: Color(red: 1, green: 0.478, blue: 0.18)))
                .frame(height: 6)
                .padding(.leading, 16)
                .padding(.trailing, 16)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
    }
}

// NumericTextField for number pad input
#if os(iOS)
struct NumericTextField: UIViewRepresentable {
    @Binding var text: String
    var placeholder: String
    var autoFocus: Bool = true
    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.keyboardType = .numberPad
        textField.font = UIFont(name: "Nunito-Bold", size: 32)
        textField.textAlignment = .center
        textField.delegate = context.coordinator
        if autoFocus {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                textField.becomeFirstResponder()
            }
        }
        return textField
    }
    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
    }
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: NumericTextField
        init(_ parent: NumericTextField) { self.parent = parent }
        func textFieldDidChangeSelection(_ textField: UITextField) {
            parent.text = textField.text ?? ""
        }
    }
}
#endif

struct OnboardingReduceSpikesPage: View {
    var onNext: () -> Void
    var onBack: () -> Void
    var body: some View {
        VStack(spacing: 0) {
            OnboardingNavBar(progress: 0.7, onBack: onBack)
            Text("How to Reduce Spikes")
                .font(.custom("Nunito-Bold", size: 24))
                .foregroundColor(.black)
                .padding(.top, 24)
                .padding(.horizontal, 24)
            Image("no-glucose-spikes")
                .resizable()
                .scaledToFit()
                .frame(height: 140)
                .padding(.top, 16)
                .padding(.bottom, 24)
                .padding(.horizontal, 24)
                .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 4)
            VStack(alignment: .leading, spacing: 24) {
                ReduceSpikeStep(number: 1, text: "Start with veggies and then all the other foods in the plate.")
                ReduceSpikeStep(number: 2, text: "Eat a salty breakfast instead of sugary pastries or snacks")
                ReduceSpikeStep(number: 3, text: "Eat savoury snacks with proteins, healthy fats, and fiber.")
                ReduceSpikeStep(number: 4, text: "Eat sweets after a meal as a dessert.")
            }
            .padding(.horizontal, 24)
            Spacer()
            Button(action: onNext) {
                Text("Continue")
                    .font(.custom("Inter-SemiBold", size: 18))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(RoundedRectangle(cornerRadius: 16).fill(Color(red: 1, green: 0.478, blue: 0.18)))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
    }
}

struct ReduceSpikeStep: View {
    let number: Int
    let text: String
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color(red: 1.0, green: 0.89, blue: 0.71)) // #FFE3B5
                    .frame(width: 36, height: 36)
                Text("\(number)")
                    .font(.custom("Nunito-Bold", size: 16))
                    .foregroundColor(Color(red: 1, green: 0.478, blue: 0.18)) // #FF7A2E
            }
            Text(text)
                .font(.custom("Inter-Regular", size: 20))
                .foregroundColor(.black)
        }
    }
}

struct OnboardingWhatWeDoPage: View {
    var onNext: () -> Void
    var onBack: () -> Void
    var body: some View {
        VStack(spacing: 0) {
            OnboardingNavBar(progress: 0.85, onBack: onBack)
            Text("What we can do for you")
                .font(.custom("Nunito-Bold", size: 24))
                .foregroundColor(.black)
                .padding(.top, 24)
                .padding(.horizontal, 24)
            Image("week-plan")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .padding(.top, 16)
                .padding(.horizontal, 16)
                .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 4)
            Text("Gluco **generates weekly plans** that stabilize your blood sugar and help you feel your best.")
                .onboardingBodyText()
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .padding(.top, 24)
                .padding(.horizontal, 24)
            Spacer()
            Button(action: onNext) {
                Text("Continue")
                    .font(.custom("Inter-SemiBold", size: 18))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(RoundedRectangle(cornerRadius: 16).fill(Color(red: 1, green: 0.478, blue: 0.18)))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
    }
}

struct OnboardingWithGlucoPage: View {
    var onNext: () -> Void
    var onBack: () -> Void
    var body: some View {
        VStack(spacing: 0) {
            OnboardingNavBar(progress: 1.0, onBack: onBack)
            Text("Eat healthier with Gluco\nvs on your own")
                .font(.custom("Nunito-Bold", size: 24))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .padding(.top, 24)
                .padding(.horizontal, 24)
            Image("comparison")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .padding(.top, 24)
                .padding(.bottom, 16)
                .padding(.horizontal, 16)
                .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 4)
            Text("Gluco makes it easy and holds you accountable")
                .onboardingBodyText()
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .padding(.top, 16)
                .padding(.horizontal, 24)
            Spacer()
            Button(action: onNext) {
                Text("Continue")
                    .font(.custom("Inter-SemiBold", size: 18))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(RoundedRectangle(cornerRadius: 16).fill(Color(red: 1, green: 0.478, blue: 0.18)))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
    }
}

// MARK: - Body Text Style Modifier
extension Text {
    func onboardingBodyText() -> some View {
        self.font(.custom("Inter-Regular", size: 20))
            .lineSpacing(4)
    }
}

#Preview {
    OnboardingView(showOnboarding: .constant(true))
}

// Add the new testimonials page struct at the end
struct OnboardingTestimonialsPage: View {
    var onNext: () -> Void
    var onBack: () -> Void
    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 0) {
                        Text("Eat healthier with Gluco\nvs on your own")
                            .font(.custom("Nunito-Bold", size: 24))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                            .padding(.top, 24)
                        Image("testimonials-avatars")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 56)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 20)
                            .padding(.bottom, 8)
                        Text("Join healthy people around the world!")
                            .font(.custom("Inter-Regular", size: 18))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 24)
                        VStack(spacing: 20) {
                            TestimonialCard(
                                avatar: "avatar-annabel",
                                name: "Annabel B.",
                                role: "Marketing Manager",
                                text: "I never thought meal planning could feel this easy and empowering! In just a few days, I feel more in control of my food choices, and the cravings are almost gone. I actually look forward to eating, and I’ve started sleeping better too!"
                            )
                            TestimonialCard(
                                avatar: "avatar-alan",
                                name: "Alan S.",
                                role: "Sales Manager",
                                text: "For the first time in years, I’m not overwhelmed by grocery shopping. The app helped me plan an entire week without stress. Everything is so simple and satisfying and I’ve already lost 1.5kg without even trying."
                            )
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 120) // Space for fixed CTA
                    }
                    .padding(.top, 80)
                }
                VStack(spacing: 0) {
                    Button(action: onNext) {
                        Text("Create My Plan")
                            .font(.custom("Inter-SemiBold", size: 18))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(RoundedRectangle(cornerRadius: 16).fill(Color(red: 1, green: 0.478, blue: 0.18)))
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                }
                .background(Color(red: 0.97, green: 0.97, blue: 0.97).opacity(0.98))
            }
            .background(Color(red: 0.97, green: 0.97, blue: 0.97))
            // Fixed navbar overlay
            OnboardingNavBar(progress: 1.0, onBack: onBack)
                .zIndex(1)
        }
    }
}

struct TestimonialCard: View {
    let avatar: String
    let name: String
    let role: String
    let text: String
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center, spacing: 12) {
                Image(avatar)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                VStack(alignment: .leading, spacing: 2) {
                    Text(name)
                        .font(.custom("Nunito-Bold", size: 16))
                        .foregroundColor(.black)
                    Text(role)
                        .font(.custom("Inter-Regular", size: 14))
                        .foregroundColor(.gray)
                }
                Spacer()
                Image("5-stars-small")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 16)
            }
            Text(text)
                .font(.custom("Inter-Regular", size: 16))
                .foregroundColor(.black)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 4)
    }
}

struct WeeklyPlanLoaderPage: View {
    @State private var tickedDays: Int = 0
    @State private var bounce: [Bool] = Array(repeating: false, count: 7)
    @State private var isGenerating: Bool = false
    let days = ["M", "T", "W", "T", "F", "S", "S"]
    let tickColor = Color(red: 0.22, green: 0.32, blue: 0.33) // #505154
    let timer = Timer.publish(every: 0.4, on: .main, in: .common).autoconnect()
    @EnvironmentObject var appState: AppState
    var onComplete: (() -> Void)? = nil
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            Image("gluco-character")
                .resizable()
                .frame(width: 72, height: 72)
                .padding(.bottom, 8)
            Text("Weekly Plan Setup")
                .font(.custom("Nunito-Bold", size: 24))
                .foregroundColor(.black)
                .padding(.bottom, 16)
            HStack(spacing: 0) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 4)
                    HStack(spacing: 0) {
                        ForEach(0..<7) { i in
                            VStack(spacing: 8) {
                                if i < tickedDays {
                                    Image("tick-circle-filled")
                                        .resizable()
                                        .renderingMode(.template)
                                        .foregroundColor(.green)
                                        .frame(width: 20, height: 20)
                                        .scaleEffect(bounce[i] ? 1.2 : 1.0)
                                        .animation(.spring(response: 0.3, dampingFraction: 0.4, blendDuration: 0.2), value: bounce[i])
                                } else {
                                    Circle()
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                                        .frame(width: 20, height: 20)
                                }
                                Text(days[i])
                                    .font(.custom("Inter-Regular", size: 16))
                                    .foregroundColor(tickColor)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
                .frame(height: 64)
            }
            .padding(.horizontal, 32)
            Text("Let us prepare your first 7-day meal plan based on your preferences.")
                .font(.custom("Inter-Regular", size: 16))
                .foregroundColor(tickColor)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            HStack(spacing: 12) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color.orange))
                Text("Generate meals using AI")
                    .font(.custom("Inter-Regular", size: 16))
                    .foregroundColor(tickColor)
            }
            Spacer()
        }
        .onReceive(timer) { _ in
            if tickedDays < 7 {
                tickedDays += 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    withAnimation { bounce[tickedDays-1] = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        withAnimation { bounce[tickedDays-1] = false }
                    }
                }
                
                // Generate weekly meal plan when we reach the last day
                if tickedDays == 7 && !isGenerating {
                    isGenerating = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        appState.generateWeeklyMealPlan()
                    }
                }
            } else {
                timer.upstream.connect().cancel()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    onComplete?()
                }
            }
        }
        .background(Color(red: 0.97, green: 0.97, blue: 0.97).ignoresSafeArea())
    }
}
