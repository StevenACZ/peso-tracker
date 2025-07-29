import SwiftUI

struct BMICalculatorModal: View {
    @Binding var isPresented: Bool
    
    @State private var height: String = ""
    @State private var weight: String = ""
    @State private var age: String = ""
    @State private var selectedGender: Gender = .masculine
    @State private var calculatedBMI: Double?
    @State private var error: String?
    
    enum Gender: String, CaseIterable {
        case masculine = "Masculino"
        case feminine = "Femenino"
    }
    
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
                    // Height Input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Altura (cm)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.primary)
                        
                        TextField("Ej: 175", text: $height)
                            .textFieldStyle(PlainTextFieldStyle())
                            .font(.system(size: 14))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(Color(NSColor.controlBackgroundColor))
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                            )
                            .cornerRadius(6)
                    }
                    
                    // Weight Input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Peso (kg)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.primary)
                        
                        TextField("Ej: 70", text: $weight)
                            .textFieldStyle(PlainTextFieldStyle())
                            .font(.system(size: 14))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(Color(NSColor.controlBackgroundColor))
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                            )
                            .cornerRadius(6)
                    }
                }
                
                // Age and Gender Row
                HStack(spacing: 16) {
                    // Age Input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Edad")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.primary)
                        
                        TextField("Ej: 30", text: $age)
                            .textFieldStyle(PlainTextFieldStyle())
                            .font(.system(size: 14))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(Color(NSColor.controlBackgroundColor))
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                            )
                            .cornerRadius(6)
                    }
                    
                    // Gender Selection
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Sexo")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.primary)
                        
                        HStack(spacing: 16) {
                            ForEach(Gender.allCases, id: \.self) { gender in
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
                
                // Results Section
                if let bmi = calculatedBMI {
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
                                
                                Text(getBMICategory(bmi))
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(bmiCategoryColor(bmi))
                                    .cornerRadius(4)
                            }
                            .padding(.trailing, -4)
                            
                            // Ideal Weight Range
                            if let weightRange = getIdealWeightRange() {
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
            HStack(spacing: 12) {
                Button(action: {
                    calculateBMI()
                }) {
                    Text("Calcular IMC")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(Color(red: 0.2, green: 0.7, blue: 0.3))
                        .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(height.isEmpty || weight.isEmpty)
                
                Button(action: {
                    isPresented = false
                }) {
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
        .padding(24)
        .frame(width: 510, height: calculatedBMI != nil ? 520 : 340)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
    }
    
    // MARK: - BMI Calculation
    private func calculateBMI() {
        error = nil
        
        guard let heightValue = Double(height), heightValue > 0 else {
            error = "Por favor ingresa una altura válida"
            return
        }
        
        guard let weightValue = Double(weight), weightValue > 0 else {
            error = "Por favor ingresa un peso válido"
            return
        }
        
        guard heightValue <= 250 else {
            error = "La altura debe ser menor a 250 cm"
            return
        }
        
        guard weightValue <= 500 else {
            error = "El peso debe ser menor a 500 kg"
            return
        }
        
        // Convert height from cm to meters
        let heightInMeters = heightValue / 100
        
        // Calculate BMI: weight (kg) / height (m)²
        let bmi = weightValue / (heightInMeters * heightInMeters)
        
        calculatedBMI = bmi
    }
    
    private func getBMICategory(_ bmi: Double) -> String {
        switch bmi {
        case ..<18:
            return "Bajo peso"
        case 18..<25:
            return "Peso normal"
        case 25..<30:
            return "Exceso de peso"
        case 30..<35:
            return "Obesidad Grado I"
        case 35..<40:
            return "Obesidad Grado II"
        default:
            return "Obesidad Grado III"
        }
    }
    
    private func bmiCategoryColor(_ bmi: Double) -> Color {
        switch bmi {
        case ..<18:
            return Color.blue.opacity(0.7) // Bajo peso - azul claro
        case 18..<25:
            return Color.green // Peso normal - verde
        case 25..<30:
            return Color.yellow.opacity(0.8) // Exceso de peso - amarillo
        case 30..<35:
            return Color.orange // Obesidad Grado I - naranja
        case 35..<40:
            return Color.red.opacity(0.7) // Obesidad Grado II - rojo claro
        default:
            return Color.red // Obesidad Grado III - rojo
        }
    }
    
    private func getIdealWeightRange() -> String? {
        guard let heightValue = Double(height), heightValue > 0 else { return nil }
        
        let heightInMeters = heightValue / 100
        
        // Ideal BMI range: 18.5 - 24.9
        let minWeight = 18.5 * (heightInMeters * heightInMeters)
        let maxWeight = 24.9 * (heightInMeters * heightInMeters)
        
        return String(format: "%.0f - %.0f kg", minWeight, maxWeight)
    }
}

#Preview {
    BMICalculatorModal(isPresented: .constant(true))
}