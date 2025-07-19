//
//  AddWeightView.swift
//  PesoTracker
//
//  Created by Steven Coaila Zaa on 17/07/25.
//

import SwiftUI

struct AddWeightView: View {
    @ObservedObject var viewModel: DashboardViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var weight: String = ""
    @State private var notes: String = ""
    @State private var date = Date()
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            HStack {
                Text("Add Weight Entry")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("Cancel") {
                    dismiss()
                }
            }
            .padding()
            
            // Form
            VStack(spacing: 20) {
                // Date picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Date")
                        .font(.headline)
                    
                    DatePicker("Select date", selection: $date, displayedComponents: .date)
                        .datePickerStyle(.compact)
                }
                
                // Weight input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Weight (kg)")
                        .font(.headline)
                    
                    TextField("Enter your weight", text: $weight)
                        .textFieldStyle(.roundedBorder)
                }
                
                // Notes input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Notes (optional)")
                        .font(.headline)
                    
                    TextField("Add any notes...", text: $notes)
                        .textFieldStyle(.roundedBorder)
                }
                
                // Error message
                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                // Save button
                Button("Save Weight Entry") {
                    Task {
                        await saveWeight()
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(weight.isEmpty || isLoading)
                
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                }
            }
            .frame(maxWidth: 400)
            .padding()
            
            Spacer()
        }
        .frame(width: 500, height: 400)
    }
    
    private func saveWeight() async {
        guard let weightValue = Double(weight), weightValue > 0 else {
            errorMessage = "Please enter a valid weight"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // Call the API to save the weight
            try await viewModel.addWeight(
                weight: weightValue,
                date: date,
                notes: notes.isEmpty ? nil : notes
            )
            
            // Close the sheet on success
            dismiss()
            
        } catch {
            print("❌ AddWeightView: Failed to save weight: \(error)")
            errorMessage = "Failed to save weight entry: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}