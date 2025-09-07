//
//  TimelineCreatorView.swift
//  TRACES
//
//  Created by TRACES Development Team on 12/15/2024.
//

import SwiftUI
import AVKit

struct TimelineCreatorViewPure: View {
    // MARK: - Pure SwiftUI State (replacing ViewModel)
    @State private var currentStep: TimelineCreationStep = .decisionInput
    @State private var decisionText: String = ""
    @State private var selectedStyle: VideoStyle = .realistic
    @State private var timelineLength: Double = 3.0
    @State private var emotionalTone: EmotionalTone = .balanced
    @State private var pathCount: Int = 3
    @State private var isGenerating: Bool = false
    @State private var generationProgress: Double = 0.0
    @State private var generatedTimeline: Timeline?
    @State private var currentPsychologyFact: String = ""
    @State private var showingSuggestions = false
    
    // MARK: - Computed Properties (replacing ViewModel logic)
    private var canProceed: Bool {
        switch currentStep {
        case .decisionInput:
            return !decisionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .styleSelection:
            return true
        case .parameterTuning:
            return true
        case .generation, .review:
            return false
        }
    }
    
    private var psychologyFacts: [String] {
        [
            "Research shows that visualizing potential outcomes can reduce decision anxiety by up to 40%.",
            "The average person makes about 35,000 decisions per day, but only consciously considers about 70.",
            "Studies indicate that people who simulate future scenarios make 23% better long-term decisions.",
            "Neuroscience reveals that imagining future events activates the same brain regions as actual experiences.",
            "Decision fatigue affects the quality of choices - that's why TRACES helps automate the simulation process."
        ]
    }
    
