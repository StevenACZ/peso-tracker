import SwiftUI

struct WeightPredictionCard: View {
    @ObservedObject var viewModel: DashboardViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("ESTADÍSTICAS DE PESO")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
                .tracking(0.5)
            
            if viewModel.hasWeightData && viewModel.totalRecords >= 3 {
                dataView
            } else {
                emptyView
            }
        }
    }
    
    private var dataView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Promedio / semana")
                    .font(.system(size: 14))
                Spacer()
                Text(viewModel.formattedWeeklyAverage)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(weeklyChangeColor)
            }
            
            HStack {
                Text("Total de registros")
                    .font(.system(size: 14))
                Spacer()
                Text("\(viewModel.totalRecords)")
                    .font(.system(size: 14, weight: .medium))
            }
            
            HStack {
                Text("Cambio total")
                    .font(.system(size: 14))
                Spacer()
                Text(viewModel.formattedWeightChange)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(totalChangeColor)
            }
        }
    }
    
    private var emptyView: some View {
        Text("Agregue más registros de peso para ver estadísticas.")
            .font(.system(size: 14))
            .foregroundColor(.secondary)
            .italic()
    }
    
    private var weeklyChangeColor: Color {
        guard let weeklyAverage = viewModel.weeklyAverage else { return .secondary }
        return weeklyAverage < 0 ? .green : weeklyAverage > 0 ? .red : .secondary
    }
    
    private var totalChangeColor: Color {
        guard let change = viewModel.weightChange else { return .secondary }
        return change < 0 ? .green : change > 0 ? .red : .secondary
    }
}

#Preview {
    WeightPredictionCard(viewModel: DashboardViewModel())
        .padding()
}