# Gluco iOS App

A comprehensive iOS application for glucose monitoring and meal planning, built with SwiftUI and Supabase.

## 🍎 Features

- **Authentication**: Google Sign-In, Apple Sign-In, and Email/Password authentication
- **Onboarding Flow**: Guided setup for new users
- **Food Diary**: Track meals and glucose levels
- **Recipe Management**: Browse and save healthy recipes
- **Scan Flow**: Camera-based food recognition
- **Rewards System**: Gamified health tracking
- **Profile Management**: User settings and logout functionality

## 🛠️ Tech Stack

- **Frontend**: SwiftUI, iOS 15+
- **Backend**: Supabase (PostgreSQL, Authentication, Storage)
- **Authentication**: Google Sign-In, Apple Sign-In, Email/Password
- **Dependencies**: Supabase Swift SDK, Google Sign-In SDK

## 📱 Screenshots

*Add screenshots of your app here*

## 🚀 Getting Started

### Prerequisites

- Xcode 14.0+
- iOS 15.0+
- macOS 12.0+
- Supabase account
- Google Cloud Console account (for Google Sign-In)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/YOUR_USERNAME/glucko-ios.git
   cd glucko-ios
   ```

2. **Open in Xcode**
   ```bash
   open glucko.xcodeproj
   ```

3. **Configure Supabase**
   - Create a new Supabase project
   - Update `SupabaseService.swift` with your project URL and anon key
   - Set up authentication providers (Google, Apple, Email)

4. **Configure Google Sign-In**
   - Create OAuth 2.0 credentials in Google Cloud Console
   - Add your iOS bundle ID
   - Update `GoogleService-Info.plist`

5. **Build and Run**
   - Select your target device/simulator
   - Press Cmd+R to build and run

## 🔧 Configuration

### Supabase Setup

1. Create a new Supabase project
2. Enable authentication providers:
   - Email/Password
   - Google OAuth
   - Apple OAuth
3. Configure Google OAuth in Supabase dashboard
4. Set up database tables (see `create_tables.sql`)

### Google Sign-In Setup

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing
3. Enable Google Sign-In API
4. Create OAuth 2.0 credentials:
   - iOS client ID for the app
   - Web client ID for Supabase
5. Download `GoogleService-Info.plist` and add to project

## 📁 Project Structure

```
glucko/
├── App.swift                 # Main app entry point
├── ContentView.swift         # Root view with tab navigation
├── Assets.xcassets/         # App icons and images
├── Fonts/                   # Custom fonts
├── Models/                  # Data models
├── Services/                # API services
│   ├── SupabaseService.swift
│   ├── GoogleSignInService.swift
│   └── AppleSignInService.swift
├── ViewModels/              # App state management
├── Views/                   # SwiftUI views
│   ├── AuthenticationView.swift
│   ├── OnboardingView.swift
│   ├── DiaryView.swift
│   ├── ProfileView.swift
│   └── ...
└── glucko.entitlements     # App capabilities
```

## 🔐 Authentication Flow

The app supports three authentication methods:

1. **Google Sign-In**: OAuth 2.0 flow with Google
2. **Apple Sign-In**: Native iOS authentication
3. **Email/Password**: Traditional email registration/login

All authentication methods integrate with Supabase for backend user management.

## 🧪 Testing

- Use the "Debug: Manual Auth" button to test authentication flow
- Use the "DEBUG: Quick Logout" button to test logout functionality
- Test all authentication providers in the authentication view

## 📝 Database Schema

The app uses Supabase with the following main tables:

- `auth.users` - Supabase built-in user management
- `profiles` - User profile information
- `recipes` - Recipe data
- `ingredients` - Ingredient information
- `recipe_ingredients` - Many-to-many relationship

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Supabase for the backend infrastructure
- Google for authentication services
- Apple for iOS development tools

## 📞 Support

For support, email support@glucko.com or create an issue in this repository.

---

**Note**: This is a development version. Some features may be incomplete or in progress. 
