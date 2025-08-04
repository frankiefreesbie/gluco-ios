import SwiftUI

struct MealLoggerView: View {
    @State private var showImagePicker = false
    @State private var imageSource: UIImagePickerController.SourceType = .camera
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Text("Tips for the Best AI Analysis")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 16)
            
            // Plate image placeholder
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color(.systemGray4), lineWidth: 4)
                    .frame(width: 260, height: 260)
                    .opacity(0.3)
                // Placeholder for plate image
                Image(systemName: "photo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 120, height: 120)
                    .foregroundColor(.gray)
            }
            .frame(height: 280)
            .padding(.top, 8)
            
            // Tips card using GluckoCard
            GluckoCard {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(alignment: .top, spacing: 10) {
                        Text("\u{2705}")
                            .font(.system(size: 22))
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Keep it Clear")
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                                .foregroundColor(.black)
                            Text("Avoid blurry images for the best recognition.")
                                .font(.system(size: 15, weight: .regular, design: .rounded))
                                .foregroundColor(.black)
                        }
                    }
                    HStack(alignment: .top, spacing: 10) {
                        Text("\u{2705}")
                            .font(.system(size: 22))
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Capture the Whole Plate")
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                                .foregroundColor(.black)
                            Text("Make sure all your food is visible.")
                                .font(.system(size: 15, weight: .regular, design: .rounded))
                                .foregroundColor(.black)
                        }
                    }
                    HStack(alignment: .top, spacing: 10) {
                        Text("\u{2705}")
                            .font(.system(size: 22))
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Top-Down View")
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                                .foregroundColor(.black)
                            Text("Take the photo from above for better accuracy.")
                                .font(.system(size: 15, weight: .regular, design: .rounded))
                                .foregroundColor(.black)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            
            Spacer()
            
            // Circular camera button
            Button(action: { imageSource = .camera; showImagePicker = true }) {
                ZStack {
                    Circle()
                        .fill(Color(red: 1, green: 0.48, blue: 0.18))
                        .frame(width: 80, height: 80)
                        .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                    
                    Image("camera")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.white)
                }
            }
            .padding(.top, 16)
            
            GluckoButton(title: "Choose from Library", action: { imageSource = .photoLibrary; showImagePicker = true })
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 24)
        }
        .background(Color(.systemGray6).ignoresSafeArea())
    }
}
