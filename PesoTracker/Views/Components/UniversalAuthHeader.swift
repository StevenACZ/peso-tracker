import SwiftUI

/// Universal Auth Header - Consolidates LoginHeader, RegisterHeader, and other auth headers
/// Supports customizable title, subtitle, and spacing
struct UniversalAuthHeader: View {
    let title: String
    let subtitle: String?
    let spacing: CGFloat
    let titleFontSize: CGFloat
    
    /// Default auth header (similar to existing pattern)
    init(title: String, subtitle: String? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.spacing = 8
        self.titleFontSize = 28
    }
    
    /// Custom spacing and font size
    init(title: String, subtitle: String? = nil, spacing: CGFloat, titleFontSize: CGFloat = 28) {
        self.title = title
        self.subtitle = subtitle
        self.spacing = spacing
        self.titleFontSize = titleFontSize
    }
    
    var body: some View {
        // Special layout for app header (logo + title like original AuthHeader)
        if title.isEmpty && subtitle == nil {
            appHeaderLayout
        } else {
            // Regular content header layout
            contentHeaderLayout
        }
    }
    
    // MARK: - Layout Variants
    
    private var appHeaderLayout: some View {
        VStack {
            Spacer()
            
            HStack {
                Spacer()
                
                // Logo centered
                HStack(spacing: 8) {
                    Image("AppLogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                    
                    Text("PesoTracker")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                }
                
                Spacer()
            }
            
            Spacer()
        }
        .frame(height: 70)
        .padding(.top, 25)
        .background(Color(NSColor.windowBackgroundColor))
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(Color(NSColor.separatorColor)),
            alignment: .bottom
        )
    }
    
    private var contentHeaderLayout: some View {
        VStack(spacing: spacing) {
            Text(title)
                .font(.system(size: titleFontSize, weight: .semibold))
                .foregroundColor(.primary)
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Convenience Factories
extension UniversalAuthHeader {
    /// Login header (legacy LoginHeader compatibility)
    static var login: UniversalAuthHeader {
        UniversalAuthHeader(
            title: "Bienvenido de nuevo",
            subtitle: "Inicia sesión para continuar a tu panel."
        )
    }
    
    /// Register header (legacy RegisterHeader compatibility)  
    static var register: UniversalAuthHeader {
        UniversalAuthHeader(
            title: "Crea tu cuenta"
        )
    }
    
    /// Forgot password header
    static var forgotPassword: UniversalAuthHeader {
        UniversalAuthHeader(
            title: "Recuperar Contraseña",
            subtitle: "Te enviaremos un código de recuperación."
        )
    }
    
    /// Code verification header
    static var codeVerification: UniversalAuthHeader {
        UniversalAuthHeader(
            title: "Verificar Código",
            subtitle: "Ingresa el código que enviamos a tu email."
        )
    }
    
    /// Reset password header
    static var resetPassword: UniversalAuthHeader {
        UniversalAuthHeader(
            title: "Nueva Contraseña",
            subtitle: "Crea una nueva contraseña segura."
        )
    }
    
    /// App header - Simple logo + title layout like original AuthHeader
    static var appHeader: UniversalAuthHeader {
        UniversalAuthHeader(title: "", subtitle: nil) // We'll override the body
    }
    
    /// Custom header
    static func custom(title: String, subtitle: String? = nil, spacing: CGFloat = 8, fontSize: CGFloat = 28) -> UniversalAuthHeader {
        UniversalAuthHeader(title: title, subtitle: subtitle, spacing: spacing, titleFontSize: fontSize)
    }
}

// MARK: - Previews
#Preview("Login Header") {
    VStack {
        UniversalAuthHeader.login
        Spacer()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color(NSColor.windowBackgroundColor))
}

#Preview("Register Header") {
    VStack {
        UniversalAuthHeader.register
        Spacer()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color(NSColor.windowBackgroundColor))
}

#Preview("Forgot Password Header") {
    VStack {
        UniversalAuthHeader.forgotPassword
        Spacer()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color(NSColor.windowBackgroundColor))
}

#Preview("Custom Header") {
    VStack {
        UniversalAuthHeader.custom(
            title: "Custom Title",
            subtitle: "This is a custom subtitle with different styling.",
            spacing: 16,
            fontSize: 32
        )
        Spacer()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color(NSColor.windowBackgroundColor))
}