import Foundation
import Combine
import Supabase
import Auth

// Note: We'll implement the actual Supabase SDK integration later
// This is a placeholder for now

class SupabaseManager: ObservableObject {
    static let shared = SupabaseManager()
    
    // MARK: - Properties
    private let supabaseURL = SupabaseConfig.supabaseURL
    private let supabaseKey = SupabaseConfig.supabaseKey
    
    // Supabase client
    lazy var client = SupabaseClient(
        supabaseURL: URL(string: supabaseURL)!,
        supabaseKey: supabaseKey
    )
    
    @Published var session: Session?
    @Published var isAuthenticated = false
    
    // MARK: - Initialization
    private init() {
        setupAuthStateListener()
    }
    
    private func setupAuthStateListener() {
        Task {
            for await authStateChange in client.auth.authStateChanges {
                await MainActor.run {
                    if case .signedIn = authStateChange.event {
                        self.session = Session(
                            id: authStateChange.session?.id ?? "",
                            userId: authStateChange.session?.user.id.uuidString ?? "",
                            email: authStateChange.session?.user.email ?? ""
                        )
                        self.isAuthenticated = true
                        print("User authenticated: \(String(describing: self.session?.email))")
                    } else if case .signedOut = authStateChange.event {
                        self.session = nil
                        self.isAuthenticated = false
                        print("User signed out")
                    }
                }
            }
        }
    }
    
    // MARK: - Auth Methods
    func signUp(email: String, password: String) async throws {
        let authResponse = try await client.auth.signUp(
            email: email,
            password: password
        )
        
        // In Supabase, sometimes users are instantly confirmed based on settings
        // otherwise they'll need to confirm their email
        if authResponse.user != nil && authResponse.session != nil {
            await MainActor.run {
                self.session = Session(
                    id: authResponse.session?.id ?? "",
                    userId: authResponse.user?.id.uuidString ?? "",
                    email: authResponse.user?.email ?? ""
                )
                self.isAuthenticated = true
            }
        }
    }
    
    func signIn(email: String, password: String) async throws {
        let authResponse = try await client.auth.signIn(
            email: email,
            password: password
        )
        
        // Session is handled by the auth state listener
        print("Signed in user: \(String(describing: authResponse.user?.email))")
    }
    
    func signOut() async throws {
        try await client.auth.signOut()
        // Session clearing is handled by the auth state listener
    }
}

// MARK: - Supporting Types
struct Session {
    let id: String
    let userId: String
    let email: String
} 