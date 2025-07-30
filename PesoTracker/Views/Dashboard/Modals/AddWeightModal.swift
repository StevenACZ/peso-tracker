import SwiftUI
import UniformTypeIdentifiers

struct AddWeightModal: View {
    @Binding var isPresented: Bool
    let isEditing: Bool
    let record: WeightRecord?
    let selectedWeight: Weight?
    let onSave: (() -> Void)?
    
    @StateObject private var viewModel = WeightEntryViewModel()
    
    init(isPresented: Binding<Bool>, isEditing: Bool = false, record: WeightRecord? = nil, selectedWeight: Weight? = nil, onSave: (() -> Void)? = nil) {
        self._isPresented = isPresented
        self.isEditing = isEditing
        self.record = record
        self.selectedWeight = selectedWeight
        self.onSave = onSave
    }
    
    var body: some View {
        VStack(spacing: 24) {
            ModalHeader(isEditing: isEditing, isPresented: $isPresented)
            
            if viewModel.isLoadingData {
                loadingContent
            } else {
                formContent
                FormActionButtons(viewModel: viewModel, isPresented: $isPresented, onSave: onSave)
            }
        }
        .padding(24)
        .frame(width: 480)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
        .onAppear {
            if isEditing {
                if let weight = selectedWeight {
                    // Use the new simplified method with photo endpoint
                    Task {
                        await viewModel.loadExistingWeightSimple(weight)
                    }
                } else if let record = record {
                    // Fallback to WeightRecord (limited photo info)
                    viewModel.loadExistingWeight(record)
                }
            } else {
                viewModel.resetForm()
            }
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.errorMessage = nil
            }
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
    }
    
    
    // MARK: - Loading Content
    
    private var loadingContent: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.2)
            
            Text("Cargando datos...")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
        .frame(height: 200)
    }
    
    // MARK: - Form Content
    
    private var formContent: some View {
        VStack(spacing: 20) {
            // Date and Weight Row
            VStack(spacing: 8) {
                HStack(spacing: 16) {
                    DatePickerSection(viewModel: viewModel)
                        .frame(maxWidth: .infinity)
                    
                    WeightInputSection(viewModel: viewModel)
                        .frame(maxWidth: .infinity)
                }
                
                // Validation Errors Row
                ValidationErrorsSection(viewModel: viewModel)
            }
            
            NotesSection(viewModel: viewModel)
            PhotoUploadSection(viewModel: viewModel)
        }
    }
    
    
}

#Preview {
    AddWeightModal(isPresented: .constant(true))
}