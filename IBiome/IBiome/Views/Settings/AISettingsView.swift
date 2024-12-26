import SwiftUI

struct AISettingsView: View {
    @StateObject private var viewModel = AISettingsViewModel()
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Form {
            // MARK: - AI Features
            Section(header: Text("AI Features")) {
                Toggle("Enable AI Analysis", isOn: $viewModel.isAIEnabled)
                    .onChange(of: viewModel.isAIEnabled) { newValue in
                        viewModel.updateAIStatus(enabled: newValue)
                    }
                
                if viewModel.isAIEnabled {
                    Toggle("OpenAI Integration", isOn: $viewModel.isOpenAIEnabled)
                        .disabled(!viewModel.isAIEnabled)
                    
                    Toggle("Claude Integration", isOn: $viewModel.isClaudeEnabled)
                        .disabled(!viewModel.isAIEnabled)
                }
            }
            
            // MARK: - API Configuration
            if viewModel.isAIEnabled {
                Section(header: Text("API Configuration")) {
                    SecureField("OpenAI API Key", text: $viewModel.openAIKey)
                        .textContentType(.password)
                        .disabled(!viewModel.isOpenAIEnabled)
                    
                    SecureField("Claude API Key", text: $viewModel.claudeKey)
                        .textContentType(.password)
                        .disabled(!viewModel.isClaudeEnabled)
                }
                
                Section(header: Text("Model Selection")) {
                    Picker("OpenAI Model", selection: $viewModel.selectedOpenAIModel) {
                        ForEach(AIModel.openAIModels, id: \.self) { model in
                            Text(model.displayName).tag(model)
                        }
                    }
                    .disabled(!viewModel.isOpenAIEnabled)
                    
                    Picker("Claude Model", selection: $viewModel.selectedClaudeModel) {
                        ForEach(AIModel.claudeModels, id: \.self) { model in
                            Text(model.displayName).tag(model)
                        }
                    }
                    .disabled(!viewModel.isClaudeEnabled)
                }
            }
            
            // MARK: - Enterprise Features
            Section(header: Text("Enterprise Features")) {
                ForEach(EnterpriseFeature.allCases) { feature in
                    Toggle(feature.displayName, isOn: $viewModel.enabledFeatures[feature, default: false])
                        .onChange(of: viewModel.enabledFeatures[feature, default: false]) { newValue in
                            viewModel.updateFeature(feature, enabled: newValue)
                        }
                }
            }
            
            // MARK: - Privacy Settings
            Section(header: Text("Privacy & Data")) {
                Picker("Privacy Level", selection: $viewModel.privacyLevel) {
                    ForEach(PrivacyLevel.allCases) { level in
                        Text(level.displayName).tag(level)
                    }
                }
                
                Toggle("Enable Advanced Analytics", isOn: $viewModel.advancedAnalyticsEnabled)
                Toggle("Share Anonymous Data", isOn: $viewModel.shareAnonymousData)
            }
            
            // MARK: - Performance
            Section(header: Text("Performance")) {
                Picker("Update Frequency", selection: $viewModel.updateFrequency) {
                    ForEach(UpdateFrequency.allCases) { frequency in
                        Text(frequency.displayName).tag(frequency)
                    }
                }
                
                Toggle("Background Processing", isOn: $viewModel.backgroundProcessingEnabled)
            }
        }
        .navigationTitle("AI & Enterprise Settings")
        .alert("Settings Updated", isPresented: $viewModel.showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.alertMessage)
        }
    }
}

// MARK: - Supporting Types

enum AIModel: String, CaseIterable {
    // OpenAI Models
    case gpt4 = "gpt-4"
    case gpt4Turbo = "gpt-4-turbo"
    
    // Claude Models
    case claude3 = "claude-3"
    case claude3Sonnet = "claude-3-sonnet"
    
    static var openAIModels: [AIModel] {
        [.gpt4, .gpt4Turbo]
    }
    
    static var claudeModels: [AIModel] {
        [.claude3, .claude3Sonnet]
    }
    
    var displayName: String {
        switch self {
        case .gpt4: return "GPT-4"
        case .gpt4Turbo: return "GPT-4 Turbo"
        case .claude3: return "Claude 3"
        case .claude3Sonnet: return "Claude 3 Sonnet"
        }
    }
}

enum EnterpriseFeature: String, CaseIterable, Identifiable {
    case insurance = "Insurance Analytics"
    case urbanPlanning = "Urban Health Planning"
    case corporateWellness = "Corporate Wellness"
    case realEstate = "Real Estate Analysis"
    case travelTourism = "Travel & Tourism"
    case research = "Research Tools"
    case smartCity = "Smart City Integration"
    
    var id: String { rawValue }
    var displayName: String { rawValue }
}

enum UpdateFrequency: String, CaseIterable, Identifiable {
    case realtime = "Real-time"
    case hourly = "Hourly"
    case daily = "Daily"
    case weekly = "Weekly"
    
    var id: String { rawValue }
    var displayName: String { rawValue }
}

extension PrivacyLevel: CaseIterable, Identifiable {
    var id: String {
        switch self {
        case .individual: return "individual"
        case .aggregated: return "aggregated"
        case .minimal: return "minimal"
        }
    }
    
    var displayName: String {
        switch self {
        case .individual: return "Individual (Full Data)"
        case .aggregated: return "Aggregated (Anonymous)"
        case .minimal: return "Minimal (Statistical)"
        }
    }
    
    static var allCases: [PrivacyLevel] {
        [.individual, .aggregated, .minimal]
    }
}
