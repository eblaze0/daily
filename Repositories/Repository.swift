import Foundation

// Base Repository Protocol
protocol Repository {
    associatedtype Model
    
    func create(_ model: Model) async throws -> Model
    func read(id: UUID) async throws -> Model?
    func update(_ model: Model) async throws -> Model
    func delete(id: UUID) async throws
    func list() async throws -> [Model]
} 