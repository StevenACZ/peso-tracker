import Foundation

// MARK: - Auth Service
class AuthService: ObservableObject {
    
    // MARK: - Singleton
    static let shared = AuthService()
    
    // MARK: - Properties
    private let apiService = APIService.shared
    private let keychainHelper = KeychainHelper.shared
    
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isValidatingToken = false
    
    // MARK: - Initialization
    private init() {
        print("🔐 [AUTH SERVICE] Initializing authentication service")
        checkAuthenticationStatus()
    }
    
    // MARK: - Authentication Status
    private func checkAuthenticationStatus() {
        if let token = keychainHelper.get(key: Constants.Keychain.jwtToken),
           !token.isEmpty {
            print("🔐 [AUTH SERVICE] Token found in keychain - validating with server...")
            isValidatingToken = true
            
            // Validate token with server
            Task {
                let isValid = await validateTokenWithServer()
                await MainActor.run {
                    self.isValidatingToken = false
                    if isValid {
                        print("🔐 [AUTH SERVICE] Token validation successful")
                        self.isAuthenticated = true
                        // Load user data if available
                        self.loadCurrentUser()
                    } else {
                        print("🔐 [AUTH SERVICE] Token validation failed - performing auto-logout")
                        self.performAutoLogout()
                    }
                }
            }
        } else {
            print("🔐 [AUTH SERVICE] No valid token found")
            isValidatingToken = false
            isAuthenticated = false
            currentUser = nil
        }
    }
    
    private func loadCurrentUser() {
        if let userID = keychainHelper.get(key: Constants.Keychain.userID) {
            // Try to load user data from UserDefaults
            currentUser = loadUserDataLocally()
            print("🔐 [AUTH SERVICE] Loaded cached user data for ID: \(userID)")
        }
    }
    
    // MARK: - Token Validation
    private func validateTokenWithServer() async -> Bool {
        print("🔐 [AUTH SERVICE] Starting intelligent token validation...")
        
        // Step 1: Check if access token is expired locally
        if isAccessTokenExpired() {
            print("🔐 [AUTH SERVICE] Access token expired locally - attempting refresh")
            
            // Step 2: Check if we have a valid refresh token
            if hasValidRefreshToken() {
                do {
                    // Step 3: Attempt to refresh the token
                    let _ = try await refreshToken()
                    print("✅ [AUTH SERVICE] Token refreshed successfully during validation")
                    return true
                } catch {
                    print("❌ [AUTH SERVICE] Token refresh failed: \(error)")
                    return false
                }
            } else {
                print("❌ [AUTH SERVICE] No valid refresh token available")
                return false
            }
        }
        
        print("🔐 [AUTH SERVICE] Access token appears valid locally - skipping server validation")
        // Step 4: Token appears valid locally, no need for server call during loading
        // The auto-retry logic in HTTPClient will handle any 401s during actual API calls
        return true
        
        // Note: We could add a lightweight server validation here if needed:
        // But for loading performance, local JWT validation should be sufficient
        /*
        do {
            let _ = try await apiService.get(
                endpoint: "/weights/paginated?page=1&limit=1",
                responseType: PaginatedResponse<Weight>.self,
                requiresAuth: true
            )
            return true
        } catch {
            print("🔐 [AUTH SERVICE] Server validation failed: \(error)")
            
            // If server validation fails, try refresh once more
            if hasValidRefreshToken() {
                do {
                    let _ = try await refreshToken()
                    print("✅ [AUTH SERVICE] Token refreshed after server validation failure")
                    return true
                } catch {
                    print("❌ [AUTH SERVICE] Final token refresh attempt failed")
                    return false
                }
            }
            return false
        }
        */
    }
    
    // MARK: - Auto Logout
    private func performAutoLogout() {
        print("🔐 [AUTH SERVICE] Performing automatic logout due to invalid token")
        
        // Clear keychain
        keychainHelper.delete(key: Constants.Keychain.jwtToken)
        keychainHelper.delete(key: Constants.Keychain.refreshToken)
        keychainHelper.delete(key: Constants.Keychain.userID)
        
        // Update authentication state
        isAuthenticated = false
        currentUser = nil
        
        // Clear any cached data
        clearUserData()
        
        // Clear cache service
        CacheService.shared.clearCache()
        
        print("🔐 [AUTH SERVICE] Auto-logout completed - redirecting to login")
    }
    
