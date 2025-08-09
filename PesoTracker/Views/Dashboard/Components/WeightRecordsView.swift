import SwiftUI

struct WeightRecord {
    let id: Int
    let date: String
    let weight: String
    let notes: String
    let hasPhotos: Bool
}

struct WeightRecordsView: View {
    @ObservedObject var viewModel: DashboardViewModel
    let onEditRecord: (Weight) -> Void
    let onDeleteRecord: (WeightRecord) -> Void
    let onPhotoTap: (Int) -> Void
    
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
            
            // Records or skeleton loading
            if viewModel.isTableLoading {
                skeletonLoadingView
            } else {
                VStack(spacing: 0) {
                    ForEach(viewModel.weights.indices, id: \.self) { index in
                        weightRecordRow(viewModel.weights[index])
                    }
                }
            }
            
            // Pagination controls
            if viewModel.hasWeightData {
                paginationControls
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
                if weight.hasPhoto {
                    Button(action: {
                        onPhotoTap(weight.id)
                    }) {
                        Image(systemName: "photo.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.blue)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .onHover { isHovered in
                        if isHovered {
                            NSCursor.pointingHand.set()
                        } else {
                            NSCursor.arrow.set()
                        }
                    }
                } else if weight.hasPhoto {
                    Image(systemName: "photo.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
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
                    // Pass the full Weight object for better data handling
                    onEditRecord(weight)
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
                        id: weight.id,
                        date: weight.formattedDate,
                        weight: weight.formattedWeight,
                        notes: weight.notes ?? "",
                        hasPhotos: weight.hasPhoto
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
    
    private var paginationControls: some View {
        HStack(spacing: 12) {
            Button(action: {
                Task {
                    await viewModel.loadPreviousTablePage()
                }
            }) {
                Text("← Anterior")
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        (viewModel.canGoPreviousTable && !viewModel.isTableLoading) ? 
                        Color.green.opacity(0.1) : Color.gray.opacity(0.1)
                    )
                    .foregroundColor(
                        (viewModel.canGoPreviousTable && !viewModel.isTableLoading) ? 
                        .green : .gray
                    )
                    .cornerRadius(6)
                    .font(.system(size: 12))
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(!viewModel.canGoPreviousTable || viewModel.isTableLoading)
            
            Spacer()
            
            Text(viewModel.tablePaginationInfo)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
            
            Spacer()
            
            Button(action: {
                Task {
                    await viewModel.loadNextTablePage()
                }
            }) {
                Text("Siguiente →")
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        (viewModel.canGoNextTable && !viewModel.isTableLoading) ? 
                        Color.green.opacity(0.1) : Color.gray.opacity(0.1)
                    )
                    .foregroundColor(
                        (viewModel.canGoNextTable && !viewModel.isTableLoading) ? 
                        .green : .gray
                    )
                    .cornerRadius(6)
                    .font(.system(size: 12))
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(!viewModel.canGoNextTable || viewModel.isTableLoading)
        }
        .padding(.horizontal, 12)
        .padding(.top, 8)
    }
    
    private var skeletonLoadingView: some View {
        VStack(spacing: 0) {
            ForEach(0..<5, id: \.self) { _ in
                skeletonRow
            }
        }
    }
    
    private var skeletonRow: some View {
        HStack {
            // Date skeleton
            SkeletonView(width: 80, height: 12)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Weight skeleton
            SkeletonView(width: 60, height: 12)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Notes skeleton
            SkeletonView(width: 100, height: 12)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Photo skeleton
            SkeletonView(width: 16, height: 12)
                .frame(width: 50, alignment: .center)
            
            // Actions skeleton
            HStack(spacing: 8) {
                SkeletonView(width: 45, height: 20)
                SkeletonView(width: 55, height: 20)
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

// MARK: - Skeleton Loading Component
struct SkeletonView: View {
    let width: CGFloat
    let height: CGFloat
    
    @State private var isAnimating = false
    
    var body: some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.gray.opacity(0.3),
                        Color.gray.opacity(0.1),
                        Color.gray.opacity(0.3)
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(width: width, height: height)
            .mask(
                RoundedRectangle(cornerRadius: 4)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: .clear, location: 0),
                                .init(color: .black, location: 0.3),
                                .init(color: .black, location: 0.7),
                                .init(color: .clear, location: 1)
                            ]),
                            startPoint: isAnimating ? .leading : .trailing,
                            endPoint: isAnimating ? .trailing : .leading
                        )
                    )
            )
            .onAppear {
                withAnimation(
                    Animation.easeInOut(duration: 1.5)
                        .repeatForever(autoreverses: false)
                ) {
                    isAnimating.toggle()
                }
            }
    }
}

#Preview {
    WeightRecordsView(
        viewModel: DashboardViewModel(),
        onEditRecord: { _ in },
        onDeleteRecord: { _ in },
        onPhotoTap: { _ in }
    )
    .padding()
}