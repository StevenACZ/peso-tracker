import SwiftUI

struct FormActionButtons: View {
    @ObservedObject var viewModel: WeightEntryViewModel
    @Binding var isPresented: Bool
    let onSave: (() -> Void)?
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: {
                isPresented = false
            }) {
                Text("Cancelar")
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.secondary.opacity(0.1))
                    .foregroundColor(.secondary)
                    .cornerRadius(8)
            }
            .buttonStyle(PlainButtonStyle())
            
            Button(action: {
                Task {
                    await viewModel.saveWeight()
                    if viewModel.errorMessage == nil {
                        isPresented = false
                        onSave?()
                    }
                }
            }) {
                Text(viewModel.saveButtonText)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(viewModel.canSave ? .green : .green.opacity(0.5))
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(!viewModel.canSave)
        }
    }
}