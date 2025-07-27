import SwiftUI

struct RightContentPanel: View {
    let hasData: Bool
    let records: [WeightRecord]
    @Binding var selectedTimeRange: String
    let onViewProgress: () -> Void
    let onAddWeight: () -> Void
    let onEditRecord: (WeightRecord) -> Void
    let onDeleteRecord: (WeightRecord) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            progressHeader
            
            ProgressChartView(
                hasData: hasData,
                currentWeight: hasData ? "75 kg" : "-",
                weightChange: hasData ? "7 kg" : "",
                timeRange: "6 meses",
                selectedTimeRange: $selectedTimeRange
            )
            
            WeightRecordsView(
                hasData: hasData,
                records: records,
                onEditRecord: onEditRecord,
                onDeleteRecord: onDeleteRecord
            )
            
            Spacer()
        }
        .padding(30)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
    
    private var progressHeader: some View {
        HStack {
            Text("Progreso de Peso")
                .font(.system(size: 24, weight: .bold))
            
            Spacer()
            
            HStack(spacing: 12) {
                // Solo mostrar "Ver Progreso" si hay datos
                if hasData {
                    Button(action: onViewProgress) {
                        HStack(spacing: 4) {
                            Text("Ver Progreso")
                            Image(systemName: "chart.bar.fill")
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.gray.opacity(0.15))
                        .cornerRadius(8)
                        .font(.system(size: 12))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                Button(action: onAddWeight) {
                    Text("Agregar Peso")
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .font(.system(size: 12, weight: .medium))
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}

#Preview {
    let sampleRecords = [
        WeightRecord(date: "2024-01-15", weight: "82 kg", notes: "Punto de partida", hasPhoto: false),
        WeightRecord(date: "2024-02-15", weight: "80 kg", notes: "Actualización primer mes", hasPhoto: true)
    ]
    
    RightContentPanel(
        hasData: true,
        records: sampleRecords,
        selectedTimeRange: .constant("1 semana"),
        onViewProgress: {},
        onAddWeight: {},
        onEditRecord: { _ in },
        onDeleteRecord: { _ in }
    )
}