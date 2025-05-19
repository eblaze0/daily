import Foundation

struct UserProfile: Identifiable, Codable, Equatable {
    var id: UUID
    var age: Int?
    var gender: Gender?
    var heightCm: Double?
    var weightKg: Double?
    var fitnessGoal: FitnessGoal?
    var experienceLevel: ExperienceLevel?
    var createdAt: Date?
    var updatedAt: Date?
    
    enum Gender: String, Codable, CaseIterable {
        case male
        case female
        case nonBinary = "non_binary"
        case preferNotToSay = "prefer_not_to_say"
        
        var displayName: String {
            switch self {
            case .male: return "Male"
            case .female: return "Female"
            case .nonBinary: return "Non-binary"
            case .preferNotToSay: return "Prefer not to say"
            }
        }
    }
    
    enum FitnessGoal: String, Codable, CaseIterable {
        case strength
        case hypertrophy
        case endurance
        case generalFitness = "general_fitness"
        
        var displayName: String {
            switch self {
            case .strength: return "Strength"
            case .hypertrophy: return "Hypertrophy"
            case .endurance: return "Endurance"
            case .generalFitness: return "General Fitness"
            }
        }
        
        var description: String {
            switch self {
            case .strength: return "Build maximum strength with low to medium rep ranges"
            case .hypertrophy: return "Increase muscle size with medium rep ranges"
            case .endurance: return "Improve muscular endurance with high rep ranges"
            case .generalFitness: return "Overall fitness improvement with varied training"
            }
        }
    }
    
    enum ExperienceLevel: String, Codable, CaseIterable {
        case beginner
        case intermediate
        case advanced
        
        var displayName: String {
            switch self {
            case .beginner: return "Beginner"
            case .intermediate: return "Intermediate"
            case .advanced: return "Advanced"
            }
        }
        
        var description: String {
            switch self {
            case .beginner: return "Less than 1 year of consistent training"
            case .intermediate: return "1-3 years of consistent training"
            case .advanced: return "More than 3 years of consistent training"
            }
        }
    }
} 