import Foundation

// MARK: - URL Helper Utility
struct URLHelper {
    
    // MARK: - Photo URL Transformation
    /// Transforms hardcoded photo URLs to use the correct base URL based on current environment
    /// - Parameter originalURL: The URL string received from the API (potentially with hardcoded server)
    /// - Returns: Transformed URL string using the correct base URL from configuration
    static func transformPhotoURL(_ originalURL: String) -> String {
        // If the URL is already using the correct base URL, return as-is
        let currentBaseURL = Constants.API.baseURL
        if originalURL.hasPrefix(currentBaseURL) {
            return originalURL
        }
        
        // Extract the photo path from the original URL
        if let photoPath = extractPhotoPath(from: originalURL) {
            return "\(currentBaseURL)\(photoPath)"
        }
        
        // If we can't extract a path, return the original URL
        return originalURL
    }
    
    // MARK: - Private Helper Methods
    
    /// Extracts the photo path from a URL (e.g., "/photos/secure/token")
    /// - Parameter url: The complete URL string
    /// - Returns: The photo path starting with "/" or nil if not found
    private static func extractPhotoPath(from url: String) -> String? {
        // Look for common photo path patterns
        let photoPathPatterns = [
            "/photos/secure/",
            "/photos/"
        ]
        
        for pattern in photoPathPatterns {
            if let range = url.range(of: pattern) {
                let startIndex = url.index(url.startIndex, offsetBy: url.distance(from: url.startIndex, to: range.lowerBound))
                return String(url[startIndex...])
            }
        }
        
        return nil
    }
    
    // MARK: - URL Validation
    
    /// Validates if a URL string is properly formatted
    /// - Parameter urlString: The URL string to validate
    /// - Returns: True if the URL is valid, false otherwise
    static func isValidURL(_ urlString: String) -> Bool {
        return URL(string: urlString) != nil
    }
    
    /// Creates a URL from a string, with fallback handling
    /// - Parameter urlString: The URL string
    /// - Returns: URL object or nil if invalid
    static func createURL(from urlString: String) -> URL? {
        return URL(string: urlString)
    }
}