    // MARK: - Public Auto Logout (for external services)
    @MainActor
    func forceLogoutDueToExpiredToken() {
        print("🔐 [AUTH SERVICE] Force logout triggered by expired token from API")
        performAutoLogout()
    }
    
    // MARK: - Login
    func login(email: String, password: String) async throws -> User {
        let loginRequest = LoginRequest(email: email, password: password)
        
        print("🔐 [LOGIN] Enviando request:")
        print("   Email: \(email)")
        print("   Password: [HIDDEN]")
        print("   Endpoint: \(Constants.API.baseURL)\(Constants.API.Endpoints.login)")
        
        do {
            let response = try await apiService.post(
                endpoint: Constants.API.Endpoints.login,
                body: loginRequest,
                responseType: AuthResponse.self,
                requiresAuth: false
            )
            
            print("✅ [LOGIN] Respuesta recibida:")
            print("   📧 Email: \(response.user.email)")
            print("   👤 Nombre: \(response.user.username)")
            print("   🔑 Token: \(response.token)")
            print("   User ID: \(response.user.id)")
            print("   Expires: \(response.expiresAt)")
            
            // Save tokens and user ID to keychain
            let accessTokenSaved = keychainHelper.save(key: Constants.Keychain.jwtToken, value: response.accessToken)
            let refreshTokenSaved = keychainHelper.save(key: Constants.Keychain.refreshToken, value: response.refreshToken)
            let userIDSaved = keychainHelper.save(key: Constants.Keychain.userID, value: response.user.id)
            
            guard accessTokenSaved && refreshTokenSaved && userIDSaved else {
                throw APIError.serverError(500, "Error al guardar credenciales")
            }
            
            // Save user data locally in UserDefaults
            saveUserDataLocally(user: response.user)
            
            // Update authentication state
            await MainActor.run {
                self.isAuthenticated = true
                self.currentUser = response.user
            }
            
            print("✅ [LOGIN] Login exitoso!")
            return response.user
            
        } catch {
            print("❌ [LOGIN] Error en login:")
            print("   Error: \(error)")
            
            // Ensure we're not authenticated on login failure
            await MainActor.run {
                self.isAuthenticated = false
                self.currentUser = nil
            }
            throw error
        }
    }
    
    // MARK: - Register
    func register(username: String, email: String, password: String) async throws -> User {
        let registerRequest = RegisterRequest(
            username: username,
            email: email,
            password: password
        )
        
        print("🔐 [REGISTER] Enviando request:")
        print("   Username: \(username)")
        print("   Email: \(email)")
        print("   Password: [HIDDEN]")
        print("   Endpoint: \(Constants.API.baseURL)\(Constants.API.Endpoints.register)")
        
        do {
            let response = try await apiService.post(
                endpoint: Constants.API.Endpoints.register,
                body: registerRequest,
                responseType: AuthResponse.self,
                requiresAuth: false
            )
            
            print("✅ [REGISTER] Respuesta recibida:")
            print("   📧 Email: \(response.user.email)")
            print("   👤 Nombre: \(response.user.username)")
            print("   🔑 Token: \(response.token)")
            print("   User ID: \(response.user.id)")
            print("   Expires: \(response.expiresAt)")
            
            // Save tokens and user ID to keychain
            let accessTokenSaved = keychainHelper.save(key: Constants.Keychain.jwtToken, value: response.accessToken)
            let refreshTokenSaved = keychainHelper.save(key: Constants.Keychain.refreshToken, value: response.refreshToken)
            let userIDSaved = keychainHelper.save(key: Constants.Keychain.userID, value: response.user.id)
            
            guard accessTokenSaved && refreshTokenSaved && userIDSaved else {
                throw APIError.serverError(500, "Error al guardar credenciales")
            }
            
            // Save user data locally in UserDefaults
            saveUserDataLocally(user: response.user)
            
            // Update authentication state
            await MainActor.run {
                self.isAuthenticated = true
                self.currentUser = response.user
            }
            
            print("✅ [REGISTER] Registro exitoso!")
            return response.user
            
        } catch {
            print("❌ [REGISTER] Error en registro:")
            print("   Error: \(error)")
            
            // Ensure we're not authenticated on registration failure
            await MainActor.run {
                self.isAuthenticated = false
                self.currentUser = nil
            }
            throw error
        }
    }
    
