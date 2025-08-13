import Foundation
import SwiftUI
import Combine

@MainActor
class AuthViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false
    
    // MARK: - Form Fields
    @Published var loginEmail = ""
    @Published var loginPassword = ""
    @Published var registerUsername = ""
    @Published var registerEmail = ""
    @Published var registerPassword = ""
    @Published var confirmPassword = ""
    
    // MARK: - Validation States
    @Published var isLoginFormValid = false
    @Published var isRegisterFormValid = false
    @Published var emailValidationError: String?
    @Published var passwordValidationError: String?
    @Published var usernameValidationError: String?
    @Published var confirmPasswordError: String?
    @Published var loginEmailError: String?
    @Published var loginPasswordError: String?
    
    // MARK: - Real-time Validation States
    @Published var emailValidationState: AuthTextField.ValidationState = .none
    @Published var usernameValidationState: AuthTextField.ValidationState = .none
    @Published var passwordValidationState: AuthTextField.ValidationState = .none
    @Published var loginEmailValidationState: AuthTextField.ValidationState = .none
    @Published var loginPasswordValidationState: AuthTextField.ValidationState = .none
    
    // MARK: - Availability Checking
    @Published var isCheckingEmailAvailability = false
    @Published var isCheckingUsernameAvailability = false
    
    // MARK: - Error Modal
    @Published var showErrorModal = false
    @Published var errorModalMessage = ""
    
    // MARK: - Services
    private let authService = AuthService.shared
    
    // MARK: - Debouncing
    private var cancellables = Set<AnyCancellable>()
    private var emailCheckTask: Task<Void, Never>?
    private var usernameCheckTask: Task<Void, Never>?
    
    // MARK: - Initialization
    init() {
        // Observe authentication state from AuthService
        authService.$isAuthenticated
            .assign(to: &$isAuthenticated)
        
        authService.$currentUser
            .assign(to: &$currentUser)
        
        // Setup form validation
        setupFormValidation()
    }
    
    // MARK: - Form Validation Setup
    private func setupFormValidation() {
        // Login form validation
        Publishers.CombineLatest($loginEmail, $loginPassword)
            .map { email, password in
                !email.isEmpty && !password.isEmpty && self.authService.validateEmail(email) && self.authService.validatePassword(password)
            }
            .assign(to: &$isLoginFormValid)
        
        // Register form validation
        Publishers.CombineLatest4($registerUsername, $registerEmail, $registerPassword, $usernameValidationState)
            .combineLatest($emailValidationState, $passwordValidationState)
            .map { formData, emailState, passwordState in
                let (username, email, password, usernameState) = formData
                return !username.isEmpty &&
                       !email.isEmpty &&
                       !password.isEmpty &&
                       usernameState == .valid &&
                       emailState == .valid &&
                       passwordState == .valid
            }
            .assign(to: &$isRegisterFormValid)
        
        // Real-time login email validation
        $loginEmail
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] email in
                self?.validateLoginEmail(email)
            }
            .store(in: &cancellables)
        
        // Real-time login password validation
        $loginPassword
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] password in
                self?.validateLoginPassword(password)
            }
            .store(in: &cancellables)
        
        // Real-time register email validation with availability check
        $registerEmail
            .debounce(for: .milliseconds(800), scheduler: DispatchQueue.main)
            .sink { [weak self] email in
                self?.validateRegisterEmail(email)
            }
            .store(in: &cancellables)
        
        // Real-time username validation with availability check
        $registerUsername
            .debounce(for: .milliseconds(800), scheduler: DispatchQueue.main)
            .sink { [weak self] username in
                self?.validateUsername(username)
            }
            .store(in: &cancellables)
        
        // Real-time password validation
        $registerPassword
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] password in
                self?.validatePassword(password)
            }
            .store(in: &cancellables)
        
        // Confirm password validation
        Publishers.CombineLatest($registerPassword, $confirmPassword)
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] password, confirmPassword in
                self?.validateConfirmPassword(password: password, confirmPassword: confirmPassword)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Real-time Validation Methods
    
    private func validateLoginEmail(_ email: String) {
        if email.isEmpty {
            loginEmailError = nil
            loginEmailValidationState = .none
        } else if !authService.validateEmail(email) {
            loginEmailError = "Formato de email inválido"
            loginEmailValidationState = .invalid
        } else {
            loginEmailError = nil
            loginEmailValidationState = .valid
        }
    }
    
    private func validateLoginPassword(_ password: String) {
        if password.isEmpty {
            loginPasswordError = nil
            loginPasswordValidationState = .none
        } else if !authService.validatePassword(password) {
            loginPasswordError = "La contraseña debe tener entre \(Constants.Validation.minPasswordLength) y \(Constants.Validation.maxPasswordLength) caracteres"
            loginPasswordValidationState = .invalid
        } else {
            loginPasswordError = nil
            loginPasswordValidationState = .valid
        }
    }
    
    private func validateRegisterEmail(_ email: String) {
        // Cancel previous task
        emailCheckTask?.cancel()
        
        if email.isEmpty {
            emailValidationError = nil
            emailValidationState = .none
            return
        }
        
        // First validate format
        if !authService.validateEmail(email) {
            emailValidationError = "Formato de email inválido"
            emailValidationState = .invalid
            return
        }
        
        // Only check availability if email seems complete (has @ and .)
        if !email.contains("@") || !email.contains(".") {
            emailValidationError = nil
            emailValidationState = .none
            return
        }
        
        // Additional check: make sure there's something after the dot
        let components = email.split(separator: ".")
        if components.isEmpty || components.last!.count < 2 {
            emailValidationError = nil
            emailValidationState = .none
            return
        }
        
        // Then check availability
        emailValidationState = .checking
        isCheckingEmailAvailability = true
        
        emailCheckTask = Task { @MainActor in
            do {
                let response = try await authService.checkAvailability(email: email)
                
                if !Task.isCancelled {
                    if response.emailChecked && response.emailAvailable {
                        emailValidationError = nil
                        emailValidationState = .valid
                    } else if response.emailChecked && !response.emailAvailable {
                        emailValidationError = "Este email ya está registrado"
                        emailValidationState = .invalid
                    } else {
                        // If not checked or API didn't return email info, consider it valid format-wise
                        emailValidationError = nil
                        emailValidationState = .valid
                    }
                }
            } catch {
                if !Task.isCancelled {
                    print("❌ Email availability check error: \(error)")
                    // Don't show error to user for API failures - just treat as valid format-wise
                    emailValidationError = nil
                    emailValidationState = .valid
                }
            }
            isCheckingEmailAvailability = false
        }
    }
    
    private func validateUsername(_ username: String) {
        // Cancel previous task
        usernameCheckTask?.cancel()
        
        if username.isEmpty {
            usernameValidationError = nil
            usernameValidationState = .none
            return
        }
        
        // Only proceed if username has minimum length (don't check partial usernames)
        if username.count < Constants.Validation.minUsernameLength {
            usernameValidationError = nil
            usernameValidationState = .none
            return
        }
        
        // First validate format
        if !authService.validateUsername(username) {
            usernameValidationError = "El nombre de usuario debe tener entre 3 y 50 caracteres y solo contener letras, números y guiones bajos"
            usernameValidationState = .invalid
            return
        }
        
        // Then check availability
        usernameValidationState = .checking
        isCheckingUsernameAvailability = true
        
        usernameCheckTask = Task { @MainActor in
            do {
                let response = try await authService.checkAvailability(username: username)
                
                if !Task.isCancelled {
                    if response.usernameChecked && response.usernameAvailable {
                        usernameValidationError = nil
                        usernameValidationState = .valid
                    } else if response.usernameChecked && !response.usernameAvailable {
                        usernameValidationError = "Este nombre de usuario ya está en uso"
                        usernameValidationState = .invalid
                    } else {
                        // If not checked or API didn't return username info, consider it valid format-wise
                        usernameValidationError = nil
                        usernameValidationState = .valid
                    }
                }
            } catch {
                if !Task.isCancelled {
                    print("❌ Username availability check error: \(error)")
                    // Don't show error to user for API failures - just treat as valid format-wise
                    usernameValidationError = nil
                    usernameValidationState = .valid
                }
            }
            isCheckingUsernameAvailability = false
        }
    }
    
    private func validatePassword(_ password: String) {
        if password.isEmpty {
            passwordValidationError = nil
            passwordValidationState = .none
        } else if !authService.validatePassword(password) {
            passwordValidationError = "La contraseña debe tener entre \(Constants.Validation.minPasswordLength) y \(Constants.Validation.maxPasswordLength) caracteres"
            passwordValidationState = .invalid
        } else {
            passwordValidationError = nil
            passwordValidationState = .valid
        }
    }
    
    private func validateConfirmPassword(password: String, confirmPassword: String) {
        if confirmPassword.isEmpty {
            confirmPasswordError = nil
        } else if password != confirmPassword {
            confirmPasswordError = "Las contraseñas no coinciden"
        } else {
            confirmPasswordError = nil
        }
    }
    
    // MARK: - Authentication Methods
    
    func login() async {
        guard isLoginFormValid else {
            showErrorModal(message: "Por favor completa todos los campos correctamente")
            return
        }
        
        isLoading = true
        clearError()
        
        do {
            let user = try await authService.login(email: loginEmail, password: loginPassword)
            
            // Clear form on successful login
            clearLoginForm()
            
            print("Login exitoso para usuario: \(user.username)")
            
        } catch {
            showErrorModal(message: authService.handleAuthError(error))
        }
        
        isLoading = false
    }
    
    func register() async {
        guard isRegisterFormValid else {
            showErrorModal(message: "Por favor completa todos los campos correctamente")
            return
        }
        
        isLoading = true
        clearError()
        
        do {
            let user = try await authService.register(
                username: registerUsername,
                email: registerEmail,
                password: registerPassword
            )
            
            // Clear form on successful registration
            clearRegisterForm()
            
            print("Registro exitoso para usuario: \(user.username)")
            
        } catch {
            showErrorModal(message: authService.handleAuthError(error))
        }
        
        isLoading = false
    }
    
    func logout() {
        authService.logout()
        clearAllForms()
        print("Usuario desconectado")
    }
    
    // MARK: - Helper Methods
    
    private func showErrorMessage(_ message: String) {
        errorMessage = message
        showError = true
    }
    
    private func showErrorModal(message: String) {
        errorModalMessage = message
        showErrorModal = true
    }
    
    private func clearError() {
        errorMessage = nil
        showError = false
        errorModalMessage = ""
        showErrorModal = false
    }
    
    private func clearLoginForm() {
        loginEmail = ""
        loginPassword = ""
        loginEmailError = nil
        loginPasswordError = nil
        loginEmailValidationState = .none
        loginPasswordValidationState = .none
    }
    
    private func clearRegisterForm() {
        registerUsername = ""
        registerEmail = ""
        registerPassword = ""
        confirmPassword = ""
        
        // Clear validation states
        emailValidationError = nil
        passwordValidationError = nil
        usernameValidationError = nil
        confirmPasswordError = nil
        emailValidationState = .none
        usernameValidationState = .none
        passwordValidationState = .none
        
        // Cancel any running tasks
        emailCheckTask?.cancel()
        usernameCheckTask?.cancel()
    }
    
    private func clearAllForms() {
        clearLoginForm()
        clearRegisterForm()
    }
    
    // MARK: - Public Methods for Form Access
    
    func dismissErrorModal() {
        showErrorModal = false
        errorModalMessage = ""
    }
    
    // MARK: - Authentication Status
    
    func checkAuthenticationStatus() async {
        // Refresh authentication status from keychain
        authService.refreshAuthenticationStatus()
        
        // Wait for any ongoing token validation to complete
        await authService.waitForTokenValidation()
        
        // Now check the final authentication state
        isAuthenticated = authService.isAuthenticated
        currentUser = authService.currentUser
        
        if isAuthenticated {
            print("🔐 [AUTH] User authenticated successfully")
        } else {
            print("🔐 [AUTH] User not authenticated")
        }
    }
    
    func isTokenValid() -> Bool {
        return authService.isTokenValid()
    }
    
    // MARK: - Auto-logout on token expiration
    func handleTokenExpiration() {
        showErrorMessage("Tu sesión ha expirado. Por favor inicia sesión nuevamente.")
        logout()
    }
}