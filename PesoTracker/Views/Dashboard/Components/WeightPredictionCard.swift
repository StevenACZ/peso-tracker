import SwiftUI

struct WeightPredictionCard: View {
    let hasData: Bool
    let weeklyAverage: String
    let estimatedDate: String
    let daysAhead: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("PREDICCIÓN DE PESO")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
                .tracking(0.5)
            
            if hasData {
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
                Text(weeklyAverage)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.green)
            }
            
            HStack {
                Text("Fecha de meta estimada")
                    .font(.system(size: 14))
                Spacer()
                Text(estimatedDate)
                    .font(.system(size: 14, weight: .medium))
            }
            
            if daysAhead > 0 {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.system(size: 12))
                    Text("Adelantaste \(daysAhead) días")
                        .font(.system(size: 12))
                        .foregroundColor(.green)
                }
            }
        }
    }
    
    private var emptyView: some View {
        Text("Agregue peso para ver la predicción.")
            .font(.system(size: 14))
            .foregroundColor(.secondary)
            .italic()
    }
}

#Preview {
    VStack(spacing: 20) {
        WeightPredictionCard(
            hasData: true,
            weeklyAverage: "-0.5 kg",
            estimatedDate: "2024-12-15",
            daysAhead: 31
        )
        
        WeightPredictionCard(
            hasData: false,
            weeklyAverage: "",
            estimatedDate: "",
            daysAhead: 0
        )
    }
    .padding()
}