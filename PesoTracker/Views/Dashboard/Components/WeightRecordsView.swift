import SwiftUI

struct WeightRecord {
    let date: String
    let weight: String
    let notes: String
    let hasPhotos: Bool
}

struct WeightRecordsView: View {
    @ObservedObject var viewModel: DashboardViewModel
    let onEditRecord: (WeightRecord) -> Void
    let onDeleteRecord: (WeightRecord) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Registros de Peso")
                .font(.system(size: 16, weight: .medium))
            
            if viewModel.hasWeightData {
                dataView
            } else {
                emptyView
            }
        }
    }
    
    private var dataView: some View {
        VStack(spacing: 0) {
            // Table header
            tableHeader
            
            // Records
            ForEach(viewModel.recentWeights.indices, id: \.self) { index in
                weightRecordRow(viewModel.recentWeights[index])
            }
        }
    }
    
    private var tableHeader: some View {
        HStack {
            Text("FECHA")
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text("PESO")
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text("NOTAS")
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text("FOTO")
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.secondary)
                .frame(width: 50, alignment: .center)
            
            Spacer()
                .frame(width: 120) // Space for actions
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.gray.opacity(0.05))
    }
    
    private func weightRecordRow(_ weight: Weight) -> some View {
        HStack {
            Text(weight.formattedDate)
                .font(.system(size: 12))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(weight.formattedWeight)
                .font(.system(size: 12, weight: .medium))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(weight.notes ?? "Sin notas")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Photo indicator
            Group {
                if weight.hasPhotos {
                    Image(systemName: "photo.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.blue)
                } else {
                    Text("-")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: 50, alignment: .center)
            
            // Actions
            HStack(spacing: 8) {
                Button(action: { 
                    // Convert Weight to WeightRecord for compatibility
                    let record = WeightRecord(
                        date: weight.formattedDate,
                        weight: weight.formattedWeight,
                        notes: weight.notes ?? "",
                        hasPhotos: weight.hasPhotos
                    )
                    onEditRecord(record)
                }) {
                    Text("Editar")
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.green.opacity(0.1))
                        .foregroundColor(.green)
                        .cornerRadius(4)
                        .font(.system(size: 10))
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: { 
                    // Convert Weight to WeightRecord for compatibility
                    let record = WeightRecord(
                        date: weight.formattedDate,
                        weight: weight.formattedWeight,
                        notes: weight.notes ?? "",
                        hasPhotos: weight.hasPhotos
                    )
                    onDeleteRecord(record)
                }) {
                    Text("Eliminar")
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.red.opacity(0.1))
                        .foregroundColor(.red)
                        .cornerRadius(4)
                        .font(.system(size: 10))
                }
                .buttonStyle(PlainButtonStyle())
            }
            .frame(width: 120, alignment: .trailing)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.clear)
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(Color(NSColor.separatorColor)),
            alignment: .bottom
        )
    }
    
    private var emptyView: some View {
        HStack {
            Spacer()
            VStack(spacing: 12) {
                Image(systemName: "photo")
                    .font(.system(size: 48))
                    .foregroundColor(.secondary.opacity(0.6))
                
                VStack(spacing: 4) {
                    Text("No hay registros de peso")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Text("Aquí aparecerá su historial de peso una vez que agregue datos.")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.vertical, 60)
            Spacer()
        }
    }
}

#Preview {
    WeightRecordsView(
        viewModel: DashboardViewModel(),
        onEditRecord: { _ in },
        onDeleteRecord: { _ in }
    )
    .padding()
}