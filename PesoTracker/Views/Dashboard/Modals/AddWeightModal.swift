import SwiftUI
import UniformTypeIdentifiers

struct AddWeightModal: View {
    @Binding var isPresented: Bool
    let isEditing: Bool
    let record: WeightRecord?
    let selectedWeight: Weight?
    let onSave: (() -> Void)?
    
    @StateObject private var viewModel = WeightEntryViewModel()
    @State private var isImageHovered = false
    
    init(isPresented: Binding<Bool>, isEditing: Bool = false, record: WeightRecord? = nil, selectedWeight: Weight? = nil, onSave: (() -> Void)? = nil) {
        self._isPresented = isPresented
        self.isEditing = isEditing
        self.record = record
        self.selectedWeight = selectedWeight
        self.onSave = onSave
    }
    
    var body: some View {
        VStack(spacing: 24) {
            headerView
            formContent
            actionButtons
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
    
    // MARK: - Header View
    
    private var headerView: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.green)
                
                Text(isEditing ? "Editar Registro de Peso" : "Añadir Registro de Peso")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            Button(action: {
                isPresented = false
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                    .frame(width: 24, height: 24)
                    .background(Color.secondary.opacity(0.1))
                    .clipShape(Circle())
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    // MARK: - Form Content
    
    private var formContent: some View {
        VStack(spacing: 20) {
            // Date and Weight Row
            HStack(spacing: 16) {
                // Date Field
                VStack(alignment: .leading, spacing: 6) {
                    Text("Fecha")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                    
                    Button(action: {
                        viewModel.showDatePicker.toggle()
                    }) {
                        HStack {
                            Text(viewModel.dateString.isEmpty ? "DD/MM/AAAA" : viewModel.dateString)
                                .font(.system(size: 14))
                                .foregroundColor(viewModel.dateString.isEmpty ? .secondary : .primary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Image(systemName: "calendar")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 12)
                        .frame(height: 36)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color(NSColor.textBackgroundColor))
                                .stroke(Color(NSColor.separatorColor), lineWidth: 1)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .popover(isPresented: $viewModel.showDatePicker) {
                        VStack(spacing: 20) {
                            Text("Seleccionar Fecha")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            ZStack {
                                DatePicker("", selection: $viewModel.date, displayedComponents: .date)
                                    .datePickerStyle(.graphical)
                                    .accentColor(.green)
                                    .background(Color.clear)
                                    .onChange(of: viewModel.date) { _ in
                                        viewModel.updateDateString()
                                    }
                                
                                // Overlay to hide any focus rings or outlines
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.clear, lineWidth: 3)
                                    .background(Color.clear)
                                    .allowsHitTesting(false)
                            }
                            .mask(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.black)
                            )
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(NSColor.windowBackgroundColor))
                                    .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                            )
                            
                            HStack(spacing: 16) {
                                Button("Cancelar") {
                                    viewModel.showDatePicker = false
                                }
                                .buttonStyle(PlainButtonStyle())
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color(NSColor.controlBackgroundColor))
                                .foregroundColor(.secondary)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color(NSColor.separatorColor), lineWidth: 1)
                                )
                                
                                Button("Seleccionar") {
                                    viewModel.updateDateString()
                                    viewModel.showDatePicker = false
                                }
                                .buttonStyle(PlainButtonStyle())
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(.green)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                                .shadow(color: .green.opacity(0.3), radius: 4, x: 0, y: 2)
                            }
                        }
                        .padding(24)
                        .frame(width: 340)
                        .background(Color(NSColor.windowBackgroundColor))
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
                    }
                }
                .frame(maxWidth: .infinity)
                
                // Weight Field
                VStack(alignment: .leading, spacing: 6) {
                    Text("Peso")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color(NSColor.textBackgroundColor))
                            .stroke(Color(NSColor.separatorColor), lineWidth: 1)
                            .frame(height: 36)
                        
                        HStack {
                            TextField(viewModel.weightPlaceholder, text: $viewModel.weight)
                                .font(.system(size: 14))
                                .textFieldStyle(.plain)
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal, 8)
                            
                            Text("kg")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                                .padding(.trailing, 8)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
            
