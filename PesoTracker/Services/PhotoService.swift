import Foundation

class PhotoService: ObservableObject {
    
    // MARK: - Singleton
    static let shared = PhotoService()
    
    // MARK: - Properties
    private let apiService = APIService.shared
    
    // Published properties
    @Published var isLoading = false
    @Published var photos: [Photo] = []
    @Published var error: String?
    
    // MARK: - Initialization
    private init() {
        print("📸 [PHOTO SERVICE] Initializing photo service")
    }
    
    // MARK: - Load Photos
    @MainActor
    func loadPhotos(page: Int = 1, limit: Int = 10) async {
        isLoading = true
        error = nil
        
        do {
            print("📸 [PHOTO SERVICE] Loading photos from API...")
            
            let endpoint = "\(Constants.API.Endpoints.photos)?page=\(page)&limit=\(limit)"
            print("🔗 [DEBUG] Calling photos endpoint: \(endpoint)")
            
            let fetchedPhotos = try await apiService.get(
                endpoint: endpoint,
                responseType: [Photo].self
            )
            
            print("✅ [DEBUG] Photos loaded: \(fetchedPhotos.count) records")
            photos = fetchedPhotos
            
        } catch {
            print("❌ [DEBUG] Error loading photos: \(error)")
            self.error = "Error al cargar fotos: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    // MARK: - Upload Photo
    @MainActor
    func uploadPhoto(weightId: String, notes: String? = nil, photoData: Data) async -> Bool {
        do {
            print("📸 [PHOTO SERVICE] Uploading photo...")
            
            let parameters = [
                "weightId": weightId,
                "notes": notes ?? ""
            ]
            
            let _ = try await apiService.uploadMultipart(
                endpoint: "\(Constants.API.Endpoints.photos)/upload",
                parameters: parameters,
                imageData: photoData,
                imageKey: "photo",
                responseType: Photo.self
            )
            
            print("✅ [PHOTO SERVICE] Photo uploaded successfully")
            
            // Reload photos after upload
            await loadPhotos()
            
            return true
            
        } catch {
            print("❌ [PHOTO SERVICE] Error uploading photo: \(error)")
            self.error = "Error al subir foto: \(error.localizedDescription)"
            return false
        }
    }
    
    // MARK: - Get Photo by ID
    @MainActor
    func getPhoto(id: String) async -> Photo? {
        do {
            print("📸 [PHOTO SERVICE] Getting photo by ID...")
            
            let photo = try await apiService.get(
                endpoint: "\(Constants.API.Endpoints.photos)/\(id)",
                responseType: Photo.self
            )
            
            print("✅ [PHOTO SERVICE] Photo retrieved successfully")
            return photo
            
        } catch {
            print("❌ [PHOTO SERVICE] Error getting photo: \(error)")
            self.error = "Error al obtener foto: \(error.localizedDescription)"
            return nil
        }
    }
    
    // MARK: - Delete Photo
    @MainActor
    func deletePhoto(id: String) async -> Bool {
        do {
            print("📸 [PHOTO SERVICE] Deleting photo...")
            
            let _ = try await apiService.delete(
                endpoint: "\(Constants.API.Endpoints.photos)/\(id)",
                responseType: SuccessResponse.self
            )
            
            print("✅ [PHOTO SERVICE] Photo deleted successfully")
            
            // Reload photos after deletion
            await loadPhotos()
            
            return true
            
        } catch {
            print("❌ [PHOTO SERVICE] Error deleting photo: \(error)")
            self.error = "Error al eliminar foto: \(error.localizedDescription)"
            return false
        }
    }
    
    // MARK: - Helper Methods
    func getPhotosForWeight(weightId: String) -> [Photo] {
        return photos.filter { $0.weightId == weightId }
    }
    
    func getRecentPhotos(limit: Int = 5) -> [Photo] {
        return Array(photos.prefix(limit))
    }
    
    // MARK: - Statistics
    var totalPhotos: Int {
        return photos.count
    }
    
    var photosThisMonth: Int {
        let calendar = Calendar.current
        let now = Date()
        let startOfMonth = calendar.dateInterval(of: .month, for: now)?.start ?? now
        
        return photos.filter { $0.uploadedAt >= startOfMonth }.count
    }
    
    var photosThisWeek: Int {
        let calendar = Calendar.current
        let now = Date()
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
        
        return photos.filter { $0.uploadedAt >= startOfWeek }.count
    }
    
    // MARK: - Clear Data
    func clearData() {
        photos = []
        error = nil
    }
}

// MARK: - Extensions for UI Helpers
extension PhotoService {
    
    var hasPhotoData: Bool {
        return !photos.isEmpty
    }
    
    var recentPhotos: [Photo] {
        return Array(photos.prefix(5)) // Last 5 photos
    }
    
    var lastPhotoEntry: String {
        guard let lastPhoto = photos.first else { return "Sin fotos" }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        
        return "Última foto: \(formatter.string(from: lastPhoto.uploadedAt))"
    }
    
    func getPhotosByDate() -> [String: [Photo]] {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        
        return Dictionary(grouping: photos) { photo in
            formatter.string(from: photo.uploadedAt)
        }
    }
}