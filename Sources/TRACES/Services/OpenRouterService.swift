//
//  OpenRouterService.swift
//  TRACES
//
//  Created by TRACES Development Team on 12/15/2024.
//

import Foundation
import Combine

class OpenRouterService: ObservableObject {
    static let shared = OpenRouterService()
    
    // MARK: - Published Properties
    @Published var isLoading = false
    @Published var currentModel = ""
    @Published var rateLimited = false
    @Published var errorMessage: String?
    
    // MARK: - OpenRouter Configuration
    private let apiKey = "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"
    private let baseURL = "https://openrouter.ai/api/v1"
    
    // MARK: - Model Configuration (Stealth models first, then free models)
    private let stealthModels: [String] = [
        "openrouter/sonoma-sky-alpha",
        "openrouter/sonoma-alpha",
        "openrouter/sonoma",
        "nousresearch/nous-hermes-2-mixtral-8x7b-dpo",
        "perplexity/pplx-70b-online",
        "perplexity/pplx-7b-online"
    ]
    
    private let freeModels: [String] = [
        "google/gemma-7b-it:free",
        "mistralai/mistral-7b-instruct:free",
        "openchat/openchat-7b:free",
        "togethercomputer/stripedhyena-nous-7b:free",
        "google/palm-2-chat-bison:free",
        "cohere/command-r-plus:free"
    ]
    
    private var allModels: [String] = []
    private var currentModelIndex = 0
    private var lastRequestTime: Date?
    private var requestCount = 0
    
    // MARK: - Rate Limiting
    private let maxRequestsPerMinute = 60
    private let retryDelay: TimeInterval = 5.0
    
    private init() {
        allModels = stealthModels + freeModels
        currentModel = allModels.first ?? stealthModels.first ?? ""
    }
    
    // MARK: - Public API
    func generateTimelinePaths(decision: String) async throws -> [DecisionPath] {
        let prompt = """
        Analyze this life decision: "\(decision)"
        
        Generate 3 possible outcome paths with:
        1. Title (short, descriptive)
        2. Probability (0.0 to 1.0)
        3. Outcome description (1-2 sentences)
        4. Emotional indicator (success, challenge, growth, neutral)
        
        Format as JSON array with keys: title, probability, outcomeDescription, emotionalIndicator
        """
        
        let response = try await makeRequest(prompt: prompt)
        return try parseDecisionPaths(from: response)
    }
    
    func generateWisdom(from timeline: Timeline) async throws -> WisdomItem {
        let prompt = """
        Based on this timeline analysis:
        Decision: "\(timeline.decision)"
        Emotional Tone: \(timeline.emotionalTone.rawValue)
        
        Generate wisdom that could help others facing similar decisions.
        
        Include:
        1. A compelling title
        2. Practical advice (2-3 sentences)
        3. Category (career, relationship, personal_growth, finance, health)
        4. Price suggestion (5-50 credits)
        
        Format as JSON with keys: title, description, category, price
        """
        
        let response = try await makeRequest(prompt: prompt)
        return try parseWisdom(from: response)
    }
    
    func generateTimelineTitle(decision: String, emotionalTone: EmotionalTone) async throws -> String {
        let prompt = """
        Generate a concise, compelling title for a timeline about this decision: "\(decision)"
        
        The emotional tone is: \(emotionalTone.rawValue)
        
        Requirements:
        - 2-6 words maximum
        - Intriguing and thought-provoking
        - Reflect the emotional tone
        - No quotation marks
        
        Return only the title.
        """
        
        return try await makeRequest(prompt: prompt)
    }
    
    func generatePsychologyFact() async throws -> String {
        let facts = [
            "The human brain makes about 35,000 decisions per day, from simple choices to life-changing ones.",
            "Research shows that writing down decisions can reduce anxiety by up to 20%.",
            "People who visualize multiple outcomes make 37% more satisfying long-term decisions.",
            "The average person spends 13 years of their life making decisions.",
            "Studies show that discussing decisions with others increases decision quality by 25%.",
            "Your brain's prefrontal cortex, responsible for decision-making, continues developing until age 25.",
            "Research indicates that sleeping on important decisions leads to better outcomes 68% of the time.",
            "People who consider at least 3 options before deciding report 45% higher satisfaction.",
            "Studies show that writing down pros and cons activates different brain regions for better analysis.",
            "Research suggests that embracing uncertainty can lead to more creative solutions."
        ]
        
        // Return a random fact
        return facts.randomElement() ?? "Making decisions is a fundamental human experience."
    }
    
    func generateARContent(for location: CLLocationCoordinate2D) async throws -> ARContent {
        let prompt = """
        Generate AR content for a user at latitude: \(location.latitude), longitude: \(location.longitude)
        
        Create:
        1. An inspiring quote about decision-making and location
        2. A reflective question about this place
        3. A visualization concept for AR display
        
        Format as JSON with keys: quote, question, visualization
        """
        
        let response = try await makeRequest(prompt: prompt)
        return try parseARContent(from: response)
    }
    
