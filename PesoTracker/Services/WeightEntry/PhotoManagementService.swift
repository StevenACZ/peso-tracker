import Foundation
import AppKit

class PhotoManagementService {
    
    // MARK: - Properties
    private let apiService = APIService.shared
    private let imageCompressor = ImageCompressionHelper()
    
    // MARK: - Photo Upload Operations
    
    func uploadPhoto(weightId: Int, image: NSImage, notes: String?) async throws -> PhotoUploadResponse {
        print("📸 [PHOTO MGMT] Starting photo upload:")
        print("   - Weight ID: \(weightId)")
        print("   - Notes: \(notes ?? "nil")")
        print("   - Image size: \(image.size)")
        
        guard let imageData = imageCompressor.compressImage(image) else {
            print("❌ [PHOTO MGMT] Failed to compress image")
            throw APIError.encodingError(NSError(domain: "ImageProcessing", code: -1, userInfo: [NSLocalizedDescriptionKey: "No se pudo procesar la imagen"]))
        }
        
        // Use APIService's multipart upload functionality
        let parameters = [
            "weightId": String(weightId),
            "notes": notes ?? ""
        ]
        
        do {
            let result = try await apiService.uploadMultipart(
                endpoint: "/photos/upload",
                parameters: parameters,
                imageData: imageData,
                imageKey: "photo",
                responseType: PhotoUploadResponse.self
            )
            
            print("✅ [PHOTO MGMT] Photo uploaded successfully: \(result.id)")
            return result
            
        } catch {
            print("❌ [PHOTO MGMT] Failed to upload photo: \(error)")
            throw error
        }
    }
    
    func deletePhoto(photoId: Int) async throws {
        print("🗑️ [PHOTO MGMT] Deleting photo \(photoId)")
        
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
            print("❌ [PHOTO MGMT] Invalid HTTP response")
            throw APIError.networkError(NSError(domain: "NetworkError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Respuesta inválida del servidor"]))
        }
        
        print("🗑️ [PHOTO MGMT] Response status: \(httpResponse.statusCode)")
        print("🗑️ [PHOTO MGMT] Response data size: \(data.count) bytes")
        
        if let responseString = String(data: data, encoding: .utf8) {
            print("🗑️ [PHOTO MGMT] Response body: \(responseString)")
        }
        
        // Accept both 200 (deleted) and 404 (already deleted) as success
        guard 200...299 ~= httpResponse.statusCode || httpResponse.statusCode == 404 else {
            if let errorData = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let message = errorData["message"] as? String {
                print("❌ [PHOTO MGMT] Server error: \(message)")
                throw APIError.serverError(httpResponse.statusCode, message)
            }
            print("❌ [PHOTO MGMT] Server error: \(httpResponse.statusCode)")
            throw APIError.serverError(httpResponse.statusCode, "Error del servidor")
        }
        
        if httpResponse.statusCode == 404 {
            print("✅ [PHOTO MGMT] Photo already deleted (404 treated as success)")
        } else {
            print("✅ [PHOTO MGMT] Photo deleted successfully")
        }
    }
    
    // MARK: - Image Validation
    
    func validateImage(_ image: NSImage, maxSizeBytes: Int = 10 * 1024 * 1024) throws {
        // Convert to data for size validation
        guard let tiffData = image.tiffRepresentation else {
            throw APIError.encodingError(NSError(domain: "ImageProcessing", code: -1, userInfo: [NSLocalizedDescriptionKey: "No se pudo procesar la imagen"]))
        }
        
        // Validate image size
        guard imageCompressor.validateImageSize(tiffData, maxSizeBytes: maxSizeBytes) else {
            throw APIError.encodingError(NSError(domain: "ImageProcessing", code: -2, userInfo: [NSLocalizedDescriptionKey: "La imagen es muy grande. El tamaño máximo es \(maxSizeBytes / 1024 / 1024)MB."]))
        }
        
        // Validate image format
        guard imageCompressor.validateImageFormat(tiffData) else {
            throw APIError.encodingError(NSError(domain: "ImageProcessing", code: -3, userInfo: [NSLocalizedDescriptionKey: "Formato de imagen no válido. Use PNG, JPG o GIF."]))
        }
        
        print("✅ [PHOTO MGMT] Image validation passed")
    }
}