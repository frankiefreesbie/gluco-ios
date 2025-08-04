import SwiftUI

struct DesignSystemView: View {
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 32) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Design System")
                        .font(.custom("Nunito-Bold", size: 32))
                        .foregroundColor(.primary)
                    Text("Component library and design tokens")
                        .font(.custom("Inter-Regular", size: 16))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 24)
                
                // Sections
                TypographySection()
                ColorsSection()
                ButtonsSection()
                IconsSection()
                IconButtonsSection()
                CardsSection()
                FormElementsSection()
                NavigationSection()
                SpacingSection()
                TextFieldWithIconSection()
                TextAreaSection()
                ActivityCalendarSection()
                ListingSection()
            }
            .padding(.horizontal, 16) // ✅ Main padding applied here
            .padding(.bottom, 100)
            .frame(maxWidth: .infinity)
        }
        .background(Color(red: 0.97, green: 0.97, blue: 0.97))
        .edgesIgnoringSafeArea(.bottom)
    }
}

// MARK: - Typography Section

struct TypographySection: View {
    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                // Display XLarge
                Text("Display XLarge")
                    .font(.custom("Nunito-Bold", size: 44))
                    .foregroundColor(Color(red: 0.31, green: 0.32, blue: 0.33))
                Text("Nunito - 44px Bold")
                    .font(.custom("Nunito-Bold", size: 16))
                    .foregroundColor(.gray)
                Divider().padding(.vertical, 12)
                // Display Large
                Text("Display Large")
                    .font(.custom("Nunito-Bold", size: 32))
                    .foregroundColor(Color(red: 0.31, green: 0.32, blue: 0.33))
                Text("Nunito - 32px Bold")
                    .font(.custom("Nunito-Bold", size: 16))
                    .foregroundColor(.gray)
                Divider().padding(.vertical, 12)
                // Display Medium
                Text("Display Medium")
                    .font(.custom("Nunito-Bold", size: 28))
                    .foregroundColor(Color(red: 0.31, green: 0.32, blue: 0.33))
                Text("Nunito - 28px Bold")
                    .font(.custom("Nunito-Bold", size: 16))
                    .foregroundColor(.gray)
                Divider().padding(.vertical, 12)
                // Display Small
                Text("Display Small")
                    .font(.custom("Nunito-Bold", size: 24))
                    .foregroundColor(Color(red: 0.31, green: 0.32, blue: 0.33))
                Text("Nunito - 24px Bold")
                    .font(.custom("Nunito-Bold", size: 16))
                    .foregroundColor(.gray)
                Divider().padding(.vertical, 12)
                // Header 1
                Text("Header 1")
                    .font(.custom("Nunito-Bold", size: 20))
                    .foregroundColor(Color(red: 0.31, green: 0.32, blue: 0.33))
                Text("Nunito - 20px Bold")
                    .font(.custom("Nunito-Bold", size: 16))
                    .foregroundColor(.gray)
                Divider().padding(.vertical, 12)
                // Header 2
                Text("Header 2")
                    .font(.custom("Nunito-Bold", size: 18))
                    .foregroundColor(Color(red: 0.31, green: 0.32, blue: 0.33))
                Text("Nunito - 18px Bold")
                    .font(.custom("Nunito-Bold", size: 16))
                    .foregroundColor(.gray)
                Divider().padding(.vertical, 12)
                // Header 3
                Text("Header 3")
                    .font(.custom("Nunito-Bold", size: 16))
                    .foregroundColor(Color(red: 0.31, green: 0.32, blue: 0.33))
                Text("Nunito - 16px Bold")
                    .font(.custom("Nunito-Bold", size: 16))
                    .foregroundColor(.gray)
                Divider().padding(.vertical, 12)
                // Header 4 Uppercase
                Text("Header 4 Uppercase".uppercased())
                    .font(.custom("Inter-Regular", size: 14))
                    .foregroundColor(Color(red: 0.31, green: 0.32, blue: 0.33))
                Text("Inter - 14px Regular")
                    .font(.custom("Inter-Regular", size: 16))
                    .foregroundColor(.gray)
                Divider().padding(.vertical, 12)
                // Body Large
                Text("Body Large")
                    .font(.custom("Inter-Regular", size: 16))
                    .foregroundColor(Color(red: 0.31, green: 0.32, blue: 0.33))
                Text("Inter - 16px Regular")
                    .font(.custom("Inter-Regular", size: 16))
                    .foregroundColor(.gray)
                Divider().padding(.vertical, 12)
                // Body Medium
                Text("Body Medium")
                    .font(.custom("Inter-Regular", size: 14))
                    .foregroundColor(Color(red: 0.31, green: 0.32, blue: 0.33))
                Text("Inter - 14px Regular")
                    .font(.custom("Inter-Regular", size: 16))
                    .foregroundColor(.gray)
                Divider().padding(.vertical, 12)
                // Body Small
                Text("Body Small")
                    .font(.custom("Inter-Regular", size: 12))
                    .foregroundColor(Color(red: 0.31, green: 0.32, blue: 0.33))
                Text("Inter - 12px Regular")
                    .font(.custom("Inter-Regular", size: 16))
                    .foregroundColor(.gray)
                Divider().padding(.vertical, 12)
                // Caption Regular
                Text("Caption Regular")
                    .font(.custom("Inter-Regular", size: 10))
                    .foregroundColor(Color(red: 0.31, green: 0.32, blue: 0.33))
                Text("Inter - 10px Regular")
                    .font(.custom("Inter-Regular", size: 16))
                    .foregroundColor(.gray)
                Divider().padding(.vertical, 12)
                // Caption Bold
                Text("Caption Bold")
                    .font(.custom("Inter-Bold", size: 10))
                    .foregroundColor(Color(red: 0.31, green: 0.32, blue: 0.33))
                Text("Inter - 10px Bold")
                    .font(.custom("Inter-Regular", size: 16))
                    .foregroundColor(.gray)
                Divider().padding(.vertical, 12)
                // Button Label Large
                Text("Button Label Large")
                    .font(.custom("Inter-SemiBold", size: 16))
                    .foregroundColor(Color(red: 0.31, green: 0.32, blue: 0.33))
                Text("Inter - 16px SemiBold")
                    .font(.custom("Inter-Regular", size: 16))
                    .foregroundColor(.gray)
                Divider().padding(.vertical, 12)
                // Button Label Medium
                Text("Button Label Medium")
                    .font(.custom("Inter-SemiBold", size: 15))
                    .foregroundColor(Color(red: 0.31, green: 0.32, blue: 0.33))
                Text("Inter - 15px SemiBold")
                    .font(.custom("Inter-Regular", size: 16))
                    .foregroundColor(.gray)
                Divider().padding(.vertical, 12)
                // Button Label Small
                Text("Button Label Small")
                    .font(.custom("Inter-SemiBold", size: 14))
                    .foregroundColor(Color(red: 0.31, green: 0.32, blue: 0.33))
                Text("Inter - 14px SemiBold")
                    .font(.custom("Inter-Regular", size: 16))
                    .foregroundColor(.gray)
                Divider()
            }
            .padding(24)
            .background(Color.white)
            .cornerRadius(28)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
        .padding(.top, 8)
    }
}

