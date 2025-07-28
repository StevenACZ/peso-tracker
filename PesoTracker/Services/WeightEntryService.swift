import Foundation
import AppKit

class WeightEntryService: ObservableObject {
    private let apiService = APIService.shared
    
    // MARK: - Weight Operations
    
    func createWeight(weight: Double, date: Date, notes: String?) async throws -> Weight {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        let request = WeightCreateRequest(
            weight: weight,
            date: date,
            notes: notes?.isEmpty == true ? nil : notes
        )
        
        // Add logging
        print("🏋️ [WEIGHT SERVICE] Creating weight entry:")
        print("   - Weight: \(weight)")
        print("   - Date: \(formatter.string(from: date))")
        print("   - Notes: \(notes ?? "nil")")
        
        do {
            let result = try await apiService.request(
                endpoint: "/weights",
                method: .POST,
                body: request,
                responseType: Weight.self
            )
            
            print("✅ [WEIGHT SERVICE] Weight created successfully: \(result.id)")
            return result
            
        } catch {
            print("❌ [WEIGHT SERVICE] Failed to create weight: \(error)")
            throw error
        }
    }
    
    func updateWeight(id: Int, weight: Double?, date: Date?, notes: String?) async throws -> Weight {
        let request = WeightUpdateRequest(
            weight: weight,
            date: date,
            notes: notes?.isEmpty == true ? nil : notes
        )
        
        print("🔄 [WEIGHT SERVICE] Updating weight entry \(id):")
        print("   - Weight: \(weight?.description ?? "nil")")
        print("   - Date: \(date?.description ?? "nil")")
        print("   - Notes: \(notes ?? "nil")")
        
        do {
            let result = try await apiService.request(
                endpoint: "/weights/\(id)",
                method: .PATCH,
                body: request,
                responseType: Weight.self
            )
            
            print("✅ [WEIGHT SERVICE] Weight updated successfully: \(result.id)")
            return result
            
        } catch {
            print("❌ [WEIGHT SERVICE] Failed to update weight: \(error)")
            throw error
        }
    }
    
    func deletePhoto(photoId: Int) async throws {
        print("🗑️ [PHOTO SERVICE] Deleting photo \(photoId)")
        
        // Create request manually to handle 404 as success (photo already deleted)
        guard let url = URL(string: "\(Constants.API.baseURL)/photos/\(photoId)") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add auth header
        if let token = KeychainHelper.shared.get(key: Constants.Keychain.jwtToken) {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ [PHOTO SERVICE] Invalid HTTP response")
            throw APIError.networkError(NSError(domain: "NetworkError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Respuesta inválida del servidor"]))
        }
        
        print("🗑️ [PHOTO SERVICE] Response status: \(httpResponse.statusCode)")
        print("🗑️ [PHOTO SERVICE] Response data size: \(data.count) bytes")
        
        if let responseString = String(data: data, encoding: .utf8) {
            print("🗑️ [PHOTO SERVICE] Response body: \(responseString)")
        }
        
        // Accept both 200 (deleted) and 404 (already deleted) as success
        guard 200...299 ~= httpResponse.statusCode || httpResponse.statusCode == 404 else {
            if let errorData = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let message = errorData["message"] as? String {
                print("❌ [PHOTO SERVICE] Server error: \(message)")
                throw APIError.serverError(httpResponse.statusCode, message)
            }
            print("❌ [PHOTO SERVICE] Server error: \(httpResponse.statusCode)")
            throw APIError.serverError(httpResponse.statusCode, "Error del servidor")
        }
        
