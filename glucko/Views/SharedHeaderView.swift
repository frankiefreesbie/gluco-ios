import SwiftUI
#if os(iOS)
import UIKit
#endif

struct SharedHeaderView: View {
    var onUserTap: (() -> Void)? = nil
    var onWeekPlanTap: (() -> Void)? = nil
    var onShareGroceryList: (() -> Void)? = nil
    
    private func shareWeeklyGroceryList() {
        onShareGroceryList?()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                // Bell icon with notification dot
                ZStack {
                    Image("bell")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.black)
                        .padding(12)
                        .background(Color.white)
                        .clipShape(Circle())
                    // Orange notification dot
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 8, height: 8)
                        .offset(x: 8, y: -8)
                }
                // Center: Week Plan Menu
                Spacer()
                Menu {
                    Button {
                        onWeekPlanTap?()
                    } label: {
                        Label("Generate week plan", systemImage: "wand.and.stars")
                    }
                    
                    Button {
                        shareWeeklyGroceryList()
                    } label: {
                        Label("Send grocery list", systemImage: "paperplane")
                    }
                    
                    Button {
                        // TODO: Implement share functionality
                        print("Share week plan")
                    } label: {
                        Label("Share week plan", systemImage: "square.and.arrow.up")
                    }
                    
                    Button(role: .destructive) {
                        // TODO: Implement delete functionality
                        print("Delete week plan")
                    } label: {
                        Label("Delete week plan", systemImage: "trash")
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text("Week plan")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.black)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.black)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                }
                Spacer()
                // User avatar icon in circle
                ZStack {
                    Button(action: { onUserTap?() }) {
                        Image("user")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.gray)
                            .padding(12)
                            .background(Color.white)
                            .clipShape(Circle())
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 4)
            .background(Color(red: 0.97, green: 0.97, blue: 0.97))
        }
    }
} 