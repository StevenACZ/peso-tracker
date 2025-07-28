import SwiftUI

struct ValidationErrorsSection: View {
    @ObservedObject var viewModel: WeightEntryViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Weight Error
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
            
            // Date Error  
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
        }
    }
}