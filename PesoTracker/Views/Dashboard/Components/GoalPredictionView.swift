import SwiftUI

/// GoalPredictionView - Componente visual para mostrar la predicción inteligente de meta
/// Muestra estimaciones, tendencias y mensajes motivacionales
struct GoalPredictionView: View {
    let prediction: GoalPredictionCalculator.GoalPrediction
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            // Header con icono y título
            predictionHeader
            
            // Información principal de predicción
            predictionInfo
            
            // Mensaje motivacional
            motivationalSection
        }
        .padding(Spacing.cardPadding)
        .background(predictionBackgroundColor.opacity(0.05))
        .overlay(
            RoundedRectangle(cornerRadius: Spacing.radiusStandard)
                .stroke(predictionBackgroundColor.opacity(0.2), lineWidth: 1)
        )
        .cornerRadius(Spacing.radiusStandard)
    }
    
    // MARK: - Prediction Header
    private var predictionHeader: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: prediction.icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(predictionColor)
            
            Text("PREDICCIÓN INTELIGENTE")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.secondary)
                .tracking(0.5)
            
            Spacer()
            
            // Indicador de confianza
            confidenceIndicator
        }
    }
    
    // MARK: - Prediction Info
    private var predictionInfo: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Meta Original")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    
                    Text(DateFormatterFactory.shared.formatForDisplay(prediction.originalTargetDate))
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Estimado")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    
                    Text(DateFormatterFactory.shared.formatForDisplay(prediction.estimatedCompletionDate))
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(predictionColor)
                }
            }
            
            // Diferencia de tiempo
            HStack(spacing: Spacing.xs) {
                predictionIcon
                
                Text(prediction.formattedTimeDifference)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(predictionColor)
                
                Spacer()
                
                // Peso restante
                Text("\(String(format: "%.1f", prediction.remainingWeight)) kg restantes")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
        }
    }
    
    // MARK: - Motivational Section
    private var motivationalSection: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            HStack {
                Image(systemName: "quote.bubble.fill")
                    .font(.system(size: 12))
                    .foregroundColor(predictionColor.opacity(0.7))
                
                Text(prediction.motivationalMessage)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.primary)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
                
                Spacer()
            }
            
            // Barra de progreso con porcentaje
            if prediction.progressPercentage > 0 {
                progressBar
            }
        }
    }
    
    // MARK: - Progress Bar
    private var progressBar: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            HStack {
                Text("Progreso Total")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(Int(prediction.progressPercentage))%")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(predictionColor)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.15))
                        .frame(height: 4)
                        .cornerRadius(2)
                    
                    Rectangle()
                        .fill(predictionColor)
                        .frame(width: geometry.size.width * (prediction.progressPercentage / 100), height: 4)
                        .cornerRadius(2)
                        .animation(.easeInOut(duration: 0.8), value: prediction.progressPercentage)
                }
            }
            .frame(height: 4)
        }
    }
    
    // MARK: - Confidence Indicator
    private var confidenceIndicator: some View {
        HStack(spacing: 2) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(confidenceColor(for: index))
                    .frame(width: 4, height: 4)
            }
        }
        .help(confidenceTooltip)
    }
    
    // MARK: - Prediction Icon
    private var predictionIcon: some View {
        Group {
            switch prediction.predictionType {
            case .ahead:
                Image(systemName: "arrow.up.right.circle.fill")
            case .onTrack:
                Image(systemName: "arrow.right.circle.fill")
            case .behindSlightly:
                Image(systemName: "arrow.down.right.circle.fill")
            case .behindSignificantly:
                Image(systemName: "arrow.down.circle.fill")
            }
        }
        .font(.system(size: 12))
        .foregroundColor(predictionColor)
    }
    
    // MARK: - Computed Properties
    
    private var predictionColor: Color {
        switch prediction.predictionType {
        case .ahead:
            return ColorTheme.success
        case .onTrack:
            return ColorTheme.info
        case .behindSlightly:
            return ColorTheme.warning
        case .behindSignificantly:
            return ColorTheme.error
        }
    }
    
    private var predictionBackgroundColor: Color {
        predictionColor
    }
    
    private func confidenceColor(for index: Int) -> Color {
        let confidenceLevel: Int
        switch prediction.confidence {
        case .high: confidenceLevel = 3
        case .medium: confidenceLevel = 2
        case .low: confidenceLevel = 1
        }
        
        return index < confidenceLevel ? predictionColor : Color.gray.opacity(0.3)
    }
    
    private var confidenceTooltip: String {
        switch prediction.confidence {
        case .high:
            return "Confianza alta - Predicción muy probable"
        case .medium:
            return "Confianza media - Predicción moderadamente probable"
        case .low:
            return "Confianza baja - Predicción aproximada"
        }
    }
}

// MARK: - Compact Prediction Indicator
/// Versión compacta del indicador de predicción para espacios reducidos
struct CompactPredictionIndicator: View {
    let prediction: GoalPredictionCalculator.GoalPrediction
    let weeklyAverage: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            // Header con transparencia del origen de datos
            predictionHeader
            
            // Fechas específicas
            dateComparison
            
