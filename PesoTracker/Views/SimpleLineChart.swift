//
//  SimpleLineChart.swift
//  PesoTracker
//
//  Created by Steven Coaila Zaa on 17/07/25.
//

import SwiftUI

// MARK: - Main Chart View
struct SimpleLineChart: View {
    let weights: [WeightEntry]
    let goal: Goal?
    
    @State private var hoveredPoint: WeightEntry?
    @State private var hoverLocation: CGPoint = .zero
    
    // MARK: - Chart Configuration
    private let chartPadding: CGFloat = 60
    private let axisLabelPadding: CGFloat = 50
    
    var body: some View {
        GeometryReader { geometry in
            let chartWidth = geometry.size.width - (chartPadding * 2)
            let chartHeight = geometry.size.height - (chartPadding * 2)
            
            ZStack {
                // Background with subtle gradient
                backgroundView
                
                if weights.count >= 2 {
                    VStack(spacing: 0) {
                        // Chart header with progress info
                        chartHeaderView
                        
                        // Main chart area
                        ZStack {
                            // Chart background and grid
                            chartBackgroundView(width: chartWidth, height: chartHeight)
                            
                            // Chart content (lines, points, etc.)
                            chartContentView(width: chartWidth, height: chartHeight)
                                .clipped()
                            
                            // Interactive tooltip
                            if let hoveredPoint = hoveredPoint {
                                tooltipView(for: hoveredPoint)
                                    .position(hoverLocation)
                                    .zIndex(10)
                            }
                        }
                        .frame(width: chartWidth, height: chartHeight)
                        .padding(.leading, axisLabelPadding)
                        .padding(.trailing, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 10)
                        
                        // X-axis with date labels (more space)
                        xAxisView(width: chartWidth)
                            .padding(.leading, axisLabelPadding)
                            .padding(.trailing, 20)
                            .padding(.bottom, 10)
                        
                        // Legend with progress info
                        legendView
                            .padding(.top, 8)
                            .padding(.bottom, 16)
                    }
                } else {
                    emptyStateView
                }
            }
        }
    }
}

// MARK: - Chart Components
extension SimpleLineChart {
    
    // MARK: Background & Layout
    private var backgroundView: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(NSColor.textBackgroundColor),
                        Color(NSColor.controlBackgroundColor).opacity(0.3)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(NSColor.separatorColor).opacity(0.3), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    private var chartHeaderView: some View {
        VStack(spacing: 8) {
            // Progress title with emoji
            HStack {
                Text("📊")
                    .font(.title2)
                Text(progressTitle)
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .padding(.top, 20)
            
            // Progress subtitle
            Text(progressSubtitle)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 64))
                .foregroundColor(.blue.opacity(0.6))
            
            Text("Start Your Weight Journey")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Add at least 2 weight entries to see your progress chart")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
    }
    
