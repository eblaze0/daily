# Daily Fitness Tracking App - Enhanced Plan

## Overall App Goal
Daily fitness tracking

## Vibes/Aesthetic/UI/UX
Think Apple Fitness meets Whoop, with smooth modern minimal design - lightmode & darkmode are musts

## Core Features

### Profile
- Personal details (age, gender, height, weight, etc.)
- Training goals selection (strength, hypertrophy, endurance, general fitness)
- Experience level (beginner, intermediate, advanced)

### Equipment Arsenal
- Input all available equipment types at your gym
  - Dumbbells and their weights, machines, etc.
  - Accessories such as cable attachments used on cable machines
- Equipment availability tracking (for home vs gym setups)

### Exercise Library
- Link exercises to available equipment from the arsenal
- Highly specific muscle group targeting:
  - **Legs**: calves, hamstrings, quads, glutes, hip flexors
  - **Back**: upper (traps, rhomboids), mid (lats, middle traps), lower (erector spinae, lower lats)
  - **Chest**: upper, middle, lower
  - **Shoulders**: front delt, side delt, rear delt
  - **Arms**: biceps (long head, short head), triceps (long head, lateral head, medial head), forearms
- For cable exercises: specify attachment used
- Movement pattern classification (push, pull, hinge, squat, carry, etc.)

### Workout Tracker
- Log workouts using exercise library or create new exercises on-the-spot
- Create/select exercises with equipment from arsenal or add new equipment (persists for future use)
- Track sets, reps, and effort rating (1-5 scale) for each set
- **New**: Pre-workout movement quality check (1-5 rating for joint mobility/stiffness)
- **New**: Post-workout soreness/recovery rating (1-5 scale)
- Automatic muscle group tracking based on exercises performed
- Rest timer between sets
- Workout duration tracking

### Analytics & Progress Tracking
- Progress visualization for specific muscle groups and exercises
- **New**: Volume & Frequency Optimization Dashboard
  - Weekly sets per muscle group heatmap with target zones
  - Days since each muscle group was last trained
  - Weekly volume trends with color coding (green = optimal, yellow = borderline, red = neglected/overtrained)
  - Frequency alerts ("Hamstrings not trained in 6 days")
- **New**: Progressive Overload Tracking
  - Time between progression jumps visualization
  - Effort rating pattern analysis
  - Volume progression trends (sets vs weight vs reps)

### AI-Powered Features

#### Progressive Overload Intelligence
- **AI Chat Assistant** that analyzes workout trends and provides personalized suggestions
- Tracks progression patterns and suggests when to increase weight, reps, or volume
- Example suggestions: "You've hit 185x8x3 at RPE 4-5 for two weeks. Try 190x8x3 next session or push to 185x10x3"
- Identifies plateaus and recommends deload weeks or exercise variations
- **Suggested Schedule/Split Generator** based on goals, available time, and equipment

#### Imbalance & Injury Prevention System
- **Movement Quality Tracker**: Pre-workout mobility/stiffness ratings
- **Imbalance Alerts**: Flags when push volume significantly exceeds pull volume, or other muscle group disparities
- **Red Flag System**: Alerts when multiple low effort ratings or pain reports are logged
- **Recovery Indicators**: Tracks soreness, sleep quality (basic 1-5 ratings), and suggests rest days
- **Smart Warm-up Protocols**: Suggests dynamic warm-ups based on planned muscle groups for the session

### Advanced Analytics
- Training load progression over time
- Volume landmarks and personal records
- Muscle group development balance wheel
- Effort vs performance correlation analysis
- Deload week recommendations based on accumulated fatigue

# iOS Fitness Tracking App - Single Phase Implementation Plan

## Tech Stack & Architecture

