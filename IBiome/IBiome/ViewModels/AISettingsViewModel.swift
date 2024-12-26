import Foundation
import Combine

final class AISettingsViewModel: ObservableObject {
    private let config = SecureConfig.shared
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Published Properties
    
    @Published var isAIEnabled: Bool {
        didSet {
            config.isAIEnabled = isAIEnabled
        }
    }
    
    @Published var isOpenAIEnabled: Bool {
        didSet {
            config.isOpenAIEnabled = isOpenAIEnabled
        }
    }
    
    @Published var isClaudeEnabled: Bool {
        didSet {
            config.isClaudeEnabled = isClaudeEnabled
        }
    }
    
    @Published var openAIKey: String = "" {
        didSet {
            updateAPIKey(.openAI, key: openAIKey)
        }
    }
    
    @Published var claudeKey: String = "" {
        didSet {
            updateAPIKey(.claude, key: claudeKey)
        }
    }
    
    @Published var selectedOpenAIModel: AIModel {
        didSet {
            config.setModel(selectedOpenAIModel.rawValue, for: .openAI)
        }
    }
    
    @Published var selectedClaudeModel: AIModel {
        didSet {
            config.setModel(selectedClaudeModel.rawValue, for: .claude)
        }
    }
    
    @Published var enabledFeatures: [EnterpriseFeature: Bool] = [:] {
        didSet {
            saveEnabledFeatures()
        }
    }
    
    @Published var privacyLevel: PrivacyLevel = .aggregated {
        didSet {
            UserDefaults.standard.set(privacyLevel.rawValue, forKey: "privacy_level")
        }
    }
    
    @Published var advancedAnalyticsEnabled: Bool = false {
        didSet {
            UserDefaults.standard.set(advancedAnalyticsEnabled, forKey: "advanced_analytics_enabled")
        }
    }
    
    @Published var shareAnonymousData: Bool = false {
        didSet {
            UserDefaults.standard.set(shareAnonymousData, forKey: "share_anonymous_data")
        }
    }
    
    @Published var updateFrequency: UpdateFrequency = .daily {
        didSet {
            UserDefaults.standard.set(updateFrequency.rawValue, forKey: "update_frequency")
        }
    }
    
    @Published var backgroundProcessingEnabled: Bool = false {
        didSet {
            UserDefaults.standard.set(backgroundProcessingEnabled, forKey: "background_processing_enabled")
        }
    }
    
    @Published var showAlert = false
    @Published var alertMessage = ""
    
    // MARK: - Initialization
    
    init() {
        // Load AI settings
        self.isAIEnabled = config.isAIEnabled
        self.isOpenAIEnabled = config.isOpenAIEnabled
        self.isClaudeEnabled = config.isClaudeEnabled
        
        // Load model selections
        self.selectedOpenAIModel = AIModel(rawValue: config.getModel(for: .openAI)) ?? .gpt4
        self.selectedClaudeModel = AIModel(rawValue: config.getModel(for: .claude)) ?? .claude3
        
        // Load API keys
        loadAPIKeys()
        
        // Load enterprise features
        loadEnabledFeatures()
        
        // Load other settings
        loadSettings()
        
        // Setup observers
        setupObservers()
    }
    
    // MARK: - Public Methods
    
    func updateAIStatus(enabled: Bool) {
        isAIEnabled = enabled
        if !enabled {
            isOpenAIEnabled = false
            isClaudeEnabled = false
        }
        showAlert(message: "AI settings updated successfully")
    }
    
    func updateFeature(_ feature: EnterpriseFeature, enabled: Bool) {
        enabledFeatures[feature] = enabled
        showAlert(message: "\(feature.displayName) \(enabled ? "enabled" : "disabled")")
    }
    
    // MARK: - Private Methods
    
    private func loadAPIKeys() {
        do {
            openAIKey = try config.getAPIKey(for: .openAI)
            claudeKey = try config.getAPIKey(for: .claude)
        } catch {
            print("Failed to load API keys: \(error)")
        }
    }
    
    private func updateAPIKey(_ service: AIService, key: String) {
        do {
            try config.setAPIKey(key, for: service)
            showAlert(message: "\(service) API key updated successfully")
        } catch {
            showAlert(message: "Failed to update API key: \(error.localizedDescription)")
        }
    }
    
    private func loadEnabledFeatures() {
        if let data = UserDefaults.standard.dictionary(forKey: "enabled_features") as? [String: Bool] {
            enabledFeatures = Dictionary(uniqueKeysWithValues: data.compactMap { key, value in
                guard let feature = EnterpriseFeature(rawValue: key) else { return nil }
                return (feature, value)
            })
        }
    }
    
    private func saveEnabledFeatures() {
        let data = Dictionary(uniqueKeysWithValues: enabledFeatures.map { ($0.key.rawValue, $0.value) })
        UserDefaults.standard.set(data, forKey: "enabled_features")
    }
    
    private func loadSettings() {
        if let privacyLevelRaw = UserDefaults.standard.string(forKey: "privacy_level"),
           let level = PrivacyLevel(rawValue: privacyLevelRaw) {
            privacyLevel = level
        }
        
        advancedAnalyticsEnabled = UserDefaults.standard.bool(forKey: "advanced_analytics_enabled")
        shareAnonymousData = UserDefaults.standard.bool(forKey: "share_anonymous_data")
        
        if let frequencyRaw = UserDefaults.standard.string(forKey: "update_frequency"),
           let frequency = UpdateFrequency(rawValue: frequencyRaw) {
            updateFrequency = frequency
        }
        
        backgroundProcessingEnabled = UserDefaults.standard.bool(forKey: "background_processing_enabled")
    }
    
    private func setupObservers() {
        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
            .sink { [weak self] _ in
                self?.loadAPIKeys()
                self?.loadSettings()
            }
            .store(in: &cancellables)
    }
    
    private func showAlert(message: String) {
        alertMessage = message
        showAlert = true
    }
}