    private var suggestions: [String] {
        [
            "Should I accept this job offer?",
            "Is it time to move to a new city?",
            "Should I start my own business?",
            "Is this relationship worth pursuing?",
            "Should I go back to school?",
            "Is it time to buy a house?"
        ]
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    gradient: Gradient(colors: [Color.black, Color.gray.opacity(0.1)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Create Timeline")
                                .font(TRACTypography.heroTitle)
                                .foregroundColor(.warmWhite)
                            
                            Text("Simulate your decision across multiple possible futures")
                                .font(.system(size: 16))
                                .foregroundColor(.warmWhite.opacity(0.8))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        
                        // Progress Dots
                        HStack(spacing: 12) {
                            ForEach(TimelineCreationStep.allCases, id: \.self) { step in
                                Circle()
                                    .fill(stepColor(for: step))
                                    .frame(width: 12, height: 12)
                                    .scaleEffect(currentStep == step ? 1.2 : 1.0)
                                    .animation(.spring(), value: currentStep)
                            }
                        }
                        .padding(.vertical, 8)
                        
                        // Step Content
                        Group {
                            switch currentStep {
                            case .decisionInput:
                                DecisionInputSectionPure(
                                    decisionText: $decisionText,
                                    showingSuggestions: $showingSuggestions,
                                    suggestions: suggestions
                                )
                            case .styleSelection:
                                StyleSelectionSectionPure(
                                    selectedStyle: $selectedStyle,
                                    timelineLength: $timelineLength
                                )
                            case .parameterTuning:
                                ParameterTuningSectionPure(
                                    timelineLength: $timelineLength,
                                    emotionalTone: $emotionalTone,
                                    pathCount: $pathCount
                                )
                            case .generation:
                                TimelineGenerationSectionPure(
                                    isGenerating: $isGenerating,
                                    generationProgress: $generationProgress,
                                    currentPsychologyFact: $currentPsychologyFact
                                )
                            case .review:
                                TimelineReviewSectionPure(
                                    generatedTimeline: generatedTimeline,
                                    decisionText: decisionText,
                                    selectedStyle: selectedStyle,
                                    timelineLength: timelineLength,
                                    emotionalTone: emotionalTone,
                                    pathCount: pathCount
                                )
                            }
                        }
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                        
                        // CTA Buttons
                        if currentStep != .generation && currentStep != .review {
                            HStack(spacing: 16) {
                                if currentStep != .decisionInput {
                                    Button("Back") {
                                        goToPreviousStep()
                                    }
                                    .secondaryButtonStyle()
                                }
                                
                                Button(currentStep == .parameterTuning ? "Generate Timeline" : "Continue") {
                                    if currentStep == .parameterTuning {
                                        startGeneration()
                                    } else {
                                        proceedToNextStep()
                                    }
                                }
                                .ctaButtonStyle()
                                .disabled(!canProceed)
                            }
                            .padding(.horizontal)
                        }
                        
                        if currentStep == .review {
                            HStack(spacing: 16) {
                                Button("Create Another") {
                                    reset()
                                }
                                .secondaryButtonStyle()
                                
                                Button("Save Timeline") {
                                    // TODO: Save timeline
                                }
                                .ctaButtonStyle()
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            loadMockData()
        }
    }
    
    // MARK: - Helper Methods
    private func stepColor(for step: TimelineCreationStep) -> Color {
        if currentStep == step {
            return .electricCyan
        } else if currentStep.rawValue > step.rawValue {
            return .sageGrowth
        } else {
            return .warmWhite.opacity(0.3)
        }
    }
    
    private func proceedToNextStep() {
        guard canProceed else { return }
        
        withAnimation(.spring()) {
            if let nextStep = TimelineCreationStep(rawValue: currentStep.rawValue + 1) {
                currentStep = nextStep
            }
        }
    }
    
    private func goToPreviousStep() {
        withAnimation(.spring()) {
            if let previousStep = TimelineCreationStep(rawValue: currentStep.rawValue - 1) {
                currentStep = previousStep
            }
        }
    }
    
    private func reset() {
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
    
    private func startGeneration() {
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
    
    private func loadMockData() {
        currentPsychologyFact = psychologyFacts.first ?? ""
    }
    
    private func createMockTimeline() -> Timeline {
        let paths = (1...pathCount).map { index in
            DecisionPath(
                id: UUID(),
                title: "Path \(index)",
                outcomeDescription: "This path leads to outcome \(index) based on your decision.",
                probability: Double.random(in: 0.2...0.8),
                emotionalIndicator: EmotionalIndicator.allCases.randomElement() ?? .neutral,
                keyMoments: []
            )
        }
        
        return Timeline(
            id: UUID(),
            title: "Decision Timeline",
            decisionText: decisionText,
            style: selectedStyle,
            duration: timelineLength,
            paths: paths,
            createdAt: Date(),
            videoURL: URL(string: "https://example.com/mock-video.mp4")
        )
    }
}

// MARK: - Supporting Views
struct DecisionInputSectionPure: View {
    @Binding var decisionText: String
    @Binding var showingSuggestions: Bool
    let suggestions: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Input Section
            VStack(alignment: .leading, spacing: 12) {
                Text("What decision are you facing?")
                    .font(TRACTypography.heading3Utility)
                    .foregroundColor(.warmWhite)
                
                Text("Describe your situation in detail. The more context you provide, the more accurate your timeline will be.")
                    .font(.system(size: 14))
                    .foregroundColor(.warmWhite.opacity(0.8))
                
                ZStack(alignment: .topLeading) {
                    TextEditor(text: $decisionText)
                        .font(.system(size: 16))
                        .foregroundColor(.warmWhite)
                        .background(Color.clear)
                        .frame(minHeight: 120)
                        .padding(12)
                    
                    if decisionText.isEmpty {
                        Text("I'm considering...")
                            .font(.system(size: 16))
                            .foregroundColor(.warmWhite.opacity(0.4))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 20)
                            .allowsHitTesting(false)
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(Color.warmWhite.opacity(0.1), lineWidth: 1)
                        .background(Color.warmWhite.opacity(0.05))
                )
                .cornerRadius(16)
            }
            
            // Suggestions
            VStack(alignment: .leading, spacing: 12) {
                Button(action: { showingSuggestions.toggle() }) {
                    HStack {
                        Text("Need inspiration?")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.electricCyan)
                        
                        Image(systemName: showingSuggestions ? "chevron.up" : "chevron.down")
                            .font(.system(size: 14))
                            .foregroundColor(.electricCyan)
                        
                        Spacer()
                    }
                }
                
                if showingSuggestions {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                        ForEach(suggestions, id: \.self) { suggestion in
                            SuggestionButtonPure(text: suggestion) {
                                decisionText = suggestion
                                showingSuggestions = false
                            }
                        }
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .animation(.spring(), value: showingSuggestions)
        }
        .padding()
    }
}

struct SuggestionButtonPure: View {
    let text: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.system(size: 14))
                .foregroundColor(.warmWhite)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.warmWhite.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.electricCyan.opacity(0.2), lineWidth: 1)
                        )
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct StyleSelectionSectionPure: View {
    @Binding var selectedStyle: VideoStyle
    @Binding var timelineLength: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Text("Choose Your Visual Style")
                    .font(TRACTypography.heading3Utility)
                    .foregroundColor(.warmWhite)
                
                Text("Different styles can help you connect with your timeline in unique ways.")
                    .font(.system(size: 14))
                    .foregroundColor(.warmWhite.opacity(0.8))
            }
            
            // Style Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                ForEach(VideoStyle.allCases, id: \.self) { style in
                    StyleCardPure(
                        style: style,
                        isSelected: selectedStyle == style
                    ) {
                        withAnimation(.spring()) {
                            selectedStyle = style
                        }
                    }
                }
            }
            
            // Preview
            if selectedStyle != .realistic {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Style Preview")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.warmWhite)
                    
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 120)
                        .cornerRadius(12)
                        .overlay(
                            VStack {
                                Image(systemName: "play.circle.fill")
                                    .font(.system(size: 48))
                                    .foregroundColor(.warmWhite.opacity(0.5))
                                Text("\(Int(timelineLength)) min • \(selectedStyle.rawValue)")
                                    .font(.caption)
                                    .foregroundColor(.warmWhite.opacity(0.7))
                            }
                        )
                }
                .transition(.asymmetric(insertion: .move(edge: .bottom).combined(with: .opacity), removal: .move(edge: .top).combined(with: .opacity)))
            }
        }
        .padding()
    }
}