    // MARK: - Logout
    func logout() {
        // Clear keychain
        keychainHelper.delete(key: Constants.Keychain.jwtToken)
        keychainHelper.delete(key: Constants.Keychain.refreshToken)
        keychainHelper.delete(key: Constants.Keychain.userID)
        
        // Update authentication state
        isAuthenticated = false
        currentUser = nil
        
        // Clear any cached data
        clearUserData()
    }
    
    private func clearUserData() {
        // Clear UserDefaults if needed
        UserDefaults.standard.removeObject(forKey: Constants.UserDefaults.hasCompletedOnboarding)
        UserDefaults.standard.removeObject(forKey: Constants.UserDefaults.lastSyncDate)
        
        // Clear cached user data
        UserDefaults.standard.removeObject(forKey: Constants.UserDefaults.cachedUserData)
        UserDefaults.standard.removeObject(forKey: Constants.UserDefaults.cachedUsername)
        UserDefaults.standard.removeObject(forKey: Constants.UserDefaults.cachedUserEmail)
        UserDefaults.standard.removeObject(forKey: Constants.UserDefaults.cachedUserId)
        
        // Clear any other cached data
        // This could include clearing Core Data, cached images, etc.
    }
    
    // MARK: - Local User Data Management
    private func saveUserDataLocally(user: User) {
        print("💾 [AUTH SERVICE] Saving user data locally")
        
        // Save individual fields
        UserDefaults.standard.set(user.id, forKey: Constants.UserDefaults.cachedUserId)
        UserDefaults.standard.set(user.username, forKey: Constants.UserDefaults.cachedUsername)
        UserDefaults.standard.set(user.email, forKey: Constants.UserDefaults.cachedUserEmail)
        
        // Save complete user object as JSON
        do {
            let encoder = JSONEncoder()
            let userData = try encoder.encode(user)
            UserDefaults.standard.set(userData, forKey: Constants.UserDefaults.cachedUserData)
            print("✅ [AUTH SERVICE] User data saved successfully")
        } catch {
            print("❌ [AUTH SERVICE] Error saving user data: \(error)")
        }
    }
    
    private func loadUserDataLocally() -> User? {
        guard let userData = UserDefaults.standard.data(forKey: Constants.UserDefaults.cachedUserData) else {
            print("⚠️ [AUTH SERVICE] No cached user data found")
            return nil
        }
        
        do {
            let decoder = JSONDecoder()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = Constants.DateFormats.api
            dateFormatter.timeZone = TimeZone(identifier: "UTC")
            decoder.dateDecodingStrategy = .formatted(dateFormatter)
            
            let user = try decoder.decode(User.self, from: userData)
            print("✅ [AUTH SERVICE] Cached user data loaded successfully")
            return user
        } catch {
            print("❌ [AUTH SERVICE] Error loading cached user data: \(error)")
            return nil
        }
    }
    
    // MARK: - Token Management
    func getAuthToken() -> String? {
        return keychainHelper.get(key: Constants.Keychain.jwtToken)
    }
    
    func getRefreshToken() -> String? {
        return keychainHelper.get(key: Constants.Keychain.refreshToken)
    }
    
    func isTokenValid() -> Bool {
        guard let token = getAuthToken(), !token.isEmpty else {
            return false
        }
        
        // Basic token validation - in a real app you might want to decode JWT and check expiration
        // For now, we'll assume the token is valid if it exists
        return true
    }
    
    // MARK: - Local Token Validation
    func isAccessTokenExpired() -> Bool {
        guard let token = keychainHelper.get(key: Constants.Keychain.jwtToken),
              !token.isEmpty else {
            print("🔐 [AUTH SERVICE] No access token found - treating as expired")
            return true
        }
        
        return JWTHelper.isTokenExpired(token, bufferMinutes: 2)
    }
    
    func hasValidRefreshToken() -> Bool {
        if let refreshToken = keychainHelper.get(key: Constants.Keychain.refreshToken),
           !refreshToken.isEmpty {
            // Check if refresh token is expired (7 days typically)
            return !JWTHelper.isTokenExpired(refreshToken, bufferMinutes: 60) // 1 hour buffer
        }
        return false
    }
    
