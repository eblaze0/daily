import Foundation
import Combine

// Equipment Repository - Using in-memory storage for now
// Later we'll integrate with Supabase
class EquipmentRepository: Repository, ObservableObject {
    typealias Model = Equipment
    
    @Published var equipment: [Equipment] = []
    
    // MARK: - Mock Data
    private static let mockEquipment: [Equipment] = [
        Equipment(
            userId: UUID(), 
            name: "Olympic Barbell", 
            type: .barbell, 
            specifications: ["weight": "20kg", "length": "2.2m"]
        ),
        Equipment(
            userId: UUID(), 
            name: "Adjustable Bench", 
            type: .machine, 
            specifications: ["positions": "7", "incline": "0-85°"]
        ),
        Equipment(
            userId: UUID(), 
            name: "Dumbbell Set (2.5-25kg)", 
            type: .dumbbell, 
            specifications: ["increments": "2.5kg", "pairs": "10"]
        ),
        Equipment(
            userId: UUID(), 
            name: "Cable Machine", 
            type: .cable
        ),
        Equipment(
            userId: UUID(), 
            name: "Rope Attachment", 
            type: .cableAttachment,
            specifications: ["length": "70cm"]
        )
    ]
    
    init() {
        // Load mock data
        equipment = Self.mockEquipment
    }
    
    // MARK: - Repository Methods
    func create(_ equipment: Equipment) async throws -> Equipment {
        // In a real implementation, this would add to Supabase
        await MainActor.run {
            self.equipment.append(equipment)
        }
        return equipment
    }
    
    func read(id: UUID) async throws -> Equipment? {
        // In a real implementation, this would query Supabase
        return await MainActor.run {
            return equipment.first { $0.id == id }
        }
    }
    
    func update(_ equipment: Equipment) async throws -> Equipment {
        // In a real implementation, this would update in Supabase
        await MainActor.run {
            if let index = self.equipment.firstIndex(where: { $0.id == equipment.id }) {
                self.equipment[index] = equipment
            }
        }
        return equipment
    }
    
    func delete(id: UUID) async throws {
        // In a real implementation, this would delete from Supabase
        await MainActor.run {
            equipment.removeAll { $0.id == id }
        }
    }
    
    func list() async throws -> [Equipment] {
        // In a real implementation, this would query Supabase
        return await MainActor.run {
            return equipment
        }
    }
    
    func filterByType(_ type: Equipment.EquipmentType) async throws -> [Equipment] {
        return await MainActor.run {
            return equipment.filter { $0.type == type }
        }
    }
} 