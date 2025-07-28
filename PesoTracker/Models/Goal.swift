import Foundation

enum GoalType: String, Codable, CaseIterable {
    case main = "main"
    case milestone = "milestone"
    
    var displayName: String {
        switch self {
        case .main:
            return "Meta Principal"
        case .milestone:
            return "Milestone"
        }
    }
}

struct Goal: Codable, Identifiable {
    let id: String
    let targetWeight: Double
    let targetDate: Date
    let type: GoalType
    let parentGoalId: String?
    let milestoneNumber: Int?
    let isCompleted: Bool
    let userId: String
    let createdAt: Date
    let updatedAt: Date
    let completedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case targetWeight = "target_weight"
        case targetDate = "target_date"
        case type
        case parentGoalId = "parent_goal_id"
        case milestoneNumber = "milestone_number"
        case isCompleted = "is_completed"
        case userId = "user_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case completedAt = "completed_at"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        targetWeight = try container.decode(Double.self, forKey: .targetWeight)
        type = try container.decode(GoalType.self, forKey: .type)
        parentGoalId = try container.decodeIfPresent(String.self, forKey: .parentGoalId)
        milestoneNumber = try container.decodeIfPresent(Int.self, forKey: .milestoneNumber)
        isCompleted = try container.decode(Bool.self, forKey: .isCompleted)
        userId = try container.decode(String.self, forKey: .userId)
        
        // Date decoding helper
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
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
        
        // Decode completedAt (optional)
        if let completedAtString = try container.decodeIfPresent(String.self, forKey: .completedAt) {
            if let parsedDate = dateFormatter.date(from: completedAtString) {
                completedAt = parsedDate
            } else {
                dateFormatter.formatOptions = [.withInternetDateTime]
                completedAt = dateFormatter.date(from: completedAtString)
            }
        } else {
            completedAt = nil
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(targetWeight, forKey: .targetWeight)
        try container.encode(type, forKey: .type)
        try container.encodeIfPresent(parentGoalId, forKey: .parentGoalId)
        try container.encodeIfPresent(milestoneNumber, forKey: .milestoneNumber)
        try container.encode(isCompleted, forKey: .isCompleted)
        try container.encode(userId, forKey: .userId)
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        try container.encode(formatter.string(from: targetDate), forKey: .targetDate)
        try container.encode(formatter.string(from: createdAt), forKey: .createdAt)
        try container.encode(formatter.string(from: updatedAt), forKey: .updatedAt)
        
        if let completedAt = completedAt {
            try container.encode(formatter.string(from: completedAt), forKey: .completedAt)
        }
    }
}

// MARK: - Goal Request Models
struct GoalCreateRequest: Codable {
    let targetWeight: Double
    let targetDate: Date
    let type: GoalType
    let parentGoalId: String?
    let milestoneNumber: Int?
    
    enum CodingKeys: String, CodingKey {
        case targetWeight = "target_weight"
        case targetDate = "target_date"
        case type
        case parentGoalId = "parent_goal_id"
        case milestoneNumber = "milestone_number"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(targetWeight, forKey: .targetWeight)
        try container.encode(type, forKey: .type)
        try container.encodeIfPresent(parentGoalId, forKey: .parentGoalId)
        try container.encodeIfPresent(milestoneNumber, forKey: .milestoneNumber)
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        try container.encode(formatter.string(from: targetDate), forKey: .targetDate)
    }
}

struct GoalUpdateRequest: Codable {
    let targetWeight: Double?
    let targetDate: Date?
    let isCompleted: Bool?
    
    enum CodingKeys: String, CodingKey {
        case targetWeight = "target_weight"
        case targetDate = "target_date"
        case isCompleted = "is_completed"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(targetWeight, forKey: .targetWeight)
        try container.encodeIfPresent(isCompleted, forKey: .isCompleted)
        
        if let targetDate = targetDate {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime]
            try container.encode(formatter.string(from: targetDate), forKey: .targetDate)
        }
    }
}

// MARK: - Goal Extensions
extension Goal {
    var formattedTargetWeight: String {
        return String(format: "%.2f kg", targetWeight)
    }
    
    var formattedTargetDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: targetDate)
    }
    
    var isMainGoal: Bool {
        return type == .main
    }
    
    var isMilestone: Bool {
        return type == .milestone
    }
    
    var displayTitle: String {
        switch type {
        case .main:
            return "Meta Principal"
        case .milestone:
            if let number = milestoneNumber {
                return "Milestone #\(number)"
            } else {
                return "Milestone"
            }
        }
    }
    
    func progressPercentage(currentWeight: Double, startWeight: Double) -> Double {
        guard startWeight != targetWeight else { return 100.0 }
        
        let totalProgress = abs(startWeight - targetWeight)
        let currentProgress = abs(startWeight - currentWeight)
        
        let percentage = (currentProgress / totalProgress) * 100.0
        return min(max(percentage, 0.0), 100.0)
    }
    
    var isOverdue: Bool {
        return !isCompleted && targetDate < Date()
    }
    
    var daysRemaining: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let target = calendar.startOfDay(for: targetDate)
        
        let components = calendar.dateComponents([.day], from: today, to: target)
        return components.day ?? 0
    }
}