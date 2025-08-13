import SwiftUI

/// Universal Dashboard Card - Base component for all dashboard cards
/// Provides consistent styling, spacing, and layout patterns
struct DashboardCard<Content: View>: View {
    let title: String
    let content: Content
    let spacing: CGFloat
    let headerFontSize: CGFloat
    let headerColor: Color
    
    /// Default dashboard card
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
        self.spacing = 16
        self.headerFontSize = 12
        self.headerColor = .secondary
    }
    
    /// Custom styling
    init(title: String, spacing: CGFloat = 16, headerFontSize: CGFloat = 12, headerColor: Color = .secondary, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
        self.spacing = spacing
        self.headerFontSize = headerFontSize
        self.headerColor = headerColor
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            // Header
            Text(title)
                .font(.system(size: headerFontSize, weight: .medium))
                .foregroundColor(headerColor)
                .tracking(0.5)
            
            // Content
            content
        }
    }
}

// MARK: - Stat Card Component (for weight displays)
/// Reusable component for displaying title/value pairs with optional colors
struct StatCard: View {
    let title: String
    let value: String
    let valueColor: Color?
    let backgroundColor: Color
    
    init(title: String, value: String, valueColor: Color? = nil, backgroundColor: Color = Color(NSColor.controlBackgroundColor)) {
        self.title = title
        self.value = value
        self.valueColor = valueColor
        self.backgroundColor = backgroundColor
    }
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(valueColor ?? .primary)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(backgroundColor)
        .cornerRadius(8)
    }
}

// MARK: - Weight Change Colors Utility
extension Color {
    /// Standard weight change color logic (used across multiple cards)
    static func weightChangeColor(for change: Double?) -> Color {
        guard let change = change else { return .secondary }
        return change < 0 ? .green : change > 0 ? .red : .secondary
    }
}

// MARK: - Previews
#Preview("Dashboard Card with Stats") {
    VStack {
        DashboardCard(title: "RESUMEN PERSONAL") {
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    StatCard(title: "Peso Inicial", value: "75.5 kg")
                    StatCard(title: "Peso Actual", value: "73.2 kg")
                }
                
                StatCard(
                    title: "Total Perdido/Ganado",
                    value: "-2.3 kg",
                    valueColor: .weightChangeColor(for: -2.3)
                )
            }
        }
        Spacer()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .padding()
    .background(Color(NSColor.windowBackgroundColor))
}

#Preview("Dashboard Card with Custom Content") {
    VStack {
        DashboardCard(title: "PREDICCIÓN DE PESO", spacing: 20, headerFontSize: 14) {
            VStack(spacing: 16) {
                Text("Tu progreso indica que podrías alcanzar tu meta en:")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Text("2 semanas")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.green)
            }
            .frame(maxWidth: .infinity)
            .padding(20)
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(12)
        }
        Spacer()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .padding()
    .background(Color(NSColor.windowBackgroundColor))
}

#Preview("Empty Dashboard Card") {
    VStack {
        DashboardCard(title: "SIN DATOS") {
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    StatCard(title: "Peso Inicial", value: "-")
                    StatCard(title: "Peso Actual", value: "-")
                }
                
                StatCard(title: "Total Perdido/Ganado", value: "-")
            }
        }
        Spacer()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .padding()
    .background(Color(NSColor.windowBackgroundColor))
}