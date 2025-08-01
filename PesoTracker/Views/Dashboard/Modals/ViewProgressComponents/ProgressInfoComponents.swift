import SwiftUI

// MARK: - Progress Indicators Component
struct ProgressIndicators: View {
    let totalPhotos: Int
    let currentIndex: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalPhotos, id: \.self) { index in
                Circle()
                    .fill(index == currentIndex ? Color.blue : Color.gray.opacity(0.3))
                    .frame(width: 8, height: 8)
            }
        }
    }
}

// MARK: - Progress Weight Info Component
struct ProgressWeightInfo: View {
    let currentData: ProgressResponse?
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "es_ES")
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter
    }()
    
    var body: some View {
        VStack(spacing: 8) {
            Text(currentData?.weight != nil ? String(format: "%.1f kg", currentData!.weight) : "Sin datos")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.primary)
            
            Text(currentData?.date != nil ? dateFormatter.string(from: currentData!.date) : "Sin fecha")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Progress Notes Component
struct ProgressNotes: View {
    let notes: String?
    
    var body: some View {
        Text(notes ?? "Sin notas")
            .font(.system(size: 14))
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            .lineLimit(nil)
            .padding(.horizontal, 20)
    }
}

// MARK: - Progress Bar Component
struct ProgressBarView: View {
    let currentIndex: Int
    let totalPhotos: Int
    
    private var progressValue: Double {
        guard totalPhotos > 0 else { return 0 }
        return Double(currentIndex + 1) / Double(totalPhotos)
    }
    
    var body: some View {
        VStack(spacing: 8) {
            ProgressView(value: progressValue)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                .scaleEffect(x: 1, y: 2, anchor: .center)
            
            Text("Photo \(currentIndex + 1) of \(totalPhotos)")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 20)
    }
}