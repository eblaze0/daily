import Foundation
import Combine

@MainActor
class EquipmentViewModel: ObservableObject {
    @Published var equipment: [Equipment] = []
    @Published var filteredEquipment: [Equipment] = []
    @Published var selectedEquipmentType: Equipment.EquipmentType?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let repository = EquipmentRepository()
    
    init() {
        loadEquipment()
    }
    
    func loadEquipment() {
        isLoading = true
        
        Task {
            do {
                equipment = try await repository.list()
                applyFilters()
                isLoading = false
            } catch {
                errorMessage = "Failed to load equipment: \(error.localizedDescription)"
                isLoading = false
            }
        }
    }
    
    func addEquipment(_ equipment: Equipment) {
        Task {
            do {
                _ = try await repository.create(equipment)
                loadEquipment()
            } catch {
                errorMessage = "Failed to add equipment: \(error.localizedDescription)"
            }
        }
    }
    
    func updateEquipment(_ equipment: Equipment) {
        Task {
            do {
                _ = try await repository.update(equipment)
                loadEquipment()
            } catch {
                errorMessage = "Failed to update equipment: \(error.localizedDescription)"
            }
        }
    }
    
    func deleteEquipment(withID id: UUID) {
        Task {
            do {
                try await repository.delete(id: id)
                loadEquipment()
            } catch {
                errorMessage = "Failed to delete equipment: \(error.localizedDescription)"
            }
        }
    }
    
    func filterByType(_ type: Equipment.EquipmentType?) {
        self.selectedEquipmentType = type
        applyFilters()
    }
    
    private func applyFilters() {
        if let selectedType = selectedEquipmentType {
            filteredEquipment = equipment.filter { $0.type == selectedType }
        } else {
            filteredEquipment = equipment
        }
    }
    
    func clearFilters() {
        selectedEquipmentType = nil
        applyFilters()
    }
    
    func groupedEquipment() -> [Equipment.EquipmentType: [Equipment]] {
        Dictionary(grouping: filteredEquipment) { $0.type }
    }
    
    func createNewEquipment(name: String, type: Equipment.EquipmentType, specifications: [String: String]? = nil, isAvailable: Bool = true, gymLocation: String? = nil) {
        // In a real implementation, we would get the actual user ID from authentication
        let userID = UUID()
        
        let newEquipment = Equipment(
            userId: userID,
            name: name,
            type: type,
            specifications: specifications,
            isAvailable: isAvailable,
            gymLocation: gymLocation
        )
        
        addEquipment(newEquipment)
    }
} 