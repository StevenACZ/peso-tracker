import SwiftUI

/// Universal Stat Card - Enhanced version of StatCard for displaying statistics
/// Replaces similar stat display patterns across PersonalSummaryCard, WeightPredictionCard, etc.
struct UniversalStatCard: View {
    
    // MARK: - Configuration
    struct StatConfig {
        let title: String
        let value: String
        let valueColor: Color?
        let subtitle: String?
        let icon: String?
        let trend: TrendIndicator?
        
        enum TrendIndicator {
            case up(Color = ColorTheme.error)      // Up arrow (usually bad for weight)
            case down(Color = ColorTheme.success)  // Down arrow (usually good for weight)
            case stable(Color = ColorTheme.neutral) // Equal sign
            case custom(String, Color)             // Custom icon and color
        }
        
        init(
            title: String,
            value: String,
            valueColor: Color? = nil,
            subtitle: String? = nil,
            icon: String? = nil,
            trend: TrendIndicator? = nil
        ) {
            self.title = title
            self.value = value
            self.valueColor = valueColor
            self.subtitle = subtitle
            self.icon = icon
            self.trend = trend
        }
    }
    
    // MARK: - Properties
    let config: StatConfig
    let layout: LayoutStyle
    let backgroundColor: Color
    let cornerRadius: CGFloat
    let padding: CGFloat
    
    enum LayoutStyle {
        case compact        // Small card, minimal spacing
        case standard       // Normal card size
        case expanded       // Larger card with more spacing
        case horizontal     // Title and value side by side
    }
    
    // MARK: - Initializers
    
    /// Simple stat card (most common usage)
    init(
        title: String,
        value: String,
        valueColor: Color? = nil,
        backgroundColor: Color = Color(NSColor.controlBackgroundColor)
    ) {
        self.config = StatConfig(title: title, value: value, valueColor: valueColor)
        self.layout = .standard
        self.backgroundColor = backgroundColor
        self.cornerRadius = 8
        self.padding = 12
    }
    
    /// Weight change stat card (with automatic color)
    init(
        title: String,
        value: String,
        change: Double?,
        backgroundColor: Color = Color(NSColor.controlBackgroundColor)
    ) {
        let color = ColorTheme.weightChangeColor(for: change)
        self.config = StatConfig(title: title, value: value, valueColor: color)
        self.layout = .standard
        self.backgroundColor = backgroundColor
        self.cornerRadius = 8
        self.padding = 12
    }
    
    /// Full configuration
    init(
        config: StatConfig,
        layout: LayoutStyle = .standard,
        backgroundColor: Color = Color(NSColor.controlBackgroundColor),
        cornerRadius: CGFloat = 8,
        padding: CGFloat = 12
    ) {
        self.config = config
        self.layout = layout
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
        self.padding = padding
    }
    
    var body: some View {
        VStack(spacing: spacingForLayout) {
            if layout == .horizontal {
                horizontalLayout
            } else {
                verticalLayout
            }
        }
        .frame(maxWidth: .infinity)
        .padding(padding)
        .background(backgroundColor)
        .cornerRadius(cornerRadius)
    }
    
    // MARK: - Layout Views
    
    @ViewBuilder
    private var verticalLayout: some View {
        // Icon and title row
        HStack(spacing: 6) {
            if let icon = config.icon {
                Image(systemName: icon)
                    .font(.system(size: titleFontSize - 2))
                    .foregroundColor(.secondary)
            }
            
            Text(config.title)
                .typography(Typography.custom(size: titleFontSize))
                .foregroundColor(.secondary)
            
            Spacer()
            
            if let trend = config.trend {
                trendIndicator(trend)
            }
        }
        
        // Value row
        HStack {
            Text(config.value)
                .typography(Typography.custom(size: valueFontSize, weight: .semibold))
                .foregroundColor(config.valueColor ?? .primary)
            
            Spacer()
        }
        
        // Subtitle if present
        if let subtitle = config.subtitle {
            HStack {
                Text(subtitle)
                    .typography(Typography.custom(size: subtitleFontSize))
                    .foregroundColor(.secondary)
                
                Spacer()
            }
        }
    }
    
    @ViewBuilder
    private var horizontalLayout: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    if let icon = config.icon {
                        Image(systemName: icon)
                            .font(.system(size: titleFontSize - 2))
                            .foregroundColor(.secondary)
                    }
                    
