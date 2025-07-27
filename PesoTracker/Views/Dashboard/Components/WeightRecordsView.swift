import SwiftUI

struct WeightRecord {
    let date: String
    let weight: String
    let notes: String
    let hasPhoto: Bool
}

struct WeightRecordsView: View {
    let hasData: Bool
    let records: [WeightRecord]
    let onEditRecord: (WeightRecord) -> Void
    let onDeleteRecord: (WeightRecord) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Registros de Peso")
                .font(.system(size: 16, weight: .medium))
            
            if hasData && !records.isEmpty {
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
            ForEach(records.indices, id: \.self) { index in
                weightRecordRow(records[index])
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
    
    private func weightRecordRow(_ record: WeightRecord) -> some View {
        HStack {
            Text(record.date)
                .font(.system(size: 12))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(record.weight)
                .font(.system(size: 12, weight: .medium))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(record.notes)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Photo indicator
            Group {
                if record.hasPhoto {
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
                Button(action: { onEditRecord(record) }) {
                    Text("Editar")
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.green.opacity(0.1))
                        .foregroundColor(.green)
                        .cornerRadius(4)
                        .font(.system(size: 10))
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: { onDeleteRecord(record) }) {
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
    let sampleRecords = [
        WeightRecord(date: "2024-01-15", weight: "82 kg", notes: "Punto de partida", hasPhoto: false),
        WeightRecord(date: "2024-02-15", weight: "80 kg", notes: "Actualización primer mes", hasPhoto: true),
        WeightRecord(date: "2024-03-15", weight: "78 kg", notes: "Actualización segundo mes", hasPhoto: false)
    ]
    
    VStack(spacing: 20) {
        WeightRecordsView(
            hasData: true,
            records: sampleRecords,
            onEditRecord: { _ in },
            onDeleteRecord: { _ in }
        )
        
        WeightRecordsView(
            hasData: false,
            records: [],
            onEditRecord: { _ in },
            onDeleteRecord: { _ in }
        )
    }
    .padding()
}