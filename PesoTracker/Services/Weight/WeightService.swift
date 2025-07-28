import Foundation

class WeightService: ObservableObject {
    
    // MARK: - Singleton
    static let shared = WeightService()
    
    // MARK: - Modular Components
    private let dataProvider = WeightDataProvider()
    private let statisticsCalculator = WeightStatisticsCalculator()
    
    // Published properties
    @Published var isLoading = false
    @Published var weights: [Weight] = [] // Paginated weights for table
    @Published var allWeights: [Weight] = [] // All weights for charts and stats
    @Published var error: String?
    @Published var currentPage = 1
    @Published var totalPages = 1
    @Published var totalRecords = 0
    @Published var pageLimit = 5
    
    // MARK: - Initialization
    private init() {
        print("⚖️ [WEIGHT SERVICE] Initializing weight service")
    }
    
    // MARK: - Load Weights (with debug logs)
    @MainActor
    func loadWeights(page: Int = 1, limit: Int = 5) async {
        isLoading = true
        error = nil
        
        do {
            let result = try await dataProvider.loadPaginatedWeights(page: page, limit: limit)
            
            weights = result.weights
            currentPage = result.pagination.page
            totalPages = result.pagination.totalPages
            totalRecords = result.pagination.total
            pageLimit = result.pagination.limit
            
            // Log peso information using statistics calculator
            if !weights.isEmpty {
                let totalRecords = statisticsCalculator.getTotalWeightRecords(from: weights)
                let currentWeight = statisticsCalculator.getCurrentWeight(from: weights)?.weight ?? 0
                let weightChange = statisticsCalculator.getWeightChange(from: weights) ?? 0
                
                print("📊 [PESOS] Total de registros: \(totalRecords)")
                print("📊 [PESOS] Peso actual: \(String(format: "%.2f", currentWeight)) kg")
                
                if abs(weightChange) > 0 {
                    let tipo = weightChange >= 0 ? "ganado" : "perdido"
                    print("📊 [PESOS] Total \(tipo): \(String(format: "%.2f", abs(weightChange))) kg")
                }
            } else {
                print("📊 [PESOS] No hay registros de peso")
            }
            
        } catch {
            print("❌ [WEIGHT SERVICE] Error loading weights: \(error)")
            self.error = "Error al cargar pesos: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    // MARK: - Load All Weights (for charts and statistics)
    @MainActor
    func loadAllWeights() async {
        do {
            allWeights = try await dataProvider.loadAllWeights()
            
            // Log information using statistics calculator
            let totalCount = statisticsCalculator.getTotalWeightRecords(from: allWeights)
            print("📊 [ALL WEIGHTS] Total de pesos cargados: \(totalCount)")
            
            if !allWeights.isEmpty {
                let currentWeight = statisticsCalculator.formattedCurrentWeight(from: allWeights)
                let weightChange = statisticsCalculator.formattedWeightChange(from: allWeights)
                
                print("📊 [ALL WEIGHTS] Peso actual: \(currentWeight)")
                print("📊 [ALL WEIGHTS] Cambio total: \(weightChange)")
            }
            
        } catch {
            print("❌ [ALL WEIGHTS] Error loading all weights: \(error)")
            // Don't set error here as it's a background operation
        }
    }
    
    // MARK: - Create Weight
    @MainActor
    func createWeight(weight: Double, date: Date, notes: String? = nil) async -> Bool {
        do {
            _ = try await dataProvider.createWeight(weight: weight, date: date, notes: notes)
            
            // Reload both paginated and all weights after creation
            await loadWeights()
            await loadAllWeights()
            
            return true
            
        } catch {
            print("❌ [WEIGHT SERVICE] Error creating weight: \(error)")
            self.error = "Error al crear peso: \(error.localizedDescription)"
            return false
        }
    }
    
    // MARK: - Update Weight
    @MainActor
    func updateWeight(id: String, weight: Double, date: Date, notes: String? = nil) async -> Bool {
        do {
            _ = try await dataProvider.updateWeight(id: id, weight: weight, date: date, notes: notes)
            
            // Reload both paginated and all weights after update
            await loadWeights()
            await loadAllWeights()
            
            return true
            
        } catch {
            print("❌ [WEIGHT SERVICE] Error updating weight: \(error)")
            self.error = "Error al actualizar peso: \(error.localizedDescription)"
            return false
        }
    }
    
    // MARK: - Delete Weight
    @MainActor
    func deleteWeight(id: String) async -> Bool {
        do {
            try await dataProvider.deleteWeight(id: id)
            
            // Reload both paginated and all weights after deletion
            await loadWeights()
            await loadAllWeights()
            
            return true
            
        } catch {
            print("❌ [WEIGHT SERVICE] Error deleting weight: \(error)")
            self.error = "Error al eliminar peso: \(error.localizedDescription)"
            return false
        }
    }
    
    // MARK: - Helper Methods (Delegated to Statistics Calculator)
    func getCurrentWeight() -> Weight? {
        return statisticsCalculator.getCurrentWeight(from: allWeights)
    }
    
    func getWeightChange() -> Double? {
        return statisticsCalculator.getWeightChange(from: allWeights)
    }
    
    func getWeightsForChart(timeRange: String) -> [Weight] {
        return statisticsCalculator.getWeightsForChart(from: allWeights, timeRange: timeRange)
    }
    
    // MARK: - Statistics (Delegated to Statistics Calculator)
    var totalWeightRecords: Int {
        return statisticsCalculator.getTotalWeightRecords(from: allWeights)
    }
    
    var trackingDays: Int {
        return statisticsCalculator.calculateTrackingDays(from: allWeights)
    }
    
    var averageWeeklyChange: String {
        return statisticsCalculator.calculateAverageWeeklyChange(from: allWeights)
    }
    
    // MARK: - Clear Data
    func clearData() {
        weights = []
        allWeights = []
        error = nil
    }
}

// MARK: - Extensions for UI Helpers (Delegated to Statistics Calculator)
extension WeightService {
    
    var hasWeightData: Bool {
        return statisticsCalculator.hasWeightData(weights: allWeights)
    }
    
    var formattedCurrentWeight: String {
        return statisticsCalculator.formattedCurrentWeight(from: allWeights)
    }
    
    var formattedWeightChange: String {
        return statisticsCalculator.formattedWeightChange(from: allWeights)
    }
    
    var lastWeightEntry: String {
        return statisticsCalculator.formattedLastWeightEntry(from: allWeights)
    }
    
    var recentWeights: [Weight] {
        return Array(weights.prefix(5)) // Last 5 records from paginated data
    }
    
    // MARK: - Pagination Methods
    var canGoBack: Bool {
        return currentPage > 1
    }
    
    var canGoNext: Bool {
        return currentPage < totalPages
    }
    
    @MainActor
    func loadNextPage() async {
        guard canGoNext else { return }
        await loadWeights(page: currentPage + 1, limit: pageLimit)
    }
    
    @MainActor
    func loadPreviousPage() async {
        guard canGoBack else { return }
        await loadWeights(page: currentPage - 1, limit: pageLimit)
    }
    
    var paginationInfo: String {
        return "Página \(currentPage) de \(totalPages) (\(totalRecords) registros)"
    }
}