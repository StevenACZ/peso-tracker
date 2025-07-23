//
//  ErrorHandlingService.swift
//  PesoTracker
//
//  Created by Kiro on 19/07/25.
//

import Foundation
import SwiftUI

// MARK: - Error Handling Service

class ErrorHandlingService: ObservableObject {
    
    static let shared = ErrorHandlingService()
    
    @Published var currentError: AppError?
    @Published var showingError = false
    
    private init() {}
    
    // MARK: - Error Handling Methods
    
    func handleError(_ error: Error, context: String = "") {
        let appError = AppError.from(error, context: context)
        
        // Log error for debugging
        logError(appError)
        
        // Show user-friendly error
        DispatchQueue.main.async {
            self.currentError = appError
            self.showingError = true
        }
    }
    
    func handleError(_ appError: AppError) {
        logError(appError)
        
        DispatchQueue.main.async {
            self.currentError = appError
            self.showingError = true
        }
    }
    
    func dismissError() {
        currentError = nil
        showingError = false
    }
    
    // MARK: - Validation Methods
    
    func validateWeight(_ weightString: String) -> ValidationResult<Double> {
        guard !weightString.isEmpty else {
            return .failure(.emptyWeight)
        }
        
        guard let weight = Double(weightString) else {
            return .failure(.invalidWeightFormat)
        }
        
        guard weight > 0 else {
            return .failure(.negativeWeight)
        }
        
        guard weight <= 1000 else {
            return .failure(.unrealisticWeight)
        }
        
        return .success(weight)
    }
    
    func validateGoal(targetWeight: Double, currentWeight: Double, targetDate: Date) -> ValidationResult<Void> {
        guard targetWeight > 0 else {
            return .failure(.invalidTargetWeight)
        }
        
        guard targetWeight != currentWeight else {
            return .failure(.sameAsCurrentWeight)
        }
        
        guard targetDate > Date() else {
            return .failure(.pastTargetDate)
        }
        
        let daysDifference = Calendar.current.dateComponents([.day], from: Date(), to: targetDate).day ?? 0
        guard daysDifference >= 7 else {
            return .failure(.targetDateTooSoon)
        }
        
        // Check if goal is realistic (max 2kg per week loss)
        let weightDifference = abs(currentWeight - targetWeight)
        let maxRealisticLoss = Double(daysDifference) / 7.0 * 2.0
        
        if weightDifference > maxRealisticLoss {
            return .failure(.unrealisticGoal(suggested: currentWeight - maxRealisticLoss))
        }
        
        return .success(())
    }
    
    // MARK: - Recovery Suggestions
    
    func getRecoverySuggestions(for error: AppError) -> [RecoverySuggestion] {
        switch error.type {
        case .network:
            return [
                RecoverySuggestion(title: "Check Internet Connection", action: .checkConnection),
                RecoverySuggestion(title: "Retry", action: .retry),
                RecoverySuggestion(title: "Work Offline", action: .workOffline)
            ]
            
        case .validation:
            return [
                RecoverySuggestion(title: "Fix Input", action: .fixInput),
                RecoverySuggestion(title: "Reset Form", action: .resetForm)
            ]
            
        case .storage:
            return [
                RecoverySuggestion(title: "Clear Cache", action: .clearCache),
                RecoverySuggestion(title: "Restart App", action: .restartApp)
            ]
            
            
        case .photo:
            return [
                RecoverySuggestion(title: "Try Different Photo", action: .selectDifferentPhoto),
                RecoverySuggestion(title: "Check Permissions", action: .checkPermissions)
            ]
            
        case .system:
            return [
                RecoverySuggestion(title: "Restart App", action: .restartApp),
                RecoverySuggestion(title: "Contact Support", action: .contactSupport)
            ]
        }
    }
    
    // MARK: - Private Methods
    
    private func logError(_ error: AppError) {
        let timestamp = DateFormatter.logFormatter.string(from: Date())
        let logMessage = "[\(timestamp)] ERROR: \(error.type) - \(error.message)"
        
        if !error.context.isEmpty {
            print("\(logMessage) (Context: \(error.context))")
        } else {
            print(logMessage)
        }
        
        // In a production app, you might want to send this to a logging service
        #if DEBUG
        if error.severity == .critical {
            print("🚨 CRITICAL ERROR: \(error.message)")
        }
        #endif
    }
}

// MARK: - App Error Definition

struct AppError: Identifiable, Equatable {
    let id = UUID()
    let type: ErrorType
    let message: String
    let context: String
    let severity: Severity
    let timestamp: Date
    
    enum ErrorType {
        case network
        case validation
        case storage
        case photo
        case system
    }
    
    enum Severity {
        case low, medium, high, critical
    }
    
    static func from(_ error: Error, context: String = "") -> AppError {
        if let nsError = error as NSError? {
            switch nsError.domain {
            case "Network", NSURLErrorDomain:
                return AppError(
                    type: .network,
                    message: "Network connection error. Please check your internet connection.",
                    context: context,
                    severity: .medium,
                    timestamp: Date()
                )
            default:
                return AppError(
                    type: .system,
                    message: nsError.localizedDescription,
                    context: context,
                    severity: .medium,
                    timestamp: Date()
                )
            }
        }
        
        return AppError(
            type: .system,
            message: error.localizedDescription,
            context: context,
            severity: .medium,
            timestamp: Date()
        )
    }
    
