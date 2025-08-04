import SwiftUI
#if os(iOS)
import UIKit
#endif

// MARK: - Scan Flow View
struct ScanFlowView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appState: AppState
    @State private var currentStep: ScanStep = .tips
    @State private var capturedImage: UIImage?
    @State private var hiddenIngredients: String = ""
    @State private var selectedMealTime: MealType = .lunch
    @State private var showImagePicker = false
    @State private var imageSource: UIImagePickerController.SourceType = .camera
    @State private var isAnalyzing = false
    @State private var showTipsCount = UserDefaults.standard.integer(forKey: "scan_tips_shown_count")
    @Binding var selectedTab: Int
    @Binding var showScanFlow: Bool
    
    var body: some View {
        NavigationView {
            ZStack {
                switch currentStep {
                case .tips:
                    ScanTipsView(
                        onScanNow: { 
                            imageSource = .camera
                            showImagePicker = true
                        },
                        onChooseFromLibrary: {
                            imageSource = .photoLibrary
                            showImagePicker = true
                        },
                        onBack: { 
                            showScanFlow = false
                            selectedTab = 0 // Ensure we're on the Diary tab
                        }
                    )


                case .analyzing:
                    LoadingView(
                        image: capturedImage ?? UIImage(),
                        onAnalysisComplete: { currentStep = .selectMealTime }
                    )
                case .selectMealTime:
                    SelectMealTimeView(
                        image: capturedImage ?? UIImage(),
                        onSelect: { mealType in
                            print("Confirm button pressed for meal type: \(mealType)")
                            selectedMealTime = mealType
                            // Create a logged meal and add it to the app state
                            let loggedMeal = LoggedMeal(
                                recipe: Recipe(
                                    name: "Scanned Meal",
                                    prepTime: 0,
                                    tags: [],
                                    description: "Meal logged via scan",
                                    ingredients: [],
                                    instructions: [],
                                    protein: 25,
                                    carbs: 70,
                                    fat: 20,
                                    calories: 140,
                                    imageName: nil,
                                    imageURL: nil,
                                    hiddenIngredients: [],
                                    loggedAt: Date(),
                                    mealType: mealType
                                ),
                                loggedAt: Date(),
                                mealType: mealType,
                                pointsEarned: 120,
                                imageData: capturedImage?.jpegData(compressionQuality: 0.8)
                            )
                            print("Created logged meal: \(loggedMeal)")
                            // Save to Supabase (with local fallback)
                            Task {
                                await appState.saveLoggedMealToSupabase(loggedMeal)
                            }
                            selectedTab = 0 // Switch to Diary tab
                            showScanFlow = false // Hide the scan flow overlay
                            print("Set selectedTab to 0, hiding scan flow")
                        }
                    )

                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(
                sourceType: imageSource,
                selectedImage: Binding(
                    get: { capturedImage },
                                    set: { newImage in
                    capturedImage = newImage
                    if newImage != nil {
                        currentStep = .analyzing
                    }
                }
                )
            )
        }
        .onAppear {
            if showTipsCount >= 3 {
                currentStep = .tips
            }
            showTipsCount += 1
            UserDefaults.standard.set(showTipsCount, forKey: "scan_tips_shown_count")
        }
    }
}

// MARK: - Scan Steps
enum ScanStep {
    case tips
    case analyzing
    case selectMealTime
}

// MARK: - Scan Tips View
struct ScanTipsView: View {
    let onScanNow: () -> Void
    let onChooseFromLibrary: () -> Void
    let onBack: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: onBack) {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(width: 44, height: 44)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
                }
                
                Spacer()
                
                Text("Tips for the best AI Analysis")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.black)
                
                Spacer()
                
                Circle()
                    .fill(Color.clear)
                    .frame(width: 44, height: 44)
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            
            // Scan cover image
            Image("scan-cover-image")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 16)
                .padding(.top, 24)
            
            // Tips card
            VStack(alignment: .leading, spacing: 16) {
                TipRow(
                    icon: "checkmark.circle.fill",
                    title: "Keep it clear",
                    description: "Avoid blurred images for the best rec..."
                )
                
                TipRow(
                    icon: "checkmark.circle.fill",
                    title: "Capture the Whole Plate",
                    description: "Make sure all your food is visible"
                )
                
                TipRow(
                    icon: "checkmark.circle.fill",
                    title: "Top-Down View",
                    description: "Take the photo from above"
                )
            }
            .padding(20)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 2)
            .padding(.horizontal, 20)
            .padding(.top, 24)
            
            Spacer()
            
            // Action buttons
            VStack(spacing: 12) {
                Button(action: onScanNow) {
                    HStack {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 18, weight: .medium))
                        Text("Scan now")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(red: 1, green: 0.48, blue: 0.18))
                    .cornerRadius(12)
                }
                
                GluckoSecondaryButton(title: "Choose from library", action: onChooseFromLibrary)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
        }
        .background(Color(.systemGray6).ignoresSafeArea())
    }
}

struct TipRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.green)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }
            
            Spacer()
        }
    }
}





// MARK: - Select Meal Time View
struct SelectMealTimeView: View {
    let image: UIImage
    let onSelect: (MealType) -> Void
    @State private var selectedMealType: MealType = .lunch
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            Text("When did you eat this?")
                .font(.system(size: 22, weight: .bold))
            
            Text("Looks like you just had lunch 🍽️\nWant to log it as lunch?")
                .font(.system(size: 15))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
            
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 180, height: 180)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            
            VStack(spacing: 16) {
                ForEach(MealType.allCases, id: \.self) { mealType in
                    Button(action: { 
                        selectedMealType = mealType
                    }) {
                        HStack {
                            Text(mealType == .breakfast ? "🍳" : mealType == .lunch ? "🥗" : "🍲")
                                .font(.system(size: 20))
                            Text(mealType.displayName)
                                .font(.system(size: 16, weight: .medium))
                            Spacer()
                            if selectedMealType == mealType {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(Color(red: 1, green: 0.48, blue: 0.18))
                            }
                        }
                        .padding()
                        .background(selectedMealType == mealType ? Color(red: 1, green: 0.48, blue: 0.18).opacity(0.1) : Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 24)
            
            // Confirm button
            Button(action: { 
                print("Confirm button tapped")
                onSelect(selectedMealType) 
            }) {
                Text("Confirm")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(red: 1, green: 0.48, blue: 0.18))
                    .cornerRadius(12)
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - Loading View
struct LoadingView: View {
    let image: UIImage
    let onAnalysisComplete: () -> Void
    @State private var progress = 0.0
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            Text("Analysing your meal")
                .font(.system(size: 20, weight: .bold))
            
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 180, height: 180)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            
            Text("Hang tight")
                .font(.system(size: 16, weight: .semibold))
            
            Text("Uploading your image...")
                .font(.system(size: 14))
                .foregroundColor(.gray)
            
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .scaleEffect(1.5)
            
            Spacer()
        }
        .padding()
        .onAppear {
            // Simulate analysis
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                onAnalysisComplete()
            }
        }
    }
}





// MARK: - Image Picker
#if os(iOS)
struct ImagePicker: UIViewControllerRepresentable {
    let sourceType: UIImagePickerController.SourceType
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}
#endif

#Preview {
    ScanFlowView(selectedTab: .constant(0), showScanFlow: .constant(true))
        .environmentObject(AppState())
} 