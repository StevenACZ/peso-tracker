import Foundation

// MARK: - Generic API Response Wrapper
struct APIResponseWrapper<T: Codable>: Codable {
    let data: T
    let message: String?
    let success: Bool
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Try to decode as wrapped response first
        if let success = try? container.decode(Bool.self, forKey: .success) {
            self.success = success
            self.message = try container.decodeIfPresent(String.self, forKey: .message)
            self.data = try container.decode(T.self, forKey: .data)
        } else {
            // If not wrapped, assume the entire response is the data
            self.success = true
            self.message = nil
            self.data = try T(from: decoder)
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case data
        case message
        case success
    }
}

// MARK: - Paginated Response
struct PaginatedResponse<T: Codable>: Codable {
    let data: [T]
    let pagination: PaginationInfo
    
    enum CodingKeys: String, CodingKey {
        case data
        case pagination
    }
}

struct PaginationInfo: Codable {
    let page: Int
    let limit: Int
    let total: Int
    let totalPages: Int
    
    enum CodingKeys: String, CodingKey {
        case page
        case limit
        case total
        case totalPages
    }
}

// MARK: - Error Response
struct APIErrorResponse: Codable {
    let error: String
    let message: String?
    let statusCode: Int?
    let timestamp: String?
    
    enum CodingKeys: String, CodingKey {
        case error
        case message
        case statusCode = "status_code"
        case timestamp
    }
}

// MARK: - Success Response
struct SuccessResponse: Codable {
    let message: String
    let success: Bool
    
    init(message: String = "Operación exitosa") {
        self.message = message
        self.success = true
    }
}

// MARK: - Profile Response Models
struct UserProfileResponse: Codable {
    let user: User
    let profile: UserProfile?
    let stats: UserStats?
    
    enum CodingKeys: String, CodingKey {
        case user
        case profile
        case stats
    }
}

struct UserStats: Codable {
    let totalWeightRecords: Int
    let daysTracking: Int
    let currentStreak: Int
    let longestStreak: Int
    let averageWeeklyChange: Double?
    
    enum CodingKeys: String, CodingKey {
        case totalWeightRecords = "total_weight_records"
        case daysTracking = "days_tracking"
        case currentStreak = "current_streak"
        case longestStreak = "longest_streak"
        case averageWeeklyChange = "average_weekly_change"
    }
}

// MARK: - New Dashboard Response Models
struct DashboardResponse: Codable {
    let user: User
    let statistics: DashboardStatistics
    let activeGoal: DashboardGoal?
    
    enum CodingKeys: String, CodingKey {
        case user
        case statistics
        case activeGoal
    }
}

struct DashboardGoal: Codable {
    let id: Int
    let targetWeight: Double
    let targetDate: Date
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case targetWeight
        case targetDate
        case createdAt
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        targetWeight = try container.decode(Double.self, forKey: .targetWeight)
        
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
    }
}

struct DashboardStatistics: Codable {
    let initialWeight: Double?
    let currentWeight: Double?
    let totalChange: Double?
    let weeklyAverage: Double?
    let totalRecords: Int
    
    enum CodingKeys: String, CodingKey {
        case initialWeight
        case currentWeight
        case totalChange
        case weeklyAverage
        case totalRecords
    }
}

// MARK: - Chart Data Response Models
struct ChartDataResponse: Codable {
    let data: [WeightPoint]
    let pagination: ChartPagination
    
    enum CodingKeys: String, CodingKey {
        case data
        case pagination
    }
}

struct WeightPoint: Codable {
    let weight: Double
    let date: Date
    
    enum CodingKeys: String, CodingKey {
        case weight
        case date
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        weight = try container.decode(Double.self, forKey: .weight)
        
        // Handle date parsing
        let dateString = try container.decode(String.self, forKey: .date)
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let parsedDate = formatter.date(from: dateString) {
            date = parsedDate
        } else {
            formatter.formatOptions = [.withInternetDateTime]
            date = formatter.date(from: dateString) ?? Date()
        }
    }
}

struct ChartPagination: Codable {
    let currentPeriod: String
    let hasNext: Bool
    let hasPrevious: Bool
    let totalPeriods: Int
    let currentPage: Int
    
    enum CodingKeys: String, CodingKey {
        case currentPeriod
        case hasNext
        case hasPrevious
        case totalPeriods
        case currentPage
    }
}

