import Foundation
import SwiftUI
import Combine

@MainActor
class DashboardViewModel: ObservableObject {
    
    // MARK: - Properties
    private let dashboardService = DashboardService.shared
    
    // Published properties
    @Published var isLoading = false
    @Published var isChartLoading = false
    @Published var isTableLoading = false
    @Published var error: String?
    @Published var showError = false
    
    // Dashboard data (from service)
    @Published var currentUser: User?
    @Published var statistics: DashboardStatistics?
    @Published var activeGoal: DashboardGoal?
    @Published var weights: [Weight] = []
    @Published var chartPoints: [WeightPoint] = []
    @Published var progressData: [ProgressResponse] = []
    
    // UI State
    @Published var selectedTimeRange = "1month"
    @Published var hasData = false
    
    // Combine cancellables
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init() {
        print("📊 [DASHBOARD VM] Initializing simplified dashboard view model")
        setupBindings()
    }
    
    // MARK: - Setup Bindings
    private func setupBindings() {
        // Bind to dashboard service
        dashboardService.$isLoading
            .assign(to: &$isLoading)
        
        dashboardService.$isChartLoading
            .assign(to: &$isChartLoading)
        
        dashboardService.$isTableLoading
            .assign(to: &$isTableLoading)
        
        dashboardService.$error
            .compactMap { $0 }
            .sink { [weak self] errorMessage in
                self?.error = errorMessage
                self?.showError = true
            }
            .store(in: &cancellables)
        
        // Bind dashboard data
        dashboardService.$dashboardData
            .map { $0?.user }
            .assign(to: &$currentUser)
        
        dashboardService.$dashboardData
            .map { $0?.statistics }
            .assign(to: &$statistics)
        
        dashboardService.$dashboardData
            .map { $0?.activeGoal }
            .assign(to: &$activeGoal)
        
        // Bind table data - using computed property from service
        dashboardService.$tableData
            .map { $0?.data ?? [] }
            .assign(to: &$weights)
        
        // Bind chart data - using computed property from service  
        dashboardService.$chartData
            .map { $0?.data ?? [] }
            .assign(to: &$chartPoints)
        
        // Update hasData when statistics change
        dashboardService.$dashboardData
            .map { dashboardData in
                (dashboardData?.statistics.totalRecords ?? 0) > 0
            }
            .assign(to: &$hasData)
        
        // Bind time range changes
        dashboardService.$selectedTimeRange
            .assign(to: &$selectedTimeRange)
    }
    
    // MARK: - Load Data
    func loadDashboardData() async {
        print("📊 [DASHBOARD VM] Loading dashboard data...")
        await dashboardService.loadDashboardData()
    }
    
    func refreshData() async {
        print("📊 [DASHBOARD VM] Refreshing dashboard data...")
        await dashboardService.refreshData()
    }
    
    // MARK: - Data Access Methods (Simplified)
    var currentWeight: Double? {
        return statistics?.currentWeight
    }
    
    var weightChange: Double? {
        return statistics?.totalChange
    }
    
    var totalRecords: Int {
        return statistics?.totalRecords ?? 0
    }
    
    var weeklyAverage: Double? {
        return statistics?.weeklyAverage
    }
    
    var initialWeight: Double? {
        return statistics?.initialWeight
    }
    
    // MARK: - Data Status Properties
    var hasWeightData: Bool {
        return !weights.isEmpty
    }
    
    var hasGoalData: Bool {
        return activeGoal != nil
    }
    
    var hasActiveGoal: Bool {
        return activeGoal != nil
    }
    
    // MARK: - Formatted Data for UI (Direct from Service)
    var formattedCurrentWeight: String {
        return dashboardService.formattedCurrentWeight
    }
    
    var formattedWeightChange: String {
        return dashboardService.formattedWeightChange
    }
    
    var formattedGoalWeight: String {
        return dashboardService.formattedGoalWeight
    }
    
    var formattedWeeklyAverage: String {
        return dashboardService.formattedWeeklyAverage
    }
    
    var formattedUserName: String {
        return currentUser?.username ?? "Sin nombre"
    }
    
    var formattedUserEmail: String {
        return currentUser?.email ?? "Sin email"
    }
    
    // MARK: - Goal Information
    var goalWeight: Double? {
        return activeGoal?.targetWeight
    }
    
    var goalDate: Date? {
        return activeGoal?.targetDate
    }
    
    // MARK: - Actions
    func logout() {
        print("🚪 [DASHBOARD VM] Logging out...")
        dashboardService.logout()
    }
    
    func dismissError() {
        showError = false
        error = nil
    }
    
    // MARK: - Time Range Selection
    func updateTimeRange(_ newRange: String) async {
        print("📊 [DASHBOARD VM] Time range updated to: \(newRange)")
        await dashboardService.changeTimeRange(newRange)
    }
    
    // MARK: - Chart Navigation
    var canGoNextChart: Bool {
        return dashboardService.canGoNextChart
    }
    
    var canGoPreviousChart: Bool {
        return dashboardService.canGoPreviousChart
    }
    
    var chartPaginationInfo: String {
        return dashboardService.chartPaginationInfo
    }
    
    func loadNextChartPage() async {
        await dashboardService.loadNextChartPage()
    }
    
    func loadPreviousChartPage() async {
        await dashboardService.loadPreviousChartPage()
    }
    
    // MARK: - Table Pagination Methods
    var canGoNextTable: Bool {
        return dashboardService.canGoNextTable
    }
    
    var canGoPreviousTable: Bool {
        return dashboardService.canGoPreviousTable
    }
    
    var tablePaginationInfo: String {
        return dashboardService.tablePaginationInfo
    }
    
    func loadNextTablePage() async {
        await dashboardService.loadNextTablePage()
    }
    
    func loadPreviousTablePage() async {
        await dashboardService.loadPreviousTablePage()
    }
    
    // MARK: - Delete Weight with Smart Navigation
    func handleWeightDeletion() async {
        // Check if current page will be empty after deletion
        let canGoPrevious = dashboardService.canGoPreviousTable
        
        // Reload dashboard data first
        await loadDashboardData()
        
        // Check if we need to navigate to previous page
        if weights.isEmpty && canGoPrevious {
            await dashboardService.loadPreviousTablePage()
        }
    }
    
    // MARK: - Data Validation
    var canShowChart: Bool {
        return !chartPoints.isEmpty
    }
    
    var canShowProgress: Bool {
        return hasWeightData // Solo requiere datos de peso, no necesariamente una meta activa
    }
    
    // MARK: - Load Progress Data
    func loadProgressData() async {
        do {
            progressData = try await dashboardService.loadProgressData()
        } catch {
            self.error = "Error al cargar datos de progreso: \(error.localizedDescription)"
            showError = true
        }
    }
}