    // MARK: Chart Background & Grid
    private func chartBackgroundView(width: CGFloat, height: CGFloat) -> some View {
        ZStack {
            // Chart area background
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(NSColor.textBackgroundColor).opacity(0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(NSColor.separatorColor).opacity(0.2), lineWidth: 1)
                )
            
            // Y-axis labels and horizontal grid lines
            yAxisView(width: width, height: height)
            
            // Vertical grid lines
            verticalGridLines(width: width, height: height)
        }
    }
    
    private func yAxisView(width: CGFloat, height: CGFloat) -> some View {
        let chartData = ChartDataCalculator.calculateChartData(weights: weights, goal: goal)
        
        return ZStack {
            ForEach(0..<8) { i in // More grid lines for better precision
                let weight = chartData.minY + (chartData.rangeY * Double(7 - i) / 7)
                let y = height * CGFloat(i) / 7
                
                HStack(spacing: 0) {
                    // Y-axis label with better formatting
                    Text("\(String(format: weight.truncatingRemainder(dividingBy: 1) == 0 ? "%.0f" : "%.1f", weight)) kg")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(i == 0 || i == 7 ? .primary : .secondary)
                        .frame(width: axisLabelPadding - 8, alignment: .trailing)
                    
                    // Horizontal grid line with better styling
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: width, y: y))
                    }
                    .stroke(
                        Color.gray.opacity(i == 0 || i == 7 ? 0.4 : 0.15),
                        style: StrokeStyle(
                            lineWidth: i == 0 || i == 7 ? 1.5 : 0.5,
                            dash: i == 0 || i == 7 ? [] : [3, 3]
                        )
                    )
                    
                    Spacer()
                }
            }
        }
    }
    
    private func verticalGridLines(width: CGFloat, height: CGFloat) -> some View {
        ZStack {
            ForEach(Array(weights.enumerated()), id: \.element.id) { index, _ in
                let x = width * CGFloat(index) / CGFloat(weights.count - 1)
                
                Path { path in
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: height))
                }
                .stroke(
                    Color.gray.opacity(index == 0 || index == weights.count - 1 ? 0.3 : 0.1),
                    style: StrokeStyle(
                        lineWidth: index == 0 || index == weights.count - 1 ? 1 : 0.5,
                        dash: [3, 3]
                    )
                )
            }
        }
    }
    
    // MARK: Chart Content
    private func chartContentView(width: CGFloat, height: CGFloat) -> some View {
        ZStack {
            // Reference lines (goal and starting weight)
            referenceLines(width: width, height: height)
            
            // Main weight line with area fill
            weightLineWithArea(width: width, height: height)
            
            // Data points with hover interaction
            dataPointsView(width: width, height: height)
        }
    }
    
    private func referenceLines(width: CGFloat, height: CGFloat) -> some View {
        let chartData = ChartDataCalculator.calculateChartData(weights: weights, goal: goal)
        
        return ZStack {
            // Goal line (green dashed)
            if let goal = goal {
                let goalY = height * (1 - (goal.targetWeight - chartData.minY) / chartData.rangeY)
                
                ZStack {
                    // Goal line
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: goalY))
                        path.addLine(to: CGPoint(x: width, y: goalY))
                    }
                    .stroke(Color.green, style: StrokeStyle(lineWidth: 2, dash: [8, 4]))
                    
                    // Goal indicator circle
                    Circle()
                        .fill(Color.green)
                        .frame(width: 12, height: 12)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                        )
                        .position(x: width - 20, y: goalY)
                }
            }
            
            // Starting weight line (red dashed)
            if let startingWeight = weights.first?.weightValue {
                let startY = height * (1 - (startingWeight - chartData.minY) / chartData.rangeY)
                
                ZStack {
                    // Starting weight line
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: startY))
                        path.addLine(to: CGPoint(x: width, y: startY))
                    }
                    .stroke(Color.red.opacity(0.7), style: StrokeStyle(lineWidth: 2, dash: [8, 4]))
                    
                    // Starting weight indicator circle
                    Circle()
                        .fill(Color.red.opacity(0.7))
                        .frame(width: 12, height: 12)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                        )
                        .position(x: width - 40, y: startY)
                }
            }
        }
    }
    
    private func weightLineWithArea(width: CGFloat, height: CGFloat) -> some View {
        let chartData = ChartDataCalculator.calculateChartData(weights: weights, goal: goal)
        
        return ZStack {
            // Area under the curve
            WeightAreaPath(weights: weights, chartData: chartData, width: width, height: height)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.blue.opacity(0.4),
                            Color.blue.opacity(0.1),
                            Color.blue.opacity(0.05)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            
            // Main weight line
            WeightLinePath(weights: weights, chartData: chartData, width: width, height: height)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
                )
        }
    }
    
    private func dataPointsView(width: CGFloat, height: CGFloat) -> some View {
        let chartData = ChartDataCalculator.calculateChartData(weights: weights, goal: goal)
        
        return ZStack {
            ForEach(Array(weights.enumerated()), id: \.element.id) { index, weight in
                let x = width * CGFloat(index) / CGFloat(weights.count - 1)
                let normalizedWeight = (weight.weightValue - chartData.minY) / chartData.rangeY
                let y = height * (1 - normalizedWeight)
                
                DataPointView(
                    weight: weight,
                    isHovered: hoveredPoint?.id == weight.id,
                    position: CGPoint(x: x, y: y)
                ) { isHovering in
                    handlePointHover(weight: weight, isHovering: isHovering, position: CGPoint(x: x, y: y))
                }
            }
        }
    }
    
    // MARK: X-Axis
    private func xAxisView(width: CGFloat) -> some View {
        VStack(spacing: 8) {
            // X-axis line
            HStack {
                Path { path in
                    path.move(to: CGPoint(x: 0, y: 0))
                    path.addLine(to: CGPoint(x: width, y: 0))
                }
                .stroke(Color.gray.opacity(0.4), lineWidth: 1.5)
                .frame(height: 1)
            }
            
            // Date labels in a clean horizontal layout
            HStack {
                ForEach(Array(weights.enumerated()), id: \.element.id) { index, weight in
                    VStack(spacing: 2) {
                        // Tick mark
                        Rectangle()
                            .fill(Color.gray.opacity(0.6))
                            .frame(width: 1, height: 4)
                        
                        // Date label
                        Text(DateFormatter.chartAxisDate(from: weight.date))
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .opacity(shouldShowLabel(index: index) ? 1.0 : 0.0) // Hide some labels if too crowded
                }
            }
        }
        .frame(width: width, height: 30)
    }
    
    // Helper function to determine which labels to show based on available space
    private func shouldShowLabel(index: Int) -> Bool {
        let totalPoints = weights.count
        
        // Always show first and last
        if index == 0 || index == totalPoints - 1 {
            return true
        }
        
        // For 3-5 points, show all
        if totalPoints <= 5 {
            return true
        }
        
        // For 6-10 points, show every other
        if totalPoints <= 10 {
            return index % 2 == 0
        }
        
        // For more points, show every third
        return index % 3 == 0
    }
    
    // MARK: Legend
    private var legendView: some View {
        HStack(spacing: 24) {
            // Current weight indicator
            LegendItem(color: .blue, label: "Tu Peso", isCircle: true)
            
            // Goal indicator (if exists)
            if goal != nil {
                LegendItem(color: .green, label: "Meta (\(String(format: "%.0f", goal?.targetWeight ?? 0)) kg)", isDashed: true)
            }
            
            // Starting weight indicator
            LegendItem(color: .red.opacity(0.7), label: "Peso Inicial", isDashed: true)
            
            Spacer()
            
            // Progress summary
            if weights.count > 1 {
                progressSummaryView
            }
        }
        .padding(.horizontal, 24)
    }
    
    private var progressSummaryView: some View {
        let totalChange = (weights.last?.weightValue ?? 0) - (weights.first?.weightValue ?? 0)
        let changeText = totalChange >= 0 ? "+\(String(format: "%.1f", totalChange))" : "\(String(format: "%.1f", totalChange))"
        let changeColor: Color = totalChange < 0 ? .green : (totalChange > 0 ? .red : .secondary)
        
        return HStack(spacing: 6) {
            Image(systemName: totalChange < 0 ? "arrow.down.circle.fill" : (totalChange > 0 ? "arrow.up.circle.fill" : "minus.circle.fill"))
                .foregroundColor(changeColor)
                .font(.caption)
            
            Text("Cambio Total: \(changeText) kg")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(changeColor)
        }
    }
}

