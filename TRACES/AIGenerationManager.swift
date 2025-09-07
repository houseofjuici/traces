//
//  AIGenerationManager.swift
//  TRACES
//
//  Created by TRACES Development Team on 12/15/2024.
//

import SwiftUI
import Combine
import CoreML

// MARK: - AI Generation State Manager
@MainActor
class AIGenerationManager: ObservableObject {
    @Published var isGenerating: Bool = false
    @Published var generationProgress: Double = 0.0
    @Published var currentStep: GenerationStep = .idle
    @Published var estimatedTimeRemaining: TimeInterval = 0
    @Published var generationError: Error?
    @Published var activeGenerations: [String: GenerationSession] = [:]
    
    private var progressTimer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    enum GenerationStep: String, CaseIterable {
        case idle = "Idle"
        case textAnalysis = "Analyzing Decision"
        case contextProcessing = "Processing Context"
        case perspectiveGeneration = "Generating Perspectives"
        case visualGeneration = "Creating Visuals"
        case videoRendering = "Rendering Video"
        case finalAssembly = "Final Assembly"
        case completed = "Completed"
        case failed = "Failed"
        
        var progressWeight: Double {
            switch self {
            case .idle: return 0.0
            case .textAnalysis: return 0.15
            case .contextProcessing: return 0.25
            case .perspectiveGeneration: return 0.45
            case .visualGeneration: return 0.65
            case .videoRendering: return 0.85
            case .finalAssembly: return 0.95
            case .completed: return 1.0
            case .failed: return 0.0
            }
        }
        
        var estimatedDuration: TimeInterval {
            switch self {
            case .idle: return 0
            case .textAnalysis: return 3
            case .contextProcessing: return 5
            case .perspectiveGeneration: return 8
            case .visualGeneration: return 12
            case .videoRendering: return 15
            case .finalAssembly: return 5
            case .completed: return 0
            case .failed: return 0
            }
        }
    }
    
    struct GenerationSession {
        let id: String
        let startTime: Date
        let decision: String
        let style: VideoStyle
        var currentStep: GenerationStep
        var progress: Double
        var estimatedCompletion: Date
        var error: Error?
        
        var elapsedTime: TimeInterval {
            Date().timeIntervalSince(startTime)
        }
        
        var remainingTime: TimeInterval {
            max(0, estimatedCompletion.timeIntervalSince(Date()))
        }
    }
    
    // MARK: - Generation Control
    func startGeneration(decision: String, style: VideoStyle) async throws -> Timeline {
        let sessionId = UUID().uuidString
        let session = GenerationSession(
            id: sessionId,
            startTime: Date(),
            decision: decision,
            style: style,
            currentStep: .textAnalysis,
            progress: 0.0,
            estimatedCompletion: Date().addingTimeInterval(45), // 45 seconds total
            error: nil
        )
        
        activeGenerations[sessionId] = session
        isGenerating = true
        currentStep = .textAnalysis
        generationProgress = 0.0
        generationError = nil
        
        // Start progress monitoring
        startProgressMonitoring(sessionId: sessionId)
        
        do {
            let timeline = try await performGeneration(session: session)
            completeGeneration(sessionId: sessionId, timeline: timeline)
            return timeline
        } catch {
            failGeneration(sessionId: sessionId, error: error)
            throw error
        }
    }
    
    func cancelGeneration(sessionId: String) {
        guard let session = activeGenerations[sessionId] else { return }
        
        // Clean up session
        activeGenerations.removeValue(forKey: sessionId)
        
        // If this was the active generation, reset state
        if currentStep != .idle && currentStep != .completed && currentStep != .failed {
            resetGenerationState()
        }
        
        progressTimer?.invalidate()
    }
    
    func pauseGeneration(sessionId: String) {
        guard let session = activeGenerations[sessionId] else { return }
        
        // Update session state
        var updatedSession = session
        updatedSession.currentStep = .idle
        activeGenerations[sessionId] = updatedSession
        
        progressTimer?.invalidate()
    }
    
    func resumeGeneration(sessionId: String) async throws -> Timeline {
        guard let session = activeGenerations[sessionId] else {
            throw NSError(domain: "AIGenerationManager", code: 404, userInfo: [NSLocalizedDescriptionKey: "Session not found"])
        }
        
        // Resume from current step
        return try await startGeneration(decision: session.decision, style: session.style)
    }
    
