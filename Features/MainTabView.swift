import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var supabaseManager: SupabaseManager
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Dashboard Tab
            NavigationView {
                DashboardView()
            }
            .tabItem {
                Label("Dashboard", systemImage: "chart.bar.fill")
            }
            .tag(0)
            
            // Workouts Tab
            NavigationView {
                WorkoutsView()
            }
            .tabItem {
                Label("Workouts", systemImage: "figure.walk")
            }
            .tag(1)
            
            // Exercise Library Tab
            NavigationView {
                ExerciseLibraryView()
            }
            .tabItem {
                Label("Exercises", systemImage: "dumbbell.fill")
            }
            .tag(2)
            
            // Equipment Tab
            NavigationView {
                EquipmentView()
            }
            .tabItem {
                Label("Equipment", systemImage: "gym.bag.fill")
            }
            .tag(3)
            
            // Profile Tab
            NavigationView {
                ProfileView()
            }
            .tabItem {
                Label("Profile", systemImage: "person.fill")
            }
            .tag(4)
        }
        .accentColor(.blue)
    }
}

// Placeholder for views not yet implemented
struct DashboardView: View {
    var body: some View {
        Text("Dashboard Coming Soon")
            .navigationTitle("Dashboard")
    }
}

struct WorkoutsView: View {
    var body: some View {
        Text("Workouts Coming Soon")
            .navigationTitle("Workouts")
    }
}

struct ExerciseLibraryView: View {
    var body: some View {
        Text("Exercise Library Coming Soon")
            .navigationTitle("Exercises")
    }
}

struct EquipmentView: View {
    var body: some View {
        Text("Equipment Coming Soon")
            .navigationTitle("Equipment")
    }
}

struct ProfileView: View {
    @EnvironmentObject private var supabaseManager: SupabaseManager
    
    var body: some View {
        VStack {
            Text("Profile Coming Soon")
                .padding()
            
            Button("Sign Out") {
                Task {
                    try? await supabaseManager.signOut()
                }
            }
            .foregroundColor(.red)
            .padding()
        }
        .navigationTitle("Profile")
    }
} 