// MARK: - Helper Views
extension SimpleLineChart {
    
    private func tooltipView(for weight: WeightEntry) -> some View {
        let change = calculateWeightChange(for: weight)
        
        return VStack(alignment: .leading, spacing: 6) {
            // Date and weight in one line
            HStack {
                Text(DateFormatter.tooltipDate(from: weight.date))
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(String(format: "%.1f", weight.weightValue)) kg")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            }
            
            // Weight change (if exists)
            if let change = change {
                Text("\(change.text)")
                    .font(.caption)
                    .foregroundColor(change.color)
                    .fontWeight(.medium)
            }
            
            // Goal progress (if exists)
            if let goal = goal {
                let remaining = goal.targetWeight - weight.weightValue
                let progressText = remaining > 0 ? "Faltan \(String(format: "%.1f", remaining)) kg" : "¡Meta alcanzada!"
                
                Text(progressText)
                    .font(.caption)
                    .foregroundColor(remaining > 0 ? .orange : .green)
            }
            
            // Notes (if any)
            if let notes = weight.notes, !notes.isEmpty {
                Text(notes)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .padding(.top, 2)
            }
        }
        .padding(10)
        .frame(maxWidth: 180) // Fixed width to prevent it from being too wide
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(NSColor.controlBackgroundColor))
                .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 3)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(NSColor.separatorColor).opacity(0.4), lineWidth: 1)
        )
    }
}

