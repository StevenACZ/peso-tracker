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
    @Published var error: String?
    
    // Dashboard data from new API
    @Published var dashboardData: DashboardResponse?
    @Published var chartData: ChartDataResponse?
    @Published var tableData: PaginatedResponse<Weight>?
    
    // UI State
    @Published var selectedTimeRange = "1month"
    @Published var currentChartPage = 0
    @Published var currentTablePage = 1
    
    // MARK: - Initialization
    private init() {
        print("📊 [DASHBOARD SERVICE] Initializing new dashboard service")
    }
    
    // MARK: - Load Dashboard Data
    @MainActor
    func loadDashboardData() async {
        print("📊 [DASHBOARD] Loading dashboard data from new endpoint...")
        print("🔗 [DASHBOARD] Attempting to call endpoint: 'dashboard'")
        isLoading = true
        error = nil
        
        do {
            // Load main dashboard data
            print("🚀 [DASHBOARD] Making API call to /dashboard")
            dashboardData = try await apiService.get(
                endpoint: "/dashboard",
                responseType: DashboardResponse.self
            )
            print("✅ [DASHBOARD] Successfully received dashboard response")
            if let data = dashboardData {
                print("👤 [DASHBOARD] User: \(data.user.username) (\(data.user.email))")
                print("📊 [DASHBOARD] Statistics: \(data.statistics.totalRecords) records, current: \(data.statistics.currentWeight ?? 0)")
                print("🎯 [DASHBOARD] Active goal: \(data.activeGoal?.targetWeight ?? 0)")
            }
            
            // Load chart data for default time range
            await loadChartData(timeRange: selectedTimeRange, page: currentChartPage)
            
            // Load table data for first page
            await loadTableData(page: currentTablePage)
            
            print("✅ [DASHBOARD] Dashboard data loaded successfully")
            
        } catch {
            print("❌ [DASHBOARD] Error loading dashboard data: \(error)")
            self.error = "Error al cargar datos del dashboard: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    // MARK: - Load Chart Data
    @MainActor
    func loadChartData(timeRange: String, page: Int) async {
        print("📊 [DASHBOARD] Loading chart data - TimeRange: \(timeRange), Page: \(page)")
        let endpoint = "/weights/chart-data?timeRange=\(timeRange)&page=\(page)"
        print("🔗 [DASHBOARD] Chart endpoint: '\(endpoint)'")
        
        do {
            print("🚀 [DASHBOARD] Making API call to /\(endpoint)")
            chartData = try await apiService.get(
                endpoint: endpoint,
                responseType: ChartDataResponse.self
            )
            
            if let data = chartData {
                print("✅ [DASHBOARD] Chart data received: \(data.data.count) points")
                print("📈 [DASHBOARD] Pagination: \(data.pagination.currentPeriod), page \(data.pagination.currentPage + 1)/\(data.pagination.totalPeriods)")
            }
            
            currentChartPage = page
            selectedTimeRange = timeRange
            
            print("✅ [DASHBOARD] Chart data loaded - \(chartData?.data.count ?? 0) points")
            
        } catch {
            print("❌ [DASHBOARD] Error loading chart data: \(error)")
            self.error = "Error al cargar datos del gráfico: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Load Table Data
    @MainActor
    func loadTableData(page: Int) async {
        print("📊 [DASHBOARD] Loading table data - Page: \(page)")
        let endpoint = "/weights/paginated?page=\(page)&limit=5"
        print("🔗 [DASHBOARD] Table endpoint: '\(endpoint)'")
        
        do {
            print("🚀 [DASHBOARD] Making API call to /\(endpoint)")
            tableData = try await apiService.get(
                endpoint: endpoint,
                responseType: PaginatedResponse<Weight>.self
            )
            
            if let data = tableData {
                print("✅ [DASHBOARD] Table data received: \(data.data.count) records")
                print("📋 [DASHBOARD] Pagination: page \(data.pagination.page)/\(data.pagination.totalPages), total: \(data.pagination.total)")
            }
            
            currentTablePage = page
            
            print("✅ [DASHBOARD] Table data loaded - \(tableData?.data.count ?? 0) records")
            
        } catch {
            print("❌ [DASHBOARD] Error loading table data: \(error)")
            self.error = "Error al cargar datos de la tabla: \(error.localizedDescription)"
        }
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
              currentTablePage < pagination.totalPages else { return }
        await loadTableData(page: currentTablePage + 1)
    }
    
    @MainActor
    func loadPreviousTablePage() async {
        guard currentTablePage > 1 else { return }
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
        return tableData?.data ?? []
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
        print("🔄 [DASHBOARD] Refreshing all data...")
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
        selectedTimeRange = "1month"
    }
    
    // MARK: - Logout
    @MainActor
    func logout() {
        print("🚪 [DASHBOARD] Logging out...")
        clearData()
        AuthService.shared.logout()
        print("✅ [DASHBOARD] Logout completed")
    }
}