import SwiftUI

struct ViewProgressModal: View {
    @Binding var isPresented: Bool
    @State private var currentPhotoIndex = 0
    @State private var viewState: ProgressViewState = .loading
    
    var body: some View {
        VStack(spacing: 0) {
            switch viewState {
            case .loading:
                ProgressLoadingView()
                
            case .error(let errorMessage):
                ProgressErrorView(error: errorMessage) {
                    isPresented = false
                }
                
            case .empty:
                ProgressEmptyView {
                    isPresented = false
                }
                
            case .content(let progressData):
                ProgressContentView(
                    progressData: progressData,
                    currentPhotoIndex: $currentPhotoIndex
                ) {
                    isPresented = false
                }
            }
        }
        .frame(width: 400, height: 640)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
        .onAppear {
            loadProgressData()
        }
    }

    
    // MARK: - Load Progress Data
    private func loadProgressData() {
        viewState = .loading
        
        Task {
            let result = await ProgressDataManager.loadProgressData()
            
            await MainActor.run {
                switch result {
                case .success(let data):
                    if data.isEmpty {
                        viewState = .empty
                    } else {
                        viewState = .content(data)
                    }
                case .failure(let error):
                    viewState = .error(error.localizedDescription)
                }
            }
        }
    }
}

#Preview {
    ViewProgressModal(isPresented: .constant(true))
        .preferredColorScheme(.dark)
}