### Core Technologies
- **Framework**: SwiftUI + UIKit (hybrid for complex components)
- **Database**: Supabase (PostgreSQL + Real-time + Auth)
- **Architecture**: MVVM + Repository Pattern
- **Networking**: Combine + Supabase Swift SDK
- **AI/ML**: Core ML + Create ML for on-device, OpenAI API for chat
- **Charts**: Swift Charts (iOS 16+)
- **State Management**: ObservableObject + @Published
- **Real-time**: Supabase Realtime for live updates

### Project Structure
```
FitnessTracker/
├── App/
├── Core/
│   ├── Supabase/
│   ├── NetworkLayer/
│   ├── Extensions/
│   └── Utilities/
├── Features/
│   ├── Authentication/
│   ├── Profile/
│   ├── Equipment/
│   ├── Exercises/
│   ├── Workouts/
│   ├── Analytics/
│   └── AI/
├── Repositories/
├── UI/
│   ├── Components/
│   ├── Themes/
│   └── Modifiers/
└── Resources/
```

## Supabase Database Schema

### Tables & Relationships

```sql
-- Users (handled by Supabase Auth, but we'll extend with profiles)
CREATE TABLE user_profiles (
    id UUID REFERENCES auth.users PRIMARY KEY,
    age INTEGER,
    gender TEXT,
    height_cm REAL,
    weight_kg REAL,
    fitness_goal TEXT,
    experience_level TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Equipment
CREATE TABLE equipment (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users,
    name TEXT NOT NULL,
    type TEXT NOT NULL,
    specifications JSONB,
    is_available BOOLEAN DEFAULT true,
    gym_location TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Muscle Groups (reference table)
CREATE TABLE muscle_groups (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT UNIQUE NOT NULL,
    category TEXT NOT NULL, -- legs, back, chest, shoulders, arms
    subcategory TEXT -- calves, hamstrings, upper, mid, etc.
);

-- Exercises
CREATE TABLE exercises (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users,
    name TEXT NOT NULL,
    instructions TEXT,
    video_url TEXT,
    movement_pattern TEXT,
    is_custom BOOLEAN DEFAULT false,
    is_public BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Exercise Equipment Junction
CREATE TABLE exercise_equipment (
    exercise_id UUID REFERENCES exercises,
    equipment_id UUID REFERENCES equipment,
    is_primary BOOLEAN DEFAULT true,
    PRIMARY KEY (exercise_id, equipment_id)
);

-- Exercise Muscle Groups Junction
CREATE TABLE exercise_muscle_groups (
    exercise_id UUID REFERENCES exercises,
    muscle_group_id UUID REFERENCES muscle_groups,
    is_primary BOOLEAN DEFAULT true,
    PRIMARY KEY (exercise_id, muscle_group_id)
);

-- Workout Sessions
CREATE TABLE workout_sessions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users,
    date DATE NOT NULL,
    start_time TIMESTAMP WITH TIME ZONE,
    end_time TIMESTAMP WITH TIME ZONE,
    pre_workout_mobility INTEGER CHECK (pre_workout_mobility BETWEEN 1 AND 5),
    post_workout_soreness INTEGER CHECK (post_workout_soreness BETWEEN 1 AND 5),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Exercise Sets
CREATE TABLE exercise_sets (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    workout_session_id UUID REFERENCES workout_sessions,
    exercise_id UUID REFERENCES exercises,
    set_number INTEGER NOT NULL,
    reps INTEGER,
    weight_kg REAL,
    effort_rating INTEGER CHECK (effort_rating BETWEEN 1 AND 5),
    rest_duration_seconds INTEGER,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Personal Records
CREATE TABLE personal_records (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users,
    exercise_id UUID REFERENCES exercises,
    record_type TEXT NOT NULL, -- max_weight, max_reps, max_volume
    value REAL NOT NULL,
    achieved_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- AI Chat History
CREATE TABLE ai_chat_history (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users,
    message TEXT NOT NULL,
    is_user_message BOOLEAN NOT NULL,
    context_data JSONB, -- workout data context
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Row Level Security Policies
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE equipment ENABLE ROW LEVEL SECURITY;
ALTER TABLE exercises ENABLE ROW LEVEL SECURITY;
ALTER TABLE workout_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE exercise_sets ENABLE ROW LEVEL SECURITY;
ALTER TABLE personal_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_chat_history ENABLE ROW LEVEL SECURITY;

-- Policies (users can only access their own data)
CREATE POLICY "Users can view own profile" ON user_profiles
    FOR ALL USING (auth.uid() = id);

CREATE POLICY "Users can manage own equipment" ON equipment
    FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own exercises" ON exercises
    FOR ALL USING (auth.uid() = user_id OR is_public = true);

-- Similar policies for other tables...
```