struct StyleCardPure: View {
    let style: VideoStyle
    let isSelected: Bool
    let onTap: () -> Void
    @State private var isHovered = false
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                // Style Preview
                ZStack {
                    Rectangle()
                        .fill(styleBackgroundColor)
                        .frame(height: 120)
                        .cornerRadius(12)
                    
                    // Mock preview content
                    Image(systemName: style.icon)
                        .font(.system(size: isSelected ? 40 : 32))
                        .foregroundColor(.warmWhite.opacity(isSelected ? 1.0 : 0.8))
                        .scaleEffect(isHovered ? 1.05 : 1.0)
                }
                
                // Style Info
                VStack(spacing: 4) {
                    Text(style.rawValue)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.warmWhite)
                    
                    Text(style.description)
                        .font(.system(size: 12))
                        .foregroundColor(.warmWhite.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.clear)
                    .background(isSelected ? Color.electricCyan.opacity(0.1) : Color.warmWhite.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? Color.electricCyan : Color.warmWhite.opacity(0.1), lineWidth: 2)
                    )
            )
            .scaleEffect(isHovered ? 1.02 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            withAnimation(.spring(response: 0.2)) {
                isHovered = hovering
            }
        }
    }
    
    private var styleBackgroundColor: Color {
        switch style {
        case .realistic: return Color.gray.opacity(0.3)
        case .anime: return Color.purple.opacity(0.2)
        case .watercolor: return Color.blue.opacity(0.1)
        case .sketch: return Color.brown.opacity(0.2)
        }
    }
}

struct ParameterTuningSectionPure: View {
    @Binding var timelineLength: Double
    @Binding var emotionalTone: EmotionalTone
    @Binding var pathCount: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Customize Your Timeline")
                .font(TRACTypography.heading3Utility)
                .foregroundColor(.warmWhite)
            
            VStack(spacing: 24) {
                ParameterSliderPure(
                    title: "Timeline Length",
                    value: $timelineLength,
                    range: 1.0...5.0,
                    unit: "minutes",
                    icon: "clock.fill"
                )
                
                EmotionalToneSelectorPure(
                    selectedTone: $emotionalTone
                )
                
                StepperControlPure(
                    title: "Number of Paths",
                    value: $pathCount,
                    range: 2...5,
                    icon: "arrow.branch"
                )
            }
        }
        .padding()
    }
}

