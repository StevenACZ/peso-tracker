import SwiftUI

struct WeightPredictionCard: View {
    @ObservedObject var viewModel: DashboardViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("ESTADÍSTICAS DE PESO")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
                .tracking(0.5)
            
            if viewModel.hasData && (viewModel.statistics?.totalRecords ?? 0) >= 3 {
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
                Text(formattedWeeklyAverage)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(weeklyChangeColor)
            }
            
            HStack {
                Text("Total de registros")
                    .font(.system(size: 14))
                Spacer()
                Text("\(viewModel.statistics?.totalRecords ?? 0)")
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
    
    private var formattedWeeklyAverage: String {
        guard let weeklyAverage = viewModel.statistics?.weeklyAverage else { return "Sin datos" }
        let sign = weeklyAverage >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.2f", weeklyAverage)) kg/semana"
    }
    
    private var weeklyChangeColor: Color {
        guard let weeklyAverage = viewModel.statistics?.weeklyAverage else { return .secondary }
        return weeklyAverage < 0 ? .green : weeklyAverage > 0 ? .red : .secondary
    }
}

#Preview {
    WeightPredictionCard(viewModel: DashboardViewModel())
        .padding()
}