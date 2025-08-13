import SwiftUI

struct NotesSection: View {
    @ObservedObject var viewModel: WeightEntryViewModel
    
    var body: some View {
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
                    .disabled(viewModel.isLoading)
            }
            .frame(height: 80)
        }
    }
}