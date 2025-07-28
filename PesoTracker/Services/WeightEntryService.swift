import Foundation
import AppKit

class WeightEntryService: ObservableObject {
    
    // MARK: - Modular Components
    private let weightCRUD = WeightCRUDService()
    private let photoManager = PhotoManagementService()
    
    // MARK: - Weight Operations (Delegated to WeightCRUDService)
    
    func createWeight(weight: Double, date: Date, notes: String?) async throws -> Weight {
        return try await weightCRUD.createWeight(weight: weight, date: date, notes: notes)
    }
    
    func updateWeight(id: Int, weight: Double?, date: Date?, notes: String?) async throws -> Weight {
        return try await weightCRUD.updateWeight(id: id, weight: weight, date: date, notes: notes)
    }
    
    // MARK: - Photo Operations (Delegated to PhotoManagementService)
    
    func deletePhoto(photoId: Int) async throws {
        try await photoManager.deletePhoto(photoId: photoId)
    }
    
    func deleteWeight(weightId: Int) async throws {
        try await weightCRUD.deleteWeight(weightId: weightId)
    }
    
    func getWeightPhoto(weightId: Int) async throws -> PhotoDetails? {
        return try await weightCRUD.getWeightPhoto(weightId: weightId)
    }
    
    func uploadPhoto(weightId: Int, image: NSImage, notes: String?) async throws -> PhotoUploadResponse {
        return try await photoManager.uploadPhoto(weightId: weightId, image: image, notes: notes)
    }
}

// MARK: - Response Models

struct PhotoUploadResponse: Codable {
    let id: Int
    let userId: Int
    let weightId: Int
    let notes: String?
    let thumbnailUrl: String
    let mediumUrl: String
    let fullUrl: String
    let createdAt: String
    let updatedAt: String
    let weight: Weight?
}

struct PhotoDetails: Codable {
    let id: Int
    let userId: Int
    let weightId: Int
    let notes: String?
    let thumbnailUrl: String
    let mediumUrl: String
    let fullUrl: String
    let createdAt: String
    let updatedAt: String
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        userId = try container.decode(Int.self, forKey: .userId)
        weightId = try container.decode(Int.self, forKey: .weightId)
        notes = try container.decodeIfPresent(String.self, forKey: .notes)
        thumbnailUrl = try container.decode(String.self, forKey: .thumbnailUrl)
        mediumUrl = try container.decode(String.self, forKey: .mediumUrl)
        fullUrl = try container.decode(String.self, forKey: .fullUrl)
        createdAt = try container.decode(String.self, forKey: .createdAt)
        updatedAt = try container.decode(String.self, forKey: .updatedAt)
    }
    
    enum CodingKeys: String, CodingKey {
        case id, userId, weightId, notes, thumbnailUrl, mediumUrl, fullUrl, createdAt, updatedAt
    }
}