import Foundation
import SwiftUI
import Combine

@MainActor
class DashboardViewModel: ObservableObject {
    
    // MARK: - Properties
    private let dashboardService = DashboardService.shared
    
    // Published properties
    @Published var isLoading = false
    @Published var error: String?
    @Published var showError = false
    
    // Dashboard data
    @Published var currentUser: User?
    @Published var weights: [Weight] = []
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
        
        dashboardService.$goals
            .assign(to: &$goals)
        
        dashboardService.$photos
            .assign(to: &$photos)
        
        // Update hasData when weights or goals change
        Publishers.CombineLatest(
            dashboardService.$weights,
            dashboardService.$goals
        )
        .map { weights, goals in
            !weights.isEmpty || !goals.isEmpty
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
    
    // MARK: - Data Access Methods
    var currentWeight: Weight? {
        return dashboardService.getCurrentWeight()
    }
    
    var weightChange: Double? {
        return dashboardService.getWeightChange()
    }
    
    var mainGoal: Goal? {
        return dashboardService.getMainGoal()
    }
    
    var progressPercentage: Double {
        return dashboardService.getProgressPercentage()
    }
    
    var daysToGoal: Int? {
        return dashboardService.getDaysToGoal()
    }
    
    func getWeightsForChart() -> [Weight] {
        return dashboardService.getWeightsForChart(timeRange: selectedTimeRange)
    }
    
    // MARK: - Data Status Properties
    var hasWeightData: Bool {
        return !weights.isEmpty
    }
    
    var hasGoalData: Bool {
        return !goals.isEmpty
    }
    
    var hasPhotoData: Bool {
        return !photos.isEmpty
    }
    
    // MARK: - Formatted Data for UI
    var formattedCurrentWeight: String {
        return dashboardService.formattedCurrentWeight
    }
    
    var formattedWeightChange: String {
        return dashboardService.formattedWeightChange
    }
    
    var formattedGoalWeight: String {
        return dashboardService.formattedGoalWeight
    }
    
    var formattedProgressPercentage: String {
        return dashboardService.formattedProgressPercentage
    }
    
    var formattedDaysToGoal: String {
        return dashboardService.formattedDaysToGoal
    }
    
    var formattedUserName: String {
        return currentUser?.username ?? "Usuario"
    }
    
    var formattedUserEmail: String {
        return currentUser?.email ?? ""
    }
    
    // MARK: - Photos Data
    var recentPhotos: [Photo] {
        return Array(photos.prefix(5)) // Last 5 photos
    }
    
    var totalPhotos: Int {
        return photos.count
    }
    
    // MARK: - Goal Information
    var hasActiveGoal: Bool {
        return mainGoal != nil && !(mainGoal?.isCompleted ?? true)
    }
    
    var goalStatus: String {
        guard let goal = mainGoal else { return "Sin meta activa" }
        
        if goal.isCompleted {
            return "Meta completada"
        } else if goal.isOverdue {
            return "Meta vencida"
        } else {
            return "Meta activa"
        }
    }
    
    var goalProgress: String {
        guard hasActiveGoal,
              let currentWeight = currentWeight?.weight,
              let goal = mainGoal,
              let startWeight = weights.last?.weight else {
            return "No disponible"
        }
        
        let totalChange = abs(startWeight - goal.targetWeight)
        let currentChange = abs(startWeight - currentWeight)
        let remaining = totalChange - currentChange
        
        return String(format: "%.1f kg restantes", remaining)
    }
    
    // MARK: - Goals Information  
    var totalGoals: Int {
        return goals.count
    }
    
    var completedGoals: Int {
        return goals.filter { $0.isCompleted }.count
    }
    
    var activeGoals: Int {
        return goals.filter { !$0.isCompleted && !$0.isOverdue }.count
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
    
    // MARK: - Data Validation
    var canShowChart: Bool {
        return getWeightsForChart().count >= 2
    }
    
    var canShowProgress: Bool {
        return hasData && hasActiveGoal
    }
    
    var canShowPhotos: Bool {
        return hasPhotoData
    }
    
    // MARK: - Statistics
    var totalWeightRecords: Int {
        return weights.count
    }
    
    var trackingDays: Int {
        guard let firstRecord = weights.last,
              let lastRecord = weights.first else { return 0 }
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: firstRecord.date, to: lastRecord.date)
        return max(components.day ?? 0, 1)
    }
    
    var averageWeeklyChange: String {
        guard trackingDays > 7,
              let weightChange = weightChange else { return "No disponible" }
        
        let weeks = Double(trackingDays) / 7.0
        let weeklyChange = weightChange / weeks
        let sign = weeklyChange >= 0 ? "+" : ""
        
        return "\(sign)\(String(format: "%.2f", weeklyChange)) kg/semana"
    }
    
    // MARK: - Recent Activity
    var lastWeightEntry: String {
        guard let lastWeight = weights.first else { return "Sin registros" }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        
        return "Último registro: \(formatter.string(from: lastWeight.date))"
    }
    
    var recentWeights: [Weight] {
        // Sort weights by date (oldest to newest) and take first 5
        let sortedWeights = weights.sorted { $0.date < $1.date }
        return Array(sortedWeights.prefix(5))
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
}

