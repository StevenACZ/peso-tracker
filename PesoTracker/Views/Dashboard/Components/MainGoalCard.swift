import SwiftUI

struct MainGoalCard: View {
    @ObservedObject var viewModel: DashboardViewModel
    let onEditGoal: () -> Void
    let onAddGoal: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header
            
            if viewModel.hasActiveGoal {
                dataView
            } else {
                emptyView
            }
        }
    }
    
    private var header: some View {
        HStack {
            Text("META PRINCIPAL")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
                .tracking(0.5)
            
            Spacer()
            
            if viewModel.hasActiveGoal {
                CustomButton(action: onEditGoal) {
                    Image(systemName: "pencil")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    private var dataView: some View {
        VStack(spacing: 16) {
            // Weight display section
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Actual")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    Text(viewModel.formattedCurrentWeight)
                        .font(.system(size: 20, weight: .semibold))
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Objetivo")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    Text(viewModel.formattedGoalWeight)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.green)
                }
            }
            
            // Progress bar with prediction
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Meta: \(goalDateText)")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("Progreso")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 6)
                            .cornerRadius(3)
                        
                        Rectangle()
                            .fill(.green)
                            .frame(width: geometry.size.width * progressPercentage, height: 6)
                            .cornerRadius(3)
                    }
                }
                .frame(height: 6)
            }
            
            // Intelligent Prediction Section
            if let prediction = calculatePrediction(),
               let weeklyAverage = viewModel.weeklyAverage {
                CompactPredictionIndicator(
                    prediction: prediction, 
                    weeklyAverage: weeklyAverage
                )
                    .transition(.opacity.combined(with: .scale))
            }
        }
    }
    
    private var goalDateText: String {
        guard let goalDate = viewModel.goalDate else { return "Sin fecha" }
        return DateFormatterFactory.shared.formatForDisplay(goalDate)
    }
    
    private var progressPercentage: CGFloat {
        guard let currentWeight = viewModel.currentWeight,
              let goalWeight = viewModel.goalWeight,
              let initialWeight = viewModel.initialWeight else { return 0.0 }
        
        let totalChange = initialWeight - goalWeight
        let currentChange = initialWeight - currentWeight
        
        if totalChange == 0 { return 0.0 }
        
        let progress = currentChange / totalChange
        return min(max(progress, 0.0), 1.0)
    }
    
    private var emptyView: some View {
        VStack(spacing: 16) {
            Text("No has establecido una meta principal.")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            CustomButton(action: onAddGoal) {
                Text("Agregar Meta Principal")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(.green)
                    .cornerRadius(8)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }
    
    // MARK: - Prediction Calculation
    
    /// Calculates intelligent goal prediction using available dashboard data
    private func calculatePrediction() -> GoalPredictionCalculator.GoalPrediction? {
        // Verificar que tenemos todos los datos necesarios
        guard let currentWeight = viewModel.currentWeight,
              let goalWeight = viewModel.goalWeight,
              let initialWeight = viewModel.initialWeight,
              let weeklyAverage = viewModel.weeklyAverage,
              let goalDate = viewModel.goalDate else {
            return nil
        }
        
        // Solo mostrar predicción si hay suficiente progreso o datos para calcular
        guard currentWeight != initialWeight || weeklyAverage != 0 else {
            return nil
        }
        
        return GoalPredictionCalculator.shared.calculatePrediction(
            currentWeight: currentWeight,
            targetWeight: goalWeight,
            initialWeight: initialWeight,
            targetDate: goalDate,
            weeklyAverage: weeklyAverage
        )
    }
}

#Preview {
    MainGoalCard(
        viewModel: DashboardViewModel(),
        onEditGoal: {},
        onAddGoal: {}
    )
    .padding()
}