struct ParameterSliderPure: View {
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let unit: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(.electricCyan)
                
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.warmWhite)
                
                Spacer()
            }
            
            VStack(spacing: 8) {
                HStack {
                    Text(String(format: "%.1f", value))
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.warmWhite)
                    
                    Text(unit)
                        .font(.system(size: 14))
                        .foregroundColor(.warmWhite.opacity(0.7))
                }
                
                Slider(value: $value, in: range) {
                    Text(title)
                } minimumValueLabel: {
                    Text(String(format: "%.1f", range.lowerBound))
                        .font(.caption)
                        .foregroundColor(.warmWhite.opacity(0.6))
                } maximumValueLabel: {
                    Text(String(format: "%.1f", range.upperBound))
                        .font(.caption)
                        .foregroundColor(.warmWhite.opacity(0.6))
                }
                .accentColor(.electricCyan)
                .scaleEffect(0.9)
            }
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.warmWhite.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.electricCyan.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .padding(.horizontal, 4)
    }
}

struct EmotionalToneSelectorPure: View {
    @Binding var selectedTone: EmotionalTone
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "heart.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.electricCyan)
                
                Text("Emotional Tone")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.warmWhite)
                
                Spacer()
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                ForEach(EmotionalTone.allCases, id: \.self) { tone in
                    Button(action: {
                        withAnimation(.spring()) {
                            selectedTone = tone
                        }
                    }) {
                        VStack(spacing: 8) {
                            Image(systemName: tone.icon)
                                .font(.system(size: 24))
                                .foregroundColor(selectedTone == tone ? .warmWhite : .warmWhite.opacity(0.7))
                            
                            Text(tone.rawValue)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(selectedTone == tone ? .warmWhite : .warmWhite.opacity(0.8))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedTone == tone ? Color.electricCyan.opacity(0.2) : Color.warmWhite.opacity(0.05))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(selectedTone == tone ? Color.electricCyan : Color.warmWhite.opacity(0.1), lineWidth: 1)
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
}

struct StepperControlPure: View {
    let title: String
    @Binding var value: Int
    let range: ClosedRange<Int>
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(.electricCyan)
                
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.warmWhite)
                
                Spacer()
            }
            
            HStack {
                Button(action: { value = max(range.lowerBound, value - 1) }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(value > range.lowerBound ? .electricCyan : .warmWhite.opacity(0.3))
                }
                .disabled(value <= range.lowerBound)
                
                Text("\(value) Path\(value != 1 ? "s" : "")")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.warmWhite)
                    .frame(width: 60)
                    .multilineTextAlignment(.center)
                
                Button(action: { value = min(range.upperBound, value + 1) }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(value < range.upperBound ? .electricCyan : .warmWhite.opacity(0.3))
                }
                .disabled(value >= range.upperBound)
                
                Spacer()
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.warmWhite.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.electricCyan.opacity(0.2), lineWidth: 1)
                    )
            )
        }
    }
}

struct TimelineGenerationSectionPure: View {
    @Binding var isGenerating: Bool
    @Binding var generationProgress: Double
    @Binding var currentPsychologyFact: String
    
