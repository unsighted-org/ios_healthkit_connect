import SwiftUI
import HealthKit

struct ContentView: View {
    @StateObject private var viewModel = HealthViewModel()
    @State private var newWeight: String = ""
    
    var body: some View {
        NavigationView {
            List {
                if !viewModel.isAuthorized {
                    Button("Request HealthKit Access") {
                        viewModel.requestAuthorization()
                    }
                } else {
                    Section(header: Text("Steps")) {
                        Text("\(Int(viewModel.steps)) steps")
                    }
                    
                    Section(header: Text("Heart Rate")) {
                        ForEach(viewModel.heartRates, id: \.self) { rate in
                            Text("\(Int(rate)) BPM")
                        }
                    }
                    
                    Section(header: Text("Weight History")) {
                        ForEach(viewModel.weights, id: \.self) { weight in
                            Text("\(String(format: "%.1f", weight)) lbs")
                        }
                        
                        HStack {
                            TextField("New weight (lbs)", text: $newWeight)
                                .keyboardType(.decimalPad)
                            
                            Button("Add") {
                                if let weight = Double(newWeight) {
                                    viewModel.saveWeight(weight)
                                    newWeight = ""
                                }
                            }
                            .disabled(newWeight.isEmpty)
                        }
                    }
                    
                    Section(header: Text("Health Data Types")) {
                        Button("List Available Health Data Types") {
                            HealthKitTypesHelper.printAllAvailableTypes()
                        }
                    }
                }
            }
            .navigationTitle("IBiome Health")
            .refreshable {
                await viewModel.fetchHealthData()
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
        .onAppear {
            // Print available types when the app starts
            HealthKitTypesHelper.printAllAvailableTypes()
        }
    }
}
