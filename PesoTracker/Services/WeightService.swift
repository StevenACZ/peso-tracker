import Foundation
import AppKit

class WeightService {
    private let apiService = APIService.shared
    private let cacheService = CacheService.shared
    
    // MARK: - Create Weight
    func createWeight(
        weight: Double,
        date: Date,
        notes: String?,
        photoNotes: String? = nil,
        imageData: Data? = nil
    ) async throws -> Weight {
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        let dateString = dateFormatter.string(from: date)
        
        var parameters: [String: String] = [
            "weight": String(weight),
            "date": dateString
        ]
        
        if let notes = notes, !notes.isEmpty {
            parameters["notes"] = notes
        }
        
        if let photoNotes = photoNotes, !photoNotes.isEmpty {
            parameters["photoNotes"] = photoNotes
        }
        
        
        let result = try await apiService.uploadMultipart(
            endpoint: "weights",
            parameters: parameters,
            imageData: imageData,
            imageKey: "photo",
            responseType: Weight.self
        )
        
        // Invalidate cache after successful weight creation
        cacheService.invalidateTableCache()
        print("[WEIGHT SERVICE] Cache invalidated after successful weight creation")
        
        return result
    }
    
    // MARK: - Update Weight
    func updateWeight(
        id: Int,
        weight: Double,
        date: Date,
        notes: String?,
        photoNotes: String? = nil,
        imageData: Data? = nil
    ) async throws -> Weight {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        let dateString = dateFormatter.string(from: date)
        
        var parameters: [String: String] = [
            "weight": String(weight),
            "date": dateString
        ]
        
        if let notes = notes, !notes.isEmpty {
            parameters["notes"] = notes
        }
        
        if let photoNotes = photoNotes, !photoNotes.isEmpty {
            parameters["photoNotes"] = photoNotes
        }
        
        let result = try await apiService.uploadMultipart(
            endpoint: "weights/\(id)",
            parameters: parameters,
            imageData: imageData,
            imageKey: "photo",
            responseType: Weight.self,
            method: .PATCH
        )
        
        // Invalidate specific weight cache and table cache after successful weight update
        cacheService.invalidateWeight(id)
        cacheService.invalidateTableCache()
        print("[WEIGHT SERVICE] Cache invalidated after successful weight update")
        
        return result
    }
    
    // MARK: - Get Weight
    func getWeight(id: Int) async throws -> Weight {
        // Check cache first
        if let cachedWeight = cacheService.getWeight(id) {
            return cachedWeight
        }
        
        // If not in cache, fetch from API
        let weight = try await apiService.get(
            endpoint: "weights/\(id)",
            responseType: Weight.self
        )
        
        // Cache the result
        cacheService.setWeight(weight)
        
        return weight
    }
    
    // MARK: - Delete Weight
    func deleteWeight(id: Int) async throws -> DeleteResponse {
        let result = try await apiService.delete(
            endpoint: "weights/\(id)",
            responseType: DeleteResponse.self
        )
        
        // Invalidate specific weight cache and table cache after successful weight deletion
        cacheService.invalidateWeight(id)
        cacheService.invalidateTableCache()
        print("[WEIGHT SERVICE] Cache invalidated after successful weight deletion")
        
        return result
    }
    
    // MARK: - Helper Methods
    
    /// Create weight with NSImage (convenience method)
    func createWeight(
        weight: Double,
        date: Date,
        notes: String?,
        photoNotes: String? = nil,
        image: NSImage? = nil
    ) async throws -> Weight {
        
        var imageData: Data?
        if let image = image {
            imageData = try compressImage(image)
        }
        
        // This calls the main createWeight method which already handles cache invalidation
        return try await createWeight(
            weight: weight,
            date: date,
            notes: notes,
            photoNotes: photoNotes,
            imageData: imageData
        )
    }
    
    /// Update weight with NSImage (convenience method)
    func updateWeight(
        id: Int,
        weight: Double,
        date: Date,
        notes: String?,
        photoNotes: String? = nil,
        image: NSImage? = nil
    ) async throws -> Weight {
        
        var imageData: Data?
        if let image = image {
            imageData = try compressImage(image)
        }
        
        // This calls the main updateWeight method which already handles cache invalidation
        return try await updateWeight(
            id: id,
            weight: weight,
            date: date,
            notes: notes,
            photoNotes: photoNotes,
            imageData: imageData
        )
    }
    
    // MARK: - Image Processing
    
    private func compressImage(_ image: NSImage) throws -> Data {
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            throw APIError.encodingError(NSError(domain: "WeightService", code: 1, userInfo: [NSLocalizedDescriptionKey: "No se pudo convertir la imagen"]))
        }
        
        let bitmapRep = NSBitmapImageRep(cgImage: cgImage)
        bitmapRep.size = image.size
        
        guard let jpegData = bitmapRep.representation(using: .jpeg, properties: [.compressionFactor: 0.8]) else {
            throw APIError.encodingError(NSError(domain: "WeightService", code: 2, userInfo: [NSLocalizedDescriptionKey: "No se pudo comprimir la imagen"]))
        }
        
        return jpegData
    }
}

// MARK: - Response Models

struct DeleteResponse: Codable {
    let message: String
}