            // Mensaje contextual
            contextualMessage
        }
        .padding(Spacing.sm)
        .background(predictionColor.opacity(0.08))
        .cornerRadius(Spacing.radiusSmall)
        .overlay(
            RoundedRectangle(cornerRadius: Spacing.radiusSmall)
                .stroke(predictionColor.opacity(0.25), lineWidth: 1)
        )
    }
    
    // MARK: - Prediction Header with Data Transparency
    private var predictionHeader: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: Spacing.xs) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(predictionColor)
                
                Text("PREDICCIÓN")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.secondary)
                    .tracking(0.3)
                
                Spacer()
                
                // Indicador de confianza mini
                HStack(spacing: 1) {
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(confidenceColor(for: index))
                            .frame(width: 3, height: 3)
                    }
                }
            }
            
            // Origen de datos transparente
            Text("Basada en promedio: \(weeklyAverageText)")
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(.secondary)
                .opacity(0.8)
        }
    }
    
    // MARK: - Weekly Average Text
    private var weeklyAverageText: String {
        let sign = weeklyAverage >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.2f", weeklyAverage))kg/sem"
    }
    
    // MARK: - Date Comparison
    private var dateComparison: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("Meta original:")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(DateFormatterFactory.shared.formatForDisplay(prediction.originalTargetDate))
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.primary)
            }
            
            HStack {
                Text("Nueva fecha:")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(DateFormatterFactory.shared.formatForDisplay(prediction.estimatedCompletionDate))
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(predictionColor)
            }
        }
    }
    
    // MARK: - Contextual Message
    private var contextualMessage: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: Spacing.xs) {
                predictionIcon
                
                Text(prediction.formattedTimeDifference)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(predictionColor)
                
                Spacer()
            }
            
            Text(contextualAdvice)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(predictionColor)
                .multilineTextAlignment(.leading)
        }
    }
    
    // MARK: - Contextual Advice
    private var contextualAdvice: String {
        switch prediction.predictionType {
        case .ahead:
            return "¡Excelente progreso! 🎉"
        case .onTrack:
            return "Mantén el ritmo actual 🎯"
        case .behindSlightly:
            return "Pequeño ajuste necesario 💪"
        case .behindSignificantly:
            return "Considera ajustar tu plan 📋"
        }
    }
    
    // MARK: - Prediction Icon
    private var predictionIcon: some View {
        Group {
            switch prediction.predictionType {
            case .ahead:
                Image(systemName: "arrow.up.right.circle.fill")
            case .onTrack:
                Image(systemName: "arrow.right.circle.fill")
            case .behindSlightly:
                Image(systemName: "arrow.down.right.circle.fill")
            case .behindSignificantly:
                Image(systemName: "arrow.down.circle.fill")
            }
        }
        .font(.system(size: 10))
        .foregroundColor(predictionColor)
    }
    
    private var predictionColor: Color {
        switch prediction.predictionType {
        case .ahead: return ColorTheme.success
        case .onTrack: return ColorTheme.info
        case .behindSlightly: return ColorTheme.warning
        case .behindSignificantly: return ColorTheme.error
        }
    }
    
    private func confidenceColor(for index: Int) -> Color {
        let confidenceLevel: Int
        switch prediction.confidence {
        case .high: confidenceLevel = 3
        case .medium: confidenceLevel = 2
        case .low: confidenceLevel = 1
        }
        
        return index < confidenceLevel ? predictionColor : Color.gray.opacity(0.3)
    }
}

// MARK: - Previews
#Preview("Goal Prediction - Ahead") {
    let prediction = GoalPredictionCalculator.GoalPrediction(
        estimatedCompletionDate: Calendar.current.date(byAdding: .day, value: -14, to: Date()) ?? Date(),
        originalTargetDate: Date(),
        daysDifference: 14,
        weeksDifference: 2.0,
        predictionType: .ahead,
        confidence: .high,
        remainingWeight: 3.2,
        estimatedWeeksRemaining: 4.0,
        motivationalMessage: "¡Excelente! Te adelantarás 2 semanas a tu meta 🎉",
        progressPercentage: 75.0
    )
    
    VStack {
        GoalPredictionView(prediction: prediction)
        Spacer()
    }
    .padding()
    .background(Color(NSColor.windowBackgroundColor))
}

#Preview("Goal Prediction - Behind") {
    let prediction = GoalPredictionCalculator.GoalPrediction(
        estimatedCompletionDate: Calendar.current.date(byAdding: .day, value: 21, to: Date()) ?? Date(),
        originalTargetDate: Date(),
        daysDifference: -21,
        weeksDifference: -3.0,
        predictionType: .behindSignificantly,
        confidence: .medium,
        remainingWeight: 8.5,
        estimatedWeeksRemaining: 10.0,
        motivationalMessage: "Requiere mayor esfuerzo para alcanzar la fecha objetivo. ¡Tú puedes! 💫",
        progressPercentage: 45.0
    )
    
    VStack {
        GoalPredictionView(prediction: prediction)
        
        Divider()
            .padding(.vertical)
        
        CompactPredictionIndicator(prediction: prediction, weeklyAverage: -0.5)
        
        Spacer()
    }
    .padding()
    .background(Color(NSColor.windowBackgroundColor))
}

#Preview("Goal Prediction - On Track") {
    let prediction = GoalPredictionCalculator.GoalPrediction(
        estimatedCompletionDate: Calendar.current.date(byAdding: .day, value: 3, to: Date()) ?? Date(),
        originalTargetDate: Date(),
        daysDifference: 3,
        weeksDifference: 0.4,
        predictionType: .onTrack,
        confidence: .high,
        remainingWeight: 2.1,
        estimatedWeeksRemaining: 2.5,
        motivationalMessage: "¡Perfecto! Estás en el camino correcto para lograr tu meta 🎯",
        progressPercentage: 85.0
    )
    
    VStack {
        CompactPredictionIndicator(prediction: prediction, weeklyAverage: -0.5)
        Spacer()
    }
    .padding()
    .background(Color(NSColor.windowBackgroundColor))
}