import Foundation
import Combine

// MARK: - Dashboard Service (Rewritten)
class DashboardService: ObservableObject, CacheableService, AuthenticatedService {
    
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
            await handleAuthenticationError(error)
            self.error = "Error al cargar datos del dashboard: \(ErrorMessageParser.cleanMessage(from: error))"
        }
        
        isLoading = false
    }
    
    // MARK: - Load Chart Data
    @MainActor
    func loadChartData(timeRange: String, page: Int) async {
        // Check cache first before setting loading state
        if let cachedData = CacheService.shared.getChartData(timeRange: timeRange, page: page) {
            // Cache hit - return data immediately without loading state
            self.chartData = cachedData
            self.currentChartPage = page
            self.selectedTimeRange = timeRange
            return
        }
        
        // Cache miss - proceed with API call
        isChartLoading = true
        
        let endpoint = "/weights/chart-data?timeRange=\(timeRange)&page=\(page)"
        
        do {
            let apiData = try await apiService.get(
                endpoint: endpoint,
                responseType: ChartDataResponse.self
            )
            
            // Store in cache after successful API call
            CacheService.shared.setChartData(timeRange: timeRange, page: page, data: apiData)
            
            // Update UI
            self.chartData = apiData
            self.currentChartPage = page
            self.selectedTimeRange = timeRange
            
        } catch {
            await handleAuthenticationError(error)
            self.error = "Error al cargar datos del gráfico: \(ErrorMessageParser.cleanMessage(from: error))"
        }
        
        isChartLoading = false
    }
    
    // MARK: - Load Table Data
    @MainActor
    func loadTableData(page: Int) async {
        // Check cache first before setting loading state
        if let cachedData = CacheService.shared.getTableData(page) {
            // Cache hit - return data immediately without loading state
            self.tableData = cachedData
            self.currentTablePage = page
            print("[TABLE CACHE] Page \(page) loaded from cache (INSTANT)")
            return
        }
        
        // Cache miss - proceed with API call
        print("[TABLE CACHE] Page \(page) - First visit, calling API...")
        isTableLoading = true
        let endpoint = "/weights/paginated?page=\(page)&limit=5"
        
        do {
            let apiData = try await apiService.get(
                endpoint: endpoint,
                responseType: PaginatedResponse<Weight>.self
            )
            
            // Store in cache after successful API call
            CacheService.shared.setTableData(page, data: apiData)
            print("[TABLE CACHE] Page \(page) cached for future use")
            
            // Update UI
            self.tableData = apiData
            self.currentTablePage = page
            
        } catch {
            await handleAuthenticationError(error)
            self.error = "Error al cargar datos de la tabla: \(ErrorMessageParser.cleanMessage(from: error))"
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
        // Check cache first
        if let cachedData = CacheService.shared.getProgressData() {
            // Cache hit - return data immediately
            return cachedData
        }
        
        // Cache miss - proceed with API call
        do {
            let progressData = try await apiService.get(
                endpoint: "/weights/progress",
                responseType: [ProgressResponse].self
            )
            
            // Store in cache after successful API call
            CacheService.shared.setProgressData(progressData)
            
            print("📊 [DASHBOARD] Loaded \(progressData.count) progress records from API")
            return progressData
            
        } catch {
            await handleAuthenticationError(error)
            print("❌ [DASHBOARD] Error loading progress data: \(error)")
            throw error
        }
    }
    
    // MARK: - Authentication Error Handler
    private func handleAuthenticationError(_ error: Error) async {
        if let apiError = error as? APIError {
            switch apiError {
            case .authenticationFailed, .tokenExpired:
                print("🔐 [DASHBOARD] Authentication error detected - auto-logout will be triggered by HTTPClient")
                // The HTTPClient has already triggered the auto-logout
                // We don't need to do anything else here
                break
            default:
                break
            }
        }
    }
    
    // MARK: - Logout
    @MainActor
    func logout() {
        clearData()
        CacheService.shared.clearCache()
        AuthService.shared.logout()
    }
}

// MARK: - Protocol Implementations

extension DashboardService {
    
    /// Cache keys managed by this service
    var cacheKeys: [String] {
        return ["dashboard", "chart_data", "table_data", "progress_data"]
    }
    
    /// Clear all dashboard-related cache
    func clearCache() {
        CacheService.shared.clearCache()
        clearData()
    }
    
    /// Refresh dashboard cache data
    func refreshCache() async {
        await loadDashboardData()
    }
    
    /// Handle authentication failure
    func handleAuthenticationFailure() {
        Task { @MainActor in
            clearData()
            self.error = "Sesión expirada. Inicia sesión nuevamente."
        }
    }
}