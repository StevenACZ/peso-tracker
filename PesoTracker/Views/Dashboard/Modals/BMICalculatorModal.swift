import SwiftUI

struct BMICalculatorModal: View {
    @Binding var isPresented: Bool
    
    @State private var height: String = ""
    @State private var weight: String = ""
    @State private var age: String = ""
    @State private var selectedGender: BMIGender = .masculine
    @State private var calculatedBMI: Double?
    @State private var error: String?
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            Text("Calculadora de IMC")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.primary)
                .padding(.bottom, 24)
            
            // Form Fields
            VStack(spacing: 20) {
                // Height and Weight Row
                HStack(spacing: 16) {
                    BMIInputField(title: "Altura (cm)", placeholder: "Ej: 175", text: $height)
                    BMIInputField(title: "Peso (kg)", placeholder: "Ej: 70", text: $weight)
                }
                
                // Age and Gender Row
                HStack(spacing: 16) {
                    BMIInputField(title: "Edad", placeholder: "Ej: 30", text: $age)
                    BMIGenderSelector(selectedGender: $selectedGender)
                }
                
                // Results Section
                if let bmi = calculatedBMI {
                    BMIResultsView(bmi: bmi, height: height)
                }
                
                // Error message
                if let error = error {
                    Text(error)
                        .font(.system(size: 12))
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                }
            }
            
            // Conditional spacing based on results
            if calculatedBMI != nil {
                Spacer()
                    .frame(height: 16)
            } else {
                Spacer().frame(height: 32)
            }
            
            // Buttons
            BMIModalButtons(
                onCalculate: calculateBMI,
                onClose: { isPresented = false },
                isCalculateDisabled: height.isEmpty || weight.isEmpty
            )
        }
        .padding(24)
        .frame(width: 510, height: calculatedBMI != nil ? 520 : 340)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
    }
    
    // MARK: - BMI Calculation
    private func calculateBMI() {
        error = nil
        
        let validationResult = BMICalculator.validateInputs(height: height, weight: weight)
        
        switch validationResult {
        case .success(let inputs):
            let bmi = BMICalculator.calculate(height: inputs.height, weight: inputs.weight)
            calculatedBMI = bmi
        case .failure(let validationError):
            error = validationError.localizedDescription
        }
    }
}

#Preview {
    BMICalculatorModal(isPresented: .constant(true))
}