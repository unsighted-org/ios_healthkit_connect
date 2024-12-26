import Foundation

final class OpenAIService: AIService {
    private let config = SecureConfig.shared
    private let metricsEngine = MetricsEngine.shared
    
    private var apiKey: String {
        get throws {
            try config.getAPIKey(for: .openAI)
        }
    }
    
    private var endpoint: String {
        get throws {
            try config.getEndpoint(for: .openAI)
        }
    }
    
    private var model: String {
        config.getModel(for: .openAI)
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
            
            let result = try JSONDecoder().decode(OpenAIResponse.self, from: data)
            recordMetrics(startTime: startTime, success: true)
            
            return result.choices.first?.message.content ?? ""
        } catch {
            recordMetrics(startTime: startTime, success: false)
            throw error
        }
    }
    
    private func createRequest(prompt: String) throws -> URLRequest {
        var request = URLRequest(url: try createURL())
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(try apiKey)", forHTTPHeaderField: "Authorization")
        
        let body = OpenAIRequest(
            model: model,
            messages: [
                Message(role: "system", content: systemPrompt),
                Message(role: "user", content: prompt)
            ]
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
        metricsEngine.recordNetworkLatency(duration, endpoint: "openai_analysis")
        
        if !success {
            metricsEngine.record(
                .healthDataError,
                value: 1,
                metadata: ["error": "openai_analysis_failed"]
            )
        }
    }
}

// MARK: - Request/Response Types

private struct OpenAIRequest: Codable {
    let model: String
    let messages: [Message]
}

private struct Message: Codable {
    let role: String
    let content: String
}

private struct OpenAIResponse: Codable {
    struct Choice: Codable {
        let message: Message
        let finishReason: String
        
        enum CodingKeys: String, CodingKey {
            case message
            case finishReason = "finish_reason"
        }
    }
    
    let id: String
    let choices: [Choice]
}

// MARK: - Constants

private let systemPrompt = """
You are an AI health analyst specialized in analyzing health and environmental data. \
Your role is to provide insights, predictions, and recommendations based on the provided data. \
Focus on actionable insights that can help improve health outcomes while considering environmental factors.
"""