// MARK: - Colors Section

struct ColorsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Colors", subtitle: "Brand colors and semantic colors")
            
            VStack(spacing: 16) {
                // Brand Colors
                VStack(alignment: .leading, spacing: 12) {
                    Text("Brand Colors")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.secondary)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ColorSwatch(name: "Primary Orange", color: Color(red: 1, green: 0.478, blue: 0.18))
                        ColorSwatch(name: "Yellow", color: Color(red: 1, green: 0.8, blue: 0.2))
                        ColorSwatch(name: "Background", color: Color(red: 0.97, green: 0.97, blue: 0.97))
                        ColorSwatch(name: "White", color: .white)
                    }
                }
                
                // Semantic Colors
                VStack(alignment: .leading, spacing: 12) {
                    Text("Semantic Colors")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.secondary)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ColorSwatch(name: "Success", color: .green)
                        ColorSwatch(name: "Error", color: .red)
                        ColorSwatch(name: "Warning", color: .orange)
                        ColorSwatch(name: "Info", color: .blue)
                    }
                }
                
                // Text Colors
                VStack(alignment: .leading, spacing: 12) {
                    Text("Text Colors")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.secondary)
                    
                    VStack(spacing: 8) {
                        Text("Primary Text - #292A2E")
                            .foregroundColor(Color(red: 0.16, green: 0.17, blue: 0.18))
                        Text("Secondary Text - #6B7280")
                            .foregroundColor(Color(red: 0.42, green: 0.45, blue: 0.5))
                        Text("Tertiary Text - #9CA3AF")
                            .foregroundColor(Color(red: 0.61, green: 0.65, blue: 0.69))
                    }
                }
            }
            .padding(20)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
    }
}

struct ColorSwatch: View {
    let name: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 8)
                .fill(color)
                .frame(height: 40)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
            
            Text(name)
                .font(.custom("Inter-Regular", size: 12))
                .foregroundColor(.primary)
        }
    }
}

// MARK: - Buttons Section

struct ButtonsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Primary
            Text("Primary")
                .font(.custom("Nunito-Bold", size: 18))
                .padding(.bottom, 4)
            VStack(spacing: 16) {
                DesignSystemButtonRow(type: .primary, size: .large)
                DesignSystemButtonRow(type: .primary, size: .medium)
                DesignSystemButtonRow(type: .primary, size: .small)
            }
            // Secondary
            Text("Secondary")
                .font(.custom("Nunito-Bold", size: 18))
                .padding(.top, 16)
                .padding(.bottom, 4)
            VStack(spacing: 16) {
                DesignSystemButtonRow(type: .secondary, size: .large)
                DesignSystemButtonRow(type: .secondary, size: .medium)
                DesignSystemButtonRow(type: .secondary, size: .small)
            }
            // Tertiary
            Text("Tertiary (text button)")
                .font(.custom("Nunito-Bold", size: 18))
                .padding(.top, 16)
                .padding(.bottom, 4)
            VStack(spacing: 16) {
                DesignSystemButtonRow(type: .tertiary, size: .large)
                DesignSystemButtonRow(type: .tertiary, size: .medium)
                DesignSystemButtonRow(type: .tertiary, size: .small)
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// Add Button Label Styles Section
struct ButtonLabelStylesSection: View {
    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                Divider()
                Text("Action (Large Button Label)")
                    .font(.custom("Inter-SemiBold", size: 16))
                Text("Inter - 16px SemiBold")
                    .font(.custom("Inter-Regular", size: 16))
                    .foregroundColor(.gray)
                Divider().padding(.vertical, 12)
                Text("Action (Medium Button Label)")
                    .font(.custom("Inter-SemiBold", size: 15))
                Text("Inter - 15px SemiBold")
                    .font(.custom("Inter-Regular", size: 16))
                    .foregroundColor(.gray)
                Divider().padding(.vertical, 12)
                Text("Action (Small Button Label)")
                    .font(.custom("Inter-SemiBold", size: 14))
                Text("Inter - 14px SemiBold")
                    .font(.custom("Inter-Regular", size: 16))
                    .foregroundColor(.gray)
                Divider()
            }
            .padding(24)
            .background(Color.white)
            .cornerRadius(28)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
        .padding(.top, 8)
    }
}

