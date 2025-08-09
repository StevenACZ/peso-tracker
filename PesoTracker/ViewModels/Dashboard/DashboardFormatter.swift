import Foundation

/// Handles all formatting logic for dashboard data
class DashboardFormatter {
    
    // MARK: - Weight Formatting
    static func formatWeight(_ weight: Double?) -> String {
        guard let weight = weight else { return "Sin datos" }
        return String(format: "%.2f kg", weight)
    }
    
    static func formatWeightChange(_ change: Double?) -> String {
        guard let change = change else { return "Sin datos" }
        let sign = change >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.2f", change)) kg"
    }
    
    static func formatWeeklyAverage(_ average: Double?) -> String {
        guard let average = average else { return "Sin datos" }
        let sign = average >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.2f", average)) kg/semana"
    }
    
    // MARK: - User Formatting
    static func formatUserName(_ user: User?) -> String {
        return user?.username ?? "Sin nombre"
    }
    
    static func formatUserEmail(_ user: User?) -> String {
        return user?.email ?? "Sin email"
    }
    
    // MARK: - Goal Formatting
    static func formatGoalWeight(_ goal: DashboardGoal?) -> String {
        guard let goalWeight = goal?.targetWeight else { return "Sin meta" }
        return String(format: "%.2f kg", goalWeight)
    }
    
    // MARK: - Pagination Formatting
    static func formatChartPagination(_ pagination: ChartPagination?) -> String {
        guard let pagination = pagination else { return "" }
        return "\(pagination.currentPeriod) - Página \(pagination.currentPage + 1) de \(pagination.totalPeriods)"
    }
    
    static func formatTablePagination(currentPage: Int, pagination: PaginationInfo?) -> String {
        guard let pagination = pagination else { return "" }
        return "Página \(currentPage) de \(pagination.totalPages) (\(pagination.total) registros)"
    }
}