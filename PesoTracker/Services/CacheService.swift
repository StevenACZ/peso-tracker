import Foundation
import AppKit

/// CacheService provides thread-safe caching specifically for table pagination data
/// Implements singleton pattern with concurrent queue for optimal performance
class CacheService {
    
    // MARK: - Singleton
    static let shared = CacheService()
    
    // MARK: - Cache Configuration
    private let maxCacheSize: Int = 50 // Maximum number of pages to cache
    private let maxMemoryUsage: Int = 10 * 1024 * 1024 // 10MB limit
    
    // MARK: - Private Properties
    private var tableCache: [String: PaginatedResponse<Weight>] = [:]
    private var chartCache: [String: ChartDataResponse] = [:]
    private var progressCache: [ProgressResponse]? = nil // Single cache for progress data
    private var weightCache: [String: Weight] = [:] // Individual weight cache
    private var accessOrder: [String] = [] // For LRU tracking (table, chart, and weight)
    private let cacheQueue = DispatchQueue(label: "com.pesotracker.cache.queue", attributes: .concurrent)
    
    // MARK: - Private Initializer
    private init() {
        logCacheOperation("CacheService initialized")
        setupMemoryManagement()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Public Interface
    
    /// Checks if a specific table page exists in cache
    /// - Parameter pageNumber: The page number to check
    /// - Returns: true if page exists in cache, false otherwise
    func hasTablePage(_ pageNumber: Int) -> Bool {
        return cacheQueue.sync {
            let key = tableKey(for: pageNumber)
            let exists = tableCache[key] != nil
            logCacheOperation("Checking cache for page \(pageNumber): \(exists ? "HIT" : "MISS")")
            return exists
        }
    }
    
    /// Retrieves cached table data for a specific page
    /// - Parameter pageNumber: The page number to retrieve
    /// - Returns: PaginatedResponse<Weight> if found, nil otherwise
    func getTableData(_ pageNumber: Int) -> PaginatedResponse<Weight>? {
        return cacheQueue.sync {
            let key = tableKey(for: pageNumber)
            let data = tableCache[key]
            
            if data != nil {
                // Update LRU order
                updateAccessOrder(for: key)
                logCacheOperation("Page \(pageNumber) loaded from cache (INSTANT)")
            } else {
                logCacheOperation("Page \(pageNumber) not found in cache")
            }
            
            return data
        }
    }
    
    /// Stores table data in cache for a specific page
    /// - Parameters:
    ///   - pageNumber: The page number to store
    ///   - data: The paginated response data to cache
    func setTableData(_ pageNumber: Int, data: PaginatedResponse<Weight>) {
        cacheQueue.async(flags: .barrier) {
            let key = self.tableKey(for: pageNumber)
            self.tableCache[key] = data
            self.updateAccessOrder(for: key)
            
            // Check if cleanup is needed
            self.performCleanupIfNeeded()
            
            self.logCacheOperation("Page \(pageNumber) cached for future use")
        }
    }
    
    /// Invalidates all cached table data
    /// This method should be called after any weight modification operations
    func invalidateTableCache() {
        cacheQueue.async(flags: .barrier) {
            let previousTableCount = self.tableCache.count
            let previousChartCount = self.chartCache.count
            let previousWeightCount = self.weightCache.count
            let hadProgressCache = self.progressCache != nil
            
            self.tableCache.removeAll()
            self.chartCache.removeAll()
            self.weightCache.removeAll()
            self.progressCache = nil // Clear progress cache on weight changes
            self.accessOrder.removeAll()
            
            let progressMessage = hadProgressCache ? " and progress data" : ""
            let weightMessage = previousWeightCount > 0 ? ", \(previousWeightCount) individual weights" : ""
            self.logCacheOperation("Cache invalidated after weight change (cleared \(previousTableCount) table pages, \(previousChartCount) chart entries\(weightMessage)\(progressMessage))")
        }
    }
    
    // MARK: - Chart Cache Methods
    
    /// Checks if chart data exists in cache for a specific time range and page
    /// - Parameters:
    ///   - timeRange: The time range (e.g., "1month", "3months", "all")
    ///   - page: The page number
    /// - Returns: true if chart data exists in cache, false otherwise
    func hasChartData(timeRange: String, page: Int) -> Bool {
        return cacheQueue.sync {
            let key = chartKey(for: timeRange, page: page)
            let exists = chartCache[key] != nil
            logCacheOperation("Checking chart cache for \(timeRange) page \(page): \(exists ? "HIT" : "MISS")")
            return exists
        }
    }
    
    /// Retrieves cached chart data for a specific time range and page
    /// - Parameters:
    ///   - timeRange: The time range (e.g., "1month", "3months", "all")
    ///   - page: The page number
    /// - Returns: ChartDataResponse if found, nil otherwise
    func getChartData(timeRange: String, page: Int) -> ChartDataResponse? {
        return cacheQueue.sync {
            let key = chartKey(for: timeRange, page: page)
            let data = chartCache[key]
            
            if data != nil {
                // Update LRU order
                updateAccessOrder(for: key)
                logCacheOperation("Chart \(timeRange) page \(page) loaded from cache (INSTANT)")
            } else {
                logCacheOperation("Chart \(timeRange) page \(page) not found in cache")
            }
            
            return data
        }
    }
    
    /// Stores chart data in cache for a specific time range and page
    /// - Parameters:
    ///   - timeRange: The time range (e.g., "1month", "3months", "all")
    ///   - page: The page number
    ///   - data: The chart data response to cache
    func setChartData(timeRange: String, page: Int, data: ChartDataResponse) {
        cacheQueue.async(flags: .barrier) {
            let key = self.chartKey(for: timeRange, page: page)
            self.chartCache[key] = data
            self.updateAccessOrder(for: key)
            
            // Check if cleanup is needed
            self.performCleanupIfNeeded()
            
            self.logCacheOperation("Chart \(timeRange) page \(page) cached for future use")
        }
    }
    
    // MARK: - Progress Cache Methods
    
    /// Checks if progress data exists in cache
    /// - Returns: true if progress data exists in cache, false otherwise
    func hasProgressData() -> Bool {
        return cacheQueue.sync {
            let exists = progressCache != nil
            logCacheOperation("Checking progress cache: \(exists ? "HIT" : "MISS")")
            return exists
        }
    }
    
    /// Retrieves cached progress data
    /// - Returns: Array of ProgressResponse if found, nil otherwise
    func getProgressData() -> [ProgressResponse]? {
        return cacheQueue.sync {
            let data = progressCache
            
            if data != nil {
                logCacheOperation("Progress data loaded from cache (INSTANT)")
            } else {
                logCacheOperation("Progress data not found in cache")
            }
            
            return data
        }
    }
    
    /// Stores progress data in cache
    /// - Parameter data: The progress data array to cache
    func setProgressData(_ data: [ProgressResponse]) {
        cacheQueue.async(flags: .barrier) {
            self.progressCache = data
            self.logCacheOperation("Progress data cached for future use (\(data.count) records)")
        }
    }
    
    // MARK: - Individual Weight Cache Methods
    
    /// Checks if a specific weight exists in cache
    /// - Parameter weightId: The weight ID to check
    /// - Returns: true if weight exists in cache, false otherwise
    func hasWeight(_ weightId: Int) -> Bool {
        return cacheQueue.sync {
            let key = weightKey(for: weightId)
            let exists = weightCache[key] != nil
            logCacheOperation("Checking cache for weight \(weightId): \(exists ? "HIT" : "MISS")")
            return exists
        }
    }
    
    /// Retrieves cached weight data for a specific weight ID
    /// - Parameter weightId: The weight ID to retrieve
    /// - Returns: Weight if found, nil otherwise
    func getWeight(_ weightId: Int) -> Weight? {
        return cacheQueue.sync {
            let key = weightKey(for: weightId)
            let weight = weightCache[key]
            
            if weight != nil {
                // Update LRU order
                updateAccessOrder(for: key)
                logCacheOperation("Weight \(weightId) loaded from cache (INSTANT)")
            } else {
                logCacheOperation("Weight \(weightId) not found in cache")
            }
            
            return weight
        }
    }
    
    /// Stores weight data in cache
    /// - Parameter weight: The weight to cache
    func setWeight(_ weight: Weight) {
        cacheQueue.async(flags: .barrier) {
            let key = self.weightKey(for: weight.id)
            self.weightCache[key] = weight
            self.updateAccessOrder(for: key)
            
            // Check if cleanup is needed
            self.performCleanupIfNeeded()
            
            self.logCacheOperation("Weight \(weight.id) cached for future use")
        }
    }
    
    /// Invalidates cached data for a specific weight
    /// - Parameter weightId: The weight ID to invalidate
    func invalidateWeight(_ weightId: Int) {
        cacheQueue.async(flags: .barrier) {
            let key = self.weightKey(for: weightId)
            self.weightCache.removeValue(forKey: key)
            
            // Remove from access order
            if let index = self.accessOrder.firstIndex(of: key) {
                self.accessOrder.remove(at: index)
            }
            
            self.logCacheOperation("Weight \(weightId) cache invalidated after update")
        }
    }
    
    // MARK: - Private Methods
    
    /// Generates a consistent cache key for table pages
    /// - Parameter page: The page number
    /// - Returns: String key in format "table_page_X"
    private func tableKey(for page: Int) -> String {
        return "table_page_\(page)"
    }
    
    /// Generates a consistent cache key for chart data
    /// - Parameters:
    ///   - timeRange: The time range (e.g., "1month", "3months", "all")
    ///   - page: The page number
    /// - Returns: String key in format "chart_timeRange_page_X"
    private func chartKey(for timeRange: String, page: Int) -> String {
        return "chart_\(timeRange)_page_\(page)"
    }
    
    /// Generates a consistent cache key for individual weights
    /// - Parameter weightId: The weight ID
    /// - Returns: String key in format "weight_X"
    private func weightKey(for weightId: Int) -> String {
        return "weight_\(weightId)"
    }
    
    /// Logs cache operations with consistent formatting
    /// - Parameter message: The message to log
    private func logCacheOperation(_ message: String) {
        print("[SMART CACHE] \(message)")
    }
    
    // MARK: - Memory Management
    
    /// Sets up memory management observers and notifications
    private func setupMemoryManagement() {
        // Listen for app termination
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAppTermination),
            name: NSApplication.willTerminateNotification,
            object: nil
        )
        
