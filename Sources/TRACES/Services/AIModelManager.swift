//
//  AIModelManager.swift
//  TRACES
//
//  Created by TRACES Development Team on 12/15/2024.
//

import Foundation
import CoreML
import Vision
import AVFoundation
import Combine
import CoreLocation
import Speech
import UIKit

// MARK: - AI Model Manager
class AIModelManager: ObservableObject {
    static let shared = AIModelManager()
    
    // MARK: - Published Properties
    @Published var modelsLoaded = false
    @Published var loadingProgress: Double = 0.0
    @Published var isProcessing = false
    @Published var errorMessage: String?
    
    // MARK: - AI Models
    private var gemmaModel: MLModel?
    private var mobileVLMModel: MLModel?
    private var animateDiffModel: MLModel?
    private var speechRecognizer: SFSpeechRecognizer?
    
    // MARK: - Configuration
    private let modelLoadTimeout: TimeInterval = 30.0
    private let maxProcessingTime: TimeInterval = 45.0
    
    private init() {
        setupSpeechRecognition()
    }
    
    // MARK: - Model Loading
    func loadModels() async {
        guard !modelsLoaded else { return }
        
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.loadGemmaModel() }
            group.addTask { await self.loadMobileVLMModel() }
            group.addTask { await self.loadAnimateDiffModel() }
            
