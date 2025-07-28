import SwiftUI

struct WeightPredictionCard: View {
    @ObservedObject var viewModel: DashboardViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("ESTADÍSTICAS DE PESO")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
                .tracking(0.5)
            
            if viewModel.hasWeightData && viewModel.weights.count >= 3 {
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
                Text(viewModel.averageWeeklyChange)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(weeklyChangeColor)
            }
            
            HStack {
                Text("Total de registros")
                    .font(.system(size: 14))
                Spacer()
                Text("\(viewModel.totalWeightRecords)")
                    .font(.system(size: 14, weight: .medium))
            }
            
            HStack {
                Text("Días rastreando")
                    .font(.system(size: 14))
                Spacer()
                Text("\(viewModel.trackingDays)")
                    .font(.system(size: 14, weight: .medium))
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
        guard let change = viewModel.weightChange else { return .secondary }
        return change < 0 ? .green : change > 0 ? .red : .secondary
    }
}

#Preview {
    WeightPredictionCard(viewModel: DashboardViewModel())
        .padding()
}