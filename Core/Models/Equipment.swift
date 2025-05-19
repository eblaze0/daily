import Foundation

struct Equipment: Identifiable, Codable, Equatable {
    var id: UUID
    var userId: UUID
    var name: String
    var type: EquipmentType
    var specifications: [String: String]?
    var isAvailable: Bool
    var gymLocation: String?
    var createdAt: Date?
    
    enum EquipmentType: String, Codable, CaseIterable {
        case barbell
        case dumbbell
        case kettlebell
        case machine
        case cable
        case cableAttachment
        case bodyweight
        case resistanceBand
        case other
        
        var displayName: String {
            switch self {
            case .barbell: return "Barbell"
            case .dumbbell: return "Dumbbell"
            case .kettlebell: return "Kettlebell"
            case .machine: return "Machine"
            case .cable: return "Cable"
            case .cableAttachment: return "Cable Attachment"
            case .bodyweight: return "Bodyweight"
            case .resistanceBand: return "Resistance Band"
            case .other: return "Other"
            }
        }
        
        var systemImageName: String {
            switch self {
            case .barbell: return "figure.strengthtraining.traditional"
            case .dumbbell: return "dumbbell.fill"
            case .kettlebell: return "figure.cross.training"
            case .machine: return "figure.indoor.cycle"
            case .cable: return "cable.connector"
            case .cableAttachment: return "cable.connector.horizontal"
            case .bodyweight: return "figure.walk"
            case .resistanceBand: return "figure.flexibility"
            case .other: return "gear"
            }
        }
    }
    
    // Helper initializer for creating new equipment
    init(id: UUID = UUID(), userId: UUID, name: String, type: EquipmentType, specifications: [String: String]? = nil, isAvailable: Bool = true, gymLocation: String? = nil) {
        self.id = id
        self.userId = userId
        self.name = name
        self.type = type
        self.specifications = specifications
        self.isAvailable = isAvailable
        self.gymLocation = gymLocation
        self.createdAt = Date()
    }
} 