## Swift SDK Integration

### Supabase Client Setup

```swift
import Supabase

class SupabaseManager: ObservableObject {
    static let shared = SupabaseManager()
    
    let client = SupabaseClient(
        supabaseURL: URL(string: "YOUR_SUPABASE_URL")!,
        supabaseKey: "YOUR_SUPABASE_ANON_KEY"
    )
    
    @Published var session: Session?
    @Published var isAuthenticated = false
    
    init() {
        Task {
            await setupAuthListener()
        }
    }
    
    func setupAuthListener() async {
        for await state in client.auth.authStateChanges {
            DispatchQueue.main.async {
                self.session = state.session
                self.isAuthenticated = state.session != nil
            }
        }
    }
}
```

### Repository Pattern Implementation

```swift
// Base Repository
protocol Repository {
    associatedtype Model
    
    func create(_ model: Model) async throws -> Model
    func read(id: UUID) async throws -> Model?
    func update(_ model: Model) async throws -> Model
    func delete(id: UUID) async throws
    func list() async throws -> [Model]
}

// Equipment Repository
class EquipmentRepository: Repository, ObservableObject {
    typealias Model = Equipment
    
    private let supabase = SupabaseManager.shared.client
    @Published var equipment: [Equipment] = []
    
    func create(_ equipment: Equipment) async throws -> Equipment {
        let response: Equipment = try await supabase
            .from("equipment")
            .insert(equipment)
            .select()
            .single()
            .execute()
            .value
        
        DispatchQueue.main.async {
            self.equipment.append(response)
        }
        
        return response
    }
    
    func list() async throws -> [Equipment] {
        let response: [Equipment] = try await supabase
            .from("equipment")
            .select()
            .execute()
            .value
        
        DispatchQueue.main.async {
            self.equipment = response
        }
        
        return response
    }
    
    // Real-time subscription
    func subscribeToChanges() {
        Task {
            let stream = try await supabase
                .from("equipment")
                .on(.all) { [weak self] in
                    Task { @MainActor in
                        try await self?.list()
                    }
                }
                .subscribe()
        }
    }
}
```

## Feature Implementation Strategy

### 1. Authentication & User Management
```swift
class AuthService: ObservableObject {
    private let supabase = SupabaseManager.shared.client
    
    func signUp(email: String, password: String) async throws {
        try await supabase.auth.signUp(email: email, password: password)
    }
    
    func signIn(email: String, password: String) async throws {
        try await supabase.auth.signIn(email: email, password: password)
    }
    
    func signOut() async throws {
        try await supabase.auth.signOut()
    }
}
```

### 2. Profile Management
```swift
@MainActor
class ProfileViewModel: ObservableObject {
    @Published var profile: UserProfile?
    @Published var isLoading = false
    
    private let repository = ProfileRepository()
    
    func loadProfile() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            profile = try await repository.getCurrentUserProfile()
        } catch {
            print("Error loading profile: \(error)")
        }
    }
    
    func updateProfile(_ profile: UserProfile) async {
        do {
            self.profile = try await repository.update(profile)
        } catch {
            print("Error updating profile: \(error)")
        }
    }
}
```

