import Foundation

// MARK: - Goal Model (Simplified for current API)
struct Goal: Codable, Identifiable {
    let id: Int
    let userId: Int
    let targetWeight: String // API devuelve como string
    let targetDate: Date
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId
        case targetWeight
        case targetDate
        case createdAt
        case updatedAt
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        userId = try container.decode(Int.self, forKey: .userId)
        targetWeight = try container.decode(String.self, forKey: .targetWeight)
        
        // Date decoding helper
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        
        // Decode targetDate
        let targetDateString = try container.decode(String.self, forKey: .targetDate)
        if let parsedDate = dateFormatter.date(from: targetDateString) {
            targetDate = parsedDate
        } else {
            dateFormatter.formatOptions = [.withInternetDateTime]
            targetDate = dateFormatter.date(from: targetDateString) ?? Date()
        }
        
        // Decode createdAt
        let createdAtString = try container.decode(String.self, forKey: .createdAt)
        if let parsedDate = dateFormatter.date(from: createdAtString) {
            createdAt = parsedDate
        } else {
            dateFormatter.formatOptions = [.withInternetDateTime]
            createdAt = dateFormatter.date(from: createdAtString) ?? Date()
        }
        
        // Decode updatedAt
        let updatedAtString = try container.decode(String.self, forKey: .updatedAt)
        if let parsedDate = dateFormatter.date(from: updatedAtString) {
            updatedAt = parsedDate
        } else {
            dateFormatter.formatOptions = [.withInternetDateTime]
            updatedAt = dateFormatter.date(from: updatedAtString) ?? Date()
        }
    }
}

// MARK: - Goal Extensions
extension Goal {
    var formattedTargetWeight: String {
        if let weight = Double(targetWeight) {
            return String(format: "%.1f kg", weight)
        }
        return "\(targetWeight) kg"
    }
    
    var formattedTargetDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter.string(from: targetDate)
    }
    
    var targetWeightAsDouble: Double? {
        return Double(targetWeight)
    }
    
    var daysRemaining: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let target = calendar.startOfDay(for: targetDate)
        
        let components = calendar.dateComponents([.day], from: today, to: target)
        return components.day ?? 0
    }
    
    var isOverdue: Bool {
        return targetDate < Date()
    }
}