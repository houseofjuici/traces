//
//  TimelineCreatorSections.swift
//  TRACES
//
//  Created by TRACES Development Team on 12/15/2024.
//

import SwiftUI

struct DecisionInputSection: View {
    @ObservedObject var viewModel: TimelineCreatorViewModel
    @State private var showingSuggestions = false
    
    private let suggestions = TimelineCreatorMockData.decisionSuggestions
    
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
                    TextEditor(text: $viewModel.decisionText)
                        .font(.system(size: 16))
                        .foregroundColor(.warmWhite)
                        .background(Color.clear)
                        .frame(minHeight: 120)
                        .padding(12)
                    
                    if viewModel.decisionText.isEmpty {
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
                            SuggestionButton(text: suggestion) {
                                viewModel.decisionText = suggestion
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

struct StyleSelectionSection: View {
    @ObservedObject var viewModel: TimelineCreatorViewModel
    
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
                    StyleCard(
                        style: style,
                        isSelected: viewModel.selectedStyle == style
                    ) {
                        withAnimation(.spring()) {
                            viewModel.selectedStyle = style
                        }
                    }
                }
            }
            
            // Preview
            if viewModel.selectedStyle != .realistic {
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
                                Text("\(Int(viewModel.timelineLength)) min • \(viewModel.selectedStyle.rawValue)")
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

struct ParameterTuningSection: View {
    @ObservedObject var viewModel: TimelineCreatorViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Customize Your Timeline")
                .font(TRACTypography.heading3Utility)
                .foregroundColor(.warmWhite)
            
            VStack(spacing: 24) {
                ParameterSlider(
                    title: "Timeline Length",
                    value: $viewModel.timelineLength,
                    range: 1.0...5.0,
                    unit: "minutes",
                    icon: "clock.fill"
                )
                
                EmotionalToneSelector(
                    selectedTone: $viewModel.emotionalTone
                )
                
                StepperControl(
                    title: "Number of Paths",
                    value: $viewModel.pathCount,
                    range: 2...5,
                    icon: "arrow.branch"
                )
            }
        }
        .padding()
    }
}

struct TimelineGenerationSection: View {
    @ObservedObject var viewModel: TimelineCreatorViewModel
    
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
                    .trim(from: 0, to: viewModel.generationProgress)
                    .stroke(
                        Color.electricCyan,
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .frame(width: 92, height: 92)
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: 4) {
                    Text("\(Int(viewModel.generationProgress * 100))%")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.electricCyan)
                    
                    Text("Complete")
                        .font(.caption)
                        .foregroundColor(.warmWhite.opacity(0.7))
                }
            }
            .animation(.easeInOut(duration: 0.5), value: viewModel.generationProgress)
            
            // Live Preview (Progressive Loading)
            VStack(alignment: .leading, spacing: 12) {
                Text("Live Preview")
                    .font(TRACTypography.heading3Utility)
                    .foregroundColor(.warmWhite)
                
                ZStack(alignment: .center) {
                    // Skeleton loading
                    if viewModel.generationProgress < 0.25 {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 180)
                            .cornerRadius(12)
                            .shimmerEffect()
                    } else {
                        // Low-res preview
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 180)
                            .cornerRadius(12)
                            .overlay(
                                Image(systemName: "play.circle.fill")
                                    .font(.system(size: 48))
                                    .foregroundColor(.warmWhite.opacity(0.5))
                            )
                            .opacity(viewModel.generationProgress < 0.75 ? 0.7 : 1.0)
                    }
                    
                    // Progress overlay
                    if viewModel.generationProgress < 1.0 {
                        VStack {
                            Text("Rendering...")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.warmWhite)
                            
                            Text(estimatedTimeRemaining)
                                .font(.caption)
                                .foregroundColor(.warmWhite.opacity(0.7))
                        }
                        .padding()
                        .background(
                            Color.black.opacity(0.5)
                                .cornerRadius(8)
                        )
                    }
                }
            }
            
            // Psychology Facts
            if viewModel.generationProgress > 0.1 {
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
                    
                    Text(viewModel.currentPsychologyFact)
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
                        
                        if step.isComplete(viewModel.generationProgress) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.sageGrowth)
                        } else if step.isCurrent(viewModel.generationProgress) {
                            Image(systemName: "circle.fill")
                                .foregroundColor(.electricCyan)
                                .scaleEffect(0.8)
                                .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: viewModel.generationProgress)
                        } else {
                            Image(systemName: "circle")
                                .foregroundColor(.warmWhite.opacity(0.3))
                        }
                    }
                }
            }
            .padding(.vertical, 12)
            
            // Cancel Button
            Button("Cancel Generation") {
                viewModel.isGenerating = false
                viewModel.currentStep = .styleSelection
            }
            .font(.system(size: 14))
            .foregroundColor(.warmWhite.opacity(0.7))
            .padding(.vertical, 12)
            .padding(.horizontal, 24)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.warmWhite.opacity(0.2), lineWidth: 1)
                    )
            )
            .opacity(viewModel.generationProgress < 0.9 ? 1.0 : 0.0)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.clear)
                .background(Color.warmWhite.opacity(0.02))
        )
        .cornerRadius(20)
    }
    
    private var estimatedTimeRemaining: String {
        let totalTime = 30.0 // seconds
        let elapsed = viewModel.generationProgress * totalTime
        let remaining = totalTime - elapsed
        return "\(Int(remaining))s remaining"
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
        if step.isComplete(viewModel.generationProgress) {
            return .sageGrowth
        } else if step.isCurrent(viewModel.generationProgress) {
            return .electricCyan
        } else {
            return .warmWhite.opacity(0.6)
        }
    }
}