                    Text(config.title)
                        .typography(Typography.custom(size: titleFontSize))
                        .foregroundColor(.secondary)
                }
                
                if let subtitle = config.subtitle {
                    Text(subtitle)
                        .typography(Typography.custom(size: subtitleFontSize))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            HStack(spacing: 4) {
                if let trend = config.trend {
                    trendIndicator(trend)
                }
                
                Text(config.value)
                    .typography(Typography.custom(size: valueFontSize, weight: .semibold))
                    .foregroundColor(config.valueColor ?? .primary)
            }
        }
    }
    
    @ViewBuilder
    private func trendIndicator(_ trend: StatConfig.TrendIndicator) -> some View {
        switch trend {
        case .up(let color):
            Image(systemName: "arrow.up")
                .foregroundColor(color)
                .font(.system(size: trendIconSize))
        case .down(let color):
            Image(systemName: "arrow.down")
                .foregroundColor(color)
                .font(.system(size: trendIconSize))
        case .stable(let color):
            Image(systemName: "equal")
                .foregroundColor(color)
                .font(.system(size: trendIconSize))
        case .custom(let iconName, let color):
            Image(systemName: iconName)
                .foregroundColor(color)
                .font(.system(size: trendIconSize))
        }
    }
    
    // MARK: - Layout Calculations
    
    private var spacingForLayout: CGFloat {
        switch layout {
        case .compact: return 4
        case .standard: return 6
        case .expanded: return 8
        case .horizontal: return 0
        }
    }
    
    private var titleFontSize: CGFloat {
        switch layout {
        case .compact: return 11
        case .standard: return 12
        case .expanded: return 13
        case .horizontal: return 12
        }
    }
    
    private var valueFontSize: CGFloat {
        switch layout {
        case .compact: return 14
        case .standard: return 16
        case .expanded: return 18
        case .horizontal: return 16
        }
    }
    
    private var subtitleFontSize: CGFloat {
        switch layout {
        case .compact: return 10
        case .standard: return 11
        case .expanded: return 12
        case .horizontal: return 11
        }
    }
    
    private var trendIconSize: CGFloat {
        switch layout {
        case .compact: return 10
        case .standard: return 12
        case .expanded: return 14
        case .horizontal: return 12
        }
    }
}

// MARK: - Convenience Factories

extension UniversalStatCard {
    
    /// Weight stat card with automatic color
    static func weight(
        title: String,
        value: String,
        change: Double?,
        layout: LayoutStyle = .standard
    ) -> UniversalStatCard {
        return UniversalStatCard(
            config: StatConfig(
                title: title,
                value: value,
                valueColor: ColorTheme.weightChangeColor(for: change)
            ),
            layout: layout
        )
    }
    
    /// Goal progress card
    static func goalProgress(
        title: String,
        current: String,
        target: String,
        progress: Double, // 0.0 to 1.0
        layout: LayoutStyle = .standard
    ) -> UniversalStatCard {
        let progressText = "\(current) / \(target)"
        let progressColor = ColorTheme.progressColor(for: progress)
        let subtitle = "\(Int(progress * 100))% completado"
        
        return UniversalStatCard(
            config: StatConfig(
                title: title,
                value: progressText,
                valueColor: progressColor,
                subtitle: subtitle,
                icon: "target"
            ),
            layout: layout
        )
    }
    
    /// Time-based stat (with relative date)
    static func timeStat(
        title: String,
        value: String,
        date: Date,
        layout: LayoutStyle = .standard
    ) -> UniversalStatCard {
        return UniversalStatCard(
            config: StatConfig(
                title: title,
                value: value,
                subtitle: date.relativeFormat,
                icon: "clock"
            ),
            layout: layout
        )
    }
    
    /// Trend stat with arrow indicator
    static func trendStat(
        title: String,
        value: String,
        isUpward: Bool?,
        layout: LayoutStyle = .standard
    ) -> UniversalStatCard {
        let trend: StatConfig.TrendIndicator?
        if let isUpward = isUpward {
            trend = isUpward ? .up() : .down()
        } else {
            trend = .stable()
        }
        
        return UniversalStatCard(
            config: StatConfig(
                title: title,
                value: value,
                trend: trend
            ),
            layout: layout
        )
    }
    
    /// Empty state card
    static func empty(
        title: String,
        layout: LayoutStyle = .standard
    ) -> UniversalStatCard {
        return UniversalStatCard(
            config: StatConfig(
                title: title,
                value: "-",
                valueColor: .secondary
            ),
            layout: layout
        )
    }
}

// MARK: - Previews

#Preview("Standard Cards") {
    VStack(spacing: 12) {
        HStack(spacing: 12) {
            UniversalStatCard.weight(title: "Peso Inicial", value: "75.5 kg", change: nil)
            UniversalStatCard.weight(title: "Peso Actual", value: "73.2 kg", change: -2.3)
        }
        
        UniversalStatCard.weight(title: "Total Perdido/Ganado", value: "-2.3 kg", change: -2.3)
        
        HStack(spacing: 12) {
            UniversalStatCard.goalProgress(title: "Meta Actual", current: "73.2", target: "70.0", progress: 0.72)
            UniversalStatCard.timeStat(title: "Último Registro", value: "73.2 kg", date: Date())
        }
    }
    .padding()
    .background(Color(NSColor.windowBackgroundColor))
}

#Preview("Layout Styles") {
    VStack(spacing: 12) {
        UniversalStatCard.weight(title: "Compacto", value: "73.2 kg", change: -1.5, layout: .compact)
        UniversalStatCard.weight(title: "Estándar", value: "73.2 kg", change: -1.5, layout: .standard)
        UniversalStatCard.weight(title: "Expandido", value: "73.2 kg", change: -1.5, layout: .expanded)
        UniversalStatCard.weight(title: "Horizontal", value: "73.2 kg", change: -1.5, layout: .horizontal)
    }
    .padding()
    .background(Color(NSColor.windowBackgroundColor))
}

#Preview("Trend Indicators") {
    VStack(spacing: 12) {
        UniversalStatCard.trendStat(title: "Tendencia Subida", value: "+0.5 kg", isUpward: true)
        UniversalStatCard.trendStat(title: "Tendencia Bajada", value: "-0.8 kg", isUpward: false)
        UniversalStatCard.trendStat(title: "Estable", value: "0.0 kg", isUpward: nil)
    }
    .padding()
    .background(Color(NSColor.windowBackgroundColor))
}