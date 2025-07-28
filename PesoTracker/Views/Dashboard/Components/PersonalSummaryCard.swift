import SwiftUI

struct PersonalSummaryCard: View {
    @ObservedObject var viewModel: DashboardViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("RESUMEN PERSONAL")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
                .tracking(0.5)
            
            if viewModel.hasData {
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
                weightCard(title: "Peso Actual", value: viewModel.formattedCurrentWeight)
            }
            
            totalChangeCard
        }
    }
    
    private var initialWeight: String {
        guard let initial = viewModel.initialWeight else { return "-" }
        return String(format: "%.2f kg", initial)
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
                Text(viewModel.formattedWeightChange)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(weightChangeColor)
            }
            Spacer()
        }
        .padding(.vertical, 12)
        .background(weightChangeColor.opacity(0.1))
        .cornerRadius(8)
    }
    
    private var weightChangeColor: Color {
        guard let change = viewModel.weightChange else { return .secondary }
        return change < 0 ? .green : change > 0 ? .red : .secondary
    }
}

#Preview {
    PersonalSummaryCard(viewModel: DashboardViewModel())
        .padding()
}