// Helper for button row
fileprivate enum ButtonType { case primary, secondary, tertiary }
fileprivate enum ButtonSize { case large, medium, small }

fileprivate struct DesignSystemButtonRow: View {
    let type: ButtonType
    let size: ButtonSize
    
    var label: String {
        switch size {
        case .large: return "Action (Large Button Label)"
        case .medium: return "Action (Medium Button Label)"
        case .small: return "Action (Small Button Label)"
        }
    }
    var height: CGFloat {
        switch size {
        case .large: return 54
        case .medium: return 40
        case .small: return 32
        }
    }
    var radius: CGFloat {
        switch size {
        case .large: return 16
        case .medium: return 12
        case .small: return 8
        }
    }
    var font: Font {
        switch size {
        case .large: return .custom("Inter-SemiBold", size: 16)
        case .medium: return .custom("Inter-SemiBold", size: 15)
        case .small: return .custom("Inter-SemiBold", size: 14)
        }
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Spacer()
                Button(action: {}) {
                    Text(label)
                        .font(font)
                        .frame(maxWidth: .infinity)
                        .frame(height: height)
                }
                .buttonStyle(DesignSystemButtonStyle(type: type, height: height, radius: radius))
                Spacer()
            }
            Text("Height \(Int(height))px - Radius \(Int(radius))px")
                .font(.custom("Inter-Regular", size: 16))
                .foregroundColor(.gray)
                .padding(.leading, 8)
        }
    }
}

fileprivate struct DesignSystemButtonStyle: ButtonStyle {
    let type: ButtonType
    let height: CGFloat
    let radius: CGFloat
    func makeBody(configuration: Configuration) -> some View {
        let orange = Color(red: 1, green: 0.478, blue: 0.18)
        switch type {
        case .primary:
            configuration.label
                .foregroundColor(.white)
                .background(
                    RoundedRectangle(cornerRadius: radius)
                        .fill(orange)
                )
        case .secondary:
            configuration.label
                .foregroundColor(orange)
                .background(
                    RoundedRectangle(cornerRadius: radius)
                        .stroke(orange, lineWidth: 2)
                        .background(RoundedRectangle(cornerRadius: radius).fill(Color.clear))
                )
        case .tertiary:
            configuration.label
                .foregroundColor(orange)
                .background(Color.clear)
        }
    }
}

// MARK: - Cards Section

struct CardsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Cards", subtitle: "Content containers and layouts")
            
            VStack(spacing: 16) {
                // Basic Card
                VStack(alignment: .leading, spacing: 12) {
                    Text("Basic Card")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.secondary)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Card Title")
                            .font(.system(size: 18, weight: .semibold))
                        Text("This is a basic card component with title and content.")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    .padding(20)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                }
                
                // Meal Card
                VStack(alignment: .leading, spacing: 12) {
                    Text("Meal Card")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.secondary)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        // Meal image placeholder
                        Rectangle()
                            .fill(Color(.systemGray5))
                            .frame(height: 140)
                            .cornerRadius(12)
                            .overlay(
                                VStack {
                                    Image(systemName: "fork.knife")
                                        .font(.system(size: 28))
                                        .foregroundColor(.secondary)
                                    Text("Meal Image")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.secondary)
                                        .padding(.top, 6)
                                }
                            )
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Grilled Chicken Salad")
                                .font(.system(size: 16, weight: .medium))
                            
                            HStack(spacing: 4) {
                                Image(systemName: "clock")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                                Text("20 min - 320Kcal")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                            
                            HStack(spacing: 8) {
                                NutrientTagExample(value: "35g", label: "Protein", color: Color(red: 0.996, green: 0.949, blue: 0.78))
                                NutrientTagExample(value: "15g", label: "Carbs", color: Color(red: 0.890, green: 0.890, blue: 0.890))
                                NutrientTagExample(value: "12g", label: "Fat", color: Color(red: 0.878, green: 0.906, blue: 1.0))
                            }
                        }
                    }
                    .padding(16)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                }
                
                // Grocery Item Card
                VStack(alignment: .leading, spacing: 12) {
                    Text("Grocery Item Card")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 12) {
                        Button(action: { }) {
                            Image(systemName: "circle")
                                .font(.system(size: 20))
                                .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6))
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Chicken breast")
                                .font(.system(size: 16, weight: .bold))
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 8) {
                            Text("300g")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondary)
                            
                            Button(action: { }) {
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.secondary)
                                    .frame(width: 24, height: 24)
                                    .background(Color.gray.opacity(0.1))
                                    .clipShape(Circle())
                            }
                        }
                    }
                    .padding(16)
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                }
            }
            .padding(20)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
    }
}

