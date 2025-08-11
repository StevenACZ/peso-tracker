import Foundation

struct Photo: Codable, Identifiable {
    let id: String
    let weightId: String
    let thumbnailUrl: String
    let mediumUrl: String?
    let fullUrl: String?
    let notes: String?
    let uploadedAt: Date
    let userId: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case weightId
        case thumbnailUrl
        case mediumUrl
        case fullUrl
        case notes
        case uploadedAt = "createdAt"
        case userId
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Handle id as either Int or String
        if let idInt = try? container.decode(Int.self, forKey: .id) {
            id = String(idInt)
        } else {
            id = try container.decode(String.self, forKey: .id)
        }
        
        // Handle weightId as either Int or String
        if let weightIdInt = try? container.decode(Int.self, forKey: .weightId) {
            weightId = String(weightIdInt)
        } else {
            weightId = try container.decode(String.self, forKey: .weightId)
        }
        
        // Transform URLs to use correct base URL based on environment
        let rawThumbnailUrl = try container.decode(String.self, forKey: .thumbnailUrl)
        let rawMediumUrl = try container.decodeIfPresent(String.self, forKey: .mediumUrl)
        let rawFullUrl = try container.decodeIfPresent(String.self, forKey: .fullUrl)
        
        thumbnailUrl = URLHelper.transformPhotoURL(rawThumbnailUrl)
        mediumUrl = rawMediumUrl != nil ? URLHelper.transformPhotoURL(rawMediumUrl!) : nil
        fullUrl = rawFullUrl != nil ? URLHelper.transformPhotoURL(rawFullUrl!) : nil
        notes = try container.decodeIfPresent(String.self, forKey: .notes)
        
        // Handle userId as either Int or String
        if let userIdInt = try? container.decode(Int.self, forKey: .userId) {
            userId = String(userIdInt)
        } else {
            userId = try container.decode(String.self, forKey: .userId)
        }
        
        // Date decoding
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        
        let uploadedAtString = try container.decode(String.self, forKey: .uploadedAt)
        if let parsedDate = dateFormatter.date(from: uploadedAtString) {
            uploadedAt = parsedDate
        } else {
            dateFormatter.formatOptions = [.withInternetDateTime]
            uploadedAt = dateFormatter.date(from: uploadedAtString) ?? Date()
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(weightId, forKey: .weightId)
        try container.encode(thumbnailUrl, forKey: .thumbnailUrl)
        try container.encodeIfPresent(mediumUrl, forKey: .mediumUrl)
        try container.encodeIfPresent(fullUrl, forKey: .fullUrl)
        try container.encodeIfPresent(notes, forKey: .notes)
        try container.encode(userId, forKey: .userId)
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        formatter.timeZone = TimeZone(identifier: "UTC")
        try container.encode(formatter.string(from: uploadedAt), forKey: .uploadedAt)
    }
}

// MARK: - Photo Request Models
struct PhotoUploadRequest: Codable {
    let weightId: String
    let notes: String?
    
    enum CodingKeys: String, CodingKey {
        case weightId = "weight_id"
        case notes
    }
}

// MARK: - Photo Progress Models
struct PhotoProgress: Identifiable {
    let id: String
    let photo: Photo
    let weight: Weight
    let date: Date
    let weightValue: Double
    let notes: String?
    
    init(photo: Photo, weight: Weight) {
        self.id = photo.id
        self.photo = photo
        self.weight = weight
        self.date = weight.date
        self.weightValue = weight.weight
        self.notes = photo.notes ?? weight.notes
    }
}

// MARK: - Photo Extensions
extension Photo {
    var hasNotes: Bool {
        return notes != nil && !notes!.isEmpty
    }
    
    var formattedUploadDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter.string(from: uploadedAt)
    }
    
    var photoURL: String {
        // Backward compatibility - use thumbnailUrl as main photoURL
        return thumbnailUrl
    }
    
    var thumbnailURL: String {
        return thumbnailUrl
    }
    
    var fullSizeURL: String {
        return fullUrl ?? thumbnailUrl
    }
}

// MARK: - Photo Collection Extensions
extension Array where Element == PhotoProgress {
    var sortedByDate: [PhotoProgress] {
        return self.sorted { $0.date < $1.date }
    }
    
    var sortedByDateDescending: [PhotoProgress] {
        return self.sorted { $0.date > $1.date }
    }
    
    func photosInDateRange(from startDate: Date, to endDate: Date) -> [PhotoProgress] {
        return self.filter { photo in
            photo.date >= startDate && photo.date <= endDate
        }
    }
    
    func photosForMonth(_ date: Date) -> [PhotoProgress] {
        let calendar = Calendar.current
        let startOfMonth = calendar.dateInterval(of: .month, for: date)?.start ?? date
        let endOfMonth = calendar.dateInterval(of: .month, for: date)?.end ?? date
        
        return photosInDateRange(from: startOfMonth, to: endOfMonth)
    }
}