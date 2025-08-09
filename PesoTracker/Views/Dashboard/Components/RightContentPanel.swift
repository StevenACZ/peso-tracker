import SwiftUI

struct RightContentPanel: View {
    @ObservedObject var viewModel: DashboardViewModel
    let onViewProgress: () -> Void
    let onAddWeight: () -> Void
    let onEditRecord: (Weight) -> Void
    let onDeleteRecord: (WeightRecord) -> Void
    let onPhotoTap: (Int) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            progressHeader
            
            ProgressChartView(
                viewModel: viewModel
            )
            
            WeightRecordsView(
                viewModel: viewModel,
                onEditRecord: onEditRecord,
                onDeleteRecord: onDeleteRecord,
                onPhotoTap: onPhotoTap
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
                if viewModel.canShowProgress {
                    CustomButton(action: onViewProgress) {
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
                }
                
                CustomButton(action: onAddWeight) {
                    Text("Agregar Peso")
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .font(.system(size: 12, weight: .medium))
                }
            }
        }
    }
}

#Preview {
    RightContentPanel(
        viewModel: DashboardViewModel(),
        onViewProgress: {},
        onAddWeight: {},
        onEditRecord: { _ in },
        onDeleteRecord: { _ in },
        onPhotoTap: { _ in }
    )
}