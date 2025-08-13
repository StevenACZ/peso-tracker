import SwiftUI

struct FormActionButtons: View {
    @ObservedObject var viewModel: WeightEntryViewModel
    @Binding var isPresented: Bool
    let onSave: (() -> Void)?
    
    var body: some View {
        HStack(spacing: 12) {
            CustomButton(action: {
                isPresented = false
            }) {
                Text("Cancelar")
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.secondary.opacity(0.1))
                    .foregroundColor(.secondary)
                    .cornerRadius(8)
            }
            
            CustomButton(action: {
                Task {
                    await viewModel.saveWeight()
                    if !viewModel.showErrorModal {
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
            .disabled(!viewModel.canSave)
        }
    }
}