        if httpResponse.statusCode == 404 {
            print("✅ [PHOTO SERVICE] Photo already deleted (404 treated as success)")
        } else {
            print("✅ [PHOTO SERVICE] Photo deleted successfully")
        }
    }
    
    func deleteWeight(weightId: Int) async throws {
        print("🗑️ [WEIGHT SERVICE] Deleting weight \(weightId)")
        
        // Create request manually to handle different response formats
        guard let url = URL(string: "\(Constants.API.baseURL)/weights/\(weightId)") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add auth header
        if let token = KeychainHelper.shared.get(key: Constants.Keychain.jwtToken) {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ [WEIGHT SERVICE] Invalid HTTP response")
            throw APIError.networkError(NSError(domain: "NetworkError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Respuesta inválida del servidor"]))
        }
        
        print("🗑️ [WEIGHT SERVICE] Response status: \(httpResponse.statusCode)")
        print("🗑️ [WEIGHT SERVICE] Response data size: \(data.count) bytes")
        
        if let responseString = String(data: data, encoding: .utf8) {
            print("🗑️ [WEIGHT SERVICE] Response body: \(responseString)")
        }
        
        guard 200...299 ~= httpResponse.statusCode else {
            if let errorData = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let message = errorData["message"] as? String {
                print("❌ [WEIGHT SERVICE] Server error: \(message)")
                throw APIError.serverError(httpResponse.statusCode, message)
            }
            print("❌ [WEIGHT SERVICE] Server error: \(httpResponse.statusCode)")
            throw APIError.serverError(httpResponse.statusCode, "Error del servidor")
        }
        
        print("✅ [WEIGHT SERVICE] Weight deleted successfully")
    }
    
    func getWeightPhoto(weightId: Int) async throws -> PhotoDetails? {
        print("📸 [WEIGHT SERVICE] Getting photo for weight \(weightId)")
        
        do {
            let photoDetails = try await apiService.request(
                endpoint: "/weights/\(weightId)/photo",
                method: .GET,
                responseType: PhotoDetails.self
            )
            
            print("✅ [WEIGHT SERVICE] Photo details retrieved:")
            print("   - Photo ID: \(photoDetails.id)")
            print("   - Thumbnail URL: \(photoDetails.thumbnailUrl)")
            
            return photoDetails
            
        } catch let error as APIError {
            // If 404, it means no photo exists for this weight
            if case .serverError(let code, _) = error, code == 404 {
                print("ℹ️ [WEIGHT SERVICE] No photo found for weight \(weightId)")
                return nil
            }
            
            print("❌ [WEIGHT SERVICE] Failed to get photo: \(error)")
            throw error
        } catch {
            print("❌ [WEIGHT SERVICE] Unexpected error getting photo: \(error)")
            throw error
        }
    }
    
    // MARK: - Photo Upload Operations
    
    func uploadPhoto(weightId: Int, image: NSImage, notes: String?) async throws -> PhotoUploadResponse {
        print("📸 [PHOTO SERVICE] Starting photo upload:")
        print("   - Weight ID: \(weightId)")
        print("   - Notes: \(notes ?? "nil")")
        print("   - Image size: \(image.size)")
        
        guard let imageData = compressImage(image) else {
            print("❌ [PHOTO SERVICE] Failed to compress image")
            throw APIError.encodingError(NSError(domain: "ImageProcessing", code: -1, userInfo: [NSLocalizedDescriptionKey: "No se pudo procesar la imagen"]))
        }
        
        print("📸 [PHOTO SERVICE] Image compressed to \(imageData.count) bytes")
        
        // Create multipart form data
        let boundary = "Boundary-\(UUID().uuidString)"
        var body = Data()
        
        // Add weightId field
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"weightId\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(weightId)\r\n".data(using: .utf8)!)
        
        // Add notes field
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"notes\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(notes ?? "")\r\n".data(using: .utf8)!)
        
        // Add photo field
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"photo\"; filename=\"photo.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        
        // Close boundary
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        // Create request
        guard let url = URL(string: "\(Constants.API.baseURL)/photos/upload") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // Add auth header
        if let token = KeychainHelper.shared.get(key: Constants.Keychain.jwtToken) {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        request.httpBody = body
        
        print("📸 [PHOTO SERVICE] Sending request to: \(request.url?.absoluteString ?? "unknown")")
        print("📸 [PHOTO SERVICE] Request body size: \(body.count) bytes")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ [PHOTO SERVICE] Invalid HTTP response")
            throw APIError.networkError(NSError(domain: "NetworkError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Respuesta inválida del servidor"]))
        }
        
        print("📸 [PHOTO SERVICE] Response status: \(httpResponse.statusCode)")
        print("📸 [PHOTO SERVICE] Response data size: \(data.count) bytes")
        
        if let responseString = String(data: data, encoding: .utf8) {
            print("📸 [PHOTO SERVICE] Response body: \(responseString)")
        }
        
        guard 200...299 ~= httpResponse.statusCode else {
            if let errorData = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let message = errorData["message"] as? String {
                print("❌ [PHOTO SERVICE] Server error: \(message)")
                throw APIError.serverError(httpResponse.statusCode, message)
            }
            print("❌ [PHOTO SERVICE] Server error: \(httpResponse.statusCode)")
            throw APIError.serverError(httpResponse.statusCode, "Error del servidor")
        }
        
        do {
            let result = try JSONDecoder().decode(PhotoUploadResponse.self, from: data)
            print("✅ [PHOTO SERVICE] Photo uploaded successfully: \(result.id)")
            return result
        } catch {
            print("❌ [PHOTO SERVICE] Failed to decode response: \(error)")
            throw APIError.decodingError(error)
        }
    }
    
    // MARK: - Helper Methods
    
    private func compressImage(_ image: NSImage) -> Data? {
        guard let tiffData = image.tiffRepresentation,
              let bitmapImage = NSBitmapImageRep(data: tiffData) else {
            return nil
        }
        
        // Resize if needed (max 1024px)
        let maxSize: CGFloat = 1024
        var newSize = image.size
        
        if max(newSize.width, newSize.height) > maxSize {
            let scale = maxSize / max(newSize.width, newSize.height)
            newSize = CGSize(width: newSize.width * scale, height: newSize.height * scale)
            
            let resizedImage = NSImage(size: newSize)
            resizedImage.lockFocus()
            image.draw(in: NSRect(origin: .zero, size: newSize))
            resizedImage.unlockFocus()
            
            guard let resizedTiffData = resizedImage.tiffRepresentation,
                  let resizedBitmapImage = NSBitmapImageRep(data: resizedTiffData) else {
                return bitmapImage.representation(using: .jpeg, properties: [.compressionFactor: 0.8])
            }
            
            return resizedBitmapImage.representation(using: .jpeg, properties: [.compressionFactor: 0.8])
        }
        
        return bitmapImage.representation(using: .jpeg, properties: [.compressionFactor: 0.8])
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