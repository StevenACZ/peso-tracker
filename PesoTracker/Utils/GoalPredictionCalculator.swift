import Foundation

/// GoalPredictionCalculator - Sistema inteligente para predecir el progreso hacia metas de peso
/// Utiliza el promedio semanal y datos actuales para calcular estimaciones precisas
class GoalPredictionCalculator {
    
    // MARK: - Prediction Result Model
    struct GoalPrediction {
        let estimatedCompletionDate: Date
        let originalTargetDate: Date
        let daysDifference: Int
        let weeksDifference: Double
        let predictionType: PredictionType
        let confidence: ConfidenceLevel
        let remainingWeight: Double
        let estimatedWeeksRemaining: Double
        let motivationalMessage: String
        let progressPercentage: Double
        
        enum PredictionType {
            case onTrack        // Dentro del rango esperado
            case ahead          // Se adelantará
            case behindSlightly // Retraso menor (< 2 semanas)
            case behindSignificantly // Retraso mayor (>= 2 semanas)
        }
        
        enum ConfidenceLevel {
            case high      // > 80% confianza
            case medium    // 50-80% confianza
            case low       // < 50% confianza
        }
    }
    
    // MARK: - Singleton
    static let shared = GoalPredictionCalculator()
    private init() {}
    
    // MARK: - Main Prediction Method
    
    /// Calcula la predicción de progreso hacia la meta
    /// - Parameters:
    ///   - currentWeight: Peso actual del usuario
    ///   - targetWeight: Peso objetivo de la meta
    ///   - initialWeight: Peso inicial cuando se estableció la meta
    ///   - targetDate: Fecha objetivo original
    ///   - weeklyAverage: Promedio semanal de pérdida/ganancia (negativo = pérdida)
    /// - Returns: GoalPrediction con todos los cálculos
    func calculatePrediction(
        currentWeight: Double,
        targetWeight: Double,
        initialWeight: Double,
        targetDate: Date,
        weeklyAverage: Double
    ) -> GoalPrediction {
        
        // Calcular peso restante para llegar a la meta
        let remainingWeight = abs(currentWeight - targetWeight)
        
        // Calcular semanas estimadas restantes
        let estimatedWeeksRemaining: Double
        if weeklyAverage == 0 {
            // Si no hay cambio semanal, usar fecha original
            let weeks = Calendar.current.dateComponents([.weekOfYear], 
                                                       from: Date(), 
                                                       to: targetDate).weekOfYear ?? 0
            estimatedWeeksRemaining = Double(weeks)
        } else {
            // Usar promedio semanal para calcular tiempo restante
            let weeklyProgress = abs(weeklyAverage)
            estimatedWeeksRemaining = remainingWeight / weeklyProgress
        }
        
        // Calcular fecha estimada de finalización
        let estimatedCompletionDate = Calendar.current.date(
            byAdding: .weekOfYear, 
            value: Int(ceil(estimatedWeeksRemaining)), 
            to: Date()
        ) ?? targetDate
        
        // Calcular diferencia en días con la fecha original
        let daysDifference = Calendar.current.dateComponents([.day], 
                                                           from: estimatedCompletionDate, 
                                                           to: targetDate).day ?? 0
        
        let weeksDifference = Double(daysDifference) / 7.0
        
        // Determinar tipo de predicción
        let predictionType = determinePredictionType(daysDifference: daysDifference)
        
        // Calcular nivel de confianza
        let confidence = calculateConfidenceLevel(
            weeklyAverage: weeklyAverage,
            remainingWeight: remainingWeight,
            timeFrame: estimatedWeeksRemaining
        )
        
        // Calcular porcentaje de progreso
        let totalWeightGoal = abs(initialWeight - targetWeight)
        let currentProgress = abs(initialWeight - currentWeight)
        let progressPercentage = totalWeightGoal > 0 ? (currentProgress / totalWeightGoal) * 100 : 0
        
        // Generar mensaje motivacional
        let motivationalMessage = generateMotivationalMessage(
            predictionType: predictionType,
            weeksDifference: weeksDifference,
            progressPercentage: progressPercentage,
            confidence: confidence
        )
        
        return GoalPrediction(
            estimatedCompletionDate: estimatedCompletionDate,
            originalTargetDate: targetDate,
            daysDifference: daysDifference,
            weeksDifference: weeksDifference,
            predictionType: predictionType,
            confidence: confidence,
            remainingWeight: remainingWeight,
            estimatedWeeksRemaining: estimatedWeeksRemaining,
            motivationalMessage: motivationalMessage,
            progressPercentage: min(progressPercentage, 100)
        )
    }
    
