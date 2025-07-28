import Foundation

// MARK: - Photo Statistics Calculator
class PhotoStatisticsCalculator {
    
    // MARK: - Photo Filtering Methods
    
    func getPhotosForWeight(from photos: [Photo], weightId: String) -> [Photo] {
        return photos.filter { $0.weightId == weightId }
    }
    
    func getRecentPhotos(from photos: [Photo], limit: Int = 5) -> [Photo] {
        return Array(photos.prefix(limit))
    }
    
    // MARK: - Statistics Calculations
    
    func getTotalPhotos(from photos: [Photo]) -> Int {
        return photos.count
    }
    
    func getPhotosThisMonth(from photos: [Photo]) -> Int {
        let calendar = Calendar.current
        let now = Date()
        let startOfMonth = calendar.dateInterval(of: .month, for: now)?.start ?? now
        
        return photos.filter { $0.uploadedAt >= startOfMonth }.count
    }
    
    func getPhotosThisWeek(from photos: [Photo]) -> Int {
        let calendar = Calendar.current
        let now = Date()
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
        
        return photos.filter { $0.uploadedAt >= startOfWeek }.count
    }
    
    func getPhotosToday(from photos: [Photo]) -> Int {
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? now
        
        return photos.filter { photo in
            photo.uploadedAt >= startOfDay && photo.uploadedAt < endOfDay
        }.count
    }
    
    // MARK: - UI Helper Methods
    
    func hasPhotoData(photos: [Photo]) -> Bool {
        return !photos.isEmpty
    }
    
    func getLastPhotoEntry(from photos: [Photo]) -> String {
        guard let lastPhoto = photos.first else { return "Sin fotos" }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        
        return "Última foto: \(formatter.string(from: lastPhoto.uploadedAt))"
    }
    
    func getPhotosByDate(from photos: [Photo]) -> [String: [Photo]] {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        
        return Dictionary(grouping: photos) { photo in
            formatter.string(from: photo.uploadedAt)
        }
    }
    
    func getPhotosByWeek(from photos: [Photo]) -> [String: [Photo]] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-'W'ww"
        
        return Dictionary(grouping: photos) { photo in
            formatter.string(from: photo.uploadedAt)
        }
    }
    
    func getPhotosByMonth(from photos: [Photo]) -> [String: [Photo]] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        
        return Dictionary(grouping: photos) { photo in
            formatter.string(from: photo.uploadedAt)
        }
    }
    
    // MARK: - Progress Tracking
    
    func getPhotoUploadFrequency(from photos: [Photo]) -> String {
        guard !photos.isEmpty else { return "Sin datos" }
        
        let totalPhotos = photos.count
        let oldestPhoto = photos.last?.uploadedAt ?? Date()
        let daysSinceFirst = Calendar.current.dateComponents([.day], from: oldestPhoto, to: Date()).day ?? 1
        
        let frequency = Double(totalPhotos) / Double(max(daysSinceFirst, 1))
        
        if frequency >= 1.0 {
            return String(format: "%.1f fotos/día", frequency)
        } else {
            let photosPerWeek = frequency * 7
            if photosPerWeek >= 1.0 {
                return String(format: "%.1f fotos/semana", photosPerWeek)
            } else {
                let photosPerMonth = frequency * 30
                return String(format: "%.1f fotos/mes", photosPerMonth)
            }
        }
    }
    
    func getPhotoStreakDays(from photos: [Photo]) -> Int {
        guard !photos.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var streakDays = 0
        var currentDate = today
        
        // Group photos by date
        let photosByDate = Dictionary(grouping: photos) { photo in
            calendar.startOfDay(for: photo.uploadedAt)
        }
        
        // Count consecutive days with photos, starting from today
        while let _ = photosByDate[currentDate] {
            streakDays += 1
            currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
        }
        
        return streakDays
    }
    
    func getAveragePhotosPerWeightEntry(from photos: [Photo], totalWeightEntries: Int) -> String {
        guard totalWeightEntries > 0 else { return "-- fotos/entrada" }
        
        let average = Double(photos.count) / Double(totalWeightEntries)
        return String(format: "%.1f fotos/entrada", average)
    }
}