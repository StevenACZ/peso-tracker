import SwiftUI

struct WeightInputSection: View {
    @ObservedObject var viewModel: WeightEntryViewModel
    
    var body: some View {
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
                        .disabled(viewModel.isLoading)
                    
                    Text("kg")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .padding(.trailing, 8)
                }
            }
        }
    }
}