    // MARK: - Progress Monitoring
    private func startProgressMonitoring(sessionId: String) {
        progressTimer?.invalidate()
        
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateProgress(sessionId: sessionId)
            }
        }
    }
    
    private func updateProgress(sessionId: String) {
        guard let session = activeGenerations[sessionId] else { return }
        
        let elapsedTime = session.elapsedTime
        let totalEstimatedTime = session.estimatedCompletion.timeIntervalSince(session.startTime)
        let rawProgress = min(1.0, elapsedTime / totalEstimatedTime)
        
        // Apply step-based progress smoothing
        let stepProgress = session.currentStep.progressWeight
        let smoothedProgress = stepProgress + (rawProgress - stepProgress) * 0.3
        
        var updatedSession = session
        updatedSession.progress = smoothedProgress
        updatedSession.estimatedCompletion = session.startTime.addingTimeInterval(totalEstimatedTime)
        
        activeGenerations[sessionId] = updatedSession
        
        // Update current step based on progress
        updateCurrentStep(for: smoothedProgress)
        
        // Update published properties
        generationProgress = smoothedProgress
        estimatedTimeRemaining = updatedSession.remainingTime
    }
    
    private func updateCurrentStep(for progress: Double) {
        let newStep: GenerationStep
        
        switch progress {
        case 0.0..<0.15:
            newStep = .textAnalysis
        case 0.15..<0.25:
            newStep = .contextProcessing
        case 0.25..<0.45:
            newStep = .perspectiveGeneration
        case 0.45..<0.65:
            newStep = .visualGeneration
        case 0.65..<0.85:
            newStep = .videoRendering
        case 0.85..<0.95:
            newStep = .finalAssembly
        case 0.95...1.0:
            newStep = .completed
        default:
            newStep = .idle
        }
        
        if newStep != currentStep {
            currentStep = newStep
        }
    }
    
    // MARK: - Generation Process
    private func performGeneration(session: GenerationSession) async throws -> Timeline {
        // Step 1: Text Analysis
        try await executeStep(.textAnalysis) {
            try await self.analyzeDecisionText(session.decision)
        }
        
        // Step 2: Context Processing
        try await executeStep(.contextProcessing) {
            try await self.processContext(session.decision, session.style)
        }
        
        // Step 3: Perspective Generation
        let perspectives = try await executeStep(.perspectiveGeneration) {
            try await self.generatePerspectives(session.decision, session.style)
        }
        
        // Step 4: Visual Generation
        let visuals = try await executeStep(.visualGeneration) {
            try await self.generateVisuals(perspectives, session.style)
        }
        
        // Step 5: Video Rendering
        let videoURL = try await executeStep(.videoRendering) {
            try await self.renderVideo(visuals, session.style)
        }
        
        // Step 6: Final Assembly
        let timeline = try await executeStep(.finalAssembly) {
            try await self.assembleTimeline(
                decision: session.decision,
                style: session.style,
                perspectives: perspectives,
                videoURL: videoURL
            )
        }
        
        return timeline
    }
    
    private func executeStep<T>(_ step: GenerationStep, operation: () async throws -> T) async throws -> T {
        updateCurrentStep(for: step.progressWeight)
        return try await operation()
    }
    
    // MARK: - Generation Steps (Mock Implementation)
    private func analyzeDecisionText(_ decision: String) async throws -> String {
        try await Task.sleep(nanoseconds: 3_000_000_000) // 3 seconds
        return "Analyzed: \(decision)"
    }
    
    private func processContext(_ decision: String, _ style: VideoStyle) async throws -> String {
        try await Task.sleep(nanoseconds: 5_000_000_000) // 5 seconds
        return "Context processed for \(style.rawValue)"
    }
    
    private func generatePerspectives(_ decision: String, _ style: VideoStyle) async throws -> [DecisionPath] {
        try await Task.sleep(nanoseconds: 8_000_000_000) // 8 seconds
        
        return [
            DecisionPath(
                id: UUID(),
                title: "Optimistic Path",
                outcomeDescription: "Best case scenario based on your decision",
                probability: 0.4,
                emotionalIndicator: .success,
                keyMoments: []
            ),
            DecisionPath(
                id: UUID(),
                title: "Realistic Path",
                outcomeDescription: "Most likely outcome",
                probability: 0.4,
                emotionalIndicator: .neutral,
                keyMoments: []
            ),
            DecisionPath(
                id: UUID(),
                title: "Challenging Path",
                outcomeDescription: "Potential difficulties to overcome",
                probability: 0.2,
                emotionalIndicator: .challenge,
                keyMoments: []
            )
        ]
    }
    
    private func generateVisuals(_ perspectives: [DecisionPath], _ style: VideoStyle) async throws -> [URL] {
        try await Task.sleep(nanoseconds: 12_000_000_000) // 12 seconds
        return [URL(string: "https://example.com/visual.jpg")!]
    }
    
    private func renderVideo(_ visuals: [URL], _ style: VideoStyle) async throws -> URL {
        try await Task.sleep(nanoseconds: 15_000_000_000) // 15 seconds
        return URL(string: "https://example.com/timeline.mp4")!
    }
    
    private func assembleTimeline(decision: String, style: VideoStyle, perspectives: [DecisionPath], videoURL: URL) async throws -> Timeline {
        try await Task.sleep(nanoseconds: 5_000_000_000) // 5 seconds
        
        return Timeline(
            id: UUID(),
            title: "Timeline: \(decision.prefix(20))...",
            decisionText: decision,
            style: style,
            duration: 3.0,
            paths: perspectives,
            createdAt: Date(),
            videoURL: videoURL
        )
    }
    
    // MARK: - State Management
    private func completeGeneration(sessionId: String, timeline: Timeline) {
        activeGenerations.removeValue(forKey: sessionId)
        currentStep = .completed
        generationProgress = 1.0
        isGenerating = false
        progressTimer?.invalidate()
    }
    
    private func failGeneration(sessionId: String, error: Error) {
        if var session = activeGenerations[sessionId] {
            session.error = error
            session.currentStep = .failed
            activeGenerations[sessionId] = session
        }
        
        generationError = error
        currentStep = .failed
        isGenerating = false
        progressTimer?.invalidate()
    }
    
    private func resetGenerationState() {
        currentStep = .idle
        generationProgress = 0.0
        isGenerating = false
        estimatedTimeRemaining = 0
        generationError = nil
        progressTimer?.invalidate()
    }
    
    // MARK: - Cleanup
    func cleanup() {
        progressTimer?.invalidate()
        activeGenerations.removeAll()
        resetGenerationState()
    }
}

