import Foundation

struct WorkoutSession: Identifiable, Codable, Equatable {
    var id: UUID
    var userId: UUID
    var date: Date
    var startTime: Date
    var endTime: Date?
    var preWorkoutMobility: Int?
    var postWorkoutSoreness: Int?
    var notes: String?
    var createdAt: Date?
    
    // Relationships (not stored directly in DB, but used in the app)
    var exerciseSets: [ExerciseSet] = []
    
    // Helper computed properties
    var duration: TimeInterval? {
        guard let endTime = endTime else { return nil }
        return endTime.timeIntervalSince(startTime)
    }
    
    var formattedDuration: String? {
        guard let duration = duration else { return nil }
        
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    // Helper initializer for creating new workout sessions
    init(id: UUID = UUID(), 
         userId: UUID, 
         date: Date,
         startTime: Date,
         endTime: Date? = nil,
         preWorkoutMobility: Int? = nil,
         postWorkoutSoreness: Int? = nil,
         notes: String? = nil) {
        
        self.id = id
        self.userId = userId
        self.date = date
        self.startTime = startTime
        self.endTime = endTime
        self.preWorkoutMobility = preWorkoutMobility
        self.postWorkoutSoreness = postWorkoutSoreness
        self.notes = notes
        self.createdAt = Date()
    }
    
    // Convenience methods
    func getUniqueExercises() -> [Exercise] {
        var uniqueExercises: [Exercise] = []
        
        for set in exerciseSets {
            if let exercise = set.exercise, !uniqueExercises.contains(where: { $0.id == exercise.id }) {
                uniqueExercises.append(exercise)
            }
        }
        
        return uniqueExercises
    }
    
    func getSetsForExercise(_ exercise: Exercise) -> [ExerciseSet] {
        exerciseSets.filter { $0.exerciseId == exercise.id }
            .sorted { $0.setNumber < $1.setNumber }
    }
    
    func getAllTrainedMuscleGroups() -> [MuscleGroup] {
        var muscleGroups: [MuscleGroup] = []
        
        for set in exerciseSets {
            if let exercise = set.exercise {
                for muscleGroup in exercise.primaryMuscleGroups {
                    if !muscleGroups.contains(where: { $0.id == muscleGroup.id }) {
                        muscleGroups.append(muscleGroup)
                    }
                }
                
                for muscleGroup in exercise.secondaryMuscleGroups {
                    if !muscleGroups.contains(where: { $0.id == muscleGroup.id }) {
                        muscleGroups.append(muscleGroup)
                    }
                }
            }
        }
        
        return muscleGroups
    }
} 