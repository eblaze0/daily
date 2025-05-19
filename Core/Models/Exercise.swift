import Foundation

struct Exercise: Identifiable, Codable, Equatable {
    var id: UUID
    var userId: UUID?
    var name: String
    var instructions: String?
    var videoURL: URL?
    var movementPattern: MovementPattern?
    var isCustom: Bool
    var isPublic: Bool
    var createdAt: Date?
    
    // Relationships
    var primaryMuscleGroups: [MuscleGroup] = []
    var secondaryMuscleGroups: [MuscleGroup] = []
    var equipmentOptions: [Equipment] = []
    
    enum MovementPattern: String, Codable, CaseIterable {
        case push
        case pull
        case squat
        case hinge
        case lunge
        case carry
        case rotation
        case isometric
        case complex
        
        var displayName: String {
            switch self {
            case .push: return "Push"
            case .pull: return "Pull"
            case .squat: return "Squat"
            case .hinge: return "Hinge"
            case .lunge: return "Lunge"
            case .carry: return "Carry"
            case .rotation: return "Rotation"
            case .isometric: return "Isometric"
            case .complex: return "Complex"
            }
        }
        
        var description: String {
            switch self {
            case .push: return "Movement that pushes weight away from the body"
            case .pull: return "Movement that pulls weight toward the body"
            case .squat: return "Knee-dominant lower body movement"
            case .hinge: return "Hip-dominant lower body movement"
            case .lunge: return "Single-leg knee and hip movement"
            case .carry: return "Holding weight while moving"
            case .rotation: return "Twisting or rotating movement"
            case .isometric: return "Static hold without movement"
            case .complex: return "Combines multiple movement patterns"
            }
        }
    }
    
    // Helper initializer for creating new exercises
    init(id: UUID = UUID(), 
         userId: UUID? = nil, 
         name: String,
         instructions: String? = nil,
         videoURL: URL? = nil,
         movementPattern: MovementPattern? = nil,
         isCustom: Bool = false,
         isPublic: Bool = false,
         primaryMuscleGroups: [MuscleGroup] = [],
         secondaryMuscleGroups: [MuscleGroup] = [],
         equipmentOptions: [Equipment] = []) {
        
        self.id = id
        self.userId = userId
        self.name = name
        self.instructions = instructions
        self.videoURL = videoURL
        self.movementPattern = movementPattern
        self.isCustom = isCustom
        self.isPublic = isPublic
        self.createdAt = Date()
        self.primaryMuscleGroups = primaryMuscleGroups
        self.secondaryMuscleGroups = secondaryMuscleGroups
        self.equipmentOptions = equipmentOptions
    }
}

// Extension with common exercises (a small subset for now)
extension Exercise {
    static func commonExercises() -> [Exercise] {
        [
            Exercise(
                name: "Barbell Bench Press",
                instructions: "Lie on a flat bench, grip the barbell with hands slightly wider than shoulder-width apart, lower the bar to your chest, then press back up to the starting position.",
                movementPattern: .push,
                isCustom: false,
                isPublic: true,
                primaryMuscleGroups: [
                    MuscleGroup.all.first(where: { $0.name == "Middle Chest" })!
                ],
                secondaryMuscleGroups: [
                    MuscleGroup.all.first(where: { $0.name == "Front Delt" })!,
                    MuscleGroup.all.first(where: { $0.name == "Triceps - Lateral Head" })!
                ]
            ),
            
            Exercise(
                name: "Pull-Up",
                instructions: "Hang from a bar with arms fully extended and hands facing away from you. Pull your body up until your chin is above the bar, then lower back down with control.",
                movementPattern: .pull,
                isCustom: false,
                isPublic: true,
                primaryMuscleGroups: [
                    MuscleGroup.all.first(where: { $0.name == "Mid Back" })!
                ],
                secondaryMuscleGroups: [
                    MuscleGroup.all.first(where: { $0.name == "Biceps - Long Head" })!,
                    MuscleGroup.all.first(where: { $0.name == "Biceps - Short Head" })!
                ]
            ),
            
            Exercise(
                name: "Barbell Back Squat",
                instructions: "Place a barbell on your upper back, feet shoulder-width apart. Bend knees and hips to lower your body until thighs are parallel to the ground, then drive back up to standing.",
                movementPattern: .squat,
                isCustom: false,
                isPublic: true,
                primaryMuscleGroups: [
                    MuscleGroup.all.first(where: { $0.name == "Quads" })!
                ],
                secondaryMuscleGroups: [
                    MuscleGroup.all.first(where: { $0.name == "Glutes" })!,
                    MuscleGroup.all.first(where: { $0.name == "Lower Back" })!
                ]
            ),
            
            Exercise(
                name: "Deadlift",
                instructions: "Stand with feet hip-width apart, barbell over mid-foot. Bend at hips and knees, grasp bar, then drive through heels to stand up straight, pulling the bar up along your legs.",
                movementPattern: .hinge,
                isCustom: false,
                isPublic: true,
                primaryMuscleGroups: [
                    MuscleGroup.all.first(where: { $0.name == "Hamstrings" })!,
                    MuscleGroup.all.first(where: { $0.name == "Glutes" })!
                ],
                secondaryMuscleGroups: [
                    MuscleGroup.all.first(where: { $0.name == "Lower Back" })!,
                    MuscleGroup.all.first(where: { $0.name == "Forearms" })!
                ]
            )
        ]
    }
} 