        // Listen for app becoming inactive (for memory cleanup)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAppInactive),
            name: NSApplication.didResignActiveNotification,
            object: nil
        )
        
        logCacheOperation("Memory management observers set up")
    }
    
    /// Updates the access order for LRU tracking
    /// - Parameter key: The cache key that was accessed
    private func updateAccessOrder(for key: String) {
        // Remove key if it exists
        if let index = accessOrder.firstIndex(of: key) {
            accessOrder.remove(at: index)
        }
        // Add to end (most recently used)
        accessOrder.append(key)
    }
    
    /// Performs cleanup if cache limits are exceeded
    private func performCleanupIfNeeded() {
        let currentMemoryUsage = calculateApproximateMemoryUsage()
        let totalCacheSize = tableCache.count + chartCache.count
        
        // Check if we need to cleanup based on size or memory
        if totalCacheSize > maxCacheSize || currentMemoryUsage > maxMemoryUsage {
            performLRUCleanup()
        }
    }
    
    /// Performs LRU cleanup to reduce cache size
    private func performLRUCleanup() {
        let totalCacheSize = tableCache.count + chartCache.count
        let targetSize = max(1, maxCacheSize * 3 / 4) // Clean to 75% of max size
        let itemsToRemove = totalCacheSize - targetSize
        
        guard itemsToRemove > 0 else { return }
        
        // Remove least recently used items
        let keysToRemove = Array(accessOrder.prefix(itemsToRemove))
        var tableItemsRemoved = 0
        var chartItemsRemoved = 0
        
        for key in keysToRemove {
            if key.hasPrefix("table_") {
                tableCache.removeValue(forKey: key)
                tableItemsRemoved += 1
            } else if key.hasPrefix("chart_") {
                chartCache.removeValue(forKey: key)
                chartItemsRemoved += 1
            }
            
            if let index = accessOrder.firstIndex(of: key) {
                accessOrder.remove(at: index)
            }
        }
        
        logCacheOperation("LRU cleanup performed: removed \(tableItemsRemoved) table pages and \(chartItemsRemoved) chart entries")
    }
    
    /// Handles app becoming inactive (memory cleanup opportunity)
    @objc private func handleAppInactive() {
        cacheQueue.async(flags: .barrier) {
            let currentMemoryUsage = self.calculateApproximateMemoryUsage()
            
            // If memory usage is high, perform cleanup
            if currentMemoryUsage > self.maxMemoryUsage / 2 {
                let previousTableCount = self.tableCache.count
                let previousChartCount = self.chartCache.count
                let totalCacheSize = previousTableCount + previousChartCount
                let targetSize = max(1, totalCacheSize / 2)
                let itemsToRemove = totalCacheSize - targetSize
                
                if itemsToRemove > 0 {
                    let keysToRemove = Array(self.accessOrder.prefix(itemsToRemove))
                    var tableItemsRemoved = 0
                    var chartItemsRemoved = 0
                    
                    for key in keysToRemove {
                        if key.hasPrefix("table_") {
                            self.tableCache.removeValue(forKey: key)
                            tableItemsRemoved += 1
                        } else if key.hasPrefix("chart_") {
                            self.chartCache.removeValue(forKey: key)
                            chartItemsRemoved += 1
                        }
                        
                        if let index = self.accessOrder.firstIndex(of: key) {
                            self.accessOrder.remove(at: index)
                        }
                    }
                    
                    self.logCacheOperation("App inactive cleanup: cleared \(tableItemsRemoved) table pages and \(chartItemsRemoved) chart entries")
                }
            }
        }
    }
    
    /// Handles app termination notifications
    @objc private func handleAppTermination() {
        cacheQueue.async(flags: .barrier) {
            let clearedTableCount = self.tableCache.count
            let clearedChartCount = self.chartCache.count
            let hadProgressCache = self.progressCache != nil
            
            self.tableCache.removeAll()
            self.chartCache.removeAll()
            self.progressCache = nil
            self.accessOrder.removeAll()
            
            let progressMessage = hadProgressCache ? " and progress data" : ""
            self.logCacheOperation("App termination cleanup: cleared \(clearedTableCount) table pages, \(clearedChartCount) chart entries\(progressMessage)")
        }
    }
    
    /// Clears cache manually (for logout scenarios)
    func clearCache() {
        cacheQueue.async(flags: .barrier) {
            let clearedTableCount = self.tableCache.count
            let clearedChartCount = self.chartCache.count
            let hadProgressCache = self.progressCache != nil
            
            self.tableCache.removeAll()
            self.chartCache.removeAll()
            self.progressCache = nil
            self.accessOrder.removeAll()
            
            let progressMessage = hadProgressCache ? " and progress data" : ""
            self.logCacheOperation("Manual cache clear: cleared \(clearedTableCount) table pages, \(clearedChartCount) chart entries\(progressMessage)")
        }
    }
    
    /// Handles memory pressure manually (can be called when memory usage is high)
    func handleMemoryPressure() {
        cacheQueue.async(flags: .barrier) {
            let previousTableCount = self.tableCache.count
            let previousChartCount = self.chartCache.count
            let totalCacheSize = previousTableCount + previousChartCount
            
            // Clear half of the cache during memory pressure
            let targetSize = max(1, totalCacheSize / 2)
            let itemsToRemove = totalCacheSize - targetSize
            
            if itemsToRemove > 0 {
                let keysToRemove = Array(self.accessOrder.prefix(itemsToRemove))
                var tableItemsRemoved = 0
                var chartItemsRemoved = 0
                
                for key in keysToRemove {
                    if key.hasPrefix("table_") {
                        self.tableCache.removeValue(forKey: key)
                        tableItemsRemoved += 1
                    } else if key.hasPrefix("chart_") {
                        self.chartCache.removeValue(forKey: key)
                        chartItemsRemoved += 1
                    }
                    
                    if let index = self.accessOrder.firstIndex(of: key) {
                        self.accessOrder.remove(at: index)
                    }
                }
                
                self.logCacheOperation("Memory pressure cleanup: cleared \(tableItemsRemoved) table pages and \(chartItemsRemoved) chart entries")
            }
        }
    }
}

