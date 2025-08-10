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
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Try to decode success field, default to true if not present
        success = try container.decodeIfPresent(Bool.self, forKey: .success) ?? true
        
        // Try to decode message field
        if let message = try container.decodeIfPresent(String.self, forKey: .message) {
            self.message = message
        } else {
            // If no message field, try to decode the entire response as a string
            let singleValueContainer = try decoder.singleValueContainer()
            if let stringMessage = try? singleValueContainer.decode(String.self) {
                self.message = stringMessage
            } else {
                // Default message if nothing can be decoded
                self.message = "Operación exitosa"
            }
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case message
        case success
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

// MARK: - Password Recovery Models
struct PasswordResetRequest: Codable {
    let email: String
    
    enum CodingKeys: String, CodingKey {
        case email
    }
}

// MARK: - Flexible Password Reset Response
struct PasswordResetResponse: Codable {
    let message: String
    let success: Bool
    
    init(from decoder: Decoder) throws {
        // Try to decode as object first
        if let container = try? decoder.container(keyedBy: CodingKeys.self) {
            message = try container.decodeIfPresent(String.self, forKey: .message) ?? "Código enviado exitosamente"
            success = try container.decodeIfPresent(Bool.self, forKey: .success) ?? true
        } else {
            // Try to decode as simple string
            let singleValueContainer = try decoder.singleValueContainer()
            if let stringMessage = try? singleValueContainer.decode(String.self) {
                message = stringMessage
                success = true
            } else {
                // Default values
                message = "Código enviado exitosamente"
                success = true
            }
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case message
        case success
    }
}

struct CodeVerificationRequest: Codable {
    let email: String
    let code: String
    
    enum CodingKeys: String, CodingKey {
        case email
        case code
    }
}

struct ResetPasswordRequest: Codable {
    let email: String
    let code: String
    let newPassword: String
    
    enum CodingKeys: String, CodingKey {
        case email
        case code
        case newPassword
    }
}

struct CodeVerificationResponse: Codable {
    let valid: Bool
    let tempToken: String
    
    enum CodingKeys: String, CodingKey {
        case valid
        case tempToken
    }
}

// MARK: - Progress Response Models
struct ProgressResponse: Codable {
    let id: Int
    let weight: Double
    let date: Date
    let notes: String?
    let photo: ProgressPhoto?
    
    enum CodingKeys: String, CodingKey {
        case id
        case weight
        case date
        case notes
        case photo
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        weight = try container.decode(Double.self, forKey: .weight)
        notes = try container.decodeIfPresent(String.self, forKey: .notes)
        photo = try container.decodeIfPresent(ProgressPhoto.self, forKey: .photo)
        
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

struct ProgressPhoto: Codable {
    let id: Int
    let userId: Int
    let weightId: Int
    let notes: String?
    let thumbnailUrl: String
    let mediumUrl: String
    let fullUrl: String
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId
        case weightId
        case notes
        case thumbnailUrl
        case mediumUrl
        case fullUrl
        case createdAt
        case updatedAt
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        userId = try container.decode(Int.self, forKey: .userId)
        weightId = try container.decode(Int.self, forKey: .weightId)
        notes = try container.decodeIfPresent(String.self, forKey: .notes)
        thumbnailUrl = try container.decode(String.self, forKey: .thumbnailUrl)
        mediumUrl = try container.decode(String.self, forKey: .mediumUrl)
        fullUrl = try container.decode(String.self, forKey: .fullUrl)
        
        // Handle date parsing for createdAt and updatedAt
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        let createdAtString = try container.decode(String.self, forKey: .createdAt)
        if let parsedDate = formatter.date(from: createdAtString) {
            createdAt = parsedDate
        } else {
            formatter.formatOptions = [.withInternetDateTime]
            createdAt = formatter.date(from: createdAtString) ?? Date()
        }
        
        let updatedAtString = try container.decode(String.self, forKey: .updatedAt)
        if let parsedDate = formatter.date(from: updatedAtString) {
            updatedAt = parsedDate
        } else {
            formatter.formatOptions = [.withInternetDateTime]
            updatedAt = formatter.date(from: updatedAtString) ?? Date()
        }
    }
}