### 3. Equipment Arsenal
```swift
@MainActor
class EquipmentViewModel: ObservableObject {
    @Published var equipment: [Equipment] = []
    @Published var isLoading = false
    
    private let repository = EquipmentRepository()
    
    func loadEquipment() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            equipment = try await repository.list()
            repository.subscribeToChanges() // Real-time updates
        } catch {
            print("Error loading equipment: \(error)")
        }
    }
    
    func addEquipment(_ equipment: Equipment) async {
        do {
            _ = try await repository.create(equipment)
        } catch {
            print("Error adding equipment: \(error)")
        }
    }
}
```

### 4. Exercise Library
```swift
@MainActor
class ExerciseLibraryViewModel: ObservableObject {
    @Published var exercises: [Exercise] = []
    @Published var muscleGroups: [MuscleGroup] = []
    @Published var filteredExercises: [Exercise] = []
    
    private let exerciseRepository = ExerciseRepository()
    private let muscleGroupRepository = MuscleGroupRepository()
    
    func loadData() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.loadExercises() }
            group.addTask { await self.loadMuscleGroups() }
        }
    }
    
    func filterByMuscleGroup(_ muscleGroup: MuscleGroup) {
        filteredExercises = exercises.filter { exercise in
            exercise.primaryMuscleGroups.contains(muscleGroup) ||
            exercise.secondaryMuscleGroups.contains(muscleGroup)
        }
    }
}
```

### 5. Workout Tracking
```swift
@MainActor
class WorkoutViewModel: ObservableObject {
    @Published var currentSession: WorkoutSession?
    @Published var selectedExercises: [Exercise] = []
    @Published var currentSets: [ExerciseSet] = []
    @Published var isWorkoutActive = false
    
    private let workoutRepository = WorkoutRepository()
    private let setRepository = ExerciseSetRepository()
    
    func startWorkout() {
        isWorkoutActive = true
        currentSession = WorkoutSession(
            userId: getCurrentUserId(),
            date: Date(),
            startTime: Date()
        )
    }
    
    func addSet(exercise: Exercise, reps: Int, weight: Double?, effort: Int) async {
        guard let session = currentSession else { return }
        
        let set = ExerciseSet(
            workoutSessionId: session.id,
            exerciseId: exercise.id,
            setNumber: currentSets.filter { $0.exerciseId == exercise.id }.count + 1,
            reps: reps,
            weightKg: weight,
            effortRating: effort
        )
        
        do {
            let savedSet = try await setRepository.create(set)
            currentSets.append(savedSet)
        } catch {
            print("Error saving set: \(error)")
        }
    }
    
    func finishWorkout() async {
        guard var session = currentSession else { return }
        
        session.endTime = Date()
        
        do {
            _ = try await workoutRepository.update(session)
            isWorkoutActive = false
            currentSession = nil
            currentSets = []
        } catch {
            print("Error finishing workout: \(error)")
        }
    }
}
```

### 6. Analytics & Progress Tracking
```swift
@MainActor
class AnalyticsViewModel: ObservableObject {
    @Published var progressData: [ProgressDataPoint] = []
    @Published var volumeData: [VolumeDataPoint] = []
    @Published var personalRecords: [PersonalRecord] = []
    
    private let analyticsRepository = AnalyticsRepository()
    
    func loadProgressData(for exercise: Exercise, timeframe: TimeFrame) async {
        do {
            progressData = try await analyticsRepository.getProgressData(
                exerciseId: exercise.id,
                timeframe: timeframe
            )
        } catch {
            print("Error loading progress data: \(error)")
        }
    }
    
    func calculateVolumeOptimization() async {
        do {
            volumeData = try await analyticsRepository.getVolumeAnalysis(
                timeframe: .lastFourWeeks
            )
        } catch {
            print("Error calculating volume: \(error)")
        }
    }
}
```