            // Validation Errors
            if let weightError = viewModel.weightError {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                        .font(.system(size: 12))
                    
                    Text(weightError)
                        .font(.system(size: 12))
                        .foregroundColor(.red)
                    
                    Spacer()
                }
            }
            
            if let dateError = viewModel.dateError {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                        .font(.system(size: 12))
                    
                    Text(dateError)
                        .font(.system(size: 12))
                        .foregroundColor(.red)
                    
                    Spacer()
                }
            }
            
            // Notes Field
            VStack(alignment: .leading, spacing: 6) {
                Text("Notas (opcional)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
                
                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(NSColor.textBackgroundColor))
                        .stroke(Color(NSColor.separatorColor), lineWidth: 1)
                        .frame(height: 80)
                    
                    if viewModel.notes.isEmpty {
                        VStack {
                            HStack {
                                Text(viewModel.notesPlaceholder)
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                Spacer()
                            }
                            Spacer()
                        }
                    }
                    
                    TextEditor(text: $viewModel.notes)
                        .font(.system(size: 14))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .background(Color.clear)
                        .scrollContentBackground(.hidden)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .frame(height: 80)
            }
            
            // Photo Upload Section
            photoUploadSection
        }
    }
    
    // MARK: - Photo Upload Section
    
    private var photoUploadSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Foto")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primary)
            
            if let selectedImage = viewModel.selectedImage {
                // New Selected Image Preview
                VStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.1))
                            .frame(height: 120)
                        
                        Image(nsImage: selectedImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 100)
                            .cornerRadius(6)
                    }
                    
                    Button(action: {
                        viewModel.removeImage()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "trash")
                                .font(.system(size: 12))
                            Text("Eliminar foto")
                                .font(.system(size: 12))
                        }
                        .foregroundColor(.red)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            } else if viewModel.hasExistingPhoto && viewModel.isEditMode {
                // Existing Photo Preview
                VStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.1))
                            .frame(height: 120)
                        
                        if let photoUrl = viewModel.existingPhotoUrl, let url = URL(string: photoUrl) {
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxHeight: 100)
                                    .cornerRadius(6)
                            } placeholder: {
                                VStack(spacing: 8) {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                    Text("Cargando...")
                                        .font(.system(size: 12))
                                        .foregroundColor(.secondary)
                                }
                            }
                        } else {
                            VStack(spacing: 8) {
                                Image(systemName: "photo.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(.green)
                                
                                Text("Foto existente")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    HStack(spacing: 12) {
                        Button(action: {
                            Task {
                                await viewModel.deleteExistingPhoto()
                            }
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "trash")
                                    .font(.system(size: 12))
                                Text("Eliminar")
                                    .font(.system(size: 12))
                            }
                            .foregroundColor(.red)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Button(action: {
                            viewModel.selectImage()
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "arrow.triangle.2.circlepath")
                                    .font(.system(size: 12))
                                Text("Cambiar")
                                    .font(.system(size: 12))
                            }
                            .foregroundColor(.blue)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            } else {
                // Photo Upload Area
                Button(action: {
                    viewModel.selectImage()
                }) {
                    VStack(spacing: 12) {
                        Image(systemName: "photo")
                            .font(.system(size: 32))
                            .foregroundColor(.secondary)
                        
                        VStack(spacing: 4) {
                            Text("Subir un archivo")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.blue)
                            
                            Text("o arrastrar y soltar")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                            
                            Text("PNG, JPG, GIF hasta 10MB")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 120)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
                            .foregroundColor(isImageHovered ? .blue : .secondary.opacity(0.5))
                    )
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(isImageHovered ? Color.blue.opacity(0.05) : Color.clear)
                    )
                }
                .buttonStyle(PlainButtonStyle())
                .onDrop(of: [UTType.image], isTargeted: $isImageHovered) { providers in
                    return viewModel.handleDrop(providers: providers)
                }
            }
        }
    }
    
    // MARK: - Action Buttons
    
    private var actionButtons: some View {
        HStack(spacing: 12) {
            Button("Cancelar") {
                isPresented = false
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Color.secondary.opacity(0.1))
            .foregroundColor(.secondary)
            .cornerRadius(8)
            
            Button(viewModel.saveButtonText) {
                Task {
                    await viewModel.saveWeight()
                    if viewModel.errorMessage == nil {
                        isPresented = false
                        onSave?()
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(viewModel.canSave ? .green : .green.opacity(0.5))
            .foregroundColor(.white)
            .cornerRadius(8)
            .disabled(!viewModel.canSave)
        }
    }
}

#Preview {
    AddWeightModal(isPresented: .constant(true))
}