import Foundation

struct ExerciseSet: Identifiable, Codable, Equatable {
    var id: UUID
    var workoutSessionId: UUID
    var exerciseId: UUID
    var setNumber: Int
    var reps: Int?
    var weightKg: Double?
    var effortRating: Int?
    var restDurationSeconds: Int?
    var notes: String?
    var createdAt: Date?
    
    // Relationships (not stored directly in DB, but used in the app)
    var exercise: Exercise?
    
    // Helper computed properties
    var volume: Double? {
        guard let reps = reps, let weightKg = weightKg else { return nil }
        return Double(reps) * weightKg
    }
    
    var formattedWeight: String? {
        guard let weightKg = weightKg else { return nil }
        
        // Format weight value
        if weightKg == floor(weightKg) {
            return "\(Int(weightKg)) kg"
        } else {
            return "\(weightKg) kg"
        }
    }
    
    var formattedRest: String? {
        guard let restDurationSeconds = restDurationSeconds else { return nil }
        
        let minutes = restDurationSeconds / 60
        let seconds = restDurationSeconds % 60
        
        if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        } else {
            return "\(seconds)s"
        }
    }
    
    // Helper initializer for creating new exercise sets
    init(id: UUID = UUID(),
         workoutSessionId: UUID, 
         exerciseId: UUID,
         setNumber: Int,
         reps: Int? = nil,
         weightKg: Double? = nil,
         effortRating: Int? = nil,
         restDurationSeconds: Int? = nil,
         notes: String? = nil,
         exercise: Exercise? = nil) {
        
        self.id = id
        self.workoutSessionId = workoutSessionId
        self.exerciseId = exerciseId
        self.setNumber = setNumber
        self.reps = reps
        self.weightKg = weightKg
        self.effortRating = effortRating
        self.restDurationSeconds = restDurationSeconds
        self.notes = notes
        self.createdAt = Date()
        self.exercise = exercise
    }
    
    // Convenience initializer with pre-existing exercise
    init(workoutSessionId: UUID,
         exercise: Exercise,
         setNumber: Int,
         reps: Int? = nil,
         weightKg: Double? = nil,
         effortRating: Int? = nil,
         restDurationSeconds: Int? = nil,
         notes: String? = nil) {
        
        self.init(
            workoutSessionId: workoutSessionId,
            exerciseId: exercise.id,
            setNumber: setNumber,
            reps: reps,
            weightKg: weightKg,
            effortRating: effortRating,
            restDurationSeconds: restDurationSeconds,
            notes: notes,
            exercise: exercise
        )
    }
} 