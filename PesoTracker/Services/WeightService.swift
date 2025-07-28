import Foundation

class WeightService: ObservableObject {
    
    // MARK: - Singleton
    static let shared = WeightService()
    
    // MARK: - Properties
    private let apiService = APIService.shared
    
    // Published properties
    @Published var isLoading = false
    @Published var weights: [Weight] = []
    @Published var error: String?
    
    // MARK: - Initialization
    private init() {
        print("⚖️ [WEIGHT SERVICE] Initializing weight service")
    }
    
    // MARK: - Load Weights (with debug logs)
    @MainActor
    func loadWeights(page: Int = 1, limit: Int = 50) async {
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
            
            weights = fetchedWeights
            
            // Log peso information
            if !fetchedWeights.isEmpty {
                let pesoInicial = fetchedWeights.last!.weight // El más antiguo
                let pesoActual = fetchedWeights.first!.weight // El más reciente
                
                print("📊 [PESOS] Total de registros: \(fetchedWeights.count)")
                print("📊 [PESOS] Peso inicial: \(String(format: "%.1f", pesoInicial)) kg")
                print("📊 [PESOS] Peso actual: \(String(format: "%.1f", pesoActual)) kg")
                
                if fetchedWeights.count > 1 {
                    let diferencia = pesoActual - pesoInicial
                    let tipo = diferencia >= 0 ? "ganado" : "perdido"
                    print("📊 [PESOS] Total \(tipo): \(String(format: "%.1f", abs(diferencia))) kg")
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
            
            // Reload weights after creation
            await loadWeights()
            
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
            
            // Reload weights after update
            await loadWeights()
            
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
            
            // Reload weights after deletion
            await loadWeights()
            
            return true
            
        } catch {
            print("❌ [WEIGHT SERVICE] Error deleting weight: \(error)")
            self.error = "Error al eliminar peso: \(error.localizedDescription)"
            return false
        }
    }
    
    // MARK: - Helper Methods
    func getCurrentWeight() -> Weight? {
        return weights.first // Assuming weights are sorted by date desc
    }
    
    func getWeightChange() -> Double? {
        guard weights.count >= 2 else { return nil }
        
        let latest = weights.first!.weight
        let oldest = weights.last!.weight
        
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
            return weights
        }
        
        return weights.filter { $0.date >= startDate }
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
              let weightChange = getWeightChange() else { return "No disponible" }
        
        let weeks = Double(trackingDays) / 7.0
        let weeklyChange = weightChange / weeks
        let sign = weeklyChange >= 0 ? "+" : ""
        
        return "\(sign)\(String(format: "%.2f", weeklyChange)) kg/semana"
    }
    
    // MARK: - Clear Data
    func clearData() {
        weights = []
        error = nil
    }
}

// MARK: - Extensions for UI Helpers
extension WeightService {
    
    var hasWeightData: Bool {
        return !weights.isEmpty
    }
    
    var formattedCurrentWeight: String {
        guard let weight = getCurrentWeight() else { return "-- kg" }
        return String(format: "%.1f kg", weight.weight)
    }
    
    var formattedWeightChange: String {
        guard let change = getWeightChange() else { return "-- kg" }
        let sign = change >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.1f", change)) kg"
    }
    
    var lastWeightEntry: String {
        guard let lastWeight = weights.first else { return "Sin registros" }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        
        return "Último registro: \(formatter.string(from: lastWeight.date))"
    }
    
    var recentWeights: [Weight] {
        return Array(weights.prefix(5)) // Last 5 records
    }
}