import Foundation
import Security
import KeychainAccess

final class SecureConfig {
    static let shared = SecureConfig()
    
    private let keychain = Keychain(service: "com.ibiome.secure")
    private let defaults = UserDefaults.standard
    
    // MARK: - AI Configuration Keys
    private enum ConfigKey: String {
        case openAIEnabled = "ai_openai_enabled"
        case claudeEnabled = "ai_claude_enabled"
        case aiFeatureEnabled = "ai_feature_enabled"
        case openAIModel = "ai_openai_model"
        case claudeModel = "ai_claude_model"
        
        // Keychain keys
        case openAIKey = "OPENAI_API_KEY"
        case claudeKey = "CLAUDE_API_KEY"
        case endpointOpenAI = "OPENAI_ENDPOINT"
        case endpointClaude = "CLAUDE_ENDPOINT"
    }
    
    // MARK: - Public Interface
    
    var isAIEnabled: Bool {
        get { defaults.bool(forKey: ConfigKey.aiFeatureEnabled.rawValue) }
        set { defaults.set(newValue, forKey: ConfigKey.aiFeatureEnabled.rawValue) }
    }
    
    var isOpenAIEnabled: Bool {
        get { defaults.bool(forKey: ConfigKey.openAIEnabled.rawValue) }
        set { defaults.set(newValue, forKey: ConfigKey.openAIEnabled.rawValue) }
    }
    
    var isClaudeEnabled: Bool {
        get { defaults.bool(forKey: ConfigKey.claudeEnabled.rawValue) }
        set { defaults.set(newValue, forKey: ConfigKey.claudeEnabled.rawValue) }
    }
    
    // MARK: - API Keys Management
    
    func setAPIKey(_ key: String, for service: AIService) throws {
        let keychainKey = keychainKey(for: service)
        try keychain.set(key, key: keychainKey)
    }
    
    func getAPIKey(for service: AIService) throws -> String {
        let keychainKey = keychainKey(for: service)
        guard let key = try keychain.get(keychainKey) else {
            throw ConfigError.keyNotFound
        }
        return key
    }
    
    func setEndpoint(_ endpoint: String, for service: AIService) throws {
        let keychainKey = endpointKey(for: service)
        try keychain.set(endpoint, key: keychainKey)
    }
    
    func getEndpoint(for service: AIService) throws -> String {
        let keychainKey = endpointKey(for: service)
        guard let endpoint = try keychain.get(keychainKey) else {
            throw ConfigError.endpointNotFound
        }
        return endpoint
    }
    
    // MARK: - Model Configuration
    
    func setModel(_ model: String, for service: AIService) {
        let key = modelKey(for: service)
        defaults.set(model, forKey: key)
    }
    
    func getModel(for service: AIService) -> String {
        let key = modelKey(for: service)
        return defaults.string(forKey: key) ?? defaultModel(for: service)
    }
    
    // MARK: - Helper Methods
    
    private func keychainKey(for service: AIService) -> String {
        switch service {
        case .openAI:
            return ConfigKey.openAIKey.rawValue
        case .claude:
            return ConfigKey.claudeKey.rawValue
        }
    }
    
    private func endpointKey(for service: AIService) -> String {
        switch service {
        case .openAI:
            return ConfigKey.endpointOpenAI.rawValue
        case .claude:
            return ConfigKey.endpointClaude.rawValue
        }
    }
    
    private func modelKey(for service: AIService) -> String {
        switch service {
        case .openAI:
            return ConfigKey.openAIModel.rawValue
        case .claude:
            return ConfigKey.claudeModel.rawValue
        }
    }
    
    private func defaultModel(for service: AIService) -> String {
        switch service {
        case .openAI:
            return "gpt-4"
        case .claude:
            return "claude-3-sonnet"
        }
    }
}

// MARK: - Supporting Types

enum AIService {
    case openAI
    case claude
}

enum ConfigError: Error {
    case keyNotFound
    case endpointNotFound
    case invalidConfiguration
    case encryptionFailed
    case decryptionFailed
}
