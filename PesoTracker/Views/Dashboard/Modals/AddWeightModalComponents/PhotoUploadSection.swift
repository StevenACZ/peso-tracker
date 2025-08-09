import SwiftUI
import UniformTypeIdentifiers

struct PhotoUploadSection: View {
    @ObservedObject var viewModel: WeightEntryViewModel
    @State private var isImageHovered = false
    
    let onImageTap: (NSImage) -> Void
    let onImageURLTap: (URL) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Foto")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primary)
            
            // Fixed height container for consistent modal size
            VStack {
                if let selectedImage = viewModel.selectedImage {
                    // New Selected Image Preview
                    NewImagePreview(viewModel: viewModel, selectedImage: selectedImage, onImageTap: onImageTap)
                } else if viewModel.hasExistingPhoto && viewModel.isEditMode {
                    // Existing Photo Preview
                    ExistingPhotoPreview(viewModel: viewModel, onImageURLTap: onImageURLTap)
                } else {
                    // Photo Upload Area
                    PhotoUploadArea(
                        viewModel: viewModel,
                        isImageHovered: $isImageHovered
                    )
                }
            }
            .frame(height: 160) // Fixed height to prevent modal resizing
        }
    }
}

struct NewImagePreview: View {
    @ObservedObject var viewModel: WeightEntryViewModel
    let selectedImage: NSImage
    let onImageTap: (NSImage) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Image preview area
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.1))
                    .frame(height: 120)
                
                CustomButton(action: {
                    onImageTap(selectedImage)
                }) {
                    Image(nsImage: selectedImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 100)
                        .cornerRadius(6)
                }
                
            }
            
            Spacer()
            
            // Button area at bottom
            CustomButton(action: {
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
            
        }
    }
}

struct ExistingPhotoPreview: View {
    @ObservedObject var viewModel: WeightEntryViewModel
    let onImageURLTap: (URL) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Image preview area
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.1))
                    .frame(height: 120)
                
                if let photoUrl = viewModel.existingPhotoUrl, let url = URL(string: photoUrl) {
                    CustomButton(action: {
                        // Use full size URL for zoom if available, otherwise use existing URL
                        if let fullSizePhotoUrl = viewModel.existingFullSizePhotoUrl,
                           let fullSizeURL = URL(string: fullSizePhotoUrl) {
                            onImageURLTap(fullSizeURL)
                        } else {
                            onImageURLTap(url)
                        }
                    }) {
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
            
            Spacer()
            
            // Button area at bottom
            ExistingPhotoActions(viewModel: viewModel)
        }
    }
}

struct ExistingPhotoActions: View {
    @ObservedObject var viewModel: WeightEntryViewModel
    
    var body: some View {
        CustomButton(action: {
            viewModel.selectImage()
        }) {
            HStack(spacing: 4) {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.system(size: 12))
                Text("Cambiar foto")
                    .font(.system(size: 12))
            }
            .foregroundColor(.blue)
        }
        
    }
}

struct PhotoUploadArea: View {
    @ObservedObject var viewModel: WeightEntryViewModel
    @Binding var isImageHovered: Bool
    
    var body: some View {
        CustomButton(action: {
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
        
        .onDrop(of: [UTType.image], isTargeted: $isImageHovered) { providers in
            return viewModel.handleDrop(providers: providers)
        }
    }
}