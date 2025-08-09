import SwiftUI

struct MainDashboardView: View {
    // MARK: - Properties
    @StateObject private var dashboardViewModel = DashboardViewModel()
    
    // Modal states
    @State private var showAddWeightModal = false
    @State private var showEditWeightModal = false
    @State private var showAddGoalModal = false
    @State private var showEditGoalModal = false
    @State private var showAdvancedSettingsModal = false
    @State private var showBMICalculatorModal = false
    @State private var showViewProgressModal = false
    @State private var showDeleteConfirmationModal = false
    @State private var showImageZoomModal = false
    @State private var isLoadingPhoto = false
    
    // Image zoom states
    @State private var showFullscreenImageModal = false
    @State private var fullscreenImage: NSImage?
    @State private var fullscreenImageURL: URL?
    
    // Selected record for editing/deleting
    @State private var selectedRecord: WeightRecord?
    @State private var selectedWeight: Weight?
    @State private var selectedImageURL: URL?
    
    var body: some View {
        ZStack {
            // Main content
            mainContent
            
            // Modal overlays
            ModalManager(
                showAddWeightModal: $showAddWeightModal,
                showEditWeightModal: $showEditWeightModal,
                showAddGoalModal: $showAddGoalModal,
                showEditGoalModal: $showEditGoalModal,
                showAdvancedSettingsModal: $showAdvancedSettingsModal,
                showBMICalculatorModal: $showBMICalculatorModal,
                showViewProgressModal: $showViewProgressModal,
                showDeleteConfirmationModal: $showDeleteConfirmationModal,
                showImageZoomModal: $showImageZoomModal,
                showFullscreenImageModal: $showFullscreenImageModal,
                selectedRecord: $selectedRecord,
                selectedWeight: $selectedWeight,
                selectedImageURL: $selectedImageURL,
                fullscreenImage: $fullscreenImage,
                fullscreenImageURL: $fullscreenImageURL,
                dashboardViewModel: dashboardViewModel
            )
            
            // Loading overlays
            LoadingOverlay(
                isLoading: dashboardViewModel.isLoading,
                isLoadingPhoto: isLoadingPhoto
            )
        }
        .onAppear {
            Task {
                await dashboardViewModel.loadDashboardData()
            }
        }
        .alert("Error", isPresented: $dashboardViewModel.showError) {
            Button("OK") {
                dashboardViewModel.dismissError()
            }
        } message: {
            Text(dashboardViewModel.error ?? "Error desconocido")
        }
    }
    
    // MARK: - Main Content
    private var mainContent: some View {
        HStack(spacing: 0) {
            // Left Panel - Summary (Sidebar)
            LeftSidebarPanel(
                viewModel: dashboardViewModel,
                onEditGoal: { showEditGoalModal = true },
                onAddGoal: { showAddGoalModal = true },
                onAdvancedSettings: { showAdvancedSettingsModal = true },
                onCalculateBMI: { showBMICalculatorModal = true },
                onLogout: { 
                    dashboardViewModel.logout()
                }
            )
            .frame(width: 350)
            .background(Color(NSColor.controlBackgroundColor))
            
            // Right Panel - Progress (Main content)
            RightContentPanel(
                viewModel: dashboardViewModel,
                onViewProgress: { showViewProgressModal = true },
                onAddWeight: { showAddWeightModal = true },
                onEditRecord: { weight in
                    selectedWeight = weight
                    showEditWeightModal = true
                },
                onDeleteRecord: { record in
                    selectedRecord = record
                    showDeleteConfirmationModal = true
                },
                onPhotoTap: { weightId in
                    Task {
                        await loadWeightPhotoFullscreen(weightId: weightId)
                    }
                }
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(NSColor.windowBackgroundColor))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.windowBackgroundColor))
        .clipped()
    }
    
    // MARK: - Helper Methods
    private func loadWeightPhoto(weightId: Int) async {
        isLoadingPhoto = true
        
        do {
            let weightService = WeightService()
            let weight = try await weightService.getWeight(id: weightId)
            
            if let photoURL = weight.photo?.fullUrl, let url = URL(string: photoURL) {
                selectedImageURL = url
                showImageZoomModal = true
            }
        } catch {
            print("Error loading weight photo: \(error)")
            // Could show an alert here if needed
        }
        
        isLoadingPhoto = false
    }
    
    private func loadWeightPhotoFullscreen(weightId: Int) async {
        isLoadingPhoto = true
        
        do {
            let weightService = WeightService()
            let weight = try await weightService.getWeight(id: weightId)
            
            if let photoURL = weight.photo?.fullUrl, let url = URL(string: photoURL) {
                fullscreenImageURL = url
                fullscreenImage = nil
                showFullscreenImageModal = true
            }
        } catch {
            print("Error loading weight photo: \(error)")
        }
        
        isLoadingPhoto = false
    }
}

// MARK: - Preview
#Preview {
    MainDashboardView()
}