    // MARK: - Refresh Token
    func refreshToken() async throws -> RefreshTokenResponse {
        guard let refreshToken = getRefreshToken(), !refreshToken.isEmpty else {
            print("❌ [REFRESH TOKEN] No refresh token available in keychain")
            throw APIError.authenticationFailed
        }
        
        let request = RefreshTokenRequest(refreshToken: refreshToken)
        
        print("🔄 [REFRESH TOKEN] Iniciando proceso de renovación de token...")
        print("   🔑 Refresh Token: \(refreshToken.prefix(20))...")
        print("   🌐 Endpoint: \(Constants.API.baseURL)\(Constants.API.Endpoints.refresh)")
        print("   📤 Request Body: {\"refreshToken\": \"\(refreshToken.prefix(10))...\"}")
        
        do {
            let response = try await apiService.post(
                endpoint: Constants.API.Endpoints.refresh,
                body: request,
                responseType: RefreshTokenResponse.self,
                requiresAuth: false
            )
            
            print("✅ [REFRESH TOKEN] ¡Renovación de token exitosa!")
            print("   🆕 New Access Token: \(response.accessToken.prefix(20))...")
            print("   🔄 New Refresh Token: \(response.refreshToken.prefix(20))...")
            print("   ⏰ Expires In: \(response.expiresIn) seconds (\(response.expiresIn/60) minutes)")
            print("   🏷️ Token Type: \(response.tokenType ?? "Bearer")")
            
            // Save new tokens to keychain
            print("💾 [REFRESH TOKEN] Guardando nuevos tokens en keychain...")
            let accessTokenSaved = keychainHelper.save(key: Constants.Keychain.jwtToken, value: response.accessToken)
            let refreshTokenSaved = keychainHelper.save(key: Constants.Keychain.refreshToken, value: response.refreshToken)
            
            guard accessTokenSaved && refreshTokenSaved else {
                print("❌ [REFRESH TOKEN] Failed to save new tokens to keychain")
                print("   Access Token Saved: \(accessTokenSaved)")
                print("   Refresh Token Saved: \(refreshTokenSaved)")
                throw APIError.serverError(500, "Error al guardar tokens actualizados")
            }
            
            print("✅ [REFRESH TOKEN] Nuevos tokens guardados exitosamente en keychain")
            print("🔒 [REFRESH TOKEN] Proceso de renovación completado - usuario puede continuar sin interrupción")
            return response
            
        } catch {
            print("❌ [REFRESH TOKEN] Error en renovación de token:")
            print("   📝 Error Type: \(type(of: error))")
            print("   💬 Error Description: \(error)")
            
            if let apiError = error as? APIError {
                switch apiError {
                case .serverError(let code, let message):
                    print("   🌐 Server Error Code: \(code)")
                    print("   📄 Server Message: \(message ?? "No message")")
                case .networkError(let underlyingError):
                    print("   🌐 Network Error: \(underlyingError)")
                case .authenticationFailed:
                    print("   🔐 Authentication failed - refresh token inválido")
                case .tokenExpired:
                    print("   ⏰ Token expired - refresh token expirado")
                default:
                    print("   ❓ Other API Error: \(apiError)")
                }
            }
            
            // If refresh fails, perform auto-logout
            print("🚪 [REFRESH TOKEN] Iniciando auto-logout debido a fallo en renovación...")
            await MainActor.run {
                self.performAutoLogout()
            }
            
            throw error
        }
    }
    
    func refreshAuthenticationStatus() {
        checkAuthenticationStatus()
    }
    
    // Wait for token validation to complete
    func waitForTokenValidation() async {
        // If not validating, return immediately
        if !isValidatingToken { 
            print("🔐 [AUTH SERVICE] Token validation not in progress - returning immediately")
            return 
        }
        
        print("🔐 [AUTH SERVICE] Waiting for token validation to complete...")
        
        // Simple polling approach - more reliable than Combine + continuation
        while isValidatingToken {
            try? await Task.sleep(nanoseconds: 50_000_000) // 50ms
        }
        
        print("🔐 [AUTH SERVICE] Token validation wait completed")
    }
    
