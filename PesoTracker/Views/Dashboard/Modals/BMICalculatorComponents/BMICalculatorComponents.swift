import SwiftUI
import Combine

// MARK: - BMI Gender Enum
enum BMIGender: String, CaseIterable {
    case masculine = "Masculino"
    case feminine = "Femenino"
}

// MARK: - BMI Calculator Logic
struct BMICalculator {
    
    // MARK: - BMI Constants
    struct Ranges {
        static let underweight = 0..<18.5
        static let normal = 18.5..<25.0
        static let overweight = 25.0..<30.0
        static let obesityI = 30.0..<35.0
        static let obesityII = 35.0..<40.0
        static let obesityIII = 40.0...Double.infinity
        
        static let idealMin = 18.5
        static let idealMax = 24.9
    }
    
    // MARK: - Validation Error
    enum ValidationError: Error, LocalizedError {
        case invalidHeight
        case invalidWeight
        case heightOutOfRange
        case weightOutOfRange
        
        var errorDescription: String? {
            switch self {
            case .invalidHeight:
                return "Por favor ingresa una altura válida"
            case .invalidWeight:
                return "Por favor ingresa un peso válido"
            case .heightOutOfRange:
                return "La altura debe estar entre 50 y 250 cm"
            case .weightOutOfRange:
                return "El peso debe estar entre 20 y 500 kg"
            }
        }
    }
    
    // MARK: - Validation
    struct ValidationResult {
        let height: Double
        let weight: Double
    }
    
    static func validateInputs(height: String, weight: String) -> Result<ValidationResult, ValidationError> {
        guard let heightValue = Double(height), heightValue > 0 else {
            return .failure(.invalidHeight)
        }
        
        guard let weightValue = Double(weight), weightValue > 0 else {
            return .failure(.invalidWeight)
        }
        
        guard heightValue >= 50 && heightValue <= 250 else {
            return .failure(.heightOutOfRange)
        }
        
        guard weightValue >= 20 && weightValue <= 500 else {
            return .failure(.weightOutOfRange)
        }
        
        return .success(ValidationResult(height: heightValue, weight: weightValue))
    }
    
    // MARK: - BMI Calculation
    static func calculate(height: Double, weight: Double) -> Double {
        let heightInMeters = height / 100
        return weight / (heightInMeters * heightInMeters)
    }
    
    // MARK: - BMI Category
    static func getCategory(for bmi: Double) -> String {
        switch bmi {
        case Ranges.underweight:
            return "Bajo peso"
        case Ranges.normal:
            return "Peso normal"
        case Ranges.overweight:
            return "Exceso de peso"
        case Ranges.obesityI:
            return "Obesidad Grado I"
        case Ranges.obesityII:
            return "Obesidad Grado II"
        case Ranges.obesityIII:
            return "Obesidad Grado III"
        default:
            return "Valor inválido"
        }
    }
    
    // MARK: - BMI Category Color
    static func getCategoryColor(for bmi: Double) -> Color {
        switch bmi {
        case Ranges.underweight:
            return .blue.opacity(0.7)
        case Ranges.normal:
            return .green
        case Ranges.overweight:
            return .yellow.opacity(0.8)
        case Ranges.obesityI:
            return .orange
        case Ranges.obesityII:
            return .red.opacity(0.7)
        case Ranges.obesityIII:
            return .red
        default:
            return .gray
        }
    }
    
    // MARK: - Ideal Weight Range
    static func getIdealWeightRange(height: String) -> String? {
        guard let heightValue = Double(height), heightValue > 0 else { return nil }
        
        let heightInMeters = heightValue / 100
        let heightSquared = heightInMeters * heightInMeters
        
        let minWeight = Ranges.idealMin * heightSquared
        let maxWeight = Ranges.idealMax * heightSquared
        
        return String(format: "%.0f - %.0f kg", minWeight, maxWeight)
    }
}

// MARK: - BMI Input Field Component
struct BMIInputField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primary)
            
            TextField(placeholder, text: $text)
                .textFieldStyle(PlainTextFieldStyle())
                .font(.system(size: 14))
                .padding(EdgeInsets(top: 10, leading: 12, bottom: 10, trailing: 12))
                .background(Color(NSColor.controlBackgroundColor))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                )
                .cornerRadius(6)
                .onReceive(text.publisher.collect()) { _ in
                    // Filter to allow only numbers and decimal point
                    let filtered = text.filter { "0123456789.".contains($0) }
                    if filtered != text {
                        text = filtered
                    }
                }
        }
    }
}

// MARK: - BMI Gender Selector Component
struct BMIGenderSelector: View {
    @Binding var selectedGender: BMIGender
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Sexo")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primary)
            
            HStack(spacing: 16) {
                ForEach(BMIGender.allCases, id: \.self) { gender in
                    Button(action: {
                        selectedGender = gender
                    }) {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(selectedGender == gender ? Color.blue : Color.clear)
                                .stroke(Color.blue, lineWidth: 2)
                                .frame(width: 16, height: 16)
                                .overlay(
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 6, height: 6)
                                        .opacity(selectedGender == gender ? 1 : 0)
                                )
                            
                            Text(gender.rawValue)
                                .font(.system(size: 14))
                                .foregroundColor(.primary)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(NSColor.controlBackgroundColor))
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
            )
            .cornerRadius(6)
        }
    }
}

// MARK: - BMI Results View Component
struct BMIResultsView: View {
    let bmi: Double
    let height: String
    
    var body: some View {
        VStack(spacing: 16) {
            Divider()
                .padding(.vertical, 8)
            
            Text("Resultados")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 12) {
                // BMI Value
                HStack {
                    Text("Tu IMC es:")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(String(format: "%.1f", bmi))
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primary)
                }
                
                // Classification
                HStack {
                    Text("Clasificación:")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(BMICalculator.getCategory(for: bmi))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(BMICalculator.getCategoryColor(for: bmi))
                        .cornerRadius(4)
                }
                .padding(.trailing, -4)
                
                // Ideal Weight Range
                if let weightRange = BMICalculator.getIdealWeightRange(height: height) {
                    HStack {
                        Text("Rango de peso ideal:")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text(weightRange)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.green)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.secondary.opacity(0.05))
            .cornerRadius(8)
        }
    }
}

// MARK: - BMI Modal Buttons Component
struct BMIModalButtons: View {
    let onCalculate: () -> Void
    let onClose: () -> Void
    let isCalculateDisabled: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: onCalculate) {
                Text("Calcular IMC")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Color(red: 0.2, green: 0.7, blue: 0.3))
                    .cornerRadius(8)
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(isCalculateDisabled)
            
            Button(action: onClose) {
                Text("Cerrar")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Color.secondary.opacity(0.2))
                    .cornerRadius(8)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}