import Foundation

enum Gender: String, Codable, CaseIterable {
    case male = "male"
    case female = "female"
    
    var displayName: String {
        switch self {
        case .male:
            return "Masculino"
        case .female:
            return "Femenino"
        }
    }
}

enum Lifestyle: String, Codable, CaseIterable {
    case sedentary = "sedentary"
    case active = "active"
    case veryActive = "very_active"
    
    var displayName: String {
        switch self {
        case .sedentary:
            return "Sedentario"
        case .active:
            return "Activo"
        case .veryActive:
            return "Muy Activo"
        }
    }
    
    var activityFactor: Double {
        switch self {
        case .sedentary:
            return 1.2
        case .active:
            return 1.55
        case .veryActive:
            return 1.9
        }
    }
    
    var description: String {
        switch self {
        case .sedentary:
            return "Poco o ningún ejercicio"
        case .active:
            return "Ejercicio moderado 3-5 días/semana"
        case .veryActive:
            return "Ejercicio intenso 6-7 días/semana"
        }
    }
}

struct UserProfile: Codable {
    let userId: String
    let height: Double? // in centimeters
    let age: Int?
    let gender: Gender?
    let lifestyle: Lifestyle?
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case height
        case age
        case gender
        case lifestyle
        case updatedAt = "updated_at"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        userId = try container.decode(String.self, forKey: .userId)
        height = try container.decodeIfPresent(Double.self, forKey: .height)
        age = try container.decodeIfPresent(Int.self, forKey: .age)
        gender = try container.decodeIfPresent(Gender.self, forKey: .gender)
        lifestyle = try container.decodeIfPresent(Lifestyle.self, forKey: .lifestyle)
        
        // Date decoding
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        
        let updatedAtString = try container.decode(String.self, forKey: .updatedAt)
        if let parsedDate = dateFormatter.date(from: updatedAtString) {
            updatedAt = parsedDate
        } else {
            dateFormatter.formatOptions = [.withInternetDateTime]
            updatedAt = dateFormatter.date(from: updatedAtString) ?? Date()
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(userId, forKey: .userId)
        try container.encodeIfPresent(height, forKey: .height)
        try container.encodeIfPresent(age, forKey: .age)
        try container.encodeIfPresent(gender, forKey: .gender)
        try container.encodeIfPresent(lifestyle, forKey: .lifestyle)
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        formatter.timeZone = TimeZone(identifier: "UTC")
        try container.encode(formatter.string(from: updatedAt), forKey: .updatedAt)
    }
}

// MARK: - Profile Request Models
struct UserProfileUpdateRequest: Codable {
    let height: Double?
    let age: Int?
    let gender: Gender?
    let lifestyle: Lifestyle?
    
    enum CodingKeys: String, CodingKey {
        case height
        case age
        case gender
        case lifestyle
    }
}

// MARK: - BMI Calculation
enum BMICategory: String, CaseIterable {
    case underweight = "underweight"
    case normal = "normal"
    case overweight = "overweight"
    case obese = "obese"
    
    var displayName: String {
        switch self {
        case .underweight:
            return "Bajo peso"
        case .normal:
            return "Normal"
        case .overweight:
            return "Sobrepeso"
        case .obese:
            return "Obesidad"
        }
    }
    
    var color: String {
        switch self {
        case .underweight:
            return "blue"
        case .normal:
            return "green"
        case .overweight:
            return "yellow"
        case .obese:
            return "red"
        }
    }
    
    var range: String {
        switch self {
        case .underweight:
            return "< 18.5"
        case .normal:
            return "18.5 - 24.9"
        case .overweight:
            return "25.0 - 29.9"
        case .obese:
            return "≥ 30.0"
        }
    }
}

// MARK: - UserProfile Extensions
extension UserProfile {
    var isComplete: Bool {
        return height != nil && age != nil && gender != nil && lifestyle != nil
    }
    
    var hasBasicInfo: Bool {
        return height != nil && age != nil
    }
    
    func calculateBMI(currentWeight: Double) -> Double? {
        guard let height = height, height > 0 else { return nil }
        
        let heightInMeters = height / 100.0
        return currentWeight / (heightInMeters * heightInMeters)
    }
    
    func getBMICategory(currentWeight: Double) -> BMICategory? {
        guard let bmi = calculateBMI(currentWeight: currentWeight) else { return nil }
        
        switch bmi {
        case ..<18.5:
            return .underweight
        case 18.5..<25.0:
            return .normal
        case 25.0..<30.0:
            return .overweight
        default:
            return .obese
        }
    }
    
    func calculateBMR(currentWeight: Double) -> Double? {
        guard let age = age, let gender = gender, let height = height else { return nil }
        
        // Mifflin-St Jeor Equation
        switch gender {
        case .male:
            return (10 * currentWeight) + (6.25 * height) - (5 * Double(age)) + 5
        case .female:
            return (10 * currentWeight) + (6.25 * height) - (5 * Double(age)) - 161
        }
    }
    
    func calculateTDEE(currentWeight: Double) -> Double? {
        guard let bmr = calculateBMR(currentWeight: currentWeight),
              let lifestyle = lifestyle else { return nil }
        
        return bmr * lifestyle.activityFactor
    }
    
    func estimatedDailyCalorieDeficit(targetWeight: Double, currentWeight: Double, daysToGoal: Int) -> Double? {
        guard calculateTDEE(currentWeight: currentWeight) != nil else { return nil }
        
        let weightDifference = abs(currentWeight - targetWeight)
        let totalCaloriesNeeded = weightDifference * 7700 // 7700 calories per kg
        let dailyCalorieDeficit = totalCaloriesNeeded / Double(daysToGoal)
        
        return dailyCalorieDeficit
    }
    
    var formattedHeight: String? {
        guard let height = height else { return nil }
        return String(format: "%.0f cm", height)
    }
    
    var formattedAge: String? {
        guard let age = age else { return nil }
        return "\(age) años"
    }
    
    func formattedBMI(currentWeight: Double) -> String? {
        guard let bmi = calculateBMI(currentWeight: currentWeight) else { return nil }
        return String(format: "%.2f", bmi)
    }
}