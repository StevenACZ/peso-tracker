import Foundation

/// DateDecodingHelper - Utility centralizada para decodificar fechas ISO8601 de manera consistente
/// Consolida la lógica duplicada de decodificación de fechas en todos los models
class DateDecodingHelper {
    
    // MARK: - Singleton
    static let shared = DateDecodingHelper()
    private init() {}
    
    // MARK: - Formatters (Lazy initialization for performance)
    
    /// Formatter para fechas con microsegundos
    private lazy var formatterWithFractionalSeconds: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
    
    /// Formatter para fechas sin microsegundos (fallback)
    private lazy var formatterStandard: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()
    
    // MARK: - Core Decoding Methods
    
    /// Decodifica una fecha ISO8601 string aplicando DateNormalizer automáticamente
    /// Usado para fechas que representan días específicos (targetDate, date, etc.)
    /// - Parameters:
    ///   - dateString: String ISO8601 del API
    ///   - applyNormalization: Si aplicar DateNormalizer.normalizeFromAPI() (default: true)
    /// - Returns: Date normalizada para consistencia timezone
    func decodeNormalizedDate(from dateString: String, applyNormalization: Bool = true) -> Date {
        let rawDate = decodeRawDate(from: dateString)
        
        if applyNormalization {
            let normalized = DateNormalizer.shared.normalizeFromAPI(rawDate)
            
            #if DEBUG
            print("📅 [DATE DECODER] Normalized date:")
            print("   Raw: \(DateNormalizer.shared.debugDescription(for: rawDate))")
            print("   Normalized: \(DateNormalizer.shared.debugDescription(for: normalized))")
            #endif
            
            return normalized
        }
        
        return rawDate
    }
    
    /// Decodifica una fecha ISO8601 string sin aplicar normalización
    /// Usado para timestamps/metadata (createdAt, updatedAt, etc.)
    /// - Parameter dateString: String ISO8601 del API
    /// - Returns: Date raw sin normalización timezone
    func decodeTimestamp(from dateString: String) -> Date {
        return decodeRawDate(from: dateString)
    }
    
    /// Método interno para decodificar fecha raw con fallback automático
    /// - Parameter dateString: String ISO8601 del API
    /// - Returns: Date parseada con mejor formato disponible
    private func decodeRawDate(from dateString: String) -> Date {
        // Intentar primero con microsegundos
        if let date = formatterWithFractionalSeconds.date(from: dateString) {
            return date
        }
        
        // Fallback a formato estándar
        if let date = formatterStandard.date(from: dateString) {
            return date
        }
        
        // Último fallback - fecha actual si parsing falla
        print("⚠️ [DATE DECODER] Failed to parse date string: \(dateString), using current date")
        return Date()
    }
    
    // MARK: - Container Convenience Methods
    
    /// Decodifica fecha normalizada desde KeyedDecodingContainer
    /// - Parameters:
    ///   - container: Container del decoder
    ///   - key: CodingKey para la fecha
    ///   - applyNormalization: Si aplicar normalización (default: true)
    /// - Returns: Date decodificada y normalizada
    func decodeNormalizedDate<K: CodingKey>(
        from container: KeyedDecodingContainer<K>, 
        forKey key: K, 
        applyNormalization: Bool = true
    ) throws -> Date {
        let dateString = try container.decode(String.self, forKey: key)
        return decodeNormalizedDate(from: dateString, applyNormalization: applyNormalization)
    }
    
    /// Decodifica timestamp desde KeyedDecodingContainer
    /// - Parameters:
    ///   - container: Container del decoder
    ///   - key: CodingKey para el timestamp
    /// - Returns: Date timestamp sin normalización
    func decodeTimestamp<K: CodingKey>(
        from container: KeyedDecodingContainer<K>, 
        forKey key: K
    ) throws -> Date {
        let dateString = try container.decode(String.self, forKey: key)
        return decodeTimestamp(from: dateString)
    }
    
    // MARK: - Validation and Debugging
    
    /// Valida que una fecha string sea válida ISO8601
    /// - Parameter dateString: String a validar
    /// - Returns: true si es válida, false si no
    func isValidISO8601(_ dateString: String) -> Bool {
        return formatterWithFractionalSeconds.date(from: dateString) != nil ||
               formatterStandard.date(from: dateString) != nil
    }
    
    /// Convierte Date a string ISO8601 para debugging
    /// - Parameter date: Date a convertir
    /// - Returns: String ISO8601 representativo
    func debugString(from date: Date) -> String {
        return formatterWithFractionalSeconds.string(from: date)
    }
}

// MARK: - Convenience Extensions

extension KeyedDecodingContainer {
    
    /// Decodifica fecha normalizada usando DateDecodingHelper
    /// - Parameter key: CodingKey para la fecha
    /// - Returns: Date normalizada para consistency timezone
    func decodeNormalizedDate<CKey: CodingKey>(_ key: CKey) throws -> Date {
        return try DateDecodingHelper.shared.decodeNormalizedDate(from: self as! KeyedDecodingContainer<CKey>, forKey: key)
    }
    
    /// Decodifica timestamp usando DateDecodingHelper
    /// - Parameter key: CodingKey para el timestamp
    /// - Returns: Date timestamp sin normalización
    func decodeTimestamp<CKey: CodingKey>(_ key: CKey) throws -> Date {
        return try DateDecodingHelper.shared.decodeTimestamp(from: self as! KeyedDecodingContainer<CKey>, forKey: key)
    }
}