    // MARK: - Prediction Type Determination
    
    private func determinePredictionType(daysDifference: Int) -> GoalPrediction.PredictionType {
        switch daysDifference {
        case 8...: // 8+ días de adelanto
            return .ahead
        case -7...7: // Dentro de 1 semana de diferencia
            return .onTrack
        case -14..<(-7): // 1-2 semanas de retraso
            return .behindSlightly
        default: // Más de 2 semanas de retraso
            return .behindSignificantly
        }
    }
    
    // MARK: - Confidence Level Calculation
    
    private func calculateConfidenceLevel(
        weeklyAverage: Double,
        remainingWeight: Double,
        timeFrame: Double
    ) -> GoalPrediction.ConfidenceLevel {
        
        // Factor 1: Consistencia del promedio semanal
        let consistencyFactor: Double
        if abs(weeklyAverage) >= 0.1 && abs(weeklyAverage) <= 1.0 {
            consistencyFactor = 0.8 // Rango saludable y consistente
        } else if abs(weeklyAverage) < 0.1 {
            consistencyFactor = 0.3 // Muy poco progreso
        } else {
            consistencyFactor = 0.5 // Progreso muy rápido (poco sostenible)
        }
        
        // Factor 2: Tiempo restante
        let timeFrameFactor: Double
        if timeFrame <= 12 { // Menos de 3 meses
            timeFrameFactor = 0.8
        } else if timeFrame <= 24 { // 3-6 meses
            timeFrameFactor = 0.6
        } else {
            timeFrameFactor = 0.4 // Más de 6 meses (difícil predecir)
        }
        
        // Factor 3: Cantidad de peso restante
        let weightFactor: Double
        if remainingWeight <= 5.0 {
            weightFactor = 0.9 // Meta cercana
        } else if remainingWeight <= 15.0 {
            weightFactor = 0.7 // Meta moderada
        } else {
            weightFactor = 0.5 // Meta ambiciosa
        }
        
        // Calcular confianza total
        let totalConfidence = (consistencyFactor + timeFrameFactor + weightFactor) / 3.0
        
        if totalConfidence >= 0.7 {
            return .high
        } else if totalConfidence >= 0.5 {
            return .medium
        } else {
            return .low
        }
    }
    
    // MARK: - Motivational Message Generation
    
    private func generateMotivationalMessage(
        predictionType: GoalPrediction.PredictionType,
        weeksDifference: Double,
        progressPercentage: Double,
        confidence: GoalPrediction.ConfidenceLevel
    ) -> String {
        
        let confidenceText = confidence == .high ? "" : 
                           confidence == .medium ? " (estimación moderada)" : " (estimación aproximada)"
        
        switch predictionType {
        case .ahead:
            if weeksDifference >= 2 {
                return "¡Excelente! Te adelantarás \(Int(abs(weeksDifference))) semanas a tu meta\(confidenceText) 🎉"
            } else {
                return "¡Muy bien! Llegarás a tu meta antes de tiempo\(confidenceText) ✅"
            }
            
        case .onTrack:
            return "¡Perfecto! Estás en el camino correcto para lograr tu meta\(confidenceText) 🎯"
            
        case .behindSlightly:
            return "Un pequeño ajuste y llegarás. Se estima \(Int(abs(weeksDifference))) semana\(abs(weeksDifference) == 1 ? "" : "s") adicional\(abs(weeksDifference) == 1 ? "" : "es")\(confidenceText) 💪"
            
        case .behindSignificantly:
            if progressPercentage > 60 {
                return "Ya has avanzado mucho (\(Int(progressPercentage))%). Considera ajustar tu meta o intensificar el plan\(confidenceText) 🚀"
            } else {
                return "Requiere mayor esfuerzo para alcanzar la fecha objetivo. ¡Tú puedes!\(confidenceText) 💫"
            }
        }
    }
    
