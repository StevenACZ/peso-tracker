import SwiftUI

/// Manages all modal states and overlays for the dashboard
struct ModalManager: View {
    // Modal states
    @Binding var showAddWeightModal: Bool
    @Binding var showEditWeightModal: Bool
    @Binding var showAddGoalModal: Bool
    @Binding var showEditGoalModal: Bool
    @Binding var showAdvancedSettingsModal: Bool
    @Binding var showBMICalculatorModal: Bool
    @Binding var showViewProgressModal: Bool
    @Binding var showDeleteConfirmationModal: Bool
    @Binding var showImageZoomModal: Bool
    @Binding var showFullscreenImageModal: Bool
    
    // Data states
    @Binding var selectedRecord: WeightRecord?
    @Binding var selectedWeight: Weight?
    @Binding var selectedImageURL: URL?
    @Binding var fullscreenImage: NSImage?
    @Binding var fullscreenImageURL: URL?
    
    let dashboardViewModel: DashboardViewModel
    
    var body: some View {
        ZStack {
            // Add Weight Modal
            if showAddWeightModal {
                modalOverlay {
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
            
            // Edit Weight Modal
            if showEditWeightModal {
                modalOverlay {
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
            
            // Add Goal Modal
            if showAddGoalModal {
                modalOverlay {
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
            
            // Edit Goal Modal
            if showEditGoalModal {
                modalOverlay {
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
            
            // Advanced Settings Modal
            if showAdvancedSettingsModal {
                modalOverlay {
                    showAdvancedSettingsModal = false
                }
                
                AdvancedSettingsModal(isPresented: $showAdvancedSettingsModal)
            }
            
            // BMI Calculator Modal
            if showBMICalculatorModal {
                modalOverlay {
                    showBMICalculatorModal = false
                }
                
                BMICalculatorModal(isPresented: $showBMICalculatorModal)
            }
            
            // View Progress Modal
            if showViewProgressModal {
                modalOverlay {
                    showViewProgressModal = false
                }
                
                ViewProgressModal(isPresented: $showViewProgressModal)
            }
            
            // Delete Confirmation Modal
            if showDeleteConfirmationModal {
                modalOverlay {
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
            
            // Image Zoom Modal
            if showImageZoomModal {
                modalOverlay {
                    showImageZoomModal = false
                }
                
                if let imageURL = selectedImageURL {
                    ImageZoomModal(imageURL: imageURL, isPresented: $showImageZoomModal)
                }
            }
            
            // Fullscreen Image Modal
            if showFullscreenImageModal {
                if let image = fullscreenImage {
                    ImageZoomModal(image: image, isPresented: $showFullscreenImageModal)
                } else if let imageURL = fullscreenImageURL {
                    ImageZoomModal(imageURL: imageURL, isPresented: $showFullscreenImageModal)
                }
            }
        }
    }
    
    private func modalOverlay(onTap: @escaping () -> Void) -> some View {
        Color.black.opacity(0.3)
            .ignoresSafeArea()
            .onTapGesture {
                onTap()
            }
    }
}