    // MARK: - Private API
    private func makeRequest(prompt: String) async throws -> String {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        defer {
            Task { @MainActor in
                isLoading = false
            }
        }
        
        // Check rate limiting
        if rateLimited {
            try await Task.sleep(nanoseconds: UInt64(retryDelay * 1_000_000_000))
        }
        
        // Try current model, rotate if fails
        for attempt in 0..<allModels.count {
            let modelIndex = (currentModelIndex + attempt) % allModels.count
            let model = allModels[modelIndex]
            
            do {
                let response = try await callOpenRouter(prompt: prompt, model: model)
                
                // Success - update current model
                await MainActor.run {
                    currentModel = model
                    currentModelIndex = modelIndex
                    rateLimited = false
                }
                
                return response
                
            } catch {
                print("Failed with model \(model): \(error)")
                
                // If this was the last attempt, throw the error
                if attempt == allModels.count - 1 {
                    await MainActor.run {
                        rateLimited = true
                        errorMessage = "All models unavailable. Please try again later."
                    }
                    throw error
                }
                
                // Wait before trying next model
                try await Task.sleep(nanoseconds: UInt64(retryDelay * 1_000_000_000))
            }
        }
        
        throw NSError(domain: "OpenRouterService", code: 500, userInfo: [NSLocalizedDescriptionKey: "All models failed"])
    }
    
    private func callOpenRouter(prompt: String, model: String) async throws -> String {
        guard let url = URL(string: "\(baseURL)/chat/completions") else {
            throw NSError(domain: "OpenRouterService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("https://traces.app", forHTTPHeaderField: "HTTP-Referer")
        request.setValue("traces-ios-1.0", forHTTPHeaderField: "X-Title")
        
        let requestBody: [String: Any] = [
            "model": model,
            "messages": [
                [
                    "role": "user",
                    "content": prompt
                ]
            ],
            "max_tokens": 1000,
            "temperature": 0.7
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSError(domain: "OpenRouterService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
        }
        
        if httpResponse.statusCode == 429 {
            // Rate limited
            throw NSError(domain: "OpenRouterService", code: 429, userInfo: [NSLocalizedDescriptionKey: "Rate limited"])
        }
        
        guard httpResponse.statusCode == 200 else {
            let errorText = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw NSError(domain: "OpenRouterService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorText])
        }
        
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = json["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw NSError(domain: "OpenRouterService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])
        }
        
        return content
    }
    
    // MARK: - Parsing Helpers
    private func parseDecisionPaths(from response: String) throws -> [DecisionPath] {
        guard let data = response.data(using: .utf8) else {
            throw NSError(domain: "OpenRouterService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Invalid response data"])
        }
        
        do {
            let decoder = JSONDecoder()
            let paths = try decoder.decode([DecisionPath].self, from: data)
            return paths
        } catch {
            // Fallback: try to extract JSON from response
            if let range = response.range(of: "\\[.*\\]", options: .regularExpression) {
                let json = String(response[range])
                let data = json.data(using: .utf8)!
                let paths = try JSONDecoder().decode([DecisionPath].self, from: data)
                return paths
            }
            throw error
        }
    }
    
    private func parseWisdom(from response: String) throws -> WisdomItem {
        guard let data = response.data(using: .utf8) else {
            throw NSError(domain: "OpenRouterService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Invalid response data"])
        }
        
        do {
            let decoder = JSONDecoder()
            let wisdom = try decoder.decode(WisdomResponse.self, from: data)
            
            return WisdomItem(
                id: UUID().uuidString,
                title: wisdom.title,
                description: wisdom.description,
                price: wisdom.price,
                category: wisdom.category,
                author: "TRACES AI",
                rating: 0.0,
                purchaseCount: 0
            )
        } catch {
            // Fallback parsing
            throw NSError(domain: "OpenRouterService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to parse wisdom response"])
        }
    }
    
    private func parseARContent(from response: String) throws -> ARContent {
        guard let data = response.data(using: .utf8) else {
            throw NSError(domain: "OpenRouterService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Invalid response data"])
        }
        
        do {
            let decoder = JSONDecoder()
            let content = try decoder.decode(ARContentResponse.self, from: data)
            return ARContent(
                quote: content.quote,
                question: content.question,
                visualization: content.visualization
            )
        } catch {
            throw NSError(domain: "OpenRouterService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to parse AR content response"])
        }
    }
    
    // MARK: - Model Management
    func getCurrentModel() -> String {
        return currentModel
    }
    
    func getAvailableModels() -> [String] {
        return allModels
    }
    
    func resetRateLimiting() {
        Task { @MainActor in
            rateLimited = false
            errorMessage = nil
        }
    }
}

// MARK: - Supporting Types
struct WisdomResponse: Codable {
    let title: String
    let description: String
    let category: WisdomCategory
    let price: Int
}

struct ARContentResponse: Codable {
    let quote: String
    let question: String
    let visualization: String
}