### 7. AI Integration
```swift
@MainActor
class AIAssistantViewModel: ObservableObject {
    @Published var chatHistory: [ChatMessage] = []
    @Published var isProcessing = false
    
    private let aiService = AIService()
    private let chatRepository = AIChatRepository()
    
    func sendMessage(_ message: String) async {
        let userMessage = ChatMessage(content: message, isUser: true)
        chatHistory.append(userMessage)
        
        isProcessing = true
        defer { isProcessing = false }
        
        do {
            // Save user message
            _ = try await chatRepository.create(userMessage)
            
            // Get AI response with workout context
            let context = await getWorkoutContext()
            let response = try await aiService.generateResponse(
                to: message,
                context: context
            )
            
            let aiMessage = ChatMessage(content: response, isUser: false)
            chatHistory.append(aiMessage)
            
            // Save AI response
            _ = try await chatRepository.create(aiMessage)
        } catch {
            print("Error processing message: \(error)")
        }
    }
    
    private func getWorkoutContext() async -> WorkoutContext {
        // Aggregate recent workout data, progress, etc.
        // This context helps AI provide personalized advice
        return WorkoutContext(
            recentWorkouts: [], // Last 10 workouts
            currentGoals: [], // User fitness goals
            progressMetrics: [] // Recent progress data
        )
    }
}
```

## Real-time Features with Supabase

### Live Workout Updates
```swift
class WorkoutRealTimeManager: ObservableObject {
    private let supabase = SupabaseManager.shared.client
    
    func subscribeToWorkoutUpdates(sessionId: UUID) {
        Task {
            let stream = try await supabase
                .from("exercise_sets")
                .on(.insert) { [weak self] in
                    self?.handleNewSet($0)
                }
                .eq("workout_session_id", value: sessionId)
                .subscribe()
        }
    }
    
    private func handleNewSet(_ payload: any PostgrestResponse) {
        // Handle real-time set updates
        // Useful for trainer/trainee scenarios
    }
}
```

### Progressive Overload Notifications
```swift
class ProgressNotificationManager {
    private let supabase = SupabaseManager.shared.client
    
    func setupProgressTriggers() {
        // Supabase Edge Functions can trigger when:
        // - User hits same weight/reps for 3+ sessions
        // - Volume drops significantly
        // - New PR is achieved
        // These trigger push notifications via FCM
    }
}
```

## Data Migration & Seeding

### Pre-populate Exercise Database
```swift
class DataSeeder {
    static func seedExerciseLibrary() async {
        let commonExercises = [
            Exercise(name: "Barbell Bench Press", 
                    primaryMuscleGroups: [.chestMiddle], 
                    equipment: [.barbell]),
            Exercise(name: "Deadlift", 
                    primaryMuscleGroups: [.hamstrings, .glutes, .lowerBack], 
                    equipment: [.barbell]),
            // ... more exercises
        ]
        
        for exercise in commonExercises {
            try await ExerciseRepository().create(exercise)
        }
    }
}
```

## Performance Optimizations

### Efficient Data Loading
```swift
// Use Supabase's select() to only fetch needed columns
func loadWorkoutSummaries() async throws -> [WorkoutSummary] {
    return try await supabase
        .from("workout_sessions")
        .select("id, date, start_time, end_time, exercise_sets(count)")
        .order("date", ascending: false)
        .limit(50)
        .execute()
        .value
}

// Pagination for large datasets
func loadExerciseHistory(exerciseId: UUID, page: Int) async throws -> [ExerciseSet] {
    let offset = page * 20
    return try await supabase
        .from("exercise_sets")
        .select("*, exercises(name)")
        .eq("exercise_id", value: exerciseId)
        .order("created_at", ascending: false)
        .range(from: offset, to: offset + 19)
        .execute()
        .value
}
```

### Caching Strategy
```swift
class CacheManager {
    private let cache = NSCache<NSString, NSData>()
    
    func cacheWorkoutData(_ data: Data, for key: String) {
        cache.setObject(data as NSData, forKey: key as NSString)
    }
    
    func getCachedWorkoutData(for key: String) -> Data? {
        return cache.object(forKey: key as NSString) as Data?
    }
}
```

