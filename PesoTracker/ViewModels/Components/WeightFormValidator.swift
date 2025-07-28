import Foundation

// MARK: - Weight Form Validator
class WeightFormValidator: ObservableObject {
    
    // MARK: - Published Properties
    @Published var weightError: String?
    @Published var dateError: String?
    @Published var isValid = false
    
    // MARK: - Constants
    private let minWeight: Double = 1.0
    private let maxWeight: Double = 1000.0
    
    // MARK: - Validation Methods
    func validateWeight(_ weightText: String) -> Bool {
        weightError = nil
        
        guard !weightText.isEmpty else {
            weightError = "El peso es requerido"
            return false
        }
        
        guard let weightValue = Double(weightText.replacingOccurrences(of: ",", with: ".")) else {
            weightError = "Ingresa un peso válido"
            return false
        }
        
        guard weightValue >= minWeight && weightValue <= maxWeight else {
            weightError = "El peso debe estar entre \(String(format: "%.2f", minWeight)) y \(String(format: "%.0f", maxWeight)) kg"
            return false
        }
        
        return true
    }
    
    func validateDate(_ date: Date) -> Bool {
        dateError = nil
        
        let calendar = Calendar.current
        let now = Date()
        
        // Don't allow future dates
        if date > now {
            dateError = "No puedes registrar un peso en el futuro"
            return false
        }
        
        // Don't allow dates more than 2 years ago
        if let twoYearsAgo = calendar.date(byAdding: .year, value: -2, to: now), date < twoYearsAgo {
            dateError = "La fecha no puede ser anterior a 2 años"
            return false
        }
        
        return true
    }
    
    func validateForm(weight: String, date: Date) -> Bool {
        let weightValid = validateWeight(weight)
        let dateValid = validateDate(date)
        isValid = weightValid && dateValid
        return isValid
    }
}