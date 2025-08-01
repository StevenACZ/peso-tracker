import Foundation

// MARK: - Export Data Fetcher
class ExportDataFetcher {
    private let dashboardService = DashboardService.shared
    private let weightService = WeightService()
    
    func fetchAllWeightsData(progressCallback: @escaping (String) -> Void) async throws -> [Weight] {
        var allWeights: [Weight] = []
        var currentPage = 1
        var hasMorePages = true
        
        while hasMorePages {
            progressCallback("Obteniendo datos... (página \(currentPage))")
            
            // Load table data for current page
            await dashboardService.loadTableData(page: currentPage)
            
            guard let tableData = dashboardService.tableData else {
                throw NSError(domain: "ExportDataFetcher", code: 2, userInfo: [NSLocalizedDescriptionKey: "No se pudieron obtener los datos de pesos"])
            }
            
            // Add weights from current page
            allWeights.append(contentsOf: tableData.data)
            
            // Check if there are more pages
            hasMorePages = currentPage < tableData.pagination.totalPages
            currentPage += 1
            
            print("📁 [EXPORT_DATA_FETCHER] Fetched page \(currentPage - 1): \(tableData.data.count) weights, hasMore: \(hasMorePages)")
        }
        
        print("📁 [EXPORT_DATA_FETCHER] Total weights fetched: \(allWeights.count)")
        return allWeights
    }
    
    func fetchCompleteWeightData(for weightId: Int) async throws -> Weight {
        return try await weightService.getWeight(id: weightId)
    }
}