// MARK: - Form Elements Section

struct FormElementsSection: View {
    @State private var textInput = ""
    @State private var isToggleOn = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Form Elements", subtitle: "Input fields and controls")
            
            VStack(spacing: 16) {
                // Text Input
                VStack(alignment: .leading, spacing: 12) {
                    Text("Text Input")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.secondary)
                    
                    TextField("Enter text...", text: $textInput)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                // Toggle
                VStack(alignment: .leading, spacing: 12) {
                    Text("Toggle")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.secondary)
                    
                    Toggle("Toggle option", isOn: $isToggleOn)
                        .toggleStyle(SwitchToggleStyle(tint: Color(red: 1, green: 0.478, blue: 0.18)))
                }
                
                // Checkbox
                VStack(alignment: .leading, spacing: 12) {
                    Text("Checkbox")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 12) {
                        Button(action: { }) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.green)
                        }
                        
                        Button(action: { }) {
                            Image(systemName: "circle")
                                .font(.system(size: 20))
                                .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6))
                        }
                        
                        Text("Checkbox options")
                            .font(.system(size: 14))
                    }
                }
            }
            .padding(20)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
    }
}

// MARK: - Navigation Section

struct NavigationSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Navigation", subtitle: "Header and tab components")
            
            VStack(spacing: 16) {
                // Header
                VStack(alignment: .leading, spacing: 12) {
                    Text("Header")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.secondary)
                    
                    HeaderPreview()
                        .background(Color.white)
                        .cornerRadius(12)
                }
                
                // Week Tracker
                VStack(alignment: .leading, spacing: 12) {
                    Text("Week Tracker")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.secondary)
                    
                    WeekTrackerPreview()
                        .background(Color.white)
                        .cornerRadius(12)
                }
                
                // Tab Bar
                VStack(alignment: .leading, spacing: 12) {
                    Text("Tab Bar")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.secondary)
                    
                    TabBarPreview()
                        .background(Color.white)
                        .cornerRadius(12)
                }
            }
            .padding(20)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
    }
}

// MARK: - Spacing Section

struct SpacingSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Spacing", subtitle: "Padding and margin values")
            
            VStack(spacing: 16) {
                VStack(spacing: 12) {
                    SpacingExample(name: "4px", size: 4)
                    SpacingExample(name: "8px", size: 8)
                    SpacingExample(name: "12px", size: 12)
                    SpacingExample(name: "16px", size: 16)
                    SpacingExample(name: "20px", size: 20)
                    SpacingExample(name: "24px", size: 24)
                    SpacingExample(name: "32px", size: 32)
                }
            }
            .padding(20)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
    }
}

struct SpacingExample: View {
    let name: String
    let size: CGFloat
    
    var body: some View {
        HStack(spacing: 12) {
            Text(name)
                .font(.system(size: 14, weight: .medium))
                .frame(width: 60, alignment: .leading)
            
            Rectangle()
                                    .fill(Color(red: 1, green: 0.478, blue: 0.18))
                .frame(width: size, height: 20)
                .cornerRadius(4)
            
            Spacer()
        }
    }
}

// MARK: - Icons Section

struct IconsSection: View {
    // List of asset names (excluding AppIcon and gluco)
    let iconNames: [String] = [
        "add", "arrow-left", "arrow-right", "bell", "camera-filled", "camera-outline", "chat", "chevron-down", "chevron-left", "chevron-right", "chevron-up", "check", "clock", "close-circle-filled", "close-circle-outline", "diary-filled", "diary-outline", "edit", "email", "home-filled", "home-outlined","like-filled","like-outline", "lock", "logout", "minus", "more", "paperclip", "project", "rewards-filled", "rewards-outline", "scanner", "send", "setting", "share-screen","tick-circle-outline", "tick-circle-filled" ,"trash", "user", "warning"
    ]
    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Icons", subtitle: "System icons and custom icons")
            LazyVGrid(columns: columns, spacing: 24) {
                ForEach(iconNames, id: \.self) { name in
                    VStack(spacing: 8) {
                        Image(name)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 36, height: 36)
                        Text(name)
                            .font(.custom("Inter-Regular", size: 12))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .frame(maxWidth: 72)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.top, 8)
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Helper Components

struct SectionHeader: View {
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.custom("Nunito-Bold", size: 20))
                .foregroundColor(.primary)
            Text(subtitle)
                .font(.custom("Inter-Regular", size: 14))
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Missing Components

struct NutrientTagExample: View {
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Text(value)
                .font(.system(size: 12, weight: .bold))
            Text(label)
                .font(.system(size: 12, weight: .medium))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color)
        .cornerRadius(12)
    }
}

struct HeaderPreview: View {
    var body: some View {
        HStack(spacing: 12) {
            // Bell icon with notification dot
            ZStack {
                HStack(alignment: .center, spacing: 10) {
                    Image(systemName: "bell")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.black)
                }
                .padding(12)
                .background(Color.white)
                .cornerRadius(100)
                .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 4)
                // Orange notification dot
                Circle()
                    .fill(Color.orange)
                    .frame(width: 8, height: 8)
                    .offset(x: 8, y: -8)
            }
            
