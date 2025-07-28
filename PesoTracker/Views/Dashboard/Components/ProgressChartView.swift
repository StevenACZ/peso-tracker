import SwiftUI

struct ProgressChartView: View {
    @ObservedObject var viewModel: DashboardViewModel
    
    private let timeRangeMapping: [String: String] = [
        "1 mes": "1month", 
        "3 meses": "3months",
        "6 meses": "6months",
        "1 año": "1year",
        "Todos": "all"
    ]
    
    private let timeRanges = ["Todos", "1 mes", "3 meses", "6 meses", "1 año"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header
            currentWeightDisplay
            
            if hasPaginationData {
                // Show chart (with or without data) and pagination controls
                if viewModel.canShowChart {
                    chartWithData
                } else {
                    emptyChartWithPagination
                }
                chartPaginationControls
            } else {
                // No pagination data at all - show no data message
                emptyChart
            }
        }
    }
    
    private var header: some View {
        HStack {
            Text("Peso a lo largo del tiempo")
                .font(.system(size: 16, weight: .medium))
            
            Spacer()
            
            // Time range picker
            HStack(spacing: 2) {
                ForEach(timeRanges, id: \.self) { range in
                    Button(action: {
                        Task {
                            await viewModel.updateTimeRange(timeRangeMapping[range] ?? "1month")
                        }
                    }) {
                        Text(range)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(timeRangeMapping[range] == viewModel.selectedTimeRange ? Color.gray.opacity(0.3) : Color.clear)
                            .font(.system(size: 12))
                            .foregroundColor(timeRangeMapping[range] == viewModel.selectedTimeRange ? .primary : .secondary)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
        }
    }
    
    private var currentWeightDisplay: some View {
        HStack {
            Text(viewModel.formattedCurrentWeight)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(viewModel.hasWeightData ? .primary : .secondary)
            
            if viewModel.hasWeightData, let change = viewModel.weightChange {
                HStack(spacing: 4) {
                    Text("Total")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    
                    Image(systemName: change < 0 ? "arrow.down" : change > 0 ? "arrow.up" : "minus")
                        .font(.system(size: 10))
                        .foregroundColor(change < 0 ? .green : change > 0 ? .red : .secondary)
                    
                    Text(viewModel.formattedWeightChange)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(change < 0 ? .green : change > 0 ? .red : .secondary)
                }
            }
            
            Spacer()
        }
    }
    
    private var chartWithData: some View {
        GeometryReader { geometry in
            ZStack {
                Rectangle()
                    .fill(Color.gray.opacity(0.05))
                    .frame(height: 200)
                    .cornerRadius(8)
                
                // Chart based on real data
                if !viewModel.chartPoints.isEmpty {
                    chartPath(in: geometry.size)
                        .stroke(.green, lineWidth: 2)
                        .background(
                            chartPath(in: geometry.size, filled: true)
                                .fill(LinearGradient(colors: [.green.opacity(0.3), .green.opacity(0.1)], startPoint: .top, endPoint: .bottom))
                        )
                }
            }
        }
        .frame(height: 200)
    }
    
    private var chartPaginationControls: some View {
        HStack {
            Button(action: {
                Task {
                    await viewModel.loadPreviousChartPage()
                }
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 12))
                    Text("Anterior")
                        .font(.system(size: 12))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(viewModel.canGoPreviousChart ? Color.gray.opacity(0.1) : Color.gray.opacity(0.05))
                .cornerRadius(6)
                .foregroundColor(viewModel.canGoPreviousChart ? .primary : .secondary)
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(!viewModel.canGoPreviousChart)
            
            Spacer()
            
            Text(viewModel.chartPaginationInfo)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
            
            Spacer()
            
            Button(action: {
                Task {
                    await viewModel.loadNextChartPage()
                }
            }) {
                HStack(spacing: 4) {
                    Text("Siguiente")
                        .font(.system(size: 12))
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(viewModel.canGoNextChart ? Color.gray.opacity(0.1) : Color.gray.opacity(0.05))
                .cornerRadius(6)
                .foregroundColor(viewModel.canGoNextChart ? .primary : .secondary)
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(!viewModel.canGoNextChart)
        }
    }
    
    private func chartPath(in size: CGSize, filled: Bool = false) -> Path {
        Path { path in
            guard !viewModel.chartPoints.isEmpty else { return }
            
            let points = viewModel.chartPoints.sorted { $0.date < $1.date } // Oldest to newest
            let minWeight = points.map(\.weight).min() ?? 0
            let maxWeight = points.map(\.weight).max() ?? 100
            let weightRange = maxWeight - minWeight
            
            // Add some padding to the range
            let paddedMin = minWeight - (weightRange * 0.1)
            let paddedMax = maxWeight + (weightRange * 0.1)
            let paddedRange = paddedMax - paddedMin
            
            let chartWidth = size.width - 40 // Padding
            let chartHeight = size.height - 40 // Padding
            
            var chartPoints: [CGPoint] = []
            
            for (index, point) in points.enumerated() {
                let x = 20 + (CGFloat(index) / CGFloat(points.count - 1)) * chartWidth
                let normalizedWeight = (point.weight - paddedMin) / paddedRange
                let y = 20 + (1 - normalizedWeight) * chartHeight
                
                chartPoints.append(CGPoint(x: x, y: y))
            }
            
            guard !chartPoints.isEmpty else { return }
            
            path.move(to: chartPoints[0])
            for point in chartPoints.dropFirst() {
                path.addLine(to: point)
            }
            
            if filled {
                // Close the path for filling
                path.addLine(to: CGPoint(x: chartPoints.last!.x, y: size.height - 20))
                path.addLine(to: CGPoint(x: chartPoints.first!.x, y: size.height - 20))
                path.closeSubpath()
            }
        }
    }
    
    // MARK: - Computed Properties
    private var hasPaginationData: Bool {
        // Check if we have any pagination periods available
        return (viewModel.chartPoints.count > 0) || 
               (viewModel.canGoNextChart || viewModel.canGoPreviousChart) ||
               (!viewModel.chartPaginationInfo.isEmpty && viewModel.chartPaginationInfo != "")
    }
    
    private var emptyChartWithPagination: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.05))
            .frame(height: 200)
            .cornerRadius(8)
            .overlay(
                VStack(spacing: 12) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 32))
                        .foregroundColor(.secondary.opacity(0.4))
                    
                    Text("Sin datos en este período")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .padding()
            )
    }
    
    private var emptyChart: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.05))
            .frame(height: 200)
            .cornerRadius(8)
            .overlay(
                VStack(spacing: 12) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary.opacity(0.6))
                    
                    VStack(spacing: 4) {
                        Text("No hay datos de peso")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        Text("Agregue su primer registro de peso para comenzar a ver su progreso.")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding()
            )
    }
}

#Preview {
    ProgressChartView(viewModel: DashboardViewModel())
        .padding()
}