import SwiftUI

// MARK: - Progress Content View Component
struct ProgressContentView: View {
    let progressData: [ProgressResponse]
    @Binding var currentPhotoIndex: Int
    let onClose: () -> Void
    
    private var currentData: ProgressResponse? {
        guard !progressData.isEmpty && currentPhotoIndex < progressData.count else { return nil }
        return progressData[currentPhotoIndex]
    }
    
    private var isLastPhoto: Bool {
        return currentPhotoIndex == progressData.count - 1
    }
    
    var body: some View {
        VStack(spacing: 20) {
            ProgressPhotoViewer(
                currentData: currentData,
                currentIndex: currentPhotoIndex,
                totalPhotos: progressData.count,
                onNavigate: handlePhotoNavigation
            )
            
            ProgressIndicators(
                totalPhotos: progressData.count,
                currentIndex: currentPhotoIndex
            )
            
            ProgressWeightInfo(currentData: currentData)
            
            ProgressNotes(notes: currentData?.notes)
            
            ProgressBarView(
                currentIndex: currentPhotoIndex,
                totalPhotos: progressData.count
            )
            
            ProgressActionButton(
                title: isLastPhoto ? "Completar" : "Cerrar",
                action: onClose
            )
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
        }
        .padding(.top, 16)
    }
    
    private func handlePhotoNavigation(location: CGPoint) {
        let imageWidth = 360.0 // Approximate image width (400 - 40 padding)
        let halfWidth = imageWidth / 2
        
        if location.x < halfWidth {
            // Tap on left half - go back
            if currentPhotoIndex > 0 {
                currentPhotoIndex -= 1
            }
        } else {
            // Tap on right half - go forward
            if currentPhotoIndex < progressData.count - 1 {
                currentPhotoIndex += 1
            }
        }
    }
}