            for await _ in group {
                loadingProgress += 1.0 / 3.0
            }
        }
        
        modelsLoaded = true
    }
    
    private func loadGemmaModel() async {
        do {
            guard let modelURL = Bundle.main.url(forResource: "Gemma2B_TRACES", withExtension: "mlmodelc") else {
                throw AIModelError.modelNotFound("Gemma 2B model not found")
            }
            
            let config = MLModelConfiguration()
            config.computeUnits = .all
            
            gemmaModel = try MLModel(contentsOf: modelURL, configuration: config)
            print("✅ Gemma 2B model loaded successfully")
        } catch {
            print("❌ Failed to load Gemma 2B model: \(error)")
            errorMessage = "Failed to load text generation model"
        }
    }
    
    private func loadMobileVLMModel() async {
        if #available(iOS 18.0, *) {
            do {
                // Use Apple's built-in VLM capabilities
                mobileVLMModel = try await loadAppleVLMModel()
                print("✅ Mobile VLM model loaded successfully")
            } catch {
                print("❌ Failed to load Mobile VLM model: \(error)")
                errorMessage = "Failed to load vision model"
            }
        } else {
            print("⚠️ Mobile VLM not available on iOS < 18.0")
        }
    }
    
    @available(iOS 18.0, *)
    private func loadAppleVLMModel() async throws -> MLModel {
        // This would use Apple's new VLM framework
        // For now, we'll create a placeholder
        throw AIModelError.modelNotSupported("VLM not yet implemented")
    }
    
    private func loadAnimateDiffModel() async {
        do {
            guard let modelURL = Bundle.main.url(forResource: "AnimateDiff_TRACES", withExtension: "mlmodelc") else {
                throw AIModelError.modelNotFound("AnimateDiff model not found")
            }
            
            let config = MLModelConfiguration()
            config.computeUnits = .neuralEngine
            
            animateDiffModel = try MLModel(contentsOf: modelURL, configuration: config)
            print("✅ AnimateDiff model loaded successfully")
        } catch {
            print("❌ Failed to load AnimateDiff model: \(error)")
            errorMessage = "Failed to load video generation model"
        }
    }
    
    // MARK: - Timeline Generation
    func generateTimeline(
        decision: String,
        style: VideoStyle,
        progressHandler: @escaping (Double) -> Void
    ) async -> Timeline? {
        
        isProcessing = true
        errorMessage = nil
        
        defer {
            isProcessing = false
        }
        
        do {
            // Step 1: Generate decision paths (20% progress)
            progressHandler(0.2)
            let paths = try await generateDecisionPaths(for: decision)
            
            // Step 2: Analyze emotional tone (40% progress)
            progressHandler(0.4)
            let emotionalTone = try await analyzeEmotionalTone(decision: decision, paths: paths)
            
            // Step 3: Generate title (60% progress)
            progressHandler(0.6)
            let title = try await generateTimelineTitle(decision: decision, emotionalTone: emotionalTone)
            
            // Step 4: Generate video (80% progress)
            progressHandler(0.8)
            let videoURL = try await generateTimelineVideo(
                decision: decision,
                style: style,
                emotionalTone: emotionalTone
            )
            
            // Step 5: Generate thumbnail (100% progress)
            progressHandler(1.0)
            let thumbnailURL = try await generateTimelineThumbnail(from: videoURL)
            
            return Timeline(
                title: title,
                decision: decision,
                createdDate: Date(),
                videoURL: videoURL,
                thumbnailURL: thumbnailURL,
                style: style,
                paths: paths,
                emotionalTone: emotionalTone,
                duration: 3.0
            )
            
        } catch {
            errorMessage = "Timeline generation failed: \(error.localizedDescription)"
            return nil
        }
    }
    
    private func generateDecisionPaths(for decision: String) async throws -> [DecisionPath] {
        guard let gemmaModel = gemmaModel else {
            throw AIModelError.modelNotLoaded("Gemma model not loaded")
        }
        
        let prompt = """
        Analyze this life decision: "\(decision)"
        
        Generate 3 possible outcome paths with:
        1. Title (short, descriptive)
        2. Probability (0.0 to 1.0)
        3. Outcome description (1-2 sentences)
        4. Emotional indicator (success, challenge, growth, neutral)
        
        Format as JSON array with keys: title, probability, outcomeDescription, emotionalIndicator
        """
        
        let response = try await generateTextWithGemma(prompt: prompt)
        
        // Parse response into DecisionPath objects
        guard let data = response.data(using: .utf8),
              let paths = try? JSONDecoder().decode([DecisionPath].self, from: data) else {
            throw AIModelError.responseParsingFailed("Failed to parse decision paths")
        }
        
        return paths
    }
    
    private func analyzeEmotionalTone(decision: String, paths: [DecisionPath]) async throws -> EmotionalTone {
        // Simple emotional tone analysis based on decision keywords and path probabilities
        let positiveKeywords = ["opportunity", "growth", "success", "improve", "better", "new"]
        let negativeKeywords = ["risk", "failure", "loss", "difficult", "hard", "challenge"]
        
        let lowercasedDecision = decision.lowercased()
        var positiveScore = 0
        var negativeScore = 0
        
        for keyword in positiveKeywords {
            if lowercasedDecision.contains(keyword) { positiveScore += 1 }
        }
        
        for keyword in negativeKeywords {
            if lowercasedDecision.contains(keyword) { negativeScore += 1 }
        }
        
        // Consider path probabilities
        let successProbability = paths.first { $0.emotionalIndicator == .success }?.probability ?? 0
        let challengeProbability = paths.first { $0.emotionalIndicator == .challenge }?.probability ?? 0
        
        if positiveScore > negativeScore && successProbability > 0.5 {
            return .optimistic
        } else if negativeScore > positiveScore || challengeProbability > 0.6 {
            return .challenging
        } else {
            return .realistic
        }
    }
    
    private func generateTimelineTitle(decision: String, emotionalTone: EmotionalTone) async throws -> String {
        // Generate a concise title based on the decision
        let words = decision.components(separatedBy: .whitespacesAndNewlines)
        let keywords = words.filter { word in
            let length = word.count
            return length > 3 && !["should", "would", "could", "will", "have", "this", "that"].contains(word.lowercased())
        }
        
        let prefix = emotionalTone == .optimistic ? "Path to" : 
                     emotionalTone == .challenging ? "Challenge of" : "Decision about"
        
        if let firstKeyword = keywords.first {
            return "\(prefix) \(firstKeyword.capitalized)"
        } else {
            return "Life Decision"
        }
    }
    
    private func generateTimelineVideo(
        decision: String,
        style: VideoStyle,
        emotionalTone: EmotionalTone
    ) async throws -> URL? {
        
        guard let animateDiffModel = animateDiffModel else {
            throw AIModelError.modelNotLoaded("AnimateDiff model not loaded")
        }
        
        // Create temporary video file
        let tempDir = FileManager.default.temporaryDirectory
        let videoURL = tempDir.appendingPathComponent("timeline_\(UUID().uuidString).mp4")
        
        // Simulate video generation process
        // In a real implementation, this would use AnimateDiff to generate the video
        try await Task.sleep(nanoseconds: 10_000_000_000) // 10 seconds simulation
        
        // Create mock video file (placeholder)
        let mockVideoData = "Mock video data for \(decision)".data(using: .utf8)!
        try mockVideoData.write(to: videoURL)
        
        return videoURL
    }
    
    private func generateTimelineThumbnail(from videoURL: URL?) async throws -> URL? {
        guard let videoURL = videoURL else { return nil }
        
        // Generate thumbnail from video
        let asset = AVAsset(url: videoURL)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        
        let time = CMTimeMake(value: 1, timescale: 1)
        let cgImage = try imageGenerator.copyCGImage(at: time, actualTime: nil)
        
        let thumbnailURL = FileManager.default.temporaryDirectory.appendingPathComponent("thumbnail_\(UUID().uuidString).jpg")
        
        if let data = UIImage(cgImage: cgImage).jpegData(compressionQuality: 0.8) {
            try data.write(to: thumbnailURL)
            return thumbnailURL
        }
        
        return nil
    }
    
    // MARK: - Text Generation
    private func generateTextWithGemma(prompt: String) async throws -> String {
        guard let gemmaModel = gemmaModel else {
            throw AIModelError.modelNotLoaded("Gemma model not loaded")
        }
        
        // Create input for Gemma model
        let input = Gemma2BInput(text: prompt)
        
        do {
            let output = try gemmaModel.prediction(from: input)
            
            if let textOutput = output.featureValue(for: "output")?.stringValue {
                return textOutput
            } else {
                throw AIModelError.inferenceFailed("No output from Gemma model")
            }
        } catch {
            throw AIModelError.inferenceFailed("Gemma inference failed: \(error)")
        }
    }
    
    // MARK: - Wisdom Generation
    func generateWisdom(from timeline: Timeline) async throws -> WisdomItem {
        guard let gemmaModel = gemmaModel else {
            throw AIModelError.modelNotLoaded("Gemma model not loaded")
        }
        
        let prompt = """
        Based on this timeline analysis:
        Decision: "\(timeline.decision)"
        Emotional Tone: \(timeline.emotionalTone.rawValue)
        
        Generate wisdom that could help others facing similar decisions.
        
        Include:
        1. A compelling title
        2. Practical advice (2-3 sentences)
        3. Category (career, relationship, personal_growth, finance, health)
        
        Format as JSON with keys: title, description, category
        """
        
        let response = try await generateTextWithGemma(prompt: prompt)
        
        // Parse response
        guard let data = response.data(using: .utf8),
              let wisdom = try? JSONDecoder().decode(WisdomResponse.self, from: data) else {
            throw AIModelError.responseParsingFailed("Failed to parse wisdom response")
        }
        
        return WisdomItem(
            id: UUID().uuidString,
            title: wisdom.title,
            description: wisdom.description,
            price: 15, // Default price
            category: wisdom.category,
            author: "TRACES AI",
            rating: 0.0,
            purchaseCount: 0
        )
    }
    
    // MARK: - Speech Recognition
    private func setupSpeechRecognition() {
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
        speechRecognizer?.delegate = self
    }
    
    func requestSpeechRecognitionPermission() async -> Bool {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }
    
    func startSpeechRecognition() async throws -> SFSpeechAudioBufferRecognitionRequest? {
        guard let recognizer = speechRecognizer, recognizer.isAvailable else {
            throw AIModelError.speechRecognitionNotAvailable("Speech recognizer not available")
        }
        
        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        
        return request
    }
    
    // MARK: - Image Analysis
    func analyzeImage(_ image: UIImage) async throws -> String {
        guard let mobileVLMModel = mobileVLMModel else {
            throw AIModelError.modelNotLoaded("VLM model not loaded")
        }
        
        // Convert UIImage to CIImage
        guard let ciImage = CIImage(image: image) else {
            throw AIModelError.imageProcessingFailed("Failed to convert image")
        }
        
        // Create vision request
        let request = VNCoreMLRequest(model: try VNCoreMLModel(for: mobileVLMModel))
        
        // Perform analysis
        let handler = VNImageRequestHandler(ciImage: ciImage)
        try handler.perform([request])
        
        guard let results = request.results as? [VNClassificationObservation],
              let topResult = results.first else {
            throw AIModelError.inferenceFailed("No image analysis results")
        }
        
        return topResult.identifier
    }
    
    // MARK: - AR Content Generation
    func generateARContent(for location: CLLocationCoordinate2D) async throws -> ARContent {
        guard let gemmaModel = gemmaModel else {
            throw AIModelError.modelNotLoaded("Gemma model not loaded")
        }
        
        let prompt = """
        Generate AR content for location at latitude: \(location.latitude), longitude: \(location.longitude)
        
        Create:
        1. An inspiring quote about this location
        2. A question for reflection
        3. A visualization concept
        
        Format as JSON with keys: quote, question, visualization
        """
        
        let response = try await generateTextWithGemma(prompt: prompt)
        
        guard let data = response.data(using: .utf8),
              let content = try? JSONDecoder().decode(ARContentResponse.self, from: data) else {
            throw AIModelError.responseParsingFailed("Failed to parse AR content response")
        }
        
        return ARContent(
            quote: content.quote,
            question: content.question,
            visualization: content.visualization
        )
    }
}

