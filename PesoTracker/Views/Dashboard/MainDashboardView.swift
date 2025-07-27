import SwiftUI

struct MainDashboardView: View {
    // MARK: - Properties
    @StateObject private var authViewModel = AuthViewModel()
    @State private var selectedTimeRange = "1 semana"
    @State private var hasData = false // Toggle this to show empty/filled state
    
    // Modal states
    @State private var showAddWeightModal = false
    @State private var showEditWeightModal = false
    @State private var showAddGoalModal = false
    @State private var showEditGoalModal = false
    @State private var showAdvancedSettingsModal = false
    @State private var showViewProgressModal = false
    @State private var showDeleteConfirmationModal = false
    
    // Selected record for editing/deleting
    @State private var selectedRecord: WeightRecord?
    
    // Sample data - replace with real data later
    private let sampleRecords = [
        WeightRecord(date: "2024-01-15", weight: "82 kg", notes: "Punto de partida", hasPhoto: false),
        WeightRecord(date: "2024-02-15", weight: "80 kg", notes: "Actualización primer mes", hasPhoto: true),
        WeightRecord(date: "2024-03-15", weight: "78 kg", notes: "Actualización segundo mes", hasPhoto: false)
    ]
    
    var body: some View {
        ZStack {
            // Main content
            HStack(spacing: 0) {
                // Left Panel - Summary (Sidebar)
                LeftSidebarPanel(
                    hasData: hasData,
                    onEditGoal: { showEditGoalModal = true },
                    onAddGoal: { showAddGoalModal = true },
                    onAdvancedSettings: { showAdvancedSettingsModal = true },
                    onLogout: { 
                        // TODO: Handle logout logic
                        print("Logout pressed")
                    }
                )
                .frame(width: 350)
                .background(Color(NSColor.controlBackgroundColor))
                
                // Right Panel - Progress (Main content)
                RightContentPanel(
                    hasData: hasData,
                    records: hasData ? sampleRecords : [],
                    selectedTimeRange: $selectedTimeRange,
                    onViewProgress: { showViewProgressModal = true },
                    onAddWeight: { showAddWeightModal = true },
                    onEditRecord: { record in
                        selectedRecord = record
                        showEditWeightModal = true
                    },
                    onDeleteRecord: { record in
                        selectedRecord = record
                        showDeleteConfirmationModal = true
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
                
                AddWeightModal(isPresented: $showAddWeightModal)
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
                    record: selectedRecord
                )
            }
            
            if showAddGoalModal {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        showAddGoalModal = false
                    }
                
                AddGoalModal(isPresented: $showAddGoalModal)
            }
            
            if showEditGoalModal {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        showEditGoalModal = false
                    }
                
                AddGoalModal(isPresented: $showEditGoalModal, isEditing: true)
            }
            
            if showAdvancedSettingsModal {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        showAdvancedSettingsModal = false
                    }
                
                AdvancedSettingsModal(isPresented: $showAdvancedSettingsModal)
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
                        // TODO: Delete record logic
                        print("Deleting record: \(selectedRecord?.weight ?? "")")
                    }
                )
            }
        }
    }
}

// MARK: - Preview
#Preview {
    MainDashboardView()
}