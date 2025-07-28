import Foundation

class WeightService: ObservableObject {
    
    // MARK: - Singleton
    static let shared = WeightService()
    
    // MARK: - Properties
    private let apiService = APIService.shared
    
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
            print("⚖️ [PESOS] Obteniendo pesos del usuario...")
            
            // Build endpoint with query parameters per API docs
            let endpoint = "\(Constants.API.Endpoints.weights)?page=\(page)&limit=\(limit)"
            
            // Check authentication
            guard AuthService.shared.isTokenValid() else {
                throw APIError.authenticationFailed
            }
            
            let response = try await apiService.get(
                endpoint: endpoint,
                responseType: PaginatedResponse<Weight>.self
            )
            
            let fetchedWeights = response.data
            
            // Sort weights by date (oldest to newest) for table display
            weights = fetchedWeights.sorted { $0.date < $1.date }
            
            // Update pagination info
            currentPage = response.pagination.page
            totalPages = response.pagination.totalPages
            totalRecords = response.pagination.total
            pageLimit = response.pagination.limit
            
            // Log peso information
            if !fetchedWeights.isEmpty {
                let pesoInicial = fetchedWeights.last!.weight // El más antiguo
                let pesoActual = fetchedWeights.first!.weight // El más reciente
                
                print("📊 [PESOS] Total de registros: \(fetchedWeights.count)")
                print("📊 [PESOS] Peso inicial: \(String(format: "%.2f", pesoInicial)) kg")
                print("📊 [PESOS] Peso actual: \(String(format: "%.2f", pesoActual)) kg")
                
                if fetchedWeights.count > 1 {
                    let diferencia = pesoActual - pesoInicial
                    let tipo = diferencia >= 0 ? "ganado" : "perdido"
                    print("📊 [PESOS] Total \(tipo): \(String(format: "%.2f", abs(diferencia))) kg")
                }
            } else {
                print("📊 [PESOS] No hay registros de peso")
            }
            
        } catch {
            print("❌ [DEBUG] Error loading weights: \(error)")
            if let apiError = error as? APIError {
                print("🔍 [DEBUG] API Error type: \(apiError)")
            }
            self.error = "Error al cargar pesos: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    // MARK: - Load All Weights (for charts and statistics)
    @MainActor
    func loadAllWeights() async {
        do {
            print("⚖️ [ALL WEIGHTS] Obteniendo todos los pesos para gráficos y estadísticas...")
            
            // Load all weights without pagination (high limit)
            let endpoint = "\(Constants.API.Endpoints.weights)?page=1&limit=1000"
            
            // Check authentication
            guard AuthService.shared.isTokenValid() else {
                throw APIError.authenticationFailed
            }
            
            let response = try await apiService.get(
                endpoint: endpoint,
                responseType: PaginatedResponse<Weight>.self
            )
            
            // Sort all weights by date (oldest to newest) for consistent ordering
            allWeights = response.data.sorted { $0.date < $1.date }
            
            // Log information
            print("📊 [ALL WEIGHTS] Total de pesos cargados: \(allWeights.count)")
            
            if !allWeights.isEmpty {
                let pesoInicial = allWeights.last!.weight // El más antiguo
                let pesoActual = allWeights.first!.weight // El más reciente
                
                print("📊 [ALL WEIGHTS] Peso inicial: \(String(format: "%.2f", pesoInicial)) kg")
                print("📊 [ALL WEIGHTS] Peso actual: \(String(format: "%.2f", pesoActual)) kg")
                
                if allWeights.count > 1 {
                    let diferencia = pesoActual - pesoInicial
                    let tipo = diferencia >= 0 ? "ganado" : "perdido"
                    print("📊 [ALL WEIGHTS] Total \(tipo): \(String(format: "%.2f", abs(diferencia))) kg")
                }
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
            print("⚖️ [WEIGHT SERVICE] Creating new weight record...")
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            struct WeightRequest: Codable {
                let weight: Double
                let date: String
                let notes: String
            }
            
            let weightData = WeightRequest(
                weight: weight,
                date: dateFormatter.string(from: date),
                notes: notes ?? ""
            )
            
            let _ = try await apiService.post(
                endpoint: Constants.API.Endpoints.weights,
                body: weightData,
                responseType: Weight.self
            )
            
            print("✅ [WEIGHT SERVICE] Weight created successfully")
            
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
            print("⚖️ [WEIGHT SERVICE] Updating weight record...")
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            struct WeightRequest: Codable {
                let weight: Double
                let date: String
                let notes: String
            }
            
            let weightData = WeightRequest(
                weight: weight,
                date: dateFormatter.string(from: date),
                notes: notes ?? ""
            )
            
            let _ = try await apiService.patch(
                endpoint: "\(Constants.API.Endpoints.weights)/\(id)",
                body: weightData,
                responseType: Weight.self
            )
            
            print("✅ [WEIGHT SERVICE] Weight updated successfully")
            
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
            print("⚖️ [WEIGHT SERVICE] Deleting weight record...")
            
            let _ = try await apiService.delete(
                endpoint: "\(Constants.API.Endpoints.weights)/\(id)",
                responseType: SuccessResponse.self
            )
            
            print("✅ [WEIGHT SERVICE] Weight deleted successfully")
            
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
    
    // MARK: - Helper Methods
    func getCurrentWeight() -> Weight? {
        return allWeights.first // Use allWeights for current weight
    }
    
    func getWeightChange() -> Double? {
        guard allWeights.count >= 2 else { return nil }
        
        let latest = allWeights.first!.weight
        let oldest = allWeights.last!.weight
        
        return latest - oldest
    }
    
    func getWeightsForChart(timeRange: String) -> [Weight] {
        let calendar = Calendar.current
        let now = Date()
        
        let startDate: Date
        switch timeRange {
        case "1 semana":
            startDate = calendar.date(byAdding: .weekOfYear, value: -1, to: now) ?? now
        case "1 mes":
            startDate = calendar.date(byAdding: .month, value: -1, to: now) ?? now
        case "3 meses":
            startDate = calendar.date(byAdding: .month, value: -3, to: now) ?? now
        case "6 meses":
            startDate = calendar.date(byAdding: .month, value: -6, to: now) ?? now
        case "1 año":
            startDate = calendar.date(byAdding: .year, value: -1, to: now) ?? now
        default:
            return allWeights
        }
        
        return allWeights.filter { $0.date >= startDate }
    }
    
    // MARK: - Statistics
    var totalWeightRecords: Int {
        return allWeights.count
    }
    
    var trackingDays: Int {
        guard let firstRecord = allWeights.last,
              let lastRecord = allWeights.first else { return 0 }
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: firstRecord.date, to: lastRecord.date)
        return max(components.day ?? 0, 1)
    }
    
    var averageWeeklyChange: String {
        guard trackingDays > 7,
              let weightChange = getWeightChange() else { return "No disponible" }
        
        let weeks = Double(trackingDays) / 7.0
        let weeklyChange = weightChange / weeks
        let sign = weeklyChange >= 0 ? "+" : ""
        
        return "\(sign)\(String(format: "%.2f", weeklyChange)) kg/semana"
    }
    
    // MARK: - Clear Data
    func clearData() {
        weights = []
        allWeights = []
        error = nil
    }
}

// MARK: - Extensions for UI Helpers
extension WeightService {
    
    var hasWeightData: Bool {
        return !allWeights.isEmpty
    }
    
    var formattedCurrentWeight: String {
        guard let weight = getCurrentWeight() else { return "-- kg" }
        return String(format: "%.2f kg", weight.weight)
    }
    
    var formattedWeightChange: String {
        guard let change = getWeightChange() else { return "-- kg" }
        let sign = change >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.2f", change)) kg"
    }
    
    var lastWeightEntry: String {
        guard let lastWeight = allWeights.first else { return "Sin registros" }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        
        return "Último registro: \(formatter.string(from: lastWeight.date))"
    }
    
    var recentWeights: [Weight] {
        return Array(weights.prefix(5)) // Last 5 records
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