// MARK: - Helper Methods
extension SimpleLineChart {
    
    private var progressTitle: String {
        guard let goal = goal,
              let currentWeight = weights.last?.weightValue else {
            return "Progreso de Peso"
        }
        
        let remaining = goal.targetWeight - currentWeight
        if abs(remaining) < 0.5 {
            return "¡Meta Alcanzada! 🎉"
        } else {
            return "Progreso hacia \(String(format: "%.0f", goal.targetWeight)) kg - Faltan \(String(format: "%.1f", abs(remaining))) kg"
        }
    }
    
    private var progressSubtitle: String {
        guard weights.count > 1,
              let startWeight = weights.first?.weightValue,
              let currentWeight = weights.last?.weightValue else {
            return "Agrega más entradas para ver tu progreso"
        }
        
        let totalChange = currentWeight - startWeight
        let changeText = totalChange >= 0 ? "+\(String(format: "%.1f", totalChange))" : "\(String(format: "%.1f", totalChange))"
        
        return "Cambio total: \(changeText) kg desde el inicio"
    }
    
    private func handlePointHover(weight: WeightEntry, isHovering: Bool, position: CGPoint) {
        if isHovering {
            // Only update if this is a different point or no point is currently hovered
            if hoveredPoint?.id != weight.id {
                withAnimation(.easeInOut(duration: 0.15)) {
                    hoveredPoint = weight
                    
                    // Adjust tooltip position to avoid edges and center on the hovered point
                    let tooltipWidth: CGFloat = 180
                    let tooltipHeight: CGFloat = 100
                    
                    // Calculate position relative to the chart area
                    let adjustedX = min(max(position.x, tooltipWidth/2 + 20), 700 - tooltipWidth/2)
                    let adjustedY = max(position.y - tooltipHeight - 15, 40)
                    
                    hoverLocation = CGPoint(x: adjustedX, y: adjustedY)
                }
            }
        } else {
            // Only clear if this specific point was being hovered
            if hoveredPoint?.id == weight.id {
                withAnimation(.easeInOut(duration: 0.15)) {
                    hoveredPoint = nil
                }
            }
        }
    }
    
    private func calculateWeightChange(for weight: WeightEntry) -> (text: String, color: Color)? {
        guard let index = weights.firstIndex(where: { $0.id == weight.id }),
              index > 0 else { return nil }
        
        let previousWeight = weights[index - 1].weightValue
        let change = weight.weightValue - previousWeight
        
        let changeText = change >= 0 ? "+\(String(format: "%.1f", change))" : "\(String(format: "%.1f", change))"
        let changeColor: Color = change < 0 ? .green : (change > 0 ? .red : .secondary)
        
        return (changeText, changeColor)
    }
}

// MARK: - Supporting Views
struct LegendItem: View {
    let color: Color
    let label: String
    let isCircle: Bool
    let isDashed: Bool
    
    init(color: Color, label: String, isCircle: Bool = false, isDashed: Bool = false) {
        self.color = color
        self.label = label
        self.isCircle = isCircle
        self.isDashed = isDashed
    }
    
