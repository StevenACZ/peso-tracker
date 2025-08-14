import Foundation
import Combine

/// BaseServiceProtocol - Define common service capabilities without forcing inheritance
protocol BaseServiceProtocol {
    var isLoading: Bool { get }
    var error: String? { get }
    func clearError()
}

/// ServiceUtilities - Static utilities for services
/// Provides common patterns without inheritance requirements
class ServiceUtilities {
    
    // MARK: - Error Handling Utilities
    
    /// Convert API errors to user-friendly Spanish messages
    static func handleError(_ error: Error) -> String {
        print("🔴 [SERVICE ERROR]: \(error)")
        
        // Convert technical errors to user-friendly messages
        if let apiError = error as? APIError {
            return apiError.localizedDescription
        } else {
            // Extract meaningful message from generic errors
            let errorMessage = error.localizedDescription
            
            // Common error pattern handling
            if errorMessage.contains("Internet connection appears to be offline") {
                return "Sin conexión a internet"
            } else if errorMessage.contains("timeout") {
                return "Tiempo de espera agotado"
            } else if errorMessage.contains("SSL") || errorMessage.contains("certificate") {
                return "Error de seguridad en la conexión"
            } else {
                return "Error inesperado: \(errorMessage)"
            }
        }
    }
    
    // MARK: - Loading State Utilities
    
    /// Execute async operation with loading state management
    @MainActor
    static func executeWithLoading<T>(
        setLoading: @escaping (Bool) -> Void,
        setError: @escaping (String?) -> Void,
        operation: @escaping () async throws -> T,
        onSuccess: @escaping (T) -> Void = { _ in },
        onError: @escaping (Error) -> Void = { _ in }
    ) async {
        setLoading(true)
        setError(nil)
        
        do {
            let result = try await operation()
            onSuccess(result)
        } catch {
            let errorMessage = handleError(error)
            setError(errorMessage)
            onError(error)
        }
        
        setLoading(false)
    }
    
    /// Execute async operation that returns a value
    @MainActor
    static func executeWithResult<T>(
        setLoading: @escaping (Bool) -> Void,
        setError: @escaping (String?) -> Void,
        operation: @escaping () async throws -> T
    ) async -> Result<T, Error> {
        setLoading(true)
        setError(nil)
        
        defer { setLoading(false) }
        
        do {
            let result = try await operation()
            return .success(result)
        } catch {
            let errorMessage = handleError(error)
            setError(errorMessage)
            return .failure(error)
        }
    }
    
    // MARK: - Network Monitoring Utilities
    
    /// Setup basic network monitoring for a service
    static func setupNetworkMonitoring(
        updateConnectivity: @escaping (Bool) -> Void,
        cancellables: inout Set<AnyCancellable>
    ) {
        // Basic network state monitoring
        // Could be enhanced with actual network reachability checking
        Timer.publish(every: 30.0, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                // Simplified connectivity check
                updateConnectivity(true)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Cache Utilities
    
    /// Simplified cache invalidation utilities
    static func invalidateCache(key: String) {
        // Simplified cache invalidation
        print("🗑️ [CACHE] Invalidating cache key: \(key)")
        // Could integrate with CacheService.shared if needed
    }
    
    /// Clear multiple cache keys
    static func invalidateCaches(keys: [String]) {
        for key in keys {
            invalidateCache(key: key)
        }
    }
}

// MARK: - Service State Utilities

extension ServiceUtilities {
    
    /// Check if service can perform actions
    static func canPerformActions(isLoading: Bool, isConnected: Bool = true) -> Bool {
        return !isLoading && isConnected
    }
    
    /// Get display-friendly error message
    static func displayError(_ error: String?) -> String {
        return error ?? "Error desconocido"
    }
    
    /// Check if service has error
    static func hasError(_ error: String?) -> Bool {
        return error != nil
    }
}

// MARK: - Common Service Protocols

/// Protocol for services that manage cached data
protocol CacheableService {
    var cacheKeys: [String] { get }
    func clearCache()
    func refreshCache() async
}

/// Protocol for services that require authentication
protocol AuthenticatedService {
    var requiresAuthentication: Bool { get }
    func handleAuthenticationFailure()
}

/// Protocol for services with real-time updates
protocol RealtimeService {
    func startRealTimeUpdates()
    func stopRealTimeUpdates()
    var isListeningForUpdates: Bool { get set }
}

// MARK: - Default Implementations

extension CacheableService {
    func clearCache() {
        for key in cacheKeys {
            ServiceUtilities.invalidateCache(key: key)
        }
    }
}

extension AuthenticatedService {
    var requiresAuthentication: Bool { return true }
    
    func handleAuthenticationFailure() {
        // Default implementation - services can override
        print("🔐 [AUTH] Authentication failure detected")
    }
}