// MARK: - AI Generation Progress View
struct AIGenerationProgressView: View {
    @StateObject private var aiManager = AIGenerationManager()
    let sessionId: String
    let onCancel: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                Text("Generating Timeline")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("This usually takes 30-60 seconds")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Progress Circle
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 8)
                    .frame(width: 120, height: 120)
                
                Circle()
                    .trim(from: 0, to: aiManager.generationProgress)
                    .stroke(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.3), value: aiManager.generationProgress)
                
                VStack(spacing: 4) {
                    Text("\(Int(aiManager.generationProgress * 100))%")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(aiManager.currentStep.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Step Progress
            VStack(alignment: .leading, spacing: 8) {
                ForEach(AIGenerationManager.GenerationStep.allCases, id: \.self) { step in
                    if step != .idle && step != .completed && step != .failed {
                        HStack {
                            Image(systemName: stepIcon(for: step))
                                .font(.caption)
                                .foregroundColor(stepColor(for: step))
                            
                            Text(step.rawValue)
                                .font(.caption)
                                .foregroundColor(stepColor(for: step))
                            
                            Spacer()
                            
                            if step == aiManager.currentStep {
                                ProgressView()
                                    .scaleEffect(0.7)
                            } else if aiManager.currentStep.rawValue > step.rawValue {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            }
                        }
                    }
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            
            // Time Remaining
            if aiManager.estimatedTimeRemaining > 0 {
                HStack {
                    Image(systemName: "clock")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("Estimated time: \(formatTime(aiManager.estimatedTimeRemaining))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Cancel Button
            Button("Cancel Generation") {
                aiManager.cancelGeneration(sessionId: sessionId)
                onCancel()
            }
            .foregroundColor(.red)
            .padding(.top)
        }
        .padding()
    }
    
    private func stepIcon(for step: AIGenerationManager.GenerationStep) -> String {
        switch step {
        case .textAnalysis: return "text.alignleft"
        case .contextProcessing: return "doc.text"
        case .perspectiveGeneration: return "brain.head.profile"
        case .visualGeneration: return "photo"
        case .videoRendering: return "video"
        case .finalAssembly: return "checkmark.seal"
        default: return "circle"
        }
    }
    
    private func stepColor(for step: AIGenerationManager.GenerationStep) -> Color {
        if step == aiManager.currentStep {
            return .blue
        } else if aiManager.currentStep.rawValue > step.rawValue {
            return .green
        } else {
            return .gray
        }
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        
        if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        } else {
            return "\(seconds)s"
        }
    }
}

// MARK: - Usage Example
struct AIGenerationExample: View {
    @State private var isGenerating = false
    @State private var generatedTimeline: Timeline?
    @State private var errorMessage: String?
    @State private var currentSessionId: String?
    
    var body: some View {
        VStack {
            if isGenerating {
                if let sessionId = currentSessionId {
                    AIGenerationProgressView(sessionId: sessionId) {
                        isGenerating = false
                        currentSessionId = nil
                    }
                }
            } else {
                VStack {
                    Button("Generate Timeline") {
                        startGeneration()
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    
                    if let timeline = generatedTimeline {
                        Text("Generated: \(timeline.title)")
                            .padding()
                    }
                    
                    if let errorMessage = errorMessage {
                        Text("Error: \(errorMessage)")
                            .foregroundColor(.red)
                            .padding()
                    }
                }
            }
        }
    }
    
    private func startGeneration() {
        isGenerating = true
        errorMessage = nil
        currentSessionId = UUID().uuidString
        
        Task {
            let aiManager = AIGenerationManager()
            do {
                let timeline = try await aiManager.startGeneration(
                    decision: "Should I change careers?",
                    style: .realistic
                )
                generatedTimeline = timeline
                isGenerating = false
                currentSessionId = nil
            } catch {
                errorMessage = error.localizedDescription
                isGenerating = false
                currentSessionId = nil
            }
        }
    }
}