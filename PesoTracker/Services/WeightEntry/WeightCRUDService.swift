import Foundation

class WeightCRUDService {
    
    // MARK: - Properties
    private let apiService = APIService.shared
    
    // MARK: - Weight CRUD Operations
    
    func createWeight(weight: Double, date: Date, notes: String?) async throws -> Weight {
        let request = WeightCreateRequest(
            weight: weight,
            date: date,
            notes: notes?.isEmpty == true ? nil : notes
        )
        
        // Add logging
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        print("🏋️ [WEIGHT CRUD] Creating weight entry:")
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
            
            print("✅ [WEIGHT CRUD] Weight created successfully: \(result.id)")
            return result
            
        } catch {
            print("❌ [WEIGHT CRUD] Failed to create weight: \(error)")
            throw error
        }
    }
    
    func updateWeight(id: Int, weight: Double?, date: Date?, notes: String?) async throws -> Weight {
        let request = WeightUpdateRequest(
            weight: weight,
            date: date,
            notes: notes?.isEmpty == true ? nil : notes
        )
        
        print("🔄 [WEIGHT CRUD] Updating weight entry \(id):")
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
            
            print("✅ [WEIGHT CRUD] Weight updated successfully: \(result.id)")
            return result
            
        } catch {
            print("❌ [WEIGHT CRUD] Failed to update weight: \(error)")
            throw error
        }
    }
    
    func deleteWeight(weightId: Int) async throws {
        print("🗑️ [WEIGHT CRUD] Deleting weight \(weightId)")
        
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
            print("❌ [WEIGHT CRUD] Invalid HTTP response")
            throw APIError.networkError(NSError(domain: "NetworkError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Respuesta inválida del servidor"]))
        }
        
        print("🗑️ [WEIGHT CRUD] Response status: \(httpResponse.statusCode)")
        print("🗑️ [WEIGHT CRUD] Response data size: \(data.count) bytes")
        
        if let responseString = String(data: data, encoding: .utf8) {
            print("🗑️ [WEIGHT CRUD] Response body: \(responseString)")
        }
        
        guard 200...299 ~= httpResponse.statusCode else {
            if let errorData = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let message = errorData["message"] as? String {
                print("❌ [WEIGHT CRUD] Server error: \(message)")
                throw APIError.serverError(httpResponse.statusCode, message)
            }
            print("❌ [WEIGHT CRUD] Server error: \(httpResponse.statusCode)")
            throw APIError.serverError(httpResponse.statusCode, "Error del servidor")
        }
        
        print("✅ [WEIGHT CRUD] Weight deleted successfully")
    }
    
    func getWeightPhoto(weightId: Int) async throws -> PhotoDetails? {
        print("📸 [WEIGHT CRUD] Getting photo for weight \(weightId)")
        
        do {
            let photoDetails = try await apiService.request(
                endpoint: "/weights/\(weightId)/photo",
                method: .GET,
                responseType: PhotoDetails.self
            )
            
            print("✅ [WEIGHT CRUD] Photo details retrieved:")
            print("   - Photo ID: \(photoDetails.id)")
            print("   - Thumbnail URL: \(photoDetails.thumbnailUrl)")
            
            return photoDetails
            
        } catch let error as APIError {
            // If 404, it means no photo exists for this weight
            if case .serverError(let code, _) = error, code == 404 {
                print("ℹ️ [WEIGHT CRUD] No photo found for weight \(weightId)")
                return nil
            }
            
            print("❌ [WEIGHT CRUD] Failed to get photo: \(error)")
            throw error
        } catch {
            print("❌ [WEIGHT CRUD] Unexpected error getting photo: \(error)")
            throw error
        }
    }
}