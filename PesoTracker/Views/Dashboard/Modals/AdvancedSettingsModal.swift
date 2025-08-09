import SwiftUI

struct AdvancedSettingsModal: View {
    @Binding var isPresented: Bool
    @StateObject private var themeViewModel = ThemeViewModel()
    @StateObject private var exportViewModel = DataExportViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Text("Opciones Avanzadas")
                    .font(.system(size: 18, weight: .semibold))
                
                Spacer()
                
                CustomButton(action: {
                    isPresented = false
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                
            }
            
            // Content
            VStack(spacing: 24) {
                // Theme Section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "paintbrush")
                            .font(.system(size: 16))
                            .foregroundColor(.green)
                        
                        Text("Tema de la Aplicación")
                            .font(.system(size: 16, weight: .medium))
                        
                        Spacer()
                    }
                    
                    VStack(spacing: 8) {
                        ForEach(themeViewModel.allThemes, id: \.rawValue) { theme in
                            HStack {
                                CustomButton(action: {
                                    themeViewModel.updateTheme(theme)
                                }) {
                                    HStack(spacing: 8) {
                                        Image(systemName: themeViewModel.selectedTheme == theme ? "largecircle.fill.circle" : "circle")
                                            .font(.system(size: 14))
                                            .foregroundColor(.green)
                                        
                                        Text(theme.displayName)
                                            .font(.system(size: 14))
                                            .foregroundColor(.primary)
                                        
                                        Spacer()
                                    }
                                }
                                
                                .contentShape(Rectangle())
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(themeViewModel.selectedTheme == theme ? Color.green.opacity(0.1) : Color.clear)
                            .cornerRadius(6)
                        }
                    }
                }
                .padding(16)
                .background(Color.gray.opacity(0.05))
                .cornerRadius(8)
                
                // Data Export Section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "square.and.arrow.down")
                            .font(.system(size: 16))
                            .foregroundColor(.green)
                        
                        Text("Exportar Datos Personales")
                            .font(.system(size: 16, weight: .medium))
                        
                        Spacer()
                    }
                    
                    VStack(spacing: 12) {
                        // Export Description
                        Text("Descarga todos tus datos (pesos, fotos, notas) organizados en carpetas locales para mayor seguridad.")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                        
                        // Folder Selection
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Carpeta de exportación:")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                            
                            HStack {
                                Text(exportViewModel.folderDisplayName)
                                    .font(.system(size: 12))
                                    .foregroundColor(.primary)
                                    .lineLimit(1)
                                    .truncationMode(.middle)
                                
                                Spacer()
                                
                                CustomButton(action: {
                                    exportViewModel.selectExportFolder()
                                }) {
                                    Text("Seleccionar")
                                }
                                .font(.system(size: 12))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(.blue)
                                .foregroundColor(.white)
                                .cornerRadius(4)
                                
                            }
                        }
                        
                        // Export Progress
                        if exportViewModel.isExporting {
                            VStack(spacing: 8) {
                                ProgressView(value: exportViewModel.progressPercentage)
                                    .progressViewStyle(LinearProgressViewStyle())
                                
                                Text(exportViewModel.progressText)
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        // Export Button
                        CustomButton(action: {
                            exportViewModel.startDataExport()
                        }) {
                            HStack {
                                if exportViewModel.isExporting {
                                    ProgressView()
                                        .scaleEffect(0.7)
                                        .frame(width: 14, height: 14)
                                } else {
                                    Image(systemName: "square.and.arrow.down")
                                        .font(.system(size: 14))
                                }
                                
                                Text(exportViewModel.exportButtonText)
                                    .font(.system(size: 14, weight: .medium))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(exportViewModel.canStartExport ? .green : .gray)
                            .foregroundColor(.white)
                            .cornerRadius(6)
                        }
                        
                        .disabled(!exportViewModel.canStartExport)
                        
                        // Export Complete Message
                        if exportViewModel.isExportComplete {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text("Exportación completada exitosamente")
                                    .font(.system(size: 12))
                                    .foregroundColor(.green)
                            }
                        }
                        
                        Text("Estructura: Peso Steven → 1 - DD MMMM YYYY (peso) → Foto")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                            .italic()
                    }
                }
                .padding(16)
                .background(Color.gray.opacity(0.05))
                .cornerRadius(8)
            }
            .frame(maxWidth: .infinity)
            
            // Buttons
            HStack(spacing: 12) {
                CustomButton(action: {
                    isPresented = false
                }) {
                    Text("Cerrar")
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(.green)
                        .foregroundColor(.white)
                        .cornerRadius(6)
                }
                
            }
        }
        .padding(24)
        .frame(width: 500)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
        .alert("Error de Exportación", isPresented: $exportViewModel.showingExportError) {
            Button("OK") { }
        } message: {
            Text(exportViewModel.exportErrorMessage)
        }
    }
}

#Preview {
    AdvancedSettingsModal(isPresented: .constant(true))
}