// MARK: - Dashboard Stats (Simplified - DEPRECATED)
struct DashboardStats: Codable {
    let totalRecords: Int
    let weightChange: Double?
    let averageWeeklyChange: Double?
    let daysTracking: Int
    let currentStreak: Int
    let progressPercentage: Double?
    
    enum CodingKeys: String, CodingKey {
        case totalRecords = "total_records"
        case weightChange = "weight_change"
        case averageWeeklyChange = "average_weekly_change"
        case daysTracking = "days_tracking"
        case currentStreak = "current_streak"
        case progressPercentage = "progress_percentage"
    }
}

// MARK: - Weight Query Parameters (for GET - deprecated)
struct WeightQueryParams {
    let page: Int?
    let limit: Int?
    let startDate: Date?
    let endDate: Date?
    let sortBy: String?
    let sortOrder: String?
    
    func toQueryItems() -> [URLQueryItem] {
        var items: [URLQueryItem] = []
        
        if let page = page {
            items.append(URLQueryItem(name: "page", value: String(page)))
        }
        
        if let limit = limit {
            items.append(URLQueryItem(name: "limit", value: String(limit)))
        }
        
        if let startDate = startDate {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime]
            items.append(URLQueryItem(name: "startDate", value: formatter.string(from: startDate)))
        }
        
        if let endDate = endDate {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime]
            items.append(URLQueryItem(name: "endDate", value: formatter.string(from: endDate)))
        }
        
        if let sortBy = sortBy {
            items.append(URLQueryItem(name: "sortBy", value: sortBy))
        }
        
        if let sortOrder = sortOrder {
            items.append(URLQueryItem(name: "sortOrder", value: sortOrder))
        }
        
        return items
    }
}

// MARK: - Weight Query Request (for POST)
struct WeightQueryRequest: Codable {
    let page: Int?
    let limit: Int?
    let startDate: Date?
    let endDate: Date?
    
    enum CodingKeys: String, CodingKey {
        case page
        case limit
        case startDate
        case endDate
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(page, forKey: .page)
        try container.encodeIfPresent(limit, forKey: .limit)
        
        if let startDate = startDate {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime]
            try container.encode(formatter.string(from: startDate), forKey: .startDate)
        }
        
        if let endDate = endDate {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime]
            try container.encode(formatter.string(from: endDate), forKey: .endDate)
        }
    }
}

// MARK: - Goal Query Parameters
struct GoalQueryParams {
    let type: GoalType?
    let isCompleted: Bool?
    let limit: Int?
    
    func toQueryItems() -> [URLQueryItem] {
        var items: [URLQueryItem] = []
        
        if let type = type {
            items.append(URLQueryItem(name: "type", value: type.rawValue))
        }
        
        if let isCompleted = isCompleted {
            items.append(URLQueryItem(name: "isCompleted", value: String(isCompleted)))
        }
        
        if let limit = limit {
            items.append(URLQueryItem(name: "limit", value: String(limit)))
        }
        
        return items
    }
}

// MARK: - Health Check Response
struct HealthCheckResponse: Codable {
    let status: String
    let timestamp: Date
    let version: String?
    let database: DatabaseStatus?
    let services: [String: ServiceStatus]?
    
    enum CodingKeys: String, CodingKey {
        case status
        case timestamp
        case version
        case database
        case services
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        status = try container.decode(String.self, forKey: .status)
        version = try container.decodeIfPresent(String.self, forKey: .version)
        database = try container.decodeIfPresent(DatabaseStatus.self, forKey: .database)
        services = try container.decodeIfPresent([String: ServiceStatus].self, forKey: .services)
        
        // Handle timestamp
        if let timestampString = try? container.decode(String.self, forKey: .timestamp) {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            
            if let date = formatter.date(from: timestampString) {
                timestamp = date
            } else {
                formatter.formatOptions = [.withInternetDateTime]
                timestamp = formatter.date(from: timestampString) ?? Date()
            }
        } else {
            timestamp = Date()
        }
    }
}

struct DatabaseStatus: Codable {
    let connected: Bool
    let responseTime: Double?
    
    enum CodingKeys: String, CodingKey {
        case connected
        case responseTime = "response_time"
    }
}

struct ServiceStatus: Codable {
    let status: String
    let responseTime: Double?
    
    enum CodingKeys: String, CodingKey {
        case status
        case responseTime = "response_time"
    }
}