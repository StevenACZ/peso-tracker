import SwiftUI

struct ProgressChartView: View {
    let hasData: Bool
    let currentWeight: String
    let weightChange: String
    let timeRange: String
    @Binding var selectedTimeRange: String
    
    private let timeRanges = ["1 semana", "1 mes", "6 meses"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header
            currentWeightDisplay
            
            if hasData {
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
                        selectedTimeRange = range
                    }) {
                        Text(range)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(selectedTimeRange == range ? Color.gray.opacity(0.3) : Color.clear)
                            .font(.system(size: 12))
                            .foregroundColor(selectedTimeRange == range ? .primary : .secondary)
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
            Text(currentWeight)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(currentWeight == "-" ? .secondary : .primary)
            
            if hasData && !weightChange.isEmpty {
                HStack(spacing: 4) {
                    Text("Últimos 6 meses")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    
                    Image(systemName: "arrow.down")
                        .font(.system(size: 10))
                        .foregroundColor(.green)
                    
                    Text(weightChange)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.green)
                }
            }
            
            Spacer()
        }
    }
    
    private var chartWithData: some View {
        ZStack {
            Rectangle()
                .fill(Color.gray.opacity(0.05))
                .frame(height: 200)
                .cornerRadius(8)
            
            // Simple line chart simulation
            Path { path in
                let points: [CGPoint] = [
                    CGPoint(x: 50, y: 150),
                    CGPoint(x: 100, y: 120),
                    CGPoint(x: 150, y: 140),
                    CGPoint(x: 200, y: 110),
                    CGPoint(x: 250, y: 130),
                    CGPoint(x: 300, y: 100),
                    CGPoint(x: 350, y: 80),
                    CGPoint(x: 400, y: 120),
                    CGPoint(x: 450, y: 90)
                ]
                
                path.move(to: points[0])
                for point in points.dropFirst() {
                    path.addLine(to: point)
                }
            }
            .stroke(.green, lineWidth: 2)
            .background(
                Path { path in
                    let points: [CGPoint] = [
                        CGPoint(x: 50, y: 150),
                        CGPoint(x: 100, y: 120),
                        CGPoint(x: 150, y: 140),
                        CGPoint(x: 200, y: 110),
                        CGPoint(x: 250, y: 130),
                        CGPoint(x: 300, y: 100),
                        CGPoint(x: 350, y: 80),
                        CGPoint(x: 400, y: 120),
                        CGPoint(x: 450, y: 90),
                        CGPoint(x: 450, y: 200),
                        CGPoint(x: 50, y: 200)
                    ]
                    
                    path.move(to: points[0])
                    for point in points.dropFirst() {
                        path.addLine(to: point)
                    }
                    path.closeSubpath()
                }
                .fill(LinearGradient(colors: [.green.opacity(0.3), .green.opacity(0.1)], startPoint: .top, endPoint: .bottom))
            )
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
    VStack(spacing: 20) {
        ProgressChartView(
            hasData: true,
            currentWeight: "75 kg",
            weightChange: "7 kg",
            timeRange: "6 meses",
            selectedTimeRange: .constant("1 semana")
        )
        
        ProgressChartView(
            hasData: false,
            currentWeight: "-",
            weightChange: "",
            timeRange: "",
            selectedTimeRange: .constant("1 semana")
        )
    }
    .padding()
}