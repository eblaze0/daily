import Foundation

struct MuscleGroup: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    var category: MuscleCategory
    var subcategory: String?
    
    enum MuscleCategory: String, Codable, CaseIterable {
        case legs
        case back
        case chest
        case shoulders
        case arms
        case core
        
        var displayName: String {
            switch self {
            case .legs: return "Legs"
            case .back: return "Back"
            case .chest: return "Chest"
            case .shoulders: return "Shoulders"
            case .arms: return "Arms"
            case .core: return "Core"
            }
        }
        
        var systemImageName: String {
            switch self {
            case .legs: return "figure.walk"
            case .back: return "figure.archery"
            case .chest: return "figure.mixed.cardio"
            case .shoulders: return "figure.american.football"
            case .arms: return "figure.boxing"
            case .core: return "figure.core.training"
            }
        }
        
        var subcategories: [String] {
            switch self {
            case .legs:
                return ["Calves", "Hamstrings", "Quads", "Glutes", "Hip Flexors"]
            case .back:
                return ["Upper Back (Traps/Rhomboids)", "Mid Back (Lats)", "Lower Back (Erector Spinae)"]
            case .chest:
                return ["Upper Chest", "Middle Chest", "Lower Chest"]
            case .shoulders:
                return ["Front Delt", "Side Delt", "Rear Delt"]
            case .arms:
                return ["Biceps - Long Head", "Biceps - Short Head", "Triceps - Long Head", 
                        "Triceps - Lateral Head", "Triceps - Medial Head", "Forearms"]
            case .core:
                return ["Abs - Upper", "Abs - Lower", "Obliques", "Transverse Abdominis"]
            }
        }
    }
    
    // Predefined muscle groups
    static let all: [MuscleGroup] = [
        // Legs
        MuscleGroup(id: UUID(), name: "Calves", category: .legs, subcategory: "Calves"),
        MuscleGroup(id: UUID(), name: "Hamstrings", category: .legs, subcategory: "Hamstrings"),
        MuscleGroup(id: UUID(), name: "Quads", category: .legs, subcategory: "Quads"),
        MuscleGroup(id: UUID(), name: "Glutes", category: .legs, subcategory: "Glutes"),
        MuscleGroup(id: UUID(), name: "Hip Flexors", category: .legs, subcategory: "Hip Flexors"),
        
        // Back
        MuscleGroup(id: UUID(), name: "Upper Back", category: .back, subcategory: "Upper Back (Traps/Rhomboids)"),
        MuscleGroup(id: UUID(), name: "Mid Back", category: .back, subcategory: "Mid Back (Lats)"),
        MuscleGroup(id: UUID(), name: "Lower Back", category: .back, subcategory: "Lower Back (Erector Spinae)"),
        
        // Chest
        MuscleGroup(id: UUID(), name: "Upper Chest", category: .chest, subcategory: "Upper Chest"),
        MuscleGroup(id: UUID(), name: "Middle Chest", category: .chest, subcategory: "Middle Chest"),
        MuscleGroup(id: UUID(), name: "Lower Chest", category: .chest, subcategory: "Lower Chest"),
        
        // Shoulders
        MuscleGroup(id: UUID(), name: "Front Delt", category: .shoulders, subcategory: "Front Delt"),
        MuscleGroup(id: UUID(), name: "Side Delt", category: .shoulders, subcategory: "Side Delt"),
        MuscleGroup(id: UUID(), name: "Rear Delt", category: .shoulders, subcategory: "Rear Delt"),
        
        // Arms
        MuscleGroup(id: UUID(), name: "Biceps - Long Head", category: .arms, subcategory: "Biceps - Long Head"),
        MuscleGroup(id: UUID(), name: "Biceps - Short Head", category: .arms, subcategory: "Biceps - Short Head"),
        MuscleGroup(id: UUID(), name: "Triceps - Long Head", category: .arms, subcategory: "Triceps - Long Head"),
        MuscleGroup(id: UUID(), name: "Triceps - Lateral Head", category: .arms, subcategory: "Triceps - Lateral Head"),
        MuscleGroup(id: UUID(), name: "Triceps - Medial Head", category: .arms, subcategory: "Triceps - Medial Head"),
        MuscleGroup(id: UUID(), name: "Forearms", category: .arms, subcategory: "Forearms"),
        
        // Core
        MuscleGroup(id: UUID(), name: "Abs - Upper", category: .core, subcategory: "Abs - Upper"),
        MuscleGroup(id: UUID(), name: "Abs - Lower", category: .core, subcategory: "Abs - Lower"),
        MuscleGroup(id: UUID(), name: "Obliques", category: .core, subcategory: "Obliques"),
        MuscleGroup(id: UUID(), name: "Transverse Abdominis", category: .core, subcategory: "Transverse Abdominis")
    ]
    
    // Group by category
    static func groupedByCategory() -> [MuscleCategory: [MuscleGroup]] {
        var groupedDict: [MuscleCategory: [MuscleGroup]] = [:]
        
        for muscleGroup in all {
            if groupedDict[muscleGroup.category] == nil {
                groupedDict[muscleGroup.category] = [muscleGroup]
            } else {
                groupedDict[muscleGroup.category]?.append(muscleGroup)
            }
        }
        
        return groupedDict
    }
} 