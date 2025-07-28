import SwiftUI

struct ProgressChartView: View {
    @ObservedObject var viewModel: DashboardViewModel
    
    private let timeRanges = ["1 semana", "1 mes", "3 meses", "6 meses", "1 año"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header
            currentWeightDisplay
            
            if viewModel.canShowChart {
                chartWithData
            } else {
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
                        viewModel.updateTimeRange(range)
                    }) {
                        Text(range)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(viewModel.selectedTimeRange == range ? Color.gray.opacity(0.3) : Color.clear)
                            .font(.system(size: 12))
                            .foregroundColor(viewModel.selectedTimeRange == range ? .primary : .secondary)
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
                    Text(viewModel.selectedTimeRange)
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
                if !chartWeights.isEmpty {
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
    
    private var chartWeights: [Weight] {
        return viewModel.getWeightsForChart()
    }
    
    private func chartPath(in size: CGSize, filled: Bool = false) -> Path {
        Path { path in
            guard !chartWeights.isEmpty else { return }
            
            let weights = chartWeights.reversed() // Oldest to newest
            let minWeight = weights.map(\.weight).min() ?? 0
            let maxWeight = weights.map(\.weight).max() ?? 100
            let weightRange = maxWeight - minWeight
            
            // Add some padding to the range
            let paddedMin = minWeight - (weightRange * 0.1)
            let paddedMax = maxWeight + (weightRange * 0.1)
            let paddedRange = paddedMax - paddedMin
            
            let chartWidth = size.width - 40 // Padding
            let chartHeight = size.height - 40 // Padding
            
            var points: [CGPoint] = []
            
            for (index, weight) in weights.enumerated() {
                let x = 20 + (CGFloat(index) / CGFloat(weights.count - 1)) * chartWidth
                let normalizedWeight = (weight.weight - paddedMin) / paddedRange
                let y = 20 + (1 - normalizedWeight) * chartHeight
                
                points.append(CGPoint(x: x, y: y))
            }
            
            guard !points.isEmpty else { return }
            
            path.move(to: points[0])
            for point in points.dropFirst() {
                path.addLine(to: point)
            }
            
            if filled {
                // Close the path for filling
                path.addLine(to: CGPoint(x: points.last!.x, y: size.height - 20))
                path.addLine(to: CGPoint(x: points.first!.x, y: size.height - 20))
                path.closeSubpath()
            }
        }
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