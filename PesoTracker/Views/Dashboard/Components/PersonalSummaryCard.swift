import SwiftUI

struct PersonalSummaryCard: View {
    let hasData: Bool
    let initialWeight: String
    let currentWeight: String
    let totalChange: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("RESUMEN PERSONAL")
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
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                weightCard(title: "Peso Inicial", value: initialWeight)
                weightCard(title: "Peso Actual", value: currentWeight)
            }
            
            totalChangeCard
        }
    }
    
    private var emptyView: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                weightCard(title: "Peso Inicial", value: "-")
                weightCard(title: "Peso Actual", value: "-")
            }
            
            HStack {
                Spacer()
                VStack(spacing: 4) {
                    Text("Total Perdido/Ganado")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    Text("-")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            .padding(.vertical, 12)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
        }
    }
    
    private func weightCard(title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
            Text(value)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(value == "-" ? .secondary : .primary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
    
    private var totalChangeCard: some View {
        HStack {
            Spacer()
            VStack(spacing: 4) {
                Text("Total Perdido/Ganado")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                Text(totalChange)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.green)
            }
            Spacer()
        }
        .padding(.vertical, 12)
        .background(Color.green.opacity(0.1))
        .cornerRadius(8)
    }
}

#Preview {
    VStack {
        PersonalSummaryCard(
            hasData: true,
            initialWeight: "82 kg",
            currentWeight: "75 kg",
            totalChange: "-7 kg"
        )
        
        PersonalSummaryCard(
            hasData: false,
            initialWeight: "",
            currentWeight: "",
            totalChange: ""
        )
    }
    .padding()
}