// MARK: - Debug Support
extension CacheService {
    
    /// Provides cache status information for debugging
    /// - Returns: Dictionary with cache statistics
    func getCacheStatus() -> [String: Any] {
        return cacheQueue.sync {
            let memoryUsage = calculateApproximateMemoryUsage()
            let totalCacheSize = tableCache.count + chartCache.count
            let progressRecords = progressCache?.count ?? 0
            
            return [
                "totalTablePages": tableCache.count,
                "totalChartEntries": chartCache.count,
                "progressRecords": progressRecords,
                "hasProgressCache": progressCache != nil,
                "totalCacheItems": totalCacheSize,
                "maxCacheSize": maxCacheSize,
                "cachedTablePages": Array(tableCache.keys).sorted(),
                "cachedChartEntries": Array(chartCache.keys).sorted(),
                "memoryUsage": memoryUsage,
                "maxMemoryUsage": maxMemoryUsage,
                "memoryUsagePercentage": Double(memoryUsage) / Double(maxMemoryUsage) * 100,
                "accessOrder": accessOrder,
                "cacheUtilization": Double(totalCacheSize) / Double(maxCacheSize) * 100
            ]
        }
    }
    
    /// Calculates approximate memory usage of cached data
    /// - Returns: Estimated memory usage in bytes
    private func calculateApproximateMemoryUsage() -> Int {
        // Rough estimation for table cache: each Weight record ~500 bytes + pagination overhead
        let totalTableRecords = tableCache.values.reduce(0) { $0 + $1.data.count }
        let tableMemoryUsage = totalTableRecords * 500 + (tableCache.count * 200)
        
        // Rough estimation for chart cache: each WeightPoint ~100 bytes + pagination overhead
        let totalChartRecords = chartCache.values.reduce(0) { $0 + $1.data.count }
        let chartMemoryUsage = totalChartRecords * 100 + (chartCache.count * 150)
        
        // Rough estimation for progress cache: each ProgressResponse ~400 bytes (includes photo URLs)
        let progressRecords = progressCache?.count ?? 0
        let progressMemoryUsage = progressRecords * 400
        
        return tableMemoryUsage + chartMemoryUsage + progressMemoryUsage
    }
}