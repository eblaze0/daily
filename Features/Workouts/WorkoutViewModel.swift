import Foundation
import Combine

@MainActor
class WorkoutViewModel: ObservableObject {
    // Workout session states
    @Published var isWorkoutActive = false
    @Published var currentSession: WorkoutSession?
    @Published var currentExerciseSets: [ExerciseSet] = []
    
    // Exercise selection
    @Published var availableExercises: [Exercise] = []
    @Published var selectedExercise: Exercise?
    
    // Data states
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // For a new set
    @Published var newSetReps: String = ""
    @Published var newSetWeight: String = ""
    @Published var newSetEffort: Int = 3
    
    // For timers
    @Published var elapsedSeconds: Int = 0
    @Published var restTimerSeconds: Int = 0
    @Published var isRestTimerActive = false
    
    // Repositories
    private let exerciseRepository = ExerciseRepository()
    
    // Timers
    private var workoutTimer: Timer?
    private var restTimer: Timer?
    
    init() {
        loadExercises()
    }
    
    private func loadExercises() {
        isLoading = true
        
        Task {
            do {
                availableExercises = try await exerciseRepository.list()
                isLoading = false
            } catch {
                errorMessage = "Failed to load exercises: \(error.localizedDescription)"
                isLoading = false
            }
        }
    }
    
    // MARK: - Workout Session Management
    
    func startWorkout() {
        guard !isWorkoutActive else { return }
        
        // Create a new session with a user ID (in a real app, this would come from auth)
        let userID = UUID()
        
        let newSession = WorkoutSession(
            userId: userID,
            date: Date(),
            startTime: Date()
        )
        
        currentSession = newSession
        isWorkoutActive = true
        startWorkoutTimer()
    }
    
    func finishWorkout() {
        guard isWorkoutActive, var session = currentSession else { return }
        
        // Complete the session
        session.endTime = Date()
        currentSession = session
        
        isWorkoutActive = false
        stopWorkoutTimer()
        
        // In a complete implementation, we would save the session to a repository here
        print("Workout finished: \(session.formattedDuration ?? "unknown duration")")
        
        // Reset state
        clearWorkout()
    }
    
    func clearWorkout() {
        currentSession = nil
        currentExerciseSets = []
        selectedExercise = nil
        newSetReps = ""
        newSetWeight = ""
        newSetEffort = 3
        elapsedSeconds = 0
        stopRestTimer()
    }
    
    // MARK: - Exercise Set Management
    
    func addSet() {
        guard let exercise = selectedExercise, let workoutSession = currentSession else {
            errorMessage = "No exercise or workout session selected"
            return
        }
        
        guard let reps = Int(newSetReps), reps > 0 else {
            errorMessage = "Please enter a valid number of reps"
            return
        }
        
        // Weight can be optional (for bodyweight exercises)
        let weight: Double? = Double(newSetWeight)
        
        // Create the set
        let setNumber = currentExerciseSets.filter { $0.exerciseId == exercise.id }.count + 1
        
        let newSet = ExerciseSet(
            workoutSessionId: workoutSession.id,
            exercise: exercise,
            setNumber: setNumber,
            reps: reps,
            weightKg: weight,
            effortRating: newSetEffort
        )
        
        // Add to current sets
        currentExerciseSets.append(newSet)
        
        // Reset input fields
        newSetReps = ""
        newSetWeight = ""
        
        // Start rest timer if needed
        startRestTimer(seconds: 90) // Default 90 seconds rest
    }
    
    func removeSet(_ set: ExerciseSet) {
        currentExerciseSets.removeAll { $0.id == set.id }
        
        // Re-number remaining sets for the same exercise
        let setsForExercise = currentExerciseSets.filter { $0.exerciseId == set.exerciseId }
        
        for (index, set) in setsForExercise.enumerated() {
            let newSet = ExerciseSet(
                id: set.id,
                workoutSessionId: set.workoutSessionId,
                exerciseId: set.exerciseId,
                setNumber: index + 1,
                reps: set.reps,
                weightKg: set.weightKg,
                effortRating: set.effortRating,
                restDurationSeconds: set.restDurationSeconds,
                notes: set.notes,
                exercise: set.exercise
            )
            
            if let index = currentExerciseSets.firstIndex(where: { $0.id == set.id }) {
                currentExerciseSets[index] = newSet
            }
        }
    }
    
    // MARK: - Timers
    
    private func startWorkoutTimer() {
        workoutTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.elapsedSeconds += 1
        }
    }
    
    private func stopWorkoutTimer() {
        workoutTimer?.invalidate()
        workoutTimer = nil
    }
    
    func startRestTimer(seconds: Int) {
        stopRestTimer()
        
        restTimerSeconds = seconds
        isRestTimerActive = true
        
        restTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else { timer.invalidate(); return }
            
            if self.restTimerSeconds > 0 {
                self.restTimerSeconds -= 1
            } else {
                self.stopRestTimer()
            }
        }
    }
    
    func stopRestTimer() {
        restTimer?.invalidate()
        restTimer = nil
        isRestTimerActive = false
        restTimerSeconds = 0
    }
    
    // MARK: - Convenience Methods
    
    var formattedElapsedTime: String {
        let hours = elapsedSeconds / 3600
        let minutes = (elapsedSeconds % 3600) / 60
        let seconds = elapsedSeconds % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    var formattedRestTime: String {
        let minutes = restTimerSeconds / 60
        let seconds = restTimerSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
} 