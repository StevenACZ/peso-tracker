import Foundation
import Combine

// MARK: - Dashboard Service (Rewritten)
class DashboardService: ObservableObject {
    
    // MARK: - Singleton
    static let shared = DashboardService()
    
    // MARK: - Services
    private let apiService = APIService.shared
    
    // Published properties for dashboard data
    @Published var isLoading = false
    @Published var isChartLoading = false
    @Published var isTableLoading = false
    @Published var error: String?
    
    // Dashboard data from new API
    @Published var dashboardData: DashboardResponse?
    @Published var chartData: ChartDataResponse?
    @Published var tableData: PaginatedResponse<Weight>?
    
    // UI State
    @Published var selectedTimeRange = "all"
    @Published var currentChartPage = 0
    @Published var currentTablePage = 1
    
    // MARK: - Initialization
    private init() {
    }
    
    // MARK: - Load Dashboard Data
    @MainActor
    func loadDashboardData() async {
        isLoading = true
        error = nil
        
        do {
            // Load main dashboard data
            dashboardData = try await apiService.get(
                endpoint: "/dashboard",
                responseType: DashboardResponse.self
            )
            
            // Show user info on dashboard load (keep this log only)
            if let data = dashboardData {
                print("👤 [DASHBOARD] User: \(data.user.username) (\(data.user.email)) - ID: \(data.user.id)")
            }
            
            // Load chart data for default time range
            await loadChartData(timeRange: selectedTimeRange, page: currentChartPage)
            
            // Load table data for first page
            await loadTableData(page: currentTablePage)
            
        } catch {
            self.error = "Error al cargar datos del dashboard: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    // MARK: - Load Chart Data
    @MainActor
    func loadChartData(timeRange: String, page: Int) async {
        isChartLoading = true
        
        let endpoint = "/weights/chart-data?timeRange=\(timeRange)&page=\(page)"
        
        do {
            chartData = try await apiService.get(
                endpoint: endpoint,
                responseType: ChartDataResponse.self
            )
            
            currentChartPage = page
            selectedTimeRange = timeRange
            
        } catch {
            self.error = "Error al cargar datos del gráfico: \(error.localizedDescription)"
        }
        
        isChartLoading = false
    }
    
    // MARK: - Load Table Data
    @MainActor
    func loadTableData(page: Int) async {
        isTableLoading = true
        let endpoint = "/weights/paginated?page=\(page)&limit=5"
        
        do {
            tableData = try await apiService.get(
                endpoint: endpoint,
                responseType: PaginatedResponse<Weight>.self
            )
            
            currentTablePage = page
            
        } catch {
            self.error = "Error al cargar datos de la tabla: \(error.localizedDescription)"
        }
        
        isTableLoading = false
    }
    
    // MARK: - Chart Navigation
    @MainActor
    func loadNextChartPage() async {
        guard let pagination = chartData?.pagination, pagination.hasNext else { return }
        await loadChartData(timeRange: selectedTimeRange, page: currentChartPage + 1)
    }
    
    @MainActor
    func loadPreviousChartPage() async {
        guard let pagination = chartData?.pagination, pagination.hasPrevious else { return }
        await loadChartData(timeRange: selectedTimeRange, page: currentChartPage - 1)
    }
    
    @MainActor
    func changeTimeRange(_ newTimeRange: String) async {
        selectedTimeRange = newTimeRange
        currentChartPage = 0
        await loadChartData(timeRange: newTimeRange, page: 0)
    }
    
    // MARK: - Table Navigation
    @MainActor
    func loadNextTablePage() async {
        guard let pagination = tableData?.pagination,
              currentTablePage < pagination.totalPages,
              !isTableLoading else { return }
        await loadTableData(page: currentTablePage + 1)
    }
    
    @MainActor
    func loadPreviousTablePage() async {
        guard currentTablePage > 1,
              !isTableLoading else { return }
        await loadTableData(page: currentTablePage - 1)
    }
    
    // MARK: - Computed Properties for UI
    var currentUser: User? {
        return dashboardData?.user
    }
    
    var statistics: DashboardStatistics? {
        return dashboardData?.statistics
    }
    
    var activeGoal: DashboardGoal? {
        return dashboardData?.activeGoal
    }
    
    var weights: [Weight] {
        let unsortedWeights = tableData?.data ?? []
        return unsortedWeights.sorted { $0.date > $1.date }
    }
    
    var chartPoints: [WeightPoint] {
        return chartData?.data ?? []
    }
    
    // MARK: - Chart Pagination Properties
    var canGoNextChart: Bool {
        return chartData?.pagination.hasNext ?? false
    }
    
    var canGoPreviousChart: Bool {
        return chartData?.pagination.hasPrevious ?? false
    }
    
    var chartPaginationInfo: String {
        guard let pagination = chartData?.pagination else { return "" }
        return "\(pagination.currentPeriod) - Página \(pagination.currentPage + 1) de \(pagination.totalPeriods)"
    }
    
    // MARK: - Table Pagination Properties
    var canGoNextTable: Bool {
        guard let pagination = tableData?.pagination else { return false }
        return currentTablePage < pagination.totalPages
    }
    
    var canGoPreviousTable: Bool {
        return currentTablePage > 1
    }
    
    var tablePaginationInfo: String {
        guard let pagination = tableData?.pagination else { return "" }
        return "Página \(currentTablePage) de \(pagination.totalPages) (\(pagination.total) registros)"
    }
    
    // MARK: - Data Status
    var hasData: Bool {
        return (statistics?.totalRecords ?? 0) > 0
    }
    
    var hasWeightData: Bool {
        return !weights.isEmpty
    }
    
    var hasGoalData: Bool {
        return activeGoal != nil
    }
    
    // MARK: - Formatted Data
    var formattedCurrentWeight: String {
        guard let currentWeight = statistics?.currentWeight else { return "Sin datos" }
        return String(format: "%.2f kg", currentWeight)
    }
    
    var formattedWeightChange: String {
        guard let totalChange = statistics?.totalChange else { return "Sin datos" }
        let sign = totalChange >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.2f", totalChange)) kg"
    }
    
    var formattedGoalWeight: String {
        guard let goalWeight = activeGoal?.targetWeight else { return "Sin meta" }
        return String(format: "%.2f kg", goalWeight)
    }
    
    var formattedWeeklyAverage: String {
        guard let weeklyAverage = statistics?.weeklyAverage else { return "Sin datos" }
        let sign = weeklyAverage >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.2f", weeklyAverage)) kg/semana"
    }
    
    // MARK: - Refresh Data
    @MainActor
    func refreshData() async {
        await loadDashboardData()
    }
    
    // MARK: - Clear Data
    func clearData() {
        dashboardData = nil
        chartData = nil
        tableData = nil
        error = nil
        currentChartPage = 0
        currentTablePage = 1
        selectedTimeRange = "all"
    }
    
    // MARK: - Progress Data
    @MainActor
    func loadProgressData() async throws -> [ProgressResponse] {
        do {
            let progressData = try await apiService.get(
                endpoint: "/weights/progress",
                responseType: [ProgressResponse].self
            )
            
            print("📊 [DASHBOARD] Loaded \(progressData.count) progress records")
            return progressData
            
        } catch {
            print("❌ [DASHBOARD] Error loading progress data: \(error)")
            throw error
        }
    }
    
    // MARK: - Logout
    @MainActor
    func logout() {
        clearData()
        AuthService.shared.logout()
    }
}