    // MARK: - Validation Helpers
    func validateEmail(_ email: String) -> Bool {
        let emailRegex = Constants.Validation.emailRegex
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    func validatePassword(_ password: String) -> Bool {
        return password.count >= Constants.Validation.minPasswordLength &&
               password.count <= Constants.Validation.maxPasswordLength
    }
    
    func validateUsername(_ username: String) -> Bool {
        return username.count >= Constants.Validation.minUsernameLength &&
               username.count <= Constants.Validation.maxUsernameLength &&
               !username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // MARK: - Availability Checking
    func checkAvailability(username: String? = nil, email: String? = nil) async throws -> AvailabilityResponse {
        var requestBody: [String: String] = [:]
        
        if let username = username, !username.isEmpty {
            requestBody["username"] = username
        }
        
        if let email = email, !email.isEmpty {
            requestBody["email"] = email
        }
        
        guard !requestBody.isEmpty else {
            throw APIError.invalidResponse
        }
        
        print("🔍 [AVAILABILITY] Checking availability:")
        if let username = username { print("   Username: \(username)") }
        if let email = email { print("   Email: \(email)") }
        
        do {
            let response = try await apiService.post(
                endpoint: "/auth/check-availability",
                body: requestBody,
                responseType: AvailabilityResponse.self,
                requiresAuth: false
            )
            
            print("✅ [AVAILABILITY] Response received:")
            if response.emailChecked {
                print("   Email available: \(response.emailAvailable)")
            }
            if response.usernameChecked {
                print("   Username available: \(response.usernameAvailable)")
            }
            
            return response
            
        } catch {
            print("❌ [AVAILABILITY] Error checking availability: \(error)")
            throw error
        }
    }
    
    // MARK: - Password Recovery
    func requestPasswordReset(email: String) async throws -> SuccessResponse {
        let request = PasswordResetRequest(email: email)
        
        print("🔐 [PASSWORD RESET] Requesting password reset:")
        print("   Email: \(email)")
        print("   Endpoint: \(Constants.API.baseURL)\(Constants.API.Endpoints.forgotPassword)")
        
        do {
            let response = try await apiService.post(
                endpoint: Constants.API.Endpoints.forgotPassword,
                body: request,
                responseType: SuccessResponse.self,
                requiresAuth: false
            )
            
            print("✅ [PASSWORD RESET] Request successful:")
            print("   Message: \(response.message)")
            
            return response
            
        } catch {
            print("❌ [PASSWORD RESET] Error requesting password reset:")
            print("   Error: \(error)")
            throw error
        }
    }
    
    func verifyResetCode(email: String, code: String) async throws -> CodeVerificationResponse {
        let request = CodeVerificationRequest(email: email, code: code)
        
        print("🔐 [CODE VERIFICATION] Verifying reset code:")
        print("   Email: \(email)")
        print("   Code: \(code)")
        print("   Endpoint: \(Constants.API.baseURL)\(Constants.API.Endpoints.verifyResetCode)")
        
        do {
            let response = try await apiService.post(
                endpoint: Constants.API.Endpoints.verifyResetCode,
                body: request,
                responseType: CodeVerificationResponse.self,
                requiresAuth: false
            )
            
            print("✅ [CODE VERIFICATION] Verification successful:")
            print("   Valid: \(response.valid)")
            print("   ResetToken: \(response.resetToken)")
            
            return response
            
        } catch {
            print("❌ [CODE VERIFICATION] Error verifying reset code:")
            print("   Error: \(error)")
            throw error
        }
    }
    
    func resetPassword(token: String, newPassword: String) async throws -> SuccessResponse {
        let request = ResetPasswordRequest(token: token, newPassword: newPassword)
        
        print("🔐 [RESET PASSWORD] Resetting password with token:")
        print("   Token: \(token.prefix(20))...")
        print("   Password: [HIDDEN]")
        print("   Endpoint: \(Constants.API.baseURL)\(Constants.API.Endpoints.resetPassword)")
        
        do {
            let response = try await apiService.post(
                endpoint: Constants.API.Endpoints.resetPassword,
                body: request,
                responseType: SuccessResponse.self,
                requiresAuth: false
            )
            
            print("✅ [RESET PASSWORD] Password reset successful:")
            print("   Message: \(response.message)")
            
            return response
            
        } catch {
            print("❌ [RESET PASSWORD] Error resetting password:")
            print("   Error: \(error)")
            throw error
        }
    }
    
    // MARK: - Error Handling
    func handleAuthError(_ error: Error) -> String {
        if let apiError = error as? APIError {
            switch apiError {
            case .authenticationFailed:
                return "Credenciales incorrectas. Verifica tu email y contraseña."
            case .serverError(let code, let message):
                if code == 400 {
                    if let msg = message, msg.lowercased().contains("email") {
                        return "Formato de email inválido."
                    } else if let msg = message, msg.lowercased().contains("username") {
                        return "El nombre de usuario debe tener entre 3 y 50 caracteres y solo contener letras, números y guiones bajos."
                    } else if let msg = message, msg.lowercased().contains("password") {
                        return "La contraseña debe tener entre 6 y 100 caracteres."
                    }
                    return "Datos inválidos. Revisa los campos."
                } else if code == 409 {
                    return "Este email o nombre de usuario ya está registrado."
                } else {
                    return "Error del servidor. Intenta más tarde."
                }
            case .networkError(_):
                return "Error de conexión. Verifica tu internet."
            case .noData:
                return "No se recibieron datos del servidor."
            case .decodingError(_):
                return "Error al procesar la respuesta del servidor."
            case .tokenExpired:
                return "Tu sesión ha expirado. Por favor inicia sesión nuevamente."
            case .invalidResponse:
                return "Respuesta inválida del servidor."
            case .invalidURL:
                return "Error de configuración del servidor."
            case .encodingError(_):
                return "Error al procesar la solicitud."
            }
        }
        return "Error de autenticación: \(error.localizedDescription)"
    }
    
    // MARK: - Password Recovery Error Handling
    func handlePasswordRecoveryError(_ error: Error) -> String {
        if let apiError = error as? APIError {
            switch apiError {
            case .serverError(let code, let message):
                return handlePasswordRecoveryServerError(code: code, message: message)
            case .networkError(let underlyingError):
                return handlePasswordRecoveryNetworkError(underlyingError)
            case .noData:
                return "No se recibió respuesta del servidor. Verifica tu conexión e intenta nuevamente."
            case .decodingError(_):
                return "Error al procesar la respuesta del servidor. Intenta más tarde."
            case .tokenExpired:
                return "La sesión ha expirado. Inicia el proceso nuevamente."
            case .invalidResponse:
                return "Respuesta inválida del servidor. Intenta más tarde."
            case .invalidURL:
                return "Error de configuración del servidor. Contacta soporte técnico."
            case .encodingError(_):
                return "Error al procesar la solicitud. Verifica los datos e intenta nuevamente."
            case .authenticationFailed:
                return "Error de autenticación. Inicia el proceso nuevamente."
            }
        }
        
        // Handle URLError specifically
        if let urlError = error as? URLError {
            return handlePasswordRecoveryURLError(urlError)
        }
        
        return "Error en recuperación de contraseña: \(error.localizedDescription)"
    }
    
    private func handlePasswordRecoveryServerError(code: Int, message: String?) -> String {
        switch code {
        case 400:
            return handleBadRequestError(message: message)
        case 401:
            return "No autorizado. Inicia el proceso nuevamente."
        case 403:
            return "Acceso denegado. Verifica tu información."
        case 404:
            return "No se encontró una cuenta con este email. Verifica que el email sea correcto."
        case 409:
            return "Conflicto en el servidor. Intenta más tarde."
        case 422:
            return "Datos inválidos. Verifica la información ingresada."
        case 429:
            return "Demasiados intentos. Espera 5 minutos antes de intentar nuevamente."
        case 500:
            return "Error interno del servidor. Intenta más tarde."
        case 502:
            return "Servidor no disponible temporalmente. Intenta más tarde."
        case 503:
            return "Servicio no disponible. Intenta más tarde."
        case 504:
            return "Tiempo de espera agotado. Intenta más tarde."
        default:
            return "Error del servidor (\(code)). Intenta más tarde."
        }
    }
    
    private func handleBadRequestError(message: String?) -> String {
        guard let msg = message?.lowercased() else {
            return "Datos inválidos. Verifica la información ingresada."
        }
        
        if msg.contains("email") && msg.contains("not found") {
            return "No se encontró una cuenta con este email. Verifica que el email sea correcto."
        } else if msg.contains("email") && msg.contains("invalid") {
            return "El formato del email es inválido. Ingresa un email válido."
        } else if msg.contains("code") && msg.contains("invalid") {
            return "El código ingresado es incorrecto. Verifica el código e intenta nuevamente."
        } else if msg.contains("code") && msg.contains("expired") {
            return "El código ha expirado. Solicita un nuevo código."
        } else if msg.contains("code") && msg.contains("used") {
            return "Este código ya ha sido utilizado. Solicita un nuevo código."
        } else if msg.contains("attempts") || msg.contains("maximum") {
            return "Has excedido el número máximo de intentos. Espera 15 minutos antes de intentar nuevamente."
        } else if msg.contains("password") && msg.contains("weak") {
            return "La contraseña es muy débil. Usa al menos \(Constants.Validation.minPasswordLength) caracteres con letras y números."
        } else if msg.contains("password") && msg.contains("length") {
            return "La contraseña debe tener entre \(Constants.Validation.minPasswordLength) y \(Constants.Validation.maxPasswordLength) caracteres."
        } else if msg.contains("password") && msg.contains("requirements") {
            return "La contraseña no cumple con los requisitos de seguridad."
        } else if msg.contains("rate") && msg.contains("limit") {
            return "Demasiadas solicitudes. Espera unos minutos antes de intentar nuevamente."
        } else if msg.contains("blocked") || msg.contains("suspended") {
            return "Tu cuenta ha sido temporalmente bloqueada. Contacta soporte técnico."
        }
        
        return "Datos inválidos. Verifica la información ingresada."
    }
    
    private func handlePasswordRecoveryNetworkError(_ error: Error) -> String {
        if let urlError = error as? URLError {
            return handlePasswordRecoveryURLError(urlError)
        }
        return "Error de conexión. Verifica tu internet e intenta nuevamente."
    }
    
    private func handlePasswordRecoveryURLError(_ urlError: URLError) -> String {
        switch urlError.code {
        case .notConnectedToInternet:
            return "No hay conexión a internet. Verifica tu conexión y vuelve a intentar."
        case .timedOut:
            return "La conexión ha expirado. Verifica tu conexión e intenta nuevamente."
        case .cannotFindHost:
            return "No se puede encontrar el servidor. Verifica tu conexión e intenta más tarde."
        case .cannotConnectToHost:
            return "No se puede conectar al servidor. Intenta más tarde."
        case .networkConnectionLost:
            return "Se perdió la conexión de red. Verifica tu conexión e intenta nuevamente."
        case .dnsLookupFailed:
            return "Error de DNS. Verifica tu conexión e intenta nuevamente."
        case .httpTooManyRedirects:
            return "Error de servidor. Intenta más tarde."
        case .resourceUnavailable:
            return "Servicio no disponible temporalmente. Intenta más tarde."
        case .notConnectedToInternet:
            return "Sin conexión a internet. Conecta a una red e intenta nuevamente."
        case .redirectToNonExistentLocation:
            return "Error de configuración del servidor. Intenta más tarde."
        case .badServerResponse:
            return "Respuesta inválida del servidor. Intenta más tarde."
        case .userCancelledAuthentication:
            return "Autenticación cancelada. Intenta nuevamente."
        case .userAuthenticationRequired:
            return "Se requiere autenticación. Inicia el proceso nuevamente."
        case .zeroByteResource:
            return "Respuesta vacía del servidor. Intenta más tarde."
        case .cannotDecodeRawData:
            return "Error al procesar la respuesta del servidor."
        case .cannotDecodeContentData:
            return "Error al decodificar la respuesta del servidor."
        case .cannotParseResponse:
            return "Error al interpretar la respuesta del servidor."
        case .internationalRoamingOff:
            return "Roaming internacional desactivado. Activa el roaming o conecta a WiFi."
        case .callIsActive:
            return "Llamada activa. Finaliza la llamada e intenta nuevamente."
        case .dataNotAllowed:
            return "Datos móviles desactivados. Activa los datos o conecta a WiFi."
        case .requestBodyStreamExhausted:
            return "Error en la solicitud. Intenta nuevamente."
        default:
            return "Error de conexión (\(urlError.code.rawValue)). Verifica tu internet e intenta nuevamente."
        }
    }
}