import SwiftUI

struct HealthDataSummaryView: View {
    @Environment(\.horizontalSizeClass) private var sizeClass
    let healthData: [HealthEnvironmentData]
    let isLoading: Bool
    
    private var isMobile: Bool {
        sizeClass == .compact
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if healthData.isEmpty {
                    Text("No health data available")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    Grid(alignment: .leading, horizontalSpacing: 20, verticalSpacing: 12) {
                        // Header
                        GridRow {
                            Text("Date")
                            Text("Steps")
                            Text("Activity")
                            Text("Heart Rate")
                            if !isMobile {
                                Text("BMI")
                                Text("Environmental")
                                Text("Air Quality")
                            }
                        }
                        .font(.headline)
                        
                        Divider()
                        
                        // Data rows
                        ForEach(healthData) { data in
                            GridRow {
                                Text(data.timestamp.formatted(date: .abbreviated, time: .shortened))
                                Text("\(data.steps)")
                                Text(data.activityLevel.rawValue)
                                    .foregroundColor(activityLevelColor(data.activityLevel))
                                Text("\(Int(data.heartRate)) BPM")
                                if !isMobile {
                                    Text(String(format: "%.1f", data.bmi))
                                    Text(data.environmentalImpactDescription)
                                        .foregroundColor(impactColor(data.environmentalImpact))
                                    Text(data.airQualityDescription)
                                        .foregroundColor(airQualityColor(data.airQualityIndex))
                                }
                            }
                            .font(.subheadline)
                        }
                    }
                    .padding()
                }
            }
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(radius: 2)
    }
    
    private func activityLevelColor(_ level: ActivityLevel) -> Color {
        switch level {
        case .sedentary:
            return .red
        case .lightlyActive:
            return .orange
        case .moderatelyActive:
            return .blue
        case .veryActive:
            return .green
        }
    }
    
    private func impactColor(_ impact: Int) -> Color {
        switch impact {
        case 0..<33:
            return .green
        case 33..<66:
            return .orange
        default:
            return .red
        }
    }
    
    private func airQualityColor(_ aqi: Int) -> Color {
        switch aqi {
        case 0..<50:
            return .green
        case 50..<100:
            return .yellow
        case 100..<150:
            return .orange
        case 150..<200:
            return .red
        case 200..<300:
            return .purple
        default:
            return .brown
        }
    }
}

#Preview {
    HealthDataSummaryView(
        healthData: [
            HealthEnvironmentData(
                id: "1",
                timestamp: Date(),
                steps: 8500,
                heartRate: 72,
                weight: 70,
                height: 175,
                airQualityIndex: 45,
                environmentalImpact: 30
            )
        ],
        isLoading: false
    )
}
