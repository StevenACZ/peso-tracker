import Foundation
import Combine

// MARK: - Dashboard Service
class DashboardService: ObservableObject {
    
    // MARK: - Singleton
    static let shared = DashboardService()
    
    // MARK: - Services
    private let weightService = WeightService.shared
    private let goalService = GoalService.shared
    private let photoService = PhotoService.shared
    
    // Published properties for dashboard data
    @Published var isLoading = false
    @Published var weights: [Weight] = []
    @Published var goals: [Goal] = []
    @Published var photos: [Photo] = []
    @Published var currentUser: User?
    @Published var error: String?
    
    // Combine cancellables
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    private init() {
        print("📊 [DASHBOARD SERVICE] Initializing dashboard service")
        setupBindings()
    }
    
    // MARK: - Setup Bindings
    private func setupBindings() {
        // Solo bind al weight service, no a otros servicios
        weightService.$weights
            .assign(to: &$weights)
        
        weightService.$error
            .compactMap { $0 }
            .sink { [weak self] errorMessage in
                self?.error = errorMessage
            }
            .store(in: &cancellables)
        
        // Solo mostrar loading del weight service
        weightService.$isLoading
            .assign(to: &$isLoading)
    }
    
    // MARK: - Load Dashboard Data
    @MainActor
    func loadDashboardData() async {
        print("📊 [DASHBOARD] Iniciando dashboard...")
        
        // Use cached user from AuthService
        currentUser = AuthService.shared.currentUser
        
        // Log user info
        if let user = currentUser {
            print("👤 [DASHBOARD] Usuario logueado:")
            print("   📧 Email: \(user.email)")
            print("   👤 Nombre: \(user.username)")
            if let token = AuthService.shared.getAuthToken() {
                print("   🔑 Token: \(token)")
            }
        }
        
        // Solo cargar pesos, no otros servicios
        await weightService.loadWeights()
        
        print("✅ [DASHBOARD] Dashboard cargado")
    }
    
    // MARK: - Individual Service Access
    var weightServiceInstance: WeightService {
        return weightService
    }
    
    var goalServiceInstance: GoalService {
        return goalService
    }
    
    var photoServiceInstance: PhotoService {
        return photoService
    }
    
    // MARK: - Refresh Data
    @MainActor
    func refreshData() async {
        print("🔄 [DASHBOARD] Refrescando datos...")
        await weightService.loadWeights()
    }
    
    // MARK: - Delegate Methods to Individual Services
    func getCurrentWeight() -> Weight? {
        return weightService.getCurrentWeight()
    }
    
    func getMainGoal() -> Goal? {
        return goalService.getMainGoal()
    }
    
    func getWeightChange() -> Double? {
        return weightService.getWeightChange()
    }
    
    func getWeightsForChart(timeRange: String) -> [Weight] {
        return weightService.getWeightsForChart(timeRange: timeRange)
    }
    
    func getProgressPercentage() -> Double {
        guard let currentWeight = getCurrentWeight()?.weight,
              let startWeight = weights.last?.weight else {
            return 0.0
        }
        
        return goalService.getProgressPercentage(currentWeight: currentWeight, startWeight: startWeight)
    }
    
    func getDaysToGoal() -> Int? {
        return goalService.getDaysToGoal()
    }
    
    func hasData() -> Bool {
        return weightService.hasWeightData
    }
    
    // MARK: - Logout
    @MainActor
    func logout() {
        print("🚪 [DASHBOARD] Cerrando sesión...")
        
        // Solo limpiar datos del weight service
        weightService.clearData()
        
        // Clear dashboard data
        currentUser = nil
        error = nil
        
        // Call AuthService logout
        AuthService.shared.logout()
        
        print("✅ [DASHBOARD] Sesión cerrada exitosamente")
    }
}

// MARK: - Extensions for UI Helpers
extension DashboardService {
    
    var hasWeightData: Bool {
        return weightService.hasWeightData
    }
    
    var hasGoalData: Bool {
        return goalService.hasGoalData
    }
    
    var hasPhotoData: Bool {
        return photoService.hasPhotoData
    }
    
    var formattedCurrentWeight: String {
        return weightService.formattedCurrentWeight
    }
    
    var formattedWeightChange: String {
        return weightService.formattedWeightChange
    }
    
    var formattedGoalWeight: String {
        return goalService.formattedGoalWeight
    }
    
    var formattedProgressPercentage: String {
        let percentage = getProgressPercentage()
        return String(format: "%.0f%%", percentage)
    }
    
    var formattedDaysToGoal: String {
        return goalService.formattedDaysToGoal
    }
}