    var body: some View {
        VStack(spacing: 24) {
            // Progress Header
            VStack(spacing: 12) {
                Text("Generating Your Timeline")
                    .font(TRACTypography.sectionTitle)
                    .foregroundColor(.warmWhite)
                
                Text("This usually takes 15-45 seconds. Please keep your device steady.")
                    .font(.system(size: 14))
                    .foregroundColor(.warmWhite.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
            
            // Progress Circle
            ZStack {
                Circle()
                    .fill(Color.electricCyan.opacity(0.1))
                    .frame(width: 100, height: 100)
                    .overlay(
                        Circle()
                            .stroke(Color.electricCyan.opacity(0.3), lineWidth: 4)
                    )
                
                Circle()
                    .trim(from: 0, to: generationProgress)
                    .stroke(
                        Color.electricCyan,
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .frame(width: 92, height: 92)
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: 4) {
                    Text("\(Int(generationProgress * 100))%")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.electricCyan)
                    
                    Text("Complete")
                        .font(.caption)
                        .foregroundColor(.warmWhite.opacity(0.7))
                }
            }
            .animation(.easeInOut(duration: 0.5), value: generationProgress)
            
            // Psychology Facts
            if generationProgress > 0.1 {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "lightbulb.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.sageGrowth)
                        
                        Text("While You Wait")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.warmWhite)
                        
                        Spacer()
                    }
                    
                    Text(currentPsychologyFact)
                        .font(.system(size: 14))
                        .foregroundColor(.warmWhite.opacity(0.9))
                        .lineSpacing(2)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.warmWhite.opacity(0.05))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.sageGrowth.opacity(0.2), lineWidth: 1)
                                )
                        )
                }
            }
            
            // Process Steps
            VStack(alignment: .leading, spacing: 8) {
                ForEach(GenerationStep.allCases, id: \.self) { step in
                    HStack(spacing: 12) {
                        Image(systemName: stepIcon(for: step))
                            .font(.system(size: 16))
                            .foregroundColor(stepColor(for: step))
                            .frame(width: 24, height: 24)
                        
                        Text(step.title)
                            .font(.system(size: 14))
                            .foregroundColor(.warmWhite)
                        
                        Spacer()
                        
                        if step.isComplete(generationProgress) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.sageGrowth)
                        } else if step.isCurrent(generationProgress) {
                            Image(systemName: "circle.fill")
                                .foregroundColor(.electricCyan)
                                .scaleEffect(0.8)
                                .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: generationProgress)
                        } else {
                            Image(systemName: "circle")
                                .foregroundColor(.warmWhite.opacity(0.3))
                        }
                    }
                }
            }
            .padding(.vertical, 12)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.clear)
                .background(Color.warmWhite.opacity(0.02))
        )
        .cornerRadius(20)
    }
    
    private func stepIcon(for step: GenerationStep) -> String {
        switch step {
        case .textAnalysis: return "text.alignleft"
        case .imageProcessing: return "photo"
        case .perspectiveGeneration: return "brain.head.profile"
        case .videoRendering: return "video"
        case .finalAssembly: return "checkmark.seal.fill"
        }
    }
    
    private func stepColor(for step: GenerationStep) -> Color {
        if step.isComplete(generationProgress) {
            return .sageGrowth
        } else if step.isCurrent(generationProgress) {
            return .electricCyan
        } else {
            return .warmWhite.opacity(0.6)
        }
    }
}

struct TimelineReviewSectionPure: View {
    let generatedTimeline: Timeline?
    let decisionText: String
    let selectedStyle: VideoStyle
    let timelineLength: Double
    let emotionalTone: EmotionalTone
    let pathCount: Int
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Text("Your Timeline is Ready!")
                    .font(TRACTypography.heroTitle)
                    .foregroundColor(.warmWhite)
                
                Text("Review your personalized decision simulation before saving.")
                    .font(.system(size: 16))
                    .foregroundColor(.warmWhite.opacity(0.8))
            }
            
            // Video Player Placeholder
            VStack(alignment: .leading, spacing: 12) {
                Text("Watch Your Timeline")
                    .font(TRACTypography.heading3Utility)
                    .foregroundColor(.warmWhite)
                
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 200)
                    .cornerRadius(12)
                    .overlay(
                        VStack {
                            Image(systemName: "play.circle.fill")
                                .font(.system(size: 48))
                                .foregroundColor(.warmWhite.opacity(0.5))
                            Text("Timeline Preview")
                                .font(.caption)
                                .foregroundColor(.warmWhite.opacity(0.7))
                        }
                    )
            }
            
            // Decision Summary
            VStack(alignment: .leading, spacing: 16) {
                Text("Decision Summary")
                    .font(TRACTypography.heading3Utility)
                    .foregroundColor(.warmWhite)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(decisionText)
                        .font(.system(size: 16))
                        .foregroundColor(.warmWhite)
                        .multilineTextAlignment(.leading)
                        .lineLimit(3)
                    
                    HStack(spacing: 16) {
                        TimelineParameterTag(title: "Style", value: selectedStyle.rawValue, color: .electricCyan)
                        TimelineParameterTag(title: "Length", value: "\(Int(timelineLength)) min", color: .sageGrowth)
                        TimelineParameterTag(title: "Tone", value: emotionalTone.rawValue, color: .challengeRed)
                        TimelineParameterTag(title: "Paths", value: "\(pathCount)", color: .warmWhite)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.warmWhite.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.warmWhite.opacity(0.1), lineWidth: 1)
                        )
                )
            }
            
            // Path Preview
            if let timeline = generatedTimeline {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Possible Outcomes")
                        .font(TRACTypography.heading3Utility)
                        .foregroundColor(.warmWhite)
                    
                    LazyVStack(spacing: 12) {
                        ForEach(timeline.paths) { path in
                            PathPreviewCardPure(path: path)
                        }
                    }
                }
            }
        }
        .padding()
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}

