//
//  TimelineCreatorView.swift
//  TRACES
//
//  Created by TRACES Development Team on 12/15/2024.
//

import SwiftUI
import AVKit

struct TimelineCreatorView: View {
    @EnvironmentObject var aiModelManager: AIModelManager
    @StateObject private var viewModel = TimelineCreatorViewModel()
    @Environment(\.presentationMode) var presentationMode
    
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
                                    .scaleEffect(viewModel.currentStep == step ? 1.2 : 1.0)
                                    .animation(.spring(), value: viewModel.currentStep)
                            }
                        }
                        .padding(.vertical, 8)
                        
                        // Step Content
                        Group {
                            switch viewModel.currentStep {
                            case .decisionInput:
                                DecisionInputSection(viewModel: viewModel)
                            case .styleSelection:
                                StyleSelectionSection(viewModel: viewModel)
                            case .parameterTuning:
                                ParameterTuningSection(viewModel: viewModel)
                            case .generation:
                                TimelineGenerationSection(viewModel: viewModel)
                            case .review:
                                TimelineReviewSection(viewModel: viewModel)
                            }
                        }
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                        
                        // CTA Buttons
                        if viewModel.currentStep != .generation && viewModel.currentStep != .review {
                            HStack(spacing: 16) {
                                if viewModel.currentStep != .decisionInput {
                                    Button("Back") {
                                        viewModel.goToPreviousStep()
                                    }
                                    .secondaryButtonStyle()
                                }
                                
                                Button(viewModel.currentStep == .parameterTuning ? "Generate Timeline" : "Continue") {
                                    if viewModel.currentStep == .parameterTuning {
                                        viewModel.startGeneration()
                                    } else {
                                        viewModel.proceedToNextStep()
                                    }
                                }
                                .ctaButtonStyle()
                                .disabled(!viewModel.canProceed)
                            }
                            .padding(.horizontal)
                        }
                        
                        if viewModel.currentStep == .review {
                            HStack(spacing: 16) {
                                Button("Create Another") {
                                    viewModel.reset()
                                }
                                .secondaryButtonStyle()
                                
                                Button("Save Timeline") {
                                    // TODO: Save timeline
                                    presentationMode.wrappedValue.dismiss()
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
            viewModel.loadMockData()
        }
    }
    
    private func stepColor(for step: TimelineCreationStep) -> Color {
        if viewModel.currentStep == step {
            return .electricCyan
        } else if viewModel.currentStep.rawValue > step.rawValue {
            return .sageGrowth
        } else {
            return .warmWhite.opacity(0.3)
        }
    }
}

enum TimelineCreationStep: Int, CaseIterable {
    case decisionInput = 0
    case styleSelection = 1
    case parameterTuning = 2
    case generation = 3
    case review = 4
}

// MARK: - TimelineCreatorView Previews
struct TimelineCreatorView_Previews: PreviewProvider {
    static var previews: some View {
        TimelineCreatorView()
            .environmentObject(AIModelManager())
    }
}