            // Center: Gluco logo image
            Spacer()
            Text("GLUCO")
                .font(.custom("Nunito-Bold", size: 24))
                .foregroundColor(.primary)
            Spacer()
            
            // User avatar icon in circle
            ZStack {
                HStack(alignment: .center, spacing: 10) {
                    Image(systemName: "person")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.gray)
                }
                .padding(12)
                .background(Color.white)
                .cornerRadius(100)
                .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 4)
            }
        }
        .padding(.top, 8)
        .padding(.bottom, 4)
        .padding(.horizontal, 16)
    }
}

struct WeekTrackerPreview: View {
    @State private var selectedDate = Date()
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<7) { idx in
                let weekDays = ["S", "M", "T", "W", "T", "F", "S"]
                let isSelected = idx == 3 // Wednesday selected
                
                Button(action: { }) {
                    VStack(spacing: 4) {
                        Text(weekDays[idx])
                            .font(.system(size: 14))
                            .foregroundColor(.primary)
                        
                        Text("\(idx + 1)")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Image(systemName: idx < 3 || idx > 4 ? "checkmark" : "circle")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(idx < 3 || idx > 4 ? .green : Color(.systemGray3))
                    }
                    .frame(width: 48, height: 81)
                    .background(isSelected ? .white : Color.clear)
                    .cornerRadius(8)
                    .shadow(color: isSelected ? Color.black.opacity(0.05) : Color.clear, radius: 2, x: 0, y: 1)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

// MARK: - TextFieldWithIcon (Reusable Component)
// Moved to AuthenticationView.swift to avoid redeclaration

// MARK: - TextFieldWithIcon Section

struct TextFieldWithIconSection: View {
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "TextFieldWithIcon", subtitle: "Reusable input field with icon and custom style")
            
            // Inline TextFieldWithIcon for demo purposes
            HStack(spacing: 12) {
                Image(systemName: "person")
                    .font(.system(size: 20))
                    .foregroundColor(Color(.systemGray))
                TextField("Username", text: $username)
                    .font(.custom("Inter_18pt-Regular", size: 16))
                    .foregroundColor(.primary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color(red: 0.89, green: 0.89, blue: 0.9).opacity(0.4))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 4)
            
            HStack(spacing: 12) {
                Image(systemName: "envelope")
                    .font(.system(size: 20))
                    .foregroundColor(Color(.systemGray))
                TextField("Email address", text: $email)
                    .font(.custom("Inter_18pt-Regular", size: 16))
                    .foregroundColor(.primary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color(red: 0.89, green: 0.89, blue: 0.9).opacity(0.4))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 4)
            
            HStack(spacing: 12) {
                Image(systemName: "lock")
                    .font(.system(size: 20))
                    .foregroundColor(Color(.systemGray))
                SecureField("Password", text: $password)
                    .font(.custom("Inter_18pt-Regular", size: 16))
                    .foregroundColor(.primary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color(red: 0.89, green: 0.89, blue: 0.9).opacity(0.4))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 4)
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - TextArea (Reusable Component)

struct TextArea: UIViewRepresentable {
    @Binding var text: String
    var placeholder: String
    var font: UIFont = UIFont(name: "Inter_18pt-Regular", size: 16) ?? .systemFont(ofSize: 16)
    var bgColor: UIColor = UIColor(red: 0.89, green: 0.89, blue: 0.9, alpha: 0.6)
    var cornerRadius: CGFloat = 16
    var padding: CGFloat = 12
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.font = font
        textView.backgroundColor = bgColor
        textView.layer.cornerRadius = cornerRadius
        textView.textContainerInset = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        textView.text = placeholder
        textView.textColor = UIColor.systemGray3
        textView.isScrollEnabled = true
        textView.clipsToBounds = true
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        // Only show placeholder if text is empty and not focused
        if text.isEmpty && !uiView.isFirstResponder {
            uiView.text = placeholder
            uiView.textColor = UIColor.systemGray3
        } else if uiView.isFirstResponder && uiView.text == placeholder {
            uiView.text = ""
            uiView.textColor = UIColor.label
        } else if !uiView.isFirstResponder && uiView.text == "" {
            uiView.text = placeholder
            uiView.textColor = UIColor.systemGray3
        } else if uiView.text != text && !(uiView.isFirstResponder && uiView.text == "") {
            uiView.text = text
            uiView.textColor = UIColor.label
        }
        uiView.font = font
        uiView.backgroundColor = bgColor
        uiView.layer.cornerRadius = cornerRadius
        uiView.textContainerInset = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: TextArea
        init(_ parent: TextArea) { self.parent = parent }
        func textViewDidBeginEditing(_ textView: UITextView) {
            if textView.text == parent.placeholder {
                textView.text = ""
                textView.textColor = UIColor.label
            }
        }
        func textViewDidEndEditing(_ textView: UITextView) {
            if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                textView.text = parent.placeholder
                textView.textColor = UIColor.systemGray3
            }
            parent.text = textView.text == parent.placeholder ? "" : textView.text
        }
        func textViewDidChange(_ textView: UITextView) {
            // Hide placeholder as soon as user types anything
            if textView.text == parent.placeholder {
                textView.text = ""
                textView.textColor = UIColor.label
            }
            parent.text = textView.text
        }
    }
}

