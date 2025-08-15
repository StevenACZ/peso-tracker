import Foundation
import Combine

/// ServiceRegistry - Centralized service management and dependency injection
/// Provides single point of access to all services with lifecycle management
class ServiceRegistry: ObservableObject {
    
    // MARK: - Singleton
    static let shared = ServiceRegistry()
    
    // MARK: - Core Services
    private(set) lazy var apiService = APIService.shared
    private(set) lazy var authService = AuthService.shared
    private(set) lazy var cacheService = CacheService.shared
    private(set) lazy var validationService = UniversalValidationService.shared
    
    // MARK: - Feature Services
    private(set) lazy var dashboardService = DashboardService.shared
    private(set) lazy var weightService = WeightService()
    private(set) lazy var goalService = GoalService.shared
    private(set) lazy var themeService = ThemeService.shared
    private(set) lazy var dataExportService = DataExportService.shared
    
    // MARK: - Service Health Monitoring
    @Published var servicesHealthy = true
    @Published var unhealthyServices: [String] = []
    
    private var healthCheckTimer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    private init() {
        setupServiceMonitoring()
        configureServices()
    }
    
    deinit {
        healthCheckTimer?.invalidate()
        cancellables.removeAll()
    }
    
    // MARK: - Service Configuration
    
    private func configureServices() {
        // Configure service dependencies and relationships
        setupServiceDependencies()
        logServiceStatus()
    }
    
    private func setupServiceDependencies() {
        // Example: Weight service depends on cache invalidation
        // This could be expanded for more complex dependency management
        print("🔧 [SERVICE REGISTRY] Setting up service dependencies")
    }
    
    // MARK: - Service Health Monitoring
    
    private func setupServiceMonitoring() {
        // Monitor service health every 60 seconds
        healthCheckTimer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { [weak self] _ in
            self?.performHealthCheck()
        }
    }
    
    private func performHealthCheck() {
        var unhealthy: [String] = []
        
        // Check services with error properties
        if dashboardService.error != nil {
            unhealthy.append("DashboardService")
        }
        
        if goalService.error != nil {
            unhealthy.append("GoalService")
        }
        
        // Update health status
        DispatchQueue.main.async { [weak self] in
            self?.unhealthyServices = unhealthy
            self?.servicesHealthy = unhealthy.isEmpty
        }
        
        if !unhealthy.isEmpty {
            print("⚠️ [SERVICE HEALTH] Unhealthy services: \(unhealthy.joined(separator: ", "))")
        }
    }
    
    // MARK: - Service Access Methods
    
    /// Get all services conforming to CacheableService
    var cacheableServices: [CacheableService] {
        return [
            dashboardService,  // Manages dashboard, chart, and table cache
        ]
    }
    
    /// Get all services conforming to AuthenticatedService  
    var authenticatedServices: [AuthenticatedService] {
        return [
            dashboardService,  // Requires authentication for dashboard data
            weightService,     // Requires authentication for weight operations
            goalService       // Requires authentication for goal management
        ]
    }
    
    // MARK: - Batch Operations
    
    /// Clear cache for all cacheable services
    func clearAllCaches() {
        // Simplified cache clearing
        cacheableServices.forEach { $0.clearCache() }
        print("🗑️ [SERVICE REGISTRY] All caches cleared")
    }
    
    /// Refresh all cached data
    func refreshAllCaches() async {
        await withTaskGroup(of: Void.self) { group in
            for service in cacheableServices {
                group.addTask {
                    await service.refreshCache()
                }
            }
        }
        print("🔄 [SERVICE REGISTRY] All caches refreshed")
    }
    
    /// Handle global authentication failure
    func handleGlobalAuthFailure() {
        authenticatedServices.forEach { $0.handleAuthenticationFailure() }
        
        // Clear sensitive caches
        clearAllCaches()
        
        print("🔐 [SERVICE REGISTRY] Global auth failure handled")
    }
    
    /// Reset all services to initial state
    func resetAllServices() {
        clearAllCaches()
        
        // Reset error states for services that have them
        dashboardService.error = nil
        goalService.clearError()
        
        // Re-initialize if needed
        configureServices()
        
        print("🔄 [SERVICE REGISTRY] All services reset")
    }
    
    // MARK: - Development Helpers
    
    private func logServiceStatus() {
        #if DEBUG
        print("📋 [SERVICE REGISTRY] Service Status:")
        print("   - API Service: ✅ Ready")
        print("   - Auth Service: ✅ Ready")  
        print("   - Cache Service: ✅ Ready")
        print("   - Dashboard Service: ✅ Ready")
        print("   - Weight Service: ✅ Ready")
        print("   - Goal Service: ✅ Ready")
        print("   - Theme Service: ✅ Ready")
        print("   - Validation Service: ✅ Ready")
        print("   - Data Export Service: ✅ Ready")
        #endif
    }
    
    /// Get service by type (for dependency injection)
    func getService<T>(_ type: T.Type) -> T? {
        switch type {
        case is APIService.Type:
            return apiService as? T
        case is AuthService.Type:
            return authService as? T
        case is CacheService.Type:
            return cacheService as? T
        case is DashboardService.Type:
            return dashboardService as? T
        case is WeightService.Type:
            return weightService as? T
        case is GoalService.Type:
            return goalService as? T
        case is ThemeService.Type:
            return themeService as? T
        case is UniversalValidationService.Type:
            return validationService as? T
        case is DataExportService.Type:
            return dataExportService as? T
        default:
            return nil
        }
    }
}

// MARK: - Service Registry Extensions

extension ServiceRegistry {
    
    /// Convenient access to frequently used services
    var dashboard: DashboardService { dashboardService }
    var auth: AuthService { authService }
    var weight: WeightService { weightService }
    var goal: GoalService { goalService }
    var cache: CacheService { cacheService }
    var validation: UniversalValidationService { validationService }
    var theme: ThemeService { themeService }
    var export: DataExportService { dataExportService }
    
    /// Check if all critical services are operational
    var criticalServicesHealthy: Bool {
        return dashboardService.error == nil && 
               goalService.error == nil
    }
    
    /// Get summary of service states for debugging
    var servicesSummary: String {
        let summary = """
        Services Health Summary:
        - Healthy: \(servicesHealthy ? "✅" : "❌")
        - Critical Services: \(criticalServicesHealthy ? "✅" : "❌")
        - Unhealthy: \(unhealthyServices.isEmpty ? "None" : unhealthyServices.joined(separator: ", "))
        """
        return summary
    }
}