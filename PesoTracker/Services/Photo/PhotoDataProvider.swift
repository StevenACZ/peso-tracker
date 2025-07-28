import Foundation

// MARK: - Photo Data Provider
class PhotoDataProvider {
    
    // MARK: - Properties
    private let apiService = APIService.shared
    
    // MARK: - API Operations
    
    // MARK: - Load Photos
    func loadPhotos(page: Int = 1, limit: Int = 10) async throws -> [Photo] {
        print("📸 [PHOTO DATA PROVIDER] Loading photos from API...")
        
        let endpoint = "\(Constants.API.Endpoints.photos)?page=\(page)&limit=\(limit)"
        print("🔗 [DEBUG] Calling photos endpoint: \(endpoint)")
        
        let fetchedPhotos = try await apiService.get(
            endpoint: endpoint,
            responseType: [Photo].self
        )
        
        print("✅ [DEBUG] Photos loaded: \(fetchedPhotos.count) records")
        return fetchedPhotos
    }
    
    // MARK: - Upload Photo
    func uploadPhoto(weightId: String, notes: String? = nil, photoData: Data) async throws -> Photo {
        print("📸 [PHOTO DATA PROVIDER] Uploading photo...")
        
        let parameters = [
            "weightId": weightId,
            "notes": notes ?? ""
        ]
        
        let uploadedPhoto = try await apiService.uploadMultipart(
            endpoint: "\(Constants.API.Endpoints.photos)/upload",
            parameters: parameters,
            imageData: photoData,
            imageKey: "photo",
            responseType: Photo.self
        )
        
        print("✅ [PHOTO DATA PROVIDER] Photo uploaded successfully")
        return uploadedPhoto
    }
    
    // MARK: - Get Photo by ID
    func getPhoto(id: String) async throws -> Photo {
        print("📸 [PHOTO DATA PROVIDER] Getting photo by ID...")
        
        let photo = try await apiService.get(
            endpoint: "\(Constants.API.Endpoints.photos)/\(id)",
            responseType: Photo.self
        )
        
        print("✅ [PHOTO DATA PROVIDER] Photo retrieved successfully")
        return photo
    }
    
    // MARK: - Delete Photo
    func deletePhoto(id: String) async throws {
        print("📸 [PHOTO DATA PROVIDER] Deleting photo...")
        
        _ = try await apiService.delete(
            endpoint: "\(Constants.API.Endpoints.photos)/\(id)",
            responseType: SuccessResponse.self
        )
        
        print("✅ [PHOTO DATA PROVIDER] Photo deleted successfully")
    }
}