## Security Implementation

### Row Level Security
- Already implemented in database schema
- Users can only access their own data
- Public exercises visible to all users

### API Key Management
```swift
// Store Supabase keys securely
extension Bundle {
    var supabaseURL: String {
        guard let url = infoDictionary?["SUPABASE_URL"] as? String else {
            fatalError("SUPABASE_URL not found in Info.plist")
        }
        return url
    }
    
    var supabaseAnonKey: String {
        guard let key = infoDictionary?["SUPABASE_ANON_KEY"] as? String else {
            fatalError("SUPABASE_ANON_KEY not found in Info.plist")
        }
        return key
    }
}
```

## Testing Strategy

### Repository Testing
```swift
class EquipmentRepositoryTests: XCTestCase {
    var repository: EquipmentRepository!
    var mockSupabase: MockSupabaseClient!
    
    override func setUp() {
        mockSupabase = MockSupabaseClient()
        repository = EquipmentRepository(client: mockSupabase)
    }
    
    func testCreateEquipment() async throws {
        let equipment = Equipment(name: "Barbell", type: .barbell)
        
        let result = try await repository.create(equipment)
        
        XCTAssertEqual(result.name, "Barbell")
        XCTAssertTrue(mockSupabase.insertCalled)
    }
}
```

### UI Testing with Supabase
```swift
class WorkoutTrackingUITests: XCTestCase {
    func testCompleteWorkoutFlow() {
        let app = XCUIApplication()
        
        // Mock Supabase responses for UI tests
        app.launchArguments = ["UI_TESTING"]
        app.launch()
        
        // Test complete workout flow
        app.buttons["Start Workout"].tap()
        app.buttons["Add Exercise"].tap()
        // ... rest of UI test
    }
}
```

## Development Timeline

### Phase 1: Foundation (Weeks 1-4)
- Supabase setup and authentication
- Basic UI framework and navigation
- User profile management

### Phase 2: Core Features (Weeks 5-12)
- Equipment arsenal
- Exercise library with muscle group mapping
- Basic workout tracking

### Phase 3: Advanced Features (Weeks 13-18)
- Analytics and progress tracking
- Volume optimization dashboard
- Imbalance detection

### Phase 4: AI Integration (Weeks 19-22)
- AI chat implementation
- Progressive overload intelligence
- Smart recommendations

### Phase 5: Polish & Launch (Weeks 23-26)
- Performance optimization
- Testing and bug fixes
- App Store submission

## Deployment & DevOps

### Supabase Environment Setup
```bash
# Development
SUPABASE_URL=https://dev-project.supabase.co
SUPABASE_ANON_KEY=dev_anon_key

# Production
SUPABASE_URL=https://prod-project.supabase.co
SUPABASE_ANON_KEY=prod_anon_key
```

### CI/CD Pipeline
```yaml
# .github/workflows/ios.yml
name: iOS Build & Test

on: [push, pull_request]

jobs:
  test:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v2
      - name: Setup Xcode
        uses: maxim-lobanov/setup-xcode@v1
        with:
          xcode-version: latest-stable
      - name: Run Tests
        run: |
          xcodebuild test \
            -scheme FitnessTracker \
            -destination 'platform=iOS Simulator,name=iPhone 14'
```

## Success Metrics

### Technical Metrics
- API response times < 500ms
- Offline-to-online sync success rate > 99%
- Real-time update latency < 1 second
- App crash rate < 0.1%

### User Metrics
- Workout completion rate > 85%
- Daily active users retention
- Feature adoption rates
- User satisfaction scores

This single-phase approach gives you everything needed to build a world-class fitness tracking app with Supabase powering the backend. The real-time capabilities will make the user experience incredibly smooth, and the PostgreSQL foundation gives you unlimited scalability for complex analytics.