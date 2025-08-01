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
    private var accessOrder: [String] = [] // For LRU tracking
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
            let previousCount = self.tableCache.count
            self.tableCache.removeAll()
            self.accessOrder.removeAll()
            self.logCacheOperation("Cache invalidated after weight change (cleared \(previousCount) pages)")
        }
    }
    
    // MARK: - Private Methods
    
    /// Generates a consistent cache key for table pages
    /// - Parameter page: The page number
    /// - Returns: String key in format "table_page_X"
    private func tableKey(for page: Int) -> String {
        return "table_page_\(page)"
    }
    
    /// Logs cache operations with consistent formatting
    /// - Parameter message: The message to log
    private func logCacheOperation(_ message: String) {
        print("[TABLE CACHE] \(message)")
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
        let currentCacheSize = tableCache.count
        
        // Check if we need to cleanup based on size or memory
        if currentCacheSize > maxCacheSize || currentMemoryUsage > maxMemoryUsage {
            performLRUCleanup()
        }
    }
    
    /// Performs LRU cleanup to reduce cache size
    private func performLRUCleanup() {
        let targetSize = max(1, maxCacheSize * 3 / 4) // Clean to 75% of max size
        let itemsToRemove = tableCache.count - targetSize
        
        guard itemsToRemove > 0 else { return }
        
        // Remove least recently used items
        let keysToRemove = Array(accessOrder.prefix(itemsToRemove))
        
        for key in keysToRemove {
            tableCache.removeValue(forKey: key)
            if let index = accessOrder.firstIndex(of: key) {
                accessOrder.remove(at: index)
            }
        }
        
        logCacheOperation("LRU cleanup performed: removed \(keysToRemove.count) pages")
    }
    
    /// Handles app becoming inactive (memory cleanup opportunity)
    @objc private func handleAppInactive() {
        cacheQueue.async(flags: .barrier) {
            let currentMemoryUsage = self.calculateApproximateMemoryUsage()
            
            // If memory usage is high, perform cleanup
            if currentMemoryUsage > self.maxMemoryUsage / 2 {
                let previousCount = self.tableCache.count
                let targetSize = max(1, self.tableCache.count / 2)
                let itemsToRemove = self.tableCache.count - targetSize
                
                if itemsToRemove > 0 {
                    let keysToRemove = Array(self.accessOrder.prefix(itemsToRemove))
                    
                    for key in keysToRemove {
                        self.tableCache.removeValue(forKey: key)
                        if let index = self.accessOrder.firstIndex(of: key) {
                            self.accessOrder.remove(at: index)
                        }
                    }
                    
                    self.logCacheOperation("App inactive cleanup: cleared \(keysToRemove.count) of \(previousCount) pages")
                }
            }
        }
    }
    
    /// Handles app termination notifications
    @objc private func handleAppTermination() {
        cacheQueue.async(flags: .barrier) {
            let clearedCount = self.tableCache.count
            self.tableCache.removeAll()
            self.accessOrder.removeAll()
            self.logCacheOperation("App termination cleanup: cleared \(clearedCount) pages")
        }
    }
    
    /// Clears cache manually (for logout scenarios)
    func clearCache() {
        cacheQueue.async(flags: .barrier) {
            let clearedCount = self.tableCache.count
            self.tableCache.removeAll()
            self.accessOrder.removeAll()
            self.logCacheOperation("Manual cache clear: cleared \(clearedCount) pages")
        }
    }
    
    /// Handles memory pressure manually (can be called when memory usage is high)
    func handleMemoryPressure() {
        cacheQueue.async(flags: .barrier) {
            let previousCount = self.tableCache.count
            
            // Clear half of the cache during memory pressure
            let targetSize = max(1, self.tableCache.count / 2)
            let itemsToRemove = self.tableCache.count - targetSize
            
            if itemsToRemove > 0 {
                let keysToRemove = Array(self.accessOrder.prefix(itemsToRemove))
                
                for key in keysToRemove {
                    self.tableCache.removeValue(forKey: key)
                    if let index = self.accessOrder.firstIndex(of: key) {
                        self.accessOrder.remove(at: index)
                    }
                }
                
                self.logCacheOperation("Memory pressure cleanup: cleared \(keysToRemove.count) of \(previousCount) pages")
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
            return [
                "totalPages": tableCache.count,
                "maxCacheSize": maxCacheSize,
                "cachedPages": Array(tableCache.keys).sorted(),
                "memoryUsage": memoryUsage,
                "maxMemoryUsage": maxMemoryUsage,
                "memoryUsagePercentage": Double(memoryUsage) / Double(maxMemoryUsage) * 100,
                "accessOrder": accessOrder,
                "cacheUtilization": Double(tableCache.count) / Double(maxCacheSize) * 100
            ]
        }
    }
    
    /// Calculates approximate memory usage of cached data
    /// - Returns: Estimated memory usage in bytes
    private func calculateApproximateMemoryUsage() -> Int {
        // Rough estimation: each Weight record ~500 bytes + pagination overhead
        let totalRecords = tableCache.values.reduce(0) { $0 + $1.data.count }
        return totalRecords * 500 + (tableCache.count * 200) // 200 bytes overhead per page
    }
}