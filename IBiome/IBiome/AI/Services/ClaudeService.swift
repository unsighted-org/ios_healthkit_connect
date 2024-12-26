import Foundation

final class ClaudeService: AIService {
    private let config = SecureConfig.shared
    private let metricsEngine = MetricsEngine.shared
    
    private var apiKey: String {
        get throws {
            try config.getAPIKey(for: .claude)
        }
    }
    
    private var endpoint: String {
        get throws {
            try config.getEndpoint(for: .claude)
        }
    }
    
    private var model: String {
        config.getModel(for: .claude)
    }
    
    func analyze(prompt: String) async throws -> String {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        do {
            let request = try createRequest(prompt: prompt)
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw AIError.invalidResponse
            }
            
            guard httpResponse.statusCode == 200 else {
                throw AIError.analysisError
            }
            
            let result = try JSONDecoder().decode(ClaudeResponse.self, from: data)
            recordMetrics(startTime: startTime, success: true)
            
            return result.content.first?.text ?? ""
        } catch {
            recordMetrics(startTime: startTime, success: false)
            throw error
        }
    }
    
    private func createRequest(prompt: String) throws -> URLRequest {
        var request = URLRequest(url: try createURL())
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(try apiKey)", forHTTPHeaderField: "x-api-key")
        
        let body = ClaudeRequest(
            model: model,
            prompt: systemPrompt + "\n\n" + prompt,
            maxTokens: 2000,
            temperature: 0.7
        )
        
        request.httpBody = try JSONEncoder().encode(body)
        return request
    }
    
    private func createURL() throws -> URL {
        guard let url = URL(string: try endpoint) else {
            throw AIError.invalidResponse
        }
        return url
    }
    
    private func recordMetrics(startTime: CFAbsoluteTime, success: Bool) {
        let duration = CFAbsoluteTimeGetCurrent() - startTime
        metricsEngine.recordNetworkLatency(duration, endpoint: "claude_analysis")
        
        if !success {
            metricsEngine.record(
                .healthDataError,
                value: 1,
                metadata: ["error": "claude_analysis_failed"]
            )
        }
    }
}

// MARK: - Request/Response Types

private struct ClaudeRequest: Codable {
    let model: String
    let prompt: String
    let maxTokens: Int
    let temperature: Double
    
    enum CodingKeys: String, CodingKey {
        case model
        case prompt
        case maxTokens = "max_tokens"
        case temperature
    }
}

private struct ClaudeResponse: Codable {
    struct Content: Codable {
        let text: String
    }
    
    let id: String
    let content: [Content]
}

// MARK: - Constants

private let systemPrompt = """
You are Claude, an AI health analyst specialized in analyzing health and environmental data. \
Your role is to provide insights, predictions, and recommendations based on the provided data. \
Focus on actionable insights that can help improve health outcomes while considering environmental factors.
"""
