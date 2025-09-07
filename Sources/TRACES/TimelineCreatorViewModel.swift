//
//  TimelineCreatorViewModel.swift
//  TRACES
//
//  Created by TRACES Development Team on 12/15/2024.
//

import Foundation
import SwiftUI

class TimelineCreatorViewModel: ObservableObject {
    @Published var currentStep: TimelineCreationStep = .decisionInput
    @Published var decisionText: String = ""
    @Published var selectedStyle: VideoStyle = .realistic
    @Published var timelineLength: Double = 3.0
    @Published var emotionalTone: EmotionalTone = .balanced
    @Published var pathCount: Int = 3
    @Published var isGenerating: Bool = false
    @Published var generationProgress: Double = 0.0
    @Published var generatedTimeline: Timeline?
    @Published var currentPsychologyFact: String = ""
    
    private let psychologyFacts = TimelineCreatorMockData.psychologyFacts
    
    var canProceed: Bool {
        switch currentStep {
        case .decisionInput:
            return !decisionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .styleSelection:
            return true // Style is always selected
        case .parameterTuning:
            return true // Parameters always have defaults
        case .generation, .review:
            return false // These steps don't have "proceed" buttons
        }
    }
    
    func proceedToNextStep() {
        guard canProceed else { return }
        
        withAnimation(.spring()) {
            if let nextStep = TimelineCreationStep(rawValue: currentStep.rawValue + 1) {
                currentStep = nextStep
            }
        }
    }
    
    func goToPreviousStep() {
        withAnimation(.spring()) {
            if let previousStep = TimelineCreationStep(rawValue: currentStep.rawValue - 1) {
                currentStep = previousStep
            }
        }
    }
    
    func reset() {
        withAnimation(.spring()) {
            currentStep = .decisionInput
            decisionText = ""
            selectedStyle = .realistic
            timelineLength = 3.0
            emotionalTone = .balanced
            pathCount = 3
            isGenerating = false
            generationProgress = 0.0
            generatedTimeline = nil
        }
    }
    
    func startGeneration() {
        withAnimation(.spring()) {
            currentStep = .generation
            isGenerating = true
            generationProgress = 0.0
        }
        
        generateTimeline()
    }
    
    private func generateTimeline() {
        // Simulate timeline generation with progress updates
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            DispatchQueue.main.async {
                self.generationProgress += 0.02
                
                // Update psychology fact every 25% progress
                if self.generationProgress.truncatingRemainder(dividingBy: 0.25) < 0.02 {
                    self.currentPsychologyFact = self.psychologyFacts.randomElement() ?? ""
                }
                
                if self.generationProgress >= 1.0 {
                    timer.invalidate()
                    self.generationProgress = 1.0
                    self.isGenerating = false
                    
                    // Generate mock timeline
                    self.generatedTimeline = self.createMockTimeline()
                    
                    withAnimation(.spring()) {
                        self.currentStep = .review
                    }
                }
            }
        }
    }
    
    func loadMockData() {
        // Load any necessary mock data
        currentPsychologyFact = psychologyFacts.first ?? ""
    }
    
    private func createMockTimeline() -> Timeline {
        return TimelineCreatorMockData.generateMockTimeline(
            decisionText: decisionText,
            style: selectedStyle,
            emotionalTone: emotionalTone,
            pathCount: pathCount
        )
    }
}