// MARK: - TextArea Section

struct TextAreaSection: View {
    @State private var text = ""
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "TextArea", subtitle: "Native text area with placeholder and custom style")
            TextArea(text: $text, placeholder: "Add ingredients not visible in the photo. Add any oils, sauces, seasonings to help us improve accuracy.")
                .frame(height: 140)
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        .frame(maxWidth: .infinity)
    }
}

#if os(iOS)
import UIKit

struct GluckoUITextView: UIViewRepresentable {
    @Binding var text: String
    var placeholder: String
    var font: UIFont = UIFont(name: "Inter_18pt-Regular", size: 16) ?? .systemFont(ofSize: 16)
    var bgColor: UIColor = UIColor(red: 0.89, green: 0.89, blue: 0.9, alpha: 0.6)
    var cornerRadius: CGFloat = 16
    var padding: CGFloat = 12
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.font = font
        textView.backgroundColor = bgColor
        textView.layer.cornerRadius = cornerRadius
        textView.textContainerInset = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        textView.text = placeholder
        textView.textColor = UIColor.systemGray3
        textView.isScrollEnabled = true
        textView.clipsToBounds = true
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        if text.isEmpty && !uiView.isFirstResponder {
            uiView.text = placeholder
            uiView.textColor = UIColor.systemGray3
        } else if uiView.text == placeholder && uiView.isFirstResponder {
            uiView.text = ""
            uiView.textColor = UIColor.label
        } else if uiView.text != text && !(uiView.isFirstResponder && uiView.text == "") {
            uiView.text = text
            uiView.textColor = UIColor.label
        }
        uiView.font = font
        uiView.backgroundColor = bgColor
        uiView.layer.cornerRadius = cornerRadius
        uiView.textContainerInset = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: GluckoUITextView
        init(_ parent: GluckoUITextView) { self.parent = parent }
        func textViewDidBeginEditing(_ textView: UITextView) {
            if textView.text == parent.placeholder {
                textView.text = ""
                textView.textColor = UIColor.label
            }
        }
        func textViewDidEndEditing(_ textView: UITextView) {
            if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                textView.text = parent.placeholder
                textView.textColor = UIColor.systemGray3
            }
            parent.text = textView.text == parent.placeholder ? "" : textView.text
        }
        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
        }
    }
}

struct GluckoUITextViewSection: View {
    @State private var text = ""
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "GluckoUITextView", subtitle: "Native text area with placeholder and custom style")
            GluckoUITextView(text: $text, placeholder: "Add ingredients not visible in the photo. Add any oils, sauces, seasonings to help us improve accuracy.")
                .frame(height: 140)
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        .frame(maxWidth: .infinity)
    }
}
#endif

// MARK: - Activity Calendar Example
struct ActivityCalendarSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("YOUR ACTIVITY")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.gray)
                .padding(.leading, 8)
            ActivityCalendarView()
                .padding(.horizontal, 0)
        }
        .padding(.vertical, 8)
    }
}

struct ActivityCalendarView: View {
    @State private var displayedMonth: Date = Date()
    @EnvironmentObject var appState: AppState
    private let calendar = Calendar.current
    private let weekDays = ["S", "M", "T", "W", "T", "F", "S"]
    
    // Get days with logged meals for the current month
    private var activeDays: Set<Int> {
        let loggedMealDays = appState.loggedMeals.compactMap { loggedMeal in
            let loggedDate = loggedMeal.loggedAt
            // Check if the logged meal is in the displayed month
            if calendar.isDate(loggedDate, equalTo: displayedMonth, toGranularity: .month) {
                let day = calendar.component(.day, from: loggedDate)
                print("Found logged meal on day \(day) for month \(displayedMonth)")
                return day
            }
            return nil
        }
        let activeDaysSet = Set(loggedMealDays)
        print("Active days for current month: \(activeDaysSet)")
        return activeDaysSet
    }
    var body: some View {
        VStack(spacing: 16) {
            // Month selector
            HStack(spacing: 12) {
                Text(monthYearString(for: displayedMonth))
                    .font(.custom("Nunito-Bold", size: 24))
                Spacer()
                Button(action: { displayedMonth = previousMonth(from: displayedMonth) }) {
                    Circle()
                        .fill(Color(hex: "#F2F2F2"))
                        .frame(width: 36, height: 36)
                        .overlay(
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.black)
                        )
                }
                Button(action: { displayedMonth = nextMonth(from: displayedMonth) }) {
                    Circle()
                        .fill(Color(hex: "#F2F2F2"))
                        .frame(width: 36, height: 36)
                        .overlay(
                            Image(systemName: "chevron.right")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.black)
                        )
                }
            }
            .padding(.horizontal, 8)
            // Weekday headers
            HStack {
                ForEach(weekDays, id: \.self) { day in
                    Text(day)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                }
            }
            // Calendar grid
            let days = daysInMonth(for: displayedMonth)
            let firstWeekday = firstWeekdayOfMonth(for: displayedMonth)
            let today = calendar.component(.day, from: Date())
            let isCurrentMonth = calendar.isDate(Date(), equalTo: displayedMonth, toGranularity: .month)
            VStack(spacing: 12) {
                ForEach(0..<6) { week in
                    HStack(spacing: 0) {
                        ForEach(0..<7) { weekday in
                            let dayNumber = week * 7 + weekday - (firstWeekday - 1) + 1
                            if dayNumber < 1 || dayNumber > days {
                                // Empty cell
                                Text("")
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 36)
                            } else {
                                let isToday = isCurrentMonth && dayNumber == today
                                let isActive = activeDays.contains(dayNumber)
                                Circle()
                                    .fill(isToday ? Color.black : (isActive ? Color.green : Color(hex: "#F2F2F2")))
                                    .frame(width: 36, height: 36)
                                    .overlay(
                                        Text("\(dayNumber)")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(isToday ? .white : (isActive ? .white : .gray))
                                    )
                                    .frame(maxWidth: .infinity)
                            }
                        }
                    }
                }
            }
        }
        .padding(.top, 16)
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
        .background(Color.white)
        .cornerRadius(28)
    }
    // Helpers
    private func monthYearString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL"
        return formatter.string(from: date)
    }
    private func daysInMonth(for date: Date) -> Int {
        guard let range = calendar.range(of: .day, in: .month, for: date) else { return 30 }
        return range.count
    }
    private func firstWeekdayOfMonth(for date: Date) -> Int {
        let comps = calendar.dateComponents([.year, .month], from: date)
        let firstOfMonth = calendar.date(from: comps) ?? date
        return calendar.component(.weekday, from: firstOfMonth)
    }
    private func previousMonth(from date: Date) -> Date {
        calendar.date(byAdding: .month, value: -1, to: date) ?? date
    }
    private func nextMonth(from date: Date) -> Date {
        calendar.date(byAdding: .month, value: 1, to: date) ?? date
    }
}

