import SwiftUI

@main
struct DailyFitnessApp: App {
    @StateObject private var supabaseManager = SupabaseManager.shared
    
    var body: some Scene {
        WindowGroup {
            if supabaseManager.isAuthenticated {
                MainTabView()
                    .environmentObject(supabaseManager)
            } else {
                AuthView()
                    .environmentObject(supabaseManager)
            }
        }
    }
} 