struct PathPreviewCardPure: View {
    let path: DecisionPath
    
    var body: some View {
        HStack(spacing: 16) {
            // Path Icon
            Circle()
                .fill(pathColor(for: path.emotionalIndicator))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: pathIcon(for: path.emotionalIndicator))
                        .font(.system(size: 16))
                        .foregroundColor(.warmWhite)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(path.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.warmWhite)
                
                Text(path.outcomeDescription)
                    .font(.system(size: 14))
                    .foregroundColor(.warmWhite.opacity(0.8))
                    .lineLimit(2)
            }
            
            Spacer()
            
            // Probability
            VStack(spacing: 2) {
                Text("\(Int(path.probability * 100))%")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.electricCyan)
                
                Text("Likelihood")
                    .font(.caption)
                    .foregroundColor(.warmWhite.opacity(0.6))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.warmWhite.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.warmWhite.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    private func pathColor(for indicator: EmotionalIndicator) -> Color {
        switch indicator {
        case .success: return .sageGrowth
        case .challenge: return .challengeRed
        case .neutral: return .electricCyan
        case .growth: return .sageGrowth
        }
    }
    
    private func pathIcon(for indicator: EmotionalIndicator) -> String {
        switch indicator {
        case .success: return "checkmark.circle"
        case .challenge: return "exclamationmark.triangle"
        case .neutral: return "minus"
        case .growth: return "arrow.up"
        }
    }
}

// MARK: - Supporting Types
enum TimelineCreationStep: Int, CaseIterable {
    case decisionInput = 0
    case styleSelection = 1
    case parameterTuning = 2
    case generation = 3
    case review = 4
}

enum GenerationStep: String, CaseIterable {
    case textAnalysis = "Analyzing Decision"
    case imageProcessing = "Processing Images"
    case perspectiveGeneration = "Generating Perspectives"
    case videoRendering = "Creating Video"
    case finalAssembly = "Final Assembly"
    
    var title: String { rawValue }
    
    func isComplete(_ progress: Double) -> Bool {
        switch self {
        case .textAnalysis: return progress >= 0.25
        case .imageProcessing: return progress >= 0.5
        case .perspectiveGeneration: return progress >= 0.6
        case .videoRendering: return progress >= 0.9
        case .finalAssembly: return progress >= 1.0
        }
    }
    
    func isCurrent(_ progress: Double) -> Bool {
        switch self {
        case .textAnalysis: return progress < 0.25
        case .imageProcessing: return progress >= 0.25 && progress < 0.5
        case .perspectiveGeneration: return progress >= 0.5 && progress < 0.6
        case .videoRendering: return progress >= 0.6 && progress < 0.9
        case .finalAssembly: return progress >= 0.9 && progress < 1.0
        }
    }
}

// MARK: - Extensions
extension VideoStyle {
    var description: String {
        switch self {
        case .realistic: return "Most lifelike experience"
        case .anime: return "Creative and engaging"
        case .watercolor: return "Soft and reflective"
        case .sketch: return "Quick and conceptual"
        }
    }
    
    var icon: String {
        switch self {
        case .realistic: return "photo.fill"
        case .anime: return "tv.fill"
        case .watercolor: return "paintbrush.pointed.fill"
        case .sketch: return "pencil.tip.crop.fill"
        }
    }
}

extension EmotionalTone {
    var icon: String {
        switch self {
        case .optimistic: return "sun.max.fill"
        case .realistic: return "eye.fill"
        case .cautious: return "shield.fill"
        case .balanced: return "balance.scale"
        }
    }
}

// MARK: - Preview
struct TimelineCreatorViewPure_Previews: PreviewProvider {
    static var previews: some View {
        TimelineCreatorViewPure()
    }
}