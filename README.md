# Daily Fitness Tracking App

A modern iOS fitness tracking application built with SwiftUI, focused on detailed workout tracking and progress analysis.

## Features

### Core Features
- **Profile Management**: Track personal details, fitness goals, and experience level
- **Equipment Arsenal**: Manage your available fitness equipment inventory
- **Exercise Library**: Comprehensive database of exercises with detailed muscle group targeting
- **Workout Tracker**: Log workouts with sets, reps, weight, and effort ratings
- **Analytics**: Track progress and visualize your fitness journey

### Advanced Features
- **Volume & Frequency Optimization**: Ensure optimal training frequency for each muscle group
- **Progressive Overload Intelligence**: Smart suggestions for weight and rep progression
- **Imbalance & Injury Prevention**: Identify and address potential muscle imbalances

## Technology Stack
- Swift & SwiftUI for the frontend
- Supabase (PostgreSQL) for the backend
- MVVM architecture
- Combine for reactive programming

## Requirements
- iOS 16.0+
- Xcode 14.0+
- Swift 5.7+

## Installation

### Development Setup
1. Clone the repository
2. Open the project in Xcode
3. Install dependencies (if using CocoaPods or Swift Package Manager)
4. Set up Supabase credentials (see Supabase Configuration below)
5. Build and run

### Supabase Configuration
For security reasons, Supabase credentials are not included in the repository. To configure your app:

1. Copy the template file `Core/Supabase/SupabaseConfig.template.swift` to `Core/Supabase/SupabaseConfig.swift`
2. Edit `SupabaseConfig.swift` and replace the placeholder values with your actual Supabase URL and anonymous key:
```swift
enum SupabaseConfig {
    static let supabaseURL = "YOUR_SUPABASE_URL"
    static let supabaseKey = "YOUR_SUPABASE_ANON_KEY"
}
```
3. Ensure that `SupabaseConfig.swift` is not committed to your repository (it's included in .gitignore)

> **Security Note**: Never commit your Supabase credentials directly to a public repository. For production applications, consider using more secure methods for storing secrets.

## Architecture
The app follows MVVM (Model-View-ViewModel) architecture with a Repository pattern for data operations.

### Project Structure
- **App**: Main application setup
- **Core**: Core utilities, extensions, and networking components
- **Features**: Feature-specific view and view models
- **Models**: Data models representing the domain
- **Repositories**: Data access layer
- **UI**: Reusable UI components
- **Resources**: Assets and resources

## Contributing
Contributions are welcome! Please feel free to submit a Pull Request.

## License
[Specify your license here]

## Contact
[Your contact information] 