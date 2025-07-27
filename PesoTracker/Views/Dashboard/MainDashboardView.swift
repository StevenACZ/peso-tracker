import SwiftUI

struct MainDashboardView: View {
    
    // MARK: - Properties
    @StateObject private var authViewModel = AuthViewModel()
    @State private var selectedTab = 0
    
    var body: some View {
        GeometryReader { geometry in
            if geometry.size.width > 800 {
                // Desktop layout - side by side panels
                desktopLayout(geometry: geometry)
            } else {
                // Mobile/compact layout - tabbed interface
                compactLayout
            }
        }
        .navigationTitle("PesoTracker")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button("Configuración") {
                        // TODO: Open settings
                    }
                    
                    Divider()
                    
                    Button("Cerrar Sesión", role: .destructive) {
                        authViewModel.logout()
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
    }
    
    // MARK: - Desktop Layout
    private func desktopLayout(geometry: GeometryProxy) -> some View {
        HStack(spacing: 0) {
            // Left Panel - Summary (35%)
            SummaryPanelView()
                .frame(width: geometry.size.width * Constants.UI.dashboardLeftPanelRatio)
                .background(.regularMaterial)
            
            // Divider
            Divider()
            
            // Right Panel - Data (65%)
            DataPanelView()
                .frame(width: geometry.size.width * Constants.UI.dashboardRightPanelRatio)
                .background(.regularMaterial)
        }
    }
    
    // MARK: - Compact Layout
    private var compactLayout: some View {
        TabView(selection: $selectedTab) {
            SummaryPanelView()
                .tabItem {
                    Image(systemName: "person.circle")
                    Text("Resumen")
                }
                .tag(0)
            
            DataPanelView()
                .tabItem {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                    Text("Progreso")
                }
                .tag(1)
        }
    }
}

// MARK: - Summary Panel View (Placeholder)
struct SummaryPanelView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Resumen Personal")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top)
            
            Spacer()
            
            VStack(spacing: 16) {
                Text("Peso Inicial: --")
                    .font(.subheadline)
                
                Text("Peso Actual: --")
                    .font(.subheadline)
                
                Text("Pérdida Total: --")
                    .font(.subheadline)
                
                Text("Promedio Semanal: --")
                    .font(.subheadline)
            }
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(12)
            
            Spacer()
            
            VStack(spacing: 12) {
                Button("Nueva Meta") {
                    // TODO: Implement
                }
                .buttonStyle(.borderedProminent)
                
                Button("Milestone") {
                    // TODO: Implement
                }
                .buttonStyle(.bordered)
                
                Button("Ver Progreso") {
                    // TODO: Implement
                }
                .buttonStyle(.bordered)
            }
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - Data Panel View (Placeholder)
struct DataPanelView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Datos de Progreso")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top)
            
            Spacer()
            
            VStack {
                Text("Gráfico de Progreso")
                    .font(.headline)
                    .padding()
                
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .frame(height: 200)
                    .cornerRadius(12)
                    .overlay(
                        Text("Gráfico aquí")
                            .foregroundColor(.secondary)
                    )
            }
            
            Spacer()
            
            VStack {
                Text("Tabla de Pesos")
                    .font(.headline)
                    .padding()
                
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .frame(height: 300)
                    .cornerRadius(12)
                    .overlay(
                        Text("Tabla aquí")
                            .foregroundColor(.secondary)
                    )
            }
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - Preview
#Preview {
    NavigationView {
        MainDashboardView()
    }
}