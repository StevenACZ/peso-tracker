//
//  SimpleLineChart.swift
//  PesoTracker
//
//  Created by Steven Coaila Zaa on 17/07/25.
//

import SwiftUI

struct SimpleLineChart: View {
    let weights: [WeightEntry]
    @State private var hoveredPoint: WeightEntry?
    @State private var hoverLocation: CGPoint = .zero
    
    private let chartPadding: CGFloat = 60
    private let axisLabelPadding: CGFloat = 40
    
    var body: some View {
        GeometryReader { geometry in
            let chartWidth = geometry.size.width - (chartPadding * 2)
            let chartHeight = geometry.size.height - (chartPadding * 2)
            
            ZStack {
                // Background
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(NSColor.textBackgroundColor))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(NSColor.separatorColor), lineWidth: 1)
                    )
                
                if weights.count >= 2 {
                    VStack(spacing: 0) {
                        // Chart title
                        Text("Weight Progress Over Time")
                            .font(.headline)
                            .padding(.top, 16)
                        
                        // Main chart area
                        ZStack {
                            // Y-axis labels and grid
                            yAxisLabelsAndGrid(width: chartWidth, height: chartHeight)
                            
                            // Chart content
                            chartContent(width: chartWidth, height: chartHeight)
                                .clipped()
                            
                            // Hover tooltip
                            if let hoveredPoint = hoveredPoint {
                                tooltipView(for: hoveredPoint)
                                    .position(hoverLocation)
                            }
                        }
                        .frame(width: chartWidth, height: chartHeight)
                        .padding(.leading, axisLabelPadding)
                        .padding(.trailing, 20)
                        .padding(.vertical, 20)
                        
                        // X-axis labels
                        xAxisLabels(width: chartWidth)
                            .padding(.leading, axisLabelPadding)
                            .padding(.trailing, 20)
                        
                        // Legend
                        legendView()
                            .padding(.bottom, 16)
                    }
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        
                        Text("Add more weight entries to see your progress chart")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("You need at least 2 weight entries to display the chart")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
    
    private func chartContent(width: CGFloat, height: CGFloat) -> some View {
        ZStack {
            // Grid lines
            gridLines(width: width, height: height)
            
            // Weight line with gradient
            weightLineWithGradient(width: width, height: height)
            
            // Data points with hover detection
            dataPointsWithHover(width: width, height: height)
        }
    }
    
    private func yAxisLabelsAndGrid(width: CGFloat, height: CGFloat) -> some View {
        let minWeight = weights.map { $0.weightValue }.min() ?? 0
        let maxWeight = weights.map { $0.weightValue }.max() ?? 100
        let weightRange = maxWeight - minWeight
        let padding = weightRange * 0.1 // 10% padding
        let adjustedMin = max(0, minWeight - padding)
        let adjustedMax = maxWeight + padding
        let adjustedRange = adjustedMax - adjustedMin
        
        return ZStack {
            ForEach(0..<6) { i in
                let weight = adjustedMin + (adjustedRange * Double(5 - i) / 5)
                let y = height * CGFloat(i) / 5
                
                HStack {
                    // Y-axis label
                    Text("\(String(format: "%.1f", weight)) kg")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(width: axisLabelPadding - 8, alignment: .trailing)
                    
                    // Grid line
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: width, y: y))
                    }
                    .stroke(Color.gray.opacity(0.2), lineWidth: i == 0 || i == 5 ? 1 : 0.5)
                    
                    Spacer()
                }
            }
        }
    }
    
    private func xAxisLabels(width: CGFloat) -> some View {
        HStack {
            ForEach(Array(weights.enumerated()), id: \.element.id) { index, weight in
                let x = width * CGFloat(index) / CGFloat(weights.count - 1)
                
                Text(formatDateForAxis(weight.date))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(width: 60)
                    .position(x: x, y: 10)
            }
        }
        .frame(width: width, height: 20)
    }
    
    private func gridLines(width: CGFloat, height: CGFloat) -> some View {
        ZStack {
            // Vertical grid lines for dates
            ForEach(Array(weights.enumerated()), id: \.element.id) { index, _ in
                let x = width * CGFloat(index) / CGFloat(weights.count - 1)
                
                Path { path in
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: height))
                }
                .stroke(Color.gray.opacity(0.1), lineWidth: 0.5)
            }
        }
    }
    
    private func weightLineWithGradient(width: CGFloat, height: CGFloat) -> some View {
        let minWeight = weights.map { $0.weightValue }.min() ?? 0
        let maxWeight = weights.map { $0.weightValue }.max() ?? 100
        let weightRange = maxWeight - minWeight
        let padding = weightRange * 0.1
        let adjustedMin = max(0, minWeight - padding)
        let adjustedMax = maxWeight + padding
        let adjustedRange = adjustedMax - adjustedMin
        
        return ZStack {
            // Area under the curve (gradient fill)
            areaPath(width: width, height: height, adjustedMin: adjustedMin, adjustedRange: adjustedRange)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.blue.opacity(0.05)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            
            // Main line
            weightLinePath(width: width, height: height, adjustedMin: adjustedMin, adjustedRange: adjustedRange)
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
    
    private func weightLinePath(width: CGFloat, height: CGFloat, adjustedMin: Double, adjustedRange: Double) -> Path {
        var path = Path()
        
        for (index, weight) in weights.enumerated() {
            let x = width * CGFloat(index) / CGFloat(weights.count - 1)
            let normalizedWeight = adjustedRange > 0 ? (weight.weightValue - adjustedMin) / adjustedRange : 0.5
            let y = height * (1 - normalizedWeight)
            
            if index == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        
        return path
    }
    
    private func areaPath(width: CGFloat, height: CGFloat, adjustedMin: Double, adjustedRange: Double) -> Path {
        var path = Path()
        
        // Start from bottom-left
        if let firstWeight = weights.first {
            let x = 0.0
            let normalizedWeight = adjustedRange > 0 ? (firstWeight.weightValue - adjustedMin) / adjustedRange : 0.5
            let y = height * (1 - normalizedWeight)
            
            path.move(to: CGPoint(x: x, y: height)) // Bottom
            path.addLine(to: CGPoint(x: x, y: y)) // Up to line
        }
        
        // Follow the weight line
        for (index, weight) in weights.enumerated() {
            let x = width * CGFloat(index) / CGFloat(weights.count - 1)
            let normalizedWeight = adjustedRange > 0 ? (weight.weightValue - adjustedMin) / adjustedRange : 0.5
            let y = height * (1 - normalizedWeight)
            
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        // Close the path at the bottom
        if let lastWeight = weights.last {
            let x = width
            path.addLine(to: CGPoint(x: x, y: height))
        }
        
        path.closeSubpath()
        return path
    }
    
    private func dataPointsWithHover(width: CGFloat, height: CGFloat) -> some View {
        let minWeight = weights.map { $0.weightValue }.min() ?? 0
        let maxWeight = weights.map { $0.weightValue }.max() ?? 100
        let weightRange = maxWeight - minWeight
        let padding = weightRange * 0.1
        let adjustedMin = max(0, minWeight - padding)
        let adjustedMax = maxWeight + padding
        let adjustedRange = adjustedMax - adjustedMin
        
        return ZStack {
            ForEach(Array(weights.enumerated()), id: \.element.id) { index, weight in
                let x = width * CGFloat(index) / CGFloat(weights.count - 1)
                let normalizedWeight = adjustedRange > 0 ? (weight.weightValue - adjustedMin) / adjustedRange : 0.5
                let y = height * (1 - normalizedWeight)
                
                Circle()
                    .fill(Color.blue)
                    .frame(width: hoveredPoint?.id == weight.id ? 12 : 8, 
                           height: hoveredPoint?.id == weight.id ? 12 : 8)
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 2)
                    )
                    .position(x: x, y: y)
                    .scaleEffect(hoveredPoint?.id == weight.id ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: hoveredPoint?.id)
                    .onHover { isHovering in
                        if isHovering {
                            hoveredPoint = weight
                            hoverLocation = CGPoint(x: x, y: max(30, y - 20))
                        } else if hoveredPoint?.id == weight.id {
                            hoveredPoint = nil
                        }
                    }
            }
        }
    }
    
    private func tooltipView(for weight: WeightEntry) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(formatDateForTooltip(weight.date))
                .font(.caption)
                .fontWeight(.medium)
            
            Text("\(String(format: "%.1f", weight.weightValue)) kg")
                .font(.headline)
                .foregroundColor(.blue)
            
            if let notes = weight.notes, !notes.isEmpty {
                Text(notes)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(NSColor.controlBackgroundColor))
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(NSColor.separatorColor), lineWidth: 1)
        )
    }
    
    private func legendView() -> some View {
        HStack(spacing: 20) {
            HStack(spacing: 6) {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 8, height: 8)
                Text("Weight Progress")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if weights.count > 1 {
                let totalChange = weights.last!.weightValue - weights.first!.weightValue
                let changeText = totalChange >= 0 ? "+\(String(format: "%.1f", totalChange))" : "\(String(format: "%.1f", totalChange))"
                let changeColor: Color = totalChange < 0 ? .green : (totalChange > 0 ? .red : .secondary)
                
                HStack(spacing: 6) {
                    Image(systemName: totalChange < 0 ? "arrow.down" : (totalChange > 0 ? "arrow.up" : "minus"))
                        .foregroundColor(changeColor)
                        .font(.caption)
                    Text("Total Change: \(changeText) kg")
                        .font(.caption)
                        .foregroundColor(changeColor)
                }
            }
            
            Spacer()
            
            Text("Hover over points for details")
                .font(.caption)
                .foregroundColor(.secondary)
                .italic()
        }
        .padding(.horizontal, 20)
    }
    
    private func formatDateForAxis(_ dateString: String) -> String {
        let dateFormatter = DateFormatter()
        let formats = [
            "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'",
            "yyyy-MM-dd'T'HH:mm:ss'Z'",
            "yyyy-MM-dd"
        ]
        
        for format in formats {
            dateFormatter.dateFormat = format
            if let date = dateFormatter.date(from: dateString) {
                let displayFormatter = DateFormatter()
                displayFormatter.dateFormat = "MMM dd"
                return displayFormatter.string(from: date)
            }
        }
        
        return dateString
    }
    
    private func formatDateForTooltip(_ dateString: String) -> String {
        let dateFormatter = DateFormatter()
        let formats = [
            "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'",
            "yyyy-MM-dd'T'HH:mm:ss'Z'",
            "yyyy-MM-dd"
        ]
        
        for format in formats {
            dateFormatter.dateFormat = format
            if let date = dateFormatter.date(from: dateString) {
                let displayFormatter = DateFormatter()
                displayFormatter.dateFormat = "EEEE, MMM dd, yyyy"
                return displayFormatter.string(from: date)
            }
        }
        
        return dateString
    }
}