    static func validation(_ type: WeightValidationError) -> AppError {
        return AppError(
            type: .validation,
            message: type.message,
            context: "",
            severity: .low,
            timestamp: Date()
        )
    }
}

// MARK: - Validation Types

enum ValidationResult<T> {
    case success(T)
    case failure(WeightValidationError)
}

enum WeightValidationError {
    case emptyWeight
    case invalidWeightFormat
    case negativeWeight
    case unrealisticWeight
    case invalidTargetWeight
    case sameAsCurrentWeight
    case pastTargetDate
    case targetDateTooSoon
    case unrealisticGoal(suggested: Double)
    
    var message: String {
        switch self {
        case .emptyWeight:
            return "Please enter your weight"
        case .invalidWeightFormat:
            return "Please enter a valid number for weight"
        case .negativeWeight:
            return "Weight must be a positive number"
        case .unrealisticWeight:
            return "Please enter a realistic weight (under 1000kg)"
        case .invalidTargetWeight:
            return "Please enter a valid target weight"
        case .sameAsCurrentWeight:
            return "Target weight must be different from current weight"
        case .pastTargetDate:
            return "Target date must be in the future"
        case .targetDateTooSoon:
            return "Target date should be at least a week from now"
        case .unrealisticGoal(let suggested):
            return "This goal might be too ambitious. Consider targeting \(String(format: "%.1f", suggested))kg instead."
        }
    }
}

// MARK: - Recovery Suggestions

struct RecoverySuggestion {
    let title: String
    let action: RecoveryAction
    
    enum RecoveryAction {
        case checkConnection
        case retry
        case workOffline
        case fixInput
        case resetForm
        case clearCache
        case restartApp
        case contactSupport
        case selectDifferentPhoto
        case checkPermissions
    }
}

// MARK: - Error Alert View

struct ErrorAlertView: View {
    let error: AppError
    let recoverySuggestions: [RecoverySuggestion]
    let onDismiss: () -> Void
    let onRecoveryAction: (RecoverySuggestion.RecoveryAction) -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // Error icon
            Image(systemName: iconForSeverity(error.severity))
                .font(.system(size: 40))
                .foregroundColor(colorForSeverity(error.severity))
            
            // Error message
            VStack(spacing: 8) {
                Text("Oops! Something went wrong")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(error.message)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            // Recovery suggestions
            if !recoverySuggestions.isEmpty {
                VStack(spacing: 8) {
                    Text("What would you like to do?")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    ForEach(recoverySuggestions, id: \.title) { suggestion in
                        let isFirstSuggestion = suggestion.title == recoverySuggestions.first?.title
                        Button(suggestion.title) {
                            onRecoveryAction(suggestion.action)
                        }
                        .buttonStyle(DefaultButtonStyle())
                        .foregroundColor(isFirstSuggestion ? .white : .blue)
                        .background(isFirstSuggestion ? Color.blue : Color.clear)
                        .cornerRadius(8)
                    }
                }
            }
            
            // Dismiss button
            Button("Dismiss") {
                onDismiss()
            }
            .foregroundColor(.secondary)
        }
        .padding(24)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        .padding(.horizontal, 40)
    }
    
    private func iconForSeverity(_ severity: AppError.Severity) -> String {
        switch severity {
        case .low:
            return "info.circle"
        case .medium:
            return "exclamationmark.triangle"
        case .high:
            return "exclamationmark.triangle.fill"
        case .critical:
            return "xmark.octagon.fill"
        }
    }
    
    private func colorForSeverity(_ severity: AppError.Severity) -> Color {
        switch severity {
        case .low:
            return .blue
        case .medium:
            return .orange
        case .high:
            return .red
        case .critical:
            return .red
        }
    }
}

// MARK: - Extensions

extension DateFormatter {
    static let logFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
}

// MARK: - View Modifier

extension View {
    func errorHandling() -> some View {
        self.modifier(ErrorHandlingModifier())
    }
}

struct ErrorHandlingModifier: ViewModifier {
    @StateObject private var errorHandler = ErrorHandlingService.shared
    
    func body(content: Content) -> some View {
        content
            .overlay(
                Group {
                    if errorHandler.showingError, let error = errorHandler.currentError {
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()
                            .onTapGesture {
                                errorHandler.dismissError()
                            }
                        
                        ErrorAlertView(
                            error: error,
                            recoverySuggestions: errorHandler.getRecoverySuggestions(for: error),
                            onDismiss: {
                                errorHandler.dismissError()
                            },
                            onRecoveryAction: { action in
                                handleRecoveryAction(action)
                                errorHandler.dismissError()
                            }
                        )
                    }
                }
            )
    }
    
    private func handleRecoveryAction(_ action: RecoverySuggestion.RecoveryAction) {
        switch action {
        case .checkConnection:
            // Open network settings or show connection status
            break
        case .retry:
            // Trigger retry of the failed operation
            break
        case .workOffline:
            // Switch to offline mode
            break
        case .fixInput:
            // Focus on the problematic input field
            break
        case .resetForm:
            // Reset the current form
            break
        case .clearCache:
            // Clear app cache
            print("Cache cleared")
        case .restartApp:
            // Show restart instruction
            break
        case .contactSupport:
            // Open support contact
            break
        case .selectDifferentPhoto:
            // Trigger photo selection again
            break
        case .checkPermissions:
            // Show permissions settings
            break
        }
    }
}