    // MARK: - Utility Methods
    
    /// Determina si la meta es realista basada en el progreso actual
    func isGoalRealistic(
        currentWeight: Double,
        targetWeight: Double,
        targetDate: Date,
        weeklyAverage: Double
    ) -> Bool {
        let prediction = calculatePrediction(
            currentWeight: currentWeight,
            targetWeight: targetWeight,
            initialWeight: currentWeight + 10, // Estimación inicial
            targetDate: targetDate,
            weeklyAverage: weeklyAverage
        )
        
        // Meta realista si:
        // 1. No está muy retrasada (< 4 semanas)
        // 2. El promedio semanal es saludable (0.2-1.0 kg/semana)
        // 3. La confianza no es baja
        return abs(prediction.weeksDifference) < 4 && 
               abs(weeklyAverage) >= 0.2 && abs(weeklyAverage) <= 1.0 &&
               prediction.confidence != .low
    }
    
    /// Sugiere ajustes para mejorar la predicción
    func suggestAdjustments(
        for prediction: GoalPrediction
    ) -> [String] {
        var suggestions: [String] = []
        
        switch prediction.predictionType {
        case .ahead:
            suggestions.append("Mantén tu rutina actual, ¡está funcionando perfectamente!")
            if prediction.weeksDifference > 4 {
                suggestions.append("Considera establecer una nueva meta más ambiciosa")
            }
            
        case .onTrack:
            suggestions.append("Continúa con tu plan actual")
            suggestions.append("Revisa tu progreso semanalmente")
            
        case .behindSlightly:
            suggestions.append("Aumenta ligeramente tu déficit calórico")
            suggestions.append("Incrementa 10-15 minutos tu actividad física diaria")
            
        case .behindSignificantly:
            suggestions.append("Considera ajustar la fecha de tu meta")
            suggestions.append("Evalúa tu plan de alimentación y ejercicio")
            if prediction.confidence == .low {
                suggestions.append("Consulta con un profesional de la salud")
            }
        }
        
        return suggestions
    }
}

// MARK: - Extensions for easy formatting

extension GoalPredictionCalculator.GoalPrediction {
    
    /// Texto formateado para mostrar la diferencia de tiempo
    var formattedTimeDifference: String {
        let absWeeks = abs(weeksDifference)
        
        if daysDifference > 0 {
            if absWeeks >= 1 {
                return "\(Int(absWeeks)) semana\(absWeeks == 1 ? "" : "s") antes"
            } else {
                return "\(daysDifference) día\(daysDifference == 1 ? "" : "s") antes"
            }
        } else if daysDifference < 0 {
            if absWeeks >= 1 {
                return "\(Int(absWeeks)) semana\(absWeeks == 1 ? "" : "s") después"
            } else {
                return "\(abs(daysDifference)) día\(abs(daysDifference) == 1 ? "" : "s") después"
            }
        } else {
            return "En fecha"
        }
    }
    
    /// Color semántico basado en el tipo de predicción
    var semanticColor: String {
        switch predictionType {
        case .ahead: return "green"
        case .onTrack: return "blue"
        case .behindSlightly: return "orange"
        case .behindSignificantly: return "red"
        }
    }
    
    /// Icono apropiado para el tipo de predicción
    var icon: String {
        switch predictionType {
        case .ahead: return "checkmark.circle.fill"
        case .onTrack: return "target"
        case .behindSlightly: return "clock.fill"
        case .behindSignificantly: return "exclamationmark.triangle.fill"
        }
    }
}