struct TimelineReviewSection: View {
    @ObservedObject var viewModel: TimelineCreatorViewModel
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
            
            // Video Player
            VStack(alignment: .leading, spacing: 12) {
                Text("Watch Your Timeline")
                    .font(TRACTypography.heading3Utility)
                    .foregroundColor(.warmWhite)
                
                VideoPlayer(player: createVideoPlayer(for: viewModel.generatedTimeline))
                    .frame(height: 200)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.electricCyan.opacity(0.3), lineWidth: 1)
                    )
                
                // Player Controls
                HStack {
                    Button("Play") {
                        // TODO: Play video
                    }
                    .ctaButtonStyle()
                    
                    Button("Share") {
                        // TODO: Share timeline
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.clear)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.electricCyan, lineWidth: 1)
                            )
                    )
                    .foregroundColor(.electricCyan)
                    .font(.system(size: 14, weight: .medium))
                }
            }
            
            // Decision Summary
            VStack(alignment: .leading, spacing: 16) {
                Text("Decision Summary")
                    .font(TRACTypography.heading3Utility)
                    .foregroundColor(.warmWhite)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(viewModel.decisionText)
                        .font(.system(size: 16))
                        .foregroundColor(.warmWhite)
                        .multilineTextAlignment(.leading)
                        .lineLimit(3)
                    
                    HStack(spacing: 16) {
                        TimelineParameterTag(title: "Style", value: viewModel.selectedStyle.rawValue, color: .electricCyan)
                        TimelineParameterTag(title: "Length", value: "\(Int(viewModel.timelineLength)) min", color: .sageGrowth)
                        TimelineParameterTag(title: "Tone", value: viewModel.emotionalTone.rawValue, color: .challengeRed)
                        TimelineParameterTag(title: "Paths", value: "\(viewModel.pathCount)", color: .warmWhite)
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
            if let timeline = viewModel.generatedTimeline {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Possible Outcomes")
                        .font(TRACTypography.heading3Utility)
                        .foregroundColor(.warmWhite)
                    
                    LazyVStack(spacing: 12) {
                        ForEach(timeline.paths) { path in
                            PathPreviewCard(path: path)
                        }
                    }
                }
            }
            
            // Reflection Prompt
            VStack(alignment: .leading, spacing: 16) {
                Text("How do you feel?")
                    .font(TRACTypography.heading3Utility)
                    .foregroundColor(.warmWhite)
                
                Text("This reflection helps TRACES understand your emotional response and improve future simulations.")
                    .font(.system(size: 14))
                    .foregroundColor(.warmWhite.opacity(0.8))
                
                EmotionalRatingSlider()
                
                TextEditor(text: .constant(""))
                    .frame(height: 80)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(Color.warmWhite.opacity(0.1), lineWidth: 1)
                            .background(Color.warmWhite.opacity(0.05))
                    )
                    .cornerRadius(12)
                    .overlay(
                        Text("Optional: Share your thoughts about this timeline...")
                            .foregroundColor(.warmWhite.opacity(0.4))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 12)
                            .opacity(true ? 1 : 0)
                            .allowsHitTesting(true)
                    )
            }
        }
        .padding()
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
    
    private func createVideoPlayer(for timeline: Timeline?) -> AVPlayer? {
        guard let url = timeline?.videoURL else { return nil }
        let player = AVPlayer(url: url)
        return player
    }
}

// MARK: - Supporting Enums
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