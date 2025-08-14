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
                weightCard(title: "Peso Actual", value: currentWeight)
            }
            
            totalChangeCard
        }
    }
    
    private var initialWeight: String {
        guard let initial = viewModel.statistics?.initialWeight else { return "-" }
        return String(format: "%.2f kg", initial)
    }
    
    private var currentWeight: String {
        guard let current = viewModel.statistics?.currentWeight else { return "-" }
        return String(format: "%.2f kg", current)
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
                Text(intelligentChangeText)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                Text(intelligentChangeValue)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(intelligentChangeColor)
            }
            Spacer()
        }
        .padding(.vertical, 12)
        .background(intelligentChangeColor.opacity(0.1))
        .cornerRadius(8)
    }
    
    // MARK: - Intelligent Change Display
    private var intelligentChangeText: String {
        guard let change = viewModel.statistics?.totalChange else { return "Total Perdido/Ganado" }
        if change < 0 {
            return "Total Perdido"
        } else if change > 0 {
            return "Total Ganado"
        } else {
            return "Sin Cambio"
        }
    }
    
    private var intelligentChangeValue: String {
        guard let change = viewModel.statistics?.totalChange else { return "-" }
        return String(format: "%.2f kg", abs(change))
    }
    
    private var intelligentChangeColor: Color {
        guard let change = viewModel.statistics?.totalChange else { return .secondary }
        if change < 0 {
            return .green  // Perdido = Verde (bueno)
        } else if change > 0 {
            return .red    // Ganado = Rojo (malo)
        } else {
            return .secondary  // Sin cambio = Gris
        }
    }
}

#Preview {
    PersonalSummaryCard(viewModel: DashboardViewModel())
        .padding()
}