// Color extension for hex
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// Add to DesignSystemView
extension DesignSystemView {
    @ViewBuilder
    func activityCalendarSection() -> some View {
        ActivityCalendarSection()
    }
}

// Add to the main view
// ... existing code ...
// In the main LazyVStack in DesignSystemView:
// activityCalendarSection()

#Preview {
    DesignSystemView()
} 

// MARK: - Tab Bar Preview (restore for navigation section)
struct TabBarPreview: View {
    var body: some View {
        HStack(spacing: 0) {
            TabBarItem(icon: "house", title: "Diary", isSelected: true)
            TabBarItem(icon: "calendar", title: "Plan", isSelected: false)
            TabBarItem(icon: "camera", title: "Log", isSelected: false)
            TabBarItem(icon: "person.2", title: "Partner", isSelected: false)
            TabBarItem(icon: "star", title: "Rewards", isSelected: false)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

struct TabBarItem: View {
    let icon: String
    let title: String
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(isSelected ? Color(red: 1, green: 0.478, blue: 0.18) : .gray)
            Text(title)
                .font(.custom("Inter-Regular", size: 10))
                .foregroundColor(isSelected ? Color(red: 1, green: 0.478, blue: 0.18) : .gray)
        }
        .frame(maxWidth: .infinity)
    }
} 

// Add Icon Buttons Section
struct IconButtonsSection: View {
    let navIcons: [(String, String)] = [
        ("bell", "Bell"), ("user", "Profile"), ("chevron-left", "Back"), ("more", "More")
    ]
    let iconSizes: [(String, CGFloat)] = [("Large", 54), ("Medium", 40), ("Small", 32)]
    var body: some View {
        let primaryColor = Color(red: 1, green: 0.478, blue: 0.18)
        return VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 32) {
                // Navigation Bar
                Text("Icon buttons Navigation bar")
                    .font(.custom("Nunito-Bold", size: 18))
                Text(".shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 4)")
                    .font(.custom("Inter-Regular", size: 14))
                    .foregroundColor(.gray)
                HStack(spacing: 24) {
                    ForEach(navIcons, id: \.0) { (icon, label) in
                        VStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 54, height: 54)
                                    .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 4)
                                Image(icon)
                                    .resizable()
                                    .renderingMode(.original)
                                    .scaledToFit()
                                    .frame(width: 28, height: 28)
                            }
                            Text(label)
                                .font(.custom("Inter-Regular", size: 14))
                                .fontWeight(.bold)
                                .foregroundColor(.gray)
                        }
                    }
                }
                // Primary Icon Buttons
                Text("Icon buttons Primary")
                    .font(.custom("Nunito-Bold", size: 18))
                HStack(spacing: 32) {
                    ForEach(iconSizes, id: \.0) { (label, size) in
                        VStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .fill(primaryColor)
                                    .frame(width: size, height: size)
                                Image("arrow-left")
                                    .resizable()
                                    .renderingMode(.template)
                                    .scaledToFit()
                                    .frame(width: size * 0.45, height: size * 0.45)
                                    .foregroundColor(.white)
                            }
                            Text(label)
                                .font(.custom("Inter-Regular", size: 14))
                                .foregroundColor(.gray)
                        }
                    }
                }
                // Secondary Icon Buttons
                Text("Icon buttons Secondary")
                    .font(.custom("Nunito-Bold", size: 18))
                HStack(spacing: 32) {
                    ForEach(iconSizes, id: \.0) { (label, size) in
                        VStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .stroke(primaryColor, lineWidth: 2)
                                    .background(Circle().fill(Color.white))
                                    .frame(width: size, height: size)
                                Image("arrow-left")
                                    .resizable()
                                    .renderingMode(.template)
                                    .scaledToFit()
                                    .frame(width: size * 0.45, height: size * 0.45)
                                    .foregroundColor(primaryColor)
                            }
                            Text(label)
                                .font(.custom("Inter-Regular", size: 14))
                                .foregroundColor(.gray)
                        }
                    }
                }
                // Disabled State
                VStack(alignment: .leading, spacing: 8) {
                    Text("Disabled state")
                        .font(.custom("Nunito-Bold", size: 18))
                    Text("Opacity 30%")
                        .font(.custom("Inter-Regular", size: 14))
                        .foregroundColor(.gray)
                }
                VStack(spacing: 16) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(red: 1, green: 0.478, blue: 0.18).opacity(0.3))
                            .frame(height: 54)
                        Text("Large")
                            .font(.custom("Inter-SemiBold", size: 16))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .opacity(0.7)
                    }
                    .frame(maxWidth: .infinity)
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color(red: 1, green: 0.478, blue: 0.18).opacity(0.3), lineWidth: 2)
                            .background(RoundedRectangle(cornerRadius: 16).fill(Color.white))
                            .frame(height: 54)
                        Text("Large")
                            .font(.custom("Inter-SemiBold", size: 16))
                            .fontWeight(.bold)
                            .foregroundColor(Color(red: 1, green: 0.478, blue: 0.18).opacity(0.7))
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(20)
        }
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        .padding(.vertical, 0)
    }
} 

