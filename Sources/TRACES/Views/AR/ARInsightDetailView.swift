//
//  ARInsightDetailView.swift
//  TRACES
//
//  Created by TRACES Development Team on 12/15/2024.
//

import SwiftUI

// MARK: - AR Insight Detail View
struct ARInsightDetailView: View {
    let insight: ARInsight
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 24) {
                    // Insight Header
                    VStack(spacing: 16) {
                        Image(systemName: insight.icon)
                            .font(.system(size: 64))
                            .foregroundColor(insight.color)
                        
                        Text(insight.title)
                            .font(TRACTypography.heroTitle)
                            .foregroundColor(.warmWhite)
                        
                        Text(insight.description)
                            .font(.system(size: 16))
                            .foregroundColor(.warmWhite.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .lineSpacing(2)
                            .padding(.horizontal, 40)
                    }
                    
                    // Insight Details
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Details")
                            .font(TRACTypography.heading3Utility)
                            .foregroundColor(.warmWhite)
                        
                        VStack(spacing: 12) {
                            DetailRow(icon: "gauge", label: "Relevance", value: insight.formattedRelevance, color: .electricCyan)
                            DetailRow(icon: "clock", label: "Time", value: insight.estimatedTime, color: .warmWhite)
                            DetailRow(icon: "tag", label: "Category", value: insight.category, color: insight.color)
                            DetailRow(icon: "brain.head.profile", label: "AI Analysis", value: "On-device processing", color: .sageGrowth)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.warmWhite.opacity(0.05))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.electricCyan.opacity(0.2), lineWidth: 1)
                            )
                    )
                    
                    // Action Buttons
                    if insight.isInteractive {
                        VStack(spacing: 12) {
                            Button("Generate Timeline from This Insight") {
                                // Integrate with timeline creation
                                presentationMode.wrappedValue.dismiss()
                            }
                            .ctaButtonStyle()
                            
                            Button("Save Insight") {
                                // Save to user's insights
                                presentationMode.wrappedValue.dismiss()
                            }
                            .padding(.horizontal, 24)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.clear)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.electricCyan, lineWidth: 1)
                                    )
                            )
                            .foregroundColor(.electricCyan)
                            .font(.system(size: 16, weight: .semibold))
                        }
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, TRACESLayout.heroMargin)
                .padding(.top, TRACESLayout.safeAreaTop)
            }
            .background(Color.deepMidnightBlue.ignoresSafeArea())
            .navigationTitle("Insight Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Dismiss") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.warmWhite)
                }
            }
        }
    }
}

struct DetailRow: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)
                .frame(width: 24)
            
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(.warmWhite)
                .frame(width: 80, alignment: .leading)
            
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(color)
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
}