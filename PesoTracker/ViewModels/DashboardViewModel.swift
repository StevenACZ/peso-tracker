import Foundation
import SwiftUI
import Combine

@MainActor
class DashboardViewModel: ObservableObject {
    
    // MARK: - Properties
    private let dashboardService = DashboardService.shared
    
    // MARK: - Modular Components
    private let dataFormatter = DashboardDataFormatter()
    private let statisticsCalculator = DashboardStatisticsCalculator()
    private let validator = DashboardValidator()
    
    // Published properties
    @Published var isLoading = false
    @Published var error: String?
    @Published var showError = false
    
    // Dashboard data
    @Published var currentUser: User?
    @Published var weights: [Weight] = [] // Paginated weights for table
    @Published var allWeights: [Weight] = [] // All weights for charts and stats
    @Published var goals: [Goal] = []
    @Published var photos: [Photo] = []
    
    // UI State
    @Published var selectedTimeRange = "1 mes"
    @Published var hasData = false
    
    // Combine cancellables
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init() {
        print("📊 [DASHBOARD VM] Initializing dashboard view model")
        setupBindings()
    }
    
    // MARK: - Setup Bindings
    private func setupBindings() {
        // Bind to dashboard service
        dashboardService.$isLoading
            .assign(to: &$isLoading)
        
        dashboardService.$error
            .compactMap { $0 }
            .sink { [weak self] errorMessage in
                self?.error = errorMessage
                self?.showError = true
            }
            .store(in: &cancellables)
        
        dashboardService.$currentUser
            .assign(to: &$currentUser)
        
        dashboardService.$weights
            .assign(to: &$weights)
        
        dashboardService.$allWeights
            .assign(to: &$allWeights)
        
        dashboardService.$goals
            .assign(to: &$goals)
        
        dashboardService.$photos
            .assign(to: &$photos)
        
        // Update hasData when allWeights or goals change
        Publishers.CombineLatest(
            dashboardService.$allWeights,
            dashboardService.$goals
        )
        .map { allWeights, goals in
            !allWeights.isEmpty || !goals.isEmpty
        }
        .assign(to: &$hasData)
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
    
    // MARK: - Data Access Methods (Delegated to Statistics Calculator)
    var currentWeight: Weight? {
        return statisticsCalculator.getCurrentWeight(from: allWeights)
    }
    
    var weightChange: Double? {
        return statisticsCalculator.getWeightChange(from: allWeights)
    }
    
    var mainGoal: Goal? {
        return statisticsCalculator.getMainGoal(from: goals)
    }
    
    var progressPercentage: Double {
        return statisticsCalculator.getProgressPercentage(allWeights: allWeights, goals: goals)
    }
    
    var daysToGoal: Int? {
        return statisticsCalculator.getDaysToGoal(from: goals)
    }
    
    func getWeightsForChart() -> [Weight] {
        return statisticsCalculator.getWeightsForChart(from: allWeights, timeRange: selectedTimeRange)
    }
    
    // MARK: - Data Status Properties (Delegated to Validator)
    var hasWeightData: Bool {
        return validator.hasWeightData(allWeights: allWeights)
    }
    
    var hasGoalData: Bool {
        return validator.hasGoalData(goals: goals)
    }
    
    var hasPhotoData: Bool {
        return validator.hasPhotoData(photos: photos)
    }
    
    // MARK: - Formatted Data for UI (Delegated to Data Formatter)
    var formattedCurrentWeight: String {
        return dataFormatter.formattedCurrentWeight(currentUser: currentUser, allWeights: allWeights)
    }
    
    var formattedWeightChange: String {
        return dataFormatter.formattedWeightChange(from: allWeights)
    }
    
    var formattedGoalWeight: String {
        return dataFormatter.formattedGoalWeight(from: goals)
    }
    
    var formattedProgressPercentage: String {
        return dataFormatter.formattedProgressPercentage(progressPercentage: progressPercentage)
    }
    
    var formattedDaysToGoal: String {
        return dataFormatter.formattedDaysToGoal(daysToGoal: daysToGoal)
    }
    
    var formattedUserName: String {
        return dataFormatter.formattedUserName(from: currentUser)
    }
    
    var formattedUserEmail: String {
        return dataFormatter.formattedUserEmail(from: currentUser)
    }
    
    // MARK: - Photos Data (Delegated to Statistics Calculator)
    var recentPhotos: [Photo] {
        return statisticsCalculator.getRecentPhotos(from: photos)
    }
    
    var totalPhotos: Int {
        return statisticsCalculator.getTotalPhotos(from: photos)
    }
    
    // MARK: - Goal Information (Delegated to Validator and Formatter)
    var hasActiveGoal: Bool {
        return validator.hasActiveGoal(goals: goals)
    }
    
    var goalStatus: String {
        return dataFormatter.formattedGoalStatus(from: goals)
    }
    
    var goalProgress: String {
        return dataFormatter.formattedGoalProgress(allWeights: allWeights, goals: goals)
    }
    
    // MARK: - Goals Information (Delegated to Statistics Calculator)
    var totalGoals: Int {
        return statisticsCalculator.getTotalGoals(from: goals)
    }
    
    var completedGoals: Int {
        return statisticsCalculator.getCompletedGoals(from: goals)
    }
    
    var activeGoals: Int {
        return statisticsCalculator.getActiveGoals(from: goals)
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
    func updateTimeRange(_ newRange: String) {
        selectedTimeRange = newRange
        print("📊 [DASHBOARD VM] Time range updated to: \(newRange)")
    }
    
    // MARK: - Data Validation (Delegated to Validator)
    var canShowChart: Bool {
        return validator.canShowChart(allWeights: allWeights, timeRange: selectedTimeRange)
    }
    
    var canShowProgress: Bool {
        return validator.canShowProgress(allWeights: allWeights, goals: goals)
    }
    
    var canShowPhotos: Bool {
        return validator.canShowPhotos(photos: photos)
    }
    
    // MARK: - Statistics (Delegated to Statistics Calculator and Formatter)
    var totalWeightRecords: Int {
        return statisticsCalculator.getTotalWeightRecords(from: allWeights)
    }
    
    var trackingDays: Int {
        return statisticsCalculator.calculateTrackingDays(from: allWeights)
    }
    
    var averageWeeklyChange: String {
        let weeklyChange = statisticsCalculator.calculateAverageWeeklyChange(from: allWeights)
        return dataFormatter.formattedAverageWeeklyChange(trackingDays: trackingDays, weightChange: weeklyChange)
    }
    
    // MARK: - Recent Activity (Delegated to Formatter and Statistics Calculator)
    var lastWeightEntry: String {
        return dataFormatter.formattedLastWeightEntry(from: allWeights)
    }
    
    var recentWeights: [Weight] {
        return statisticsCalculator.getRecentWeights(from: allWeights)
    }
    
    // MARK: - Weight Management
    func deleteWeight(weightId: Int) async {
        isLoading = true
        do {
            let weightService = WeightEntryService()
            try await weightService.deleteWeight(weightId: weightId)
            
            // Remove from local array
            weights.removeAll { $0.id == weightId }
            
            // Refresh data to ensure consistency
            await loadDashboardData()
            
        } catch {
            self.error = "Error al eliminar el peso: \(error.localizedDescription)"
            showError = true
        }
        isLoading = false
    }
    
    // MARK: - Pagination Methods (Delegated to Service and Formatter)
    var canGoBack: Bool {
        return dashboardService.canGoBack
    }
    
    var canGoNext: Bool {
        return dashboardService.canGoNext
    }
    
    var paginationInfo: String {
        return dashboardService.paginationInfo
    }
    
    func loadNextPage() async {
        await dashboardService.loadNextPage()
    }
    
    func loadPreviousPage() async {
        await dashboardService.loadPreviousPage()
    }
}