    var body: some View {
        HStack(spacing: 6) {
            if isCircle {
                Circle()
                    .fill(color)
                    .frame(width: 8, height: 8)
            } else {
                Rectangle()
                    .fill(color)
                    .frame(width: 16, height: 2)
                    .overlay(
                        Rectangle()
                            .stroke(color, style: StrokeStyle(lineWidth: 2, dash: isDashed ? [4, 2] : []))
                    )
            }
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct DataPointView: View {
    let weight: WeightEntry
    let isHovered: Bool
    let position: CGPoint
    let onHover: (Bool) -> Void
    
    var body: some View {
        ZStack {
            // Invisible larger hit area for better hover detection
            Circle()
                .fill(Color.clear)
                .frame(width: 24, height: 24)
                .position(position)
                .onHover(perform: onHover)
            
            // Visible circle
            Circle()
                .fill(Color.blue)
                .frame(width: isHovered ? 14 : 10, height: isHovered ? 14 : 10)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 2)
                )
                .scaleEffect(isHovered ? 1.3 : 1.0)
                .animation(.easeInOut(duration: 0.2), value: isHovered)
                .position(position)
        }
    }
}

// MARK: - Chart Calculation Helper
struct ChartDataCalculator {
    static func calculateChartData(weights: [WeightEntry], goal: Goal?) -> ChartData {
        let weightValues = weights.map { $0.weightValue }
        let minWeight = weightValues.min() ?? 0
        let maxWeight = weightValues.max() ?? 100
        
        // Include goal in range calculation if it exists
        var allValues = weightValues
        if let goalWeight = goal?.targetWeight {
            allValues.append(goalWeight)
        }
        
        let overallMin = allValues.min() ?? minWeight
        let overallMax = allValues.max() ?? maxWeight
        let range = overallMax - overallMin
        
        // Add 15% padding to make the chart look better
        let padding = max(range * 0.15, 2.0) // Minimum 2kg padding
        let adjustedMin = max(0, overallMin - padding)
        let adjustedMax = overallMax + padding
        let adjustedRange = adjustedMax - adjustedMin
        
        return ChartData(
            minY: adjustedMin,
            maxY: adjustedMax,
            rangeY: adjustedRange
        )
    }
}

struct ChartData {
    let minY: Double
    let maxY: Double
    let rangeY: Double
}

// MARK: - Path Shapes
struct WeightLinePath: Shape {
    let weights: [WeightEntry]
    let chartData: ChartData
    let width: CGFloat
    let height: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        for (index, weight) in weights.enumerated() {
            let x = width * CGFloat(index) / CGFloat(weights.count - 1)
            let normalizedWeight = (weight.weightValue - chartData.minY) / chartData.rangeY
            let y = height * (1 - normalizedWeight)
            
            if index == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        
        return path
    }
}

struct WeightAreaPath: Shape {
    let weights: [WeightEntry]
    let chartData: ChartData
    let width: CGFloat
    let height: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Start from bottom-left
        if let firstWeight = weights.first {
            let x = 0.0
            let normalizedWeight = (firstWeight.weightValue - chartData.minY) / chartData.rangeY
            let y = height * (1 - normalizedWeight)
            
            path.move(to: CGPoint(x: x, y: height))
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        // Follow the weight line
        for (index, weight) in weights.enumerated() {
            let x = width * CGFloat(index) / CGFloat(weights.count - 1)
            let normalizedWeight = (weight.weightValue - chartData.minY) / chartData.rangeY
            let y = height * (1 - normalizedWeight)
            
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        // Close the path at the bottom
        if weights.last != nil {
            let x = width
            path.addLine(to: CGPoint(x: x, y: height))
        }
        
        path.closeSubpath()
        return path
    }
}

// MARK: - Date Formatting Extension
extension DateFormatter {
    static func chartAxisDate(from dateString: String) -> String {
        let formatter = DateFormatter()
        let formats = [
            "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'",
            "yyyy-MM-dd'T'HH:mm:ss'Z'",
            "yyyy-MM-dd"
        ]
        
        for format in formats {
            formatter.dateFormat = format
            if let date = formatter.date(from: dateString) {
                let displayFormatter = DateFormatter()
                displayFormatter.locale = Locale(identifier: "es_ES") // Spanish locale
                displayFormatter.dateFormat = "dd MMM"
                return displayFormatter.string(from: date)
            }
        }
        
        return dateString
    }
    
    static func tooltipDate(from dateString: String) -> String {
        let formatter = DateFormatter()
        let formats = [
            "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'",
            "yyyy-MM-dd'T'HH:mm:ss'Z'",
            "yyyy-MM-dd"
        ]
        
        for format in formats {
            formatter.dateFormat = format
            if let date = formatter.date(from: dateString) {
                let displayFormatter = DateFormatter()
                displayFormatter.locale = Locale(identifier: "es_ES") // Spanish locale
                displayFormatter.dateFormat = "dd 'de' MMM yyyy"
                return displayFormatter.string(from: date)
            }
        }
        
        return dateString
    }
}