//
//  TimelineCreatorView.swift
//  TRACES
//
//  Created by TRACES Development Team on 12/15/2024.
//

import SwiftUI

struct TimelineCreatorView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var aiModelManager: AIModelManager
    @State private var decisionText = ""
    @State private var selectedStyle: VideoStyle = .realistic
    @State private var isCreating = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Input Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("What decision are you facing?")
                            .font(.tracesSubheadline)
                            .fontWeight(.semibold)
                        
                        TextEditor(text: $decisionText)
                            .frame(height: 120)
                            .padding(12)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    }
                    .padding(.horizontal, 20)
                    
                    // Style Selection
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Choose Video Style")
                            .font(.tracesSubheadline)
                            .fontWeight(.semibold)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                            ForEach(VideoStyle.allCases, id: \.self) { style in
                                StyleCard(style: style, isSelected: selectedStyle == style) {
                                    selectedStyle = style
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Cost Information
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(.tracesBlue)
                            Text("Creating a timeline costs 25 credits")
                                .font(.tracesCaption)
                                .foregroundColor(.secondary)
                        }
                        
                        Text("You have \(appState.credits) credits available")
                            .font(.tracesBody)
                            .fontWeight(.medium)
                            .foregroundColor(appState.credits >= 25 ? .tracesGreen : .orange)
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                }
                .padding(.top, 8)
            }
            .navigationTitle("Create Timeline")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        createTimeline()
                    }
                    .disabled(decisionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || appState.credits < 25 || isCreating)
                }
            }
        }
    }
    
    private func createTimeline() {
        guard !decisionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        isCreating = true
        
        Task {
            do {
                _ = try await appState.createTimeline(decision: decisionText, style: selectedStyle)
                
                // Reset form
                await MainActor.run {
                    decisionText = ""
                    selectedStyle = .realistic
                    isCreating = false
                    
                    // Navigate to library to see the result
                    appState.selectedTab = .library
                }
            } catch {
                await MainActor.run {
                    isCreating = false
                    appState.handleError(error)
                }
            }
        }
    }
}

struct StyleCard: View {
    let style: VideoStyle
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Image(systemName: styleIcon)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .white : .tracesBlue)
                
                Text(style.rawValue)
                    .font(.tracesCaption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 80)
            .background(isSelected ? Color.tracesBlue : Color(.systemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.tracesBlue : Color.gray.opacity(0.3), lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var styleIcon: String {
        switch style {
        case .realistic:
            return "person.fill"
        case .anime:
            return "face.smiling.fill"
        case .watercolor:
            return "paintbrush.fill"
        case .sketch:
            return "pencil"
        }
    }
}