// MARK: - Supporting Types
struct Gemma2BInput: MLFeatureProvider {
    let text: String
    
    var featureNames: Set<String> {
        return ["input"]
    }
    
    func featureValue(for featureName: String) -> MLFeatureValue? {
        guard featureName == "input" else { return nil }
        return MLFeatureValue(string: text)
    }
}

struct WisdomResponse: Codable {
    let title: String
    let description: String
    let category: WisdomCategory
}

struct ARContentResponse: Codable {
    let quote: String
    let question: String
    let visualization: String
}

struct ARContent {
    let quote: String
    let question: String
    let visualization: String
}

// MARK: - SFSpeechRecognizerDelegate
extension AIModelManager: SFSpeechRecognizerDelegate {
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        // Handle speech recognizer availability changes
    }
}

// MARK: - Error Types
enum AIModelError: LocalizedError {
    case modelNotFound(String)
    case modelNotLoaded(String)
    case modelNotSupported(String)
    case inferenceFailed(String)
    case responseParsingFailed(String)
    case speechRecognitionNotAvailable(String)
    case imageProcessingFailed(String)
    case timeout(String)
    
    var errorDescription: String? {
        switch self {
        case .modelNotFound(let message):
            return "Model not found: \(message)"
        case .modelNotLoaded(let message):
            return "Model not loaded: \(message)"
        case .modelNotSupported(let message):
            return "Model not supported: \(message)"
        case .inferenceFailed(let message):
            return "Inference failed: \(message)"
        case .responseParsingFailed(let message):
            return "Response parsing failed: \(message)"
        case .speechRecognitionNotAvailable(let message):
            return "Speech recognition not available: \(message)"
        case .imageProcessingFailed(let message):
            return "Image processing failed: \(message)"
        case .timeout(let message):
            return "Operation timed out: \(message)"
        }
    }
}