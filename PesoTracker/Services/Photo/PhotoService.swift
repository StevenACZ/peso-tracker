import Foundation

class PhotoService: ObservableObject {
    
    // MARK: - Singleton
    static let shared = PhotoService()
    
    // MARK: - Modular Components
    private let dataProvider = PhotoDataProvider()
    private let statisticsCalculator = PhotoStatisticsCalculator()
    
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
            photos = try await dataProvider.loadPhotos(page: page, limit: limit)
            
        } catch {
            print("❌ [PHOTO SERVICE] Error loading photos: \(error)")
            self.error = "Error al cargar fotos: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    // MARK: - Upload Photo
    @MainActor
    func uploadPhoto(weightId: String, notes: String? = nil, photoData: Data) async -> Bool {
        do {
            _ = try await dataProvider.uploadPhoto(
                weightId: weightId,
                notes: notes,
                photoData: photoData
            )
            
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
            let photo = try await dataProvider.getPhoto(id: id)
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
            try await dataProvider.deletePhoto(id: id)
            
            // Reload photos after deletion
            await loadPhotos()
            
            return true
            
        } catch {
            print("❌ [PHOTO SERVICE] Error deleting photo: \(error)")
            self.error = "Error al eliminar foto: \(error.localizedDescription)"
            return false
        }
    }
    
    // MARK: - Helper Methods (Delegated to Statistics Calculator)
    func getPhotosForWeight(weightId: String) -> [Photo] {
        return statisticsCalculator.getPhotosForWeight(from: photos, weightId: weightId)
    }
    
    func getRecentPhotos(limit: Int = 5) -> [Photo] {
        return statisticsCalculator.getRecentPhotos(from: photos, limit: limit)
    }
    
    // MARK: - Statistics (Delegated to Statistics Calculator)
    var totalPhotos: Int {
        return statisticsCalculator.getTotalPhotos(from: photos)
    }
    
    var photosThisMonth: Int {
        return statisticsCalculator.getPhotosThisMonth(from: photos)
    }
    
    var photosThisWeek: Int {
        return statisticsCalculator.getPhotosThisWeek(from: photos)
    }
    
    var photosToday: Int {
        return statisticsCalculator.getPhotosToday(from: photos)
    }
    
    // MARK: - Clear Data
    func clearData() {
        photos = []
        error = nil
    }
}

// MARK: - Extensions for UI Helpers (Delegated to Statistics Calculator)
extension PhotoService {
    
    var hasPhotoData: Bool {
        return statisticsCalculator.hasPhotoData(photos: photos)
    }
    
    var recentPhotos: [Photo] {
        return statisticsCalculator.getRecentPhotos(from: photos, limit: 5)
    }
    
    var lastPhotoEntry: String {
        return statisticsCalculator.getLastPhotoEntry(from: photos)
    }
    
    func getPhotosByDate() -> [String: [Photo]] {
        return statisticsCalculator.getPhotosByDate(from: photos)
    }
    
    func getPhotosByWeek() -> [String: [Photo]] {
        return statisticsCalculator.getPhotosByWeek(from: photos)
    }
    
    func getPhotosByMonth() -> [String: [Photo]] {
        return statisticsCalculator.getPhotosByMonth(from: photos)
    }
    
    var photoUploadFrequency: String {
        return statisticsCalculator.getPhotoUploadFrequency(from: photos)
    }
    
    var photoStreakDays: Int {
        return statisticsCalculator.getPhotoStreakDays(from: photos)
    }
    
    func averagePhotosPerWeightEntry(totalWeightEntries: Int) -> String {
        return statisticsCalculator.getAveragePhotosPerWeightEntry(
            from: photos,
            totalWeightEntries: totalWeightEntries
        )
    }
}