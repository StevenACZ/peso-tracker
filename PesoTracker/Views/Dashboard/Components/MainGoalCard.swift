import SwiftUI

struct MainGoalCard: View {
    @ObservedObject var viewModel: DashboardViewModel
    let onEditGoal: () -> Void
    let onAddGoal: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header
            
            if viewModel.hasActiveGoal {
                dataView
            } else {
                emptyView
            }
        }
    }
    
    private var header: some View {
        HStack {
            Text("META PRINCIPAL")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
                .tracking(0.5)
            
            Spacer()
            
            if viewModel.hasActiveGoal {
                Button(action: onEditGoal) {
                    Image(systemName: "pencil")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    private var dataView: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Actual")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    Text(viewModel.formattedCurrentWeight)
                        .font(.system(size: 20, weight: .semibold))
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Objetivo")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    Text(viewModel.formattedGoalWeight)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.green)
                }
            }
            
            // Progress bar
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Progreso: \(viewModel.formattedProgressPercentage)")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(viewModel.formattedDaysToGoal)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 6)
                            .cornerRadius(3)
                        
                        Rectangle()
                            .fill(.green)
                            .frame(width: geometry.size.width * (viewModel.progressPercentage / 100.0), height: 6)
                            .cornerRadius(3)
                    }
                }
                .frame(height: 6)
            }
        }
    }
    
    private var emptyView: some View {
        VStack(spacing: 16) {
            Text("No has establecido una meta principal.")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: onAddGoal) {
                Text("Agregar Meta Principal")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(.green)
                    .cornerRadius(8)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }
}

#Preview {
    MainGoalCard(
        viewModel: DashboardViewModel(),
        onEditGoal: {},
        onAddGoal: {}
    )
    .padding()
}