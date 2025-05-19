import Foundation
import Combine

// Exercise Repository - Using in-memory storage for now
// Later we'll integrate with Supabase
class ExerciseRepository: Repository, ObservableObject {
    typealias Model = Exercise
    
    @Published var exercises: [Exercise] = []
    
    init() {
        // Load common exercises
        exercises = Exercise.commonExercises()
    }
    
    // MARK: - Repository Methods
    func create(_ exercise: Exercise) async throws -> Exercise {
        // In a real implementation, this would add to Supabase
        await MainActor.run {
            self.exercises.append(exercise)
        }
        return exercise
    }
    
    func read(id: UUID) async throws -> Exercise? {
        // In a real implementation, this would query Supabase
        return await MainActor.run {
            return exercises.first { $0.id == id }
        }
    }
    
    func update(_ exercise: Exercise) async throws -> Exercise {
        // In a real implementation, this would update in Supabase
        await MainActor.run {
            if let index = self.exercises.firstIndex(where: { $0.id == exercise.id }) {
                self.exercises[index] = exercise
            }
        }
        return exercise
    }
    
    func delete(id: UUID) async throws {
        // In a real implementation, this would delete from Supabase
        await MainActor.run {
            exercises.removeAll { $0.id == id }
        }
    }
    
    func list() async throws -> [Exercise] {
        // In a real implementation, this would query Supabase
        return await MainActor.run {
            return exercises
        }
    }
    
    // MARK: - Additional Query Methods
    func filterByMuscleGroup(_ muscleGroup: MuscleGroup) async throws -> [Exercise] {
        return await MainActor.run {
            return exercises.filter { exercise in
                exercise.primaryMuscleGroups.contains(where: { $0.id == muscleGroup.id }) ||
                exercise.secondaryMuscleGroups.contains(where: { $0.id == muscleGroup.id })
            }
        }
    }
    
    func filterByMovementPattern(_ pattern: Exercise.MovementPattern) async throws -> [Exercise] {
        return await MainActor.run {
            return exercises.filter { $0.movementPattern == pattern }
        }
    }
    
    func filterByEquipment(_ equipment: Equipment) async throws -> [Exercise] {
        return await MainActor.run {
            return exercises.filter { exercise in
                exercise.equipmentOptions.contains(where: { $0.id == equipment.id })
            }
        }
    }
    
    func search(query: String) async throws -> [Exercise] {
        return await MainActor.run {
            guard !query.isEmpty else { return exercises }
            
            let lowercasedQuery = query.lowercased()
            return exercises.filter { exercise in
                exercise.name.lowercased().contains(lowercasedQuery) ||
                exercise.instructions?.lowercased().contains(lowercasedQuery) == true
            }
        }
    }
} 