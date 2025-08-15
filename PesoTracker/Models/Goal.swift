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
        
        // Use DateDecodingHelper for consistent date handling
        targetDate = try DateDecodingHelper.shared.decodeNormalizedDate(from: container, forKey: .targetDate)
        createdAt = try DateDecodingHelper.shared.decodeTimestamp(from: container, forKey: .createdAt)
        updatedAt = try DateDecodingHelper.shared.decodeTimestamp(from: container, forKey: .updatedAt)
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