// Add Listing Section
struct ListingSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("LISTING")
                .font(.custom("Nunito-Bold", size: 18))
                .padding(.top, 8)
            VStack(alignment: .leading, spacing: 24) {
                // Checkbox
                Text("Checkbox")
                    .font(.custom("Nunito-Bold", size: 16))
                VStack(spacing: 16) {
                    HStack(alignment: .center, spacing: 19) {
                        ZStack {
                            Circle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 32, height: 32)
                        }
                        Text("checkbox unselected")
                            .font(.custom("Inter-Regular", size: 22))
                            .foregroundColor(.black)
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 0)
                    .frame(width: 343, height: 64, alignment: .leading)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 4)
                    HStack(alignment: .center, spacing: 19) {
                        ZStack {
                            Circle()
                                .stroke(Color(red: 1, green: 0.478, blue: 0.18), lineWidth: 2)
                                .background(Circle().fill(Color.white))
                                .frame(width: 32, height: 32)
                            Image("check")
                                .resizable()
                                .renderingMode(.template)
                                .foregroundColor(Color(red: 1, green: 0.478, blue: 0.18))
                                .frame(width: 18, height: 18)
                        }
                        Text("checkbox selected")
                            .font(.custom("Inter-Regular", size: 22))
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
                            .inset(by: 0.5)
                            .stroke(Color(red: 1, green: 0.478, blue: 0.18), lineWidth: 1)
                    )
                }
                .background(Color.gray.opacity(0.12))
                .cornerRadius(28)
                // Row
                Text("Row")
                    .font(.custom("Nunito-Bold", size: 16))
                VStack(spacing: 12) {
                    HStack {
                        Text("Default + detail")
                            .font(.custom("Inter-Regular", size: 18))
                        Spacer()
                        Text("Detail")
                            .font(.custom("Inter-Regular", size: 16))
                            .foregroundColor(.gray)
                        Image("chevron-right")
                            .resizable()
                            .renderingMode(.original)
                            .frame(width: 18, height: 18)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    HStack {
                        Image("chat")
                            .resizable()
                            .renderingMode(.original)
                            .frame(width: 24, height: 24)
                        Text("Regular row with icon")
                            .font(.custom("Inter-Regular", size: 18))
                        Spacer()
                        Image("chevron-right")
                            .resizable()
                            .renderingMode(.original)
                            .frame(width: 18, height: 18)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                }
                .background(Color.gray.opacity(0.12))
                .cornerRadius(28)
                // 2-cards-grid
                Text("2-cards-grid")
                    .font(.custom("Nunito-Bold", size: 16))
                HStack(spacing: 16) {
                    ForEach([0, 1], id: \ .self) { idx in
                        VStack(alignment: .leading, spacing: 8) {
                            ZStack(alignment: .bottomLeading) {
                                RoundedRectangle(cornerRadius: 24)
                                    .fill(Color.gray.opacity(0.5))
                                    .frame(height: 180)
                                HStack(spacing: 8) {
                                    Text("10 min")
                                        .font(.custom("Inter-Regular", size: 16))
                                        .foregroundColor(.black)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(Color.white)
                                        .cornerRadius(12)
                                    Text("400 Cal")
                                        .font(.custom("Inter-Regular", size: 16))
                                        .foregroundColor(.black)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(Color.white)
                                        .cornerRadius(12)
                                }
                                .padding(12)
                            }
                            Text(idx == 0 ? "Blueberry Almond Smoohie" : "Chicken & Quinoa Stuffed Peppers")
                                .font(.custom("Nunito-Bold", size: 22))
                                .foregroundColor(.black)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .background(Color.gray.opacity(0.12))
                .cornerRadius(28)
            }
            .padding(20)
            .background(Color.gray.opacity(0.12))
            .cornerRadius(28)
        }
        .padding(.horizontal, 0)
    }
} 
