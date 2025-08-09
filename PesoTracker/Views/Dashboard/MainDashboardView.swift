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
    
    // Image zoom states - shared by table and modal
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
            
            // Modal overlays
            if showAddWeightModal {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        showAddWeightModal = false
                    }
                
                AddWeightModal(
                    isPresented: $showAddWeightModal, 
                    onSave: {
                        Task {
                            await dashboardViewModel.loadDashboardData()
                        }
                    },
                    onImageTap: { image in
                        fullscreenImage = image
                        fullscreenImageURL = nil
                        showFullscreenImageModal = true
                    },
                    onImageURLTap: { url in
                        fullscreenImageURL = url
                        fullscreenImage = nil
                        showFullscreenImageModal = true
                    }
                )
            }
            
            if showEditWeightModal {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        showEditWeightModal = false
                    }
                
                AddWeightModal(
                    isPresented: $showEditWeightModal,
                    isEditing: true,
                    selectedWeight: selectedWeight,
                    onSave: {
                        Task {
                            await dashboardViewModel.loadDashboardData()
                        }
                    },
                    onImageTap: { image in
                        fullscreenImage = image
                        fullscreenImageURL = nil
                        showFullscreenImageModal = true
                    },
                    onImageURLTap: { url in
                        fullscreenImageURL = url
                        fullscreenImage = nil
                        showFullscreenImageModal = true
                    }
                )
            }
            
            if showAddGoalModal {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        showAddGoalModal = false
                    }
                
                AddGoalModal(
                    isPresented: $showAddGoalModal,
                    onSave: {
                        Task {
                            await dashboardViewModel.loadDashboardData()
                        }
                    }
                )
            }
            
            if showEditGoalModal {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        showEditGoalModal = false
                    }
                
                AddGoalModal(
                    isPresented: $showEditGoalModal,
                    isEditing: true,
                    existingGoal: dashboardViewModel.activeGoal,
                    onSave: {
                        Task {
                            await dashboardViewModel.loadDashboardData()
                        }
                    }
                )
            }
            
            if showAdvancedSettingsModal {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        showAdvancedSettingsModal = false
                    }
                
                AdvancedSettingsModal(isPresented: $showAdvancedSettingsModal)
            }
            
            if showBMICalculatorModal {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        showBMICalculatorModal = false
                    }
                
                BMICalculatorModal(isPresented: $showBMICalculatorModal)
            }
            
            if showViewProgressModal {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        showViewProgressModal = false
                    }
                
                ViewProgressModal(isPresented: $showViewProgressModal)
            }
            
            if showDeleteConfirmationModal {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        showDeleteConfirmationModal = false
                    }
                
                DeleteConfirmationModal(
                    isPresented: $showDeleteConfirmationModal,
                    recordToDelete: selectedRecord,
                    onConfirm: {
                        Task {
                            await dashboardViewModel.handleWeightDeletion()
                        }
                    }
                )
            }
            
            if showImageZoomModal {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        showImageZoomModal = false
                    }
                
                if let imageURL = selectedImageURL {
                    ImageZoomModal(imageURL: imageURL, isPresented: $showImageZoomModal)
                }
            }
            
            // Fullscreen Image Modal - above everything
            if showFullscreenImageModal {
                if let image = fullscreenImage {
                    ImageZoomModal(image: image, isPresented: $showFullscreenImageModal)
                } else if let imageURL = fullscreenImageURL {
                    ImageZoomModal(imageURL: imageURL, isPresented: $showFullscreenImageModal)
                }
            }
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
        .overlay {
            if dashboardViewModel.isLoading {
                ZStack {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.2)
                        
                        Text("Cargando datos...")
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                    .padding(24)
                    .background(Color(NSColor.windowBackgroundColor))
                    .cornerRadius(12)
                    .shadow(radius: 10)
                }
            } else if isLoadingPhoto {
                ZStack {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 16) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .green))
                            .scaleEffect(1.2)
                        
                        Text("Cargando foto...")
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                    .padding(24)
                    .background(Color(NSColor.windowBackgroundColor))
                    .cornerRadius(12)
                    .shadow(radius: 10)
                }
            }
        }
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