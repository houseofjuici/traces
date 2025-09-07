//
//  ARCoachSupportingViews.swift
//  TRACES
//
//  Created by TRACES Development Team on 12/15/2024.
//

import SwiftUI
import CoreLocation

struct ARCoachHeroSection: View {
    @Binding var isARActive: Bool
    let onARToggle: () -> Void
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 20) {
            // AR Status Indicator
            HStack {
                Circle()
                    .fill(isARActive ? .electricCyan : .warmWhite.opacity(0.3))
                    .frame(width: 12, height: 12)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .animation(.spring(response: 1.0).repeatForever(autoreverses: true), value: isAnimating)
                
                Text(isARActive ? "AR Active" : "AR Ready")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(isARActive ? .electricCyan : .warmWhite)
                
                Spacer()
                
                if isARActive {
                    Text("Battery: 85%")
                        .font(.caption)
                        .foregroundColor(.warmWhite.opacity(0.7))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isARActive ? Color.electricCyan.opacity(0.1) : Color.warmWhite.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(isARActive ? Color.electricCyan.opacity(0.3) : Color.warmWhite.opacity(0.1), lineWidth: 1)
                    )
            )
            .onAppear {
                isAnimating = true
            }
            
            // Main AR Toggle
            VStack(spacing: 12) {
                Image(systemName: "camera.viewfinder")
                    .font(.system(size: 64))
                    .foregroundColor(.electricCyan)
                    .scaleEffect(isARActive ? 1.1 : 1.0)
                    .animation(.spring(response: 0.5), value: isARActive)
                
                Text("AR Life Coach")
                    .font(TRACTypography.heroTitle)
                    .foregroundColor(.warmWhite)
                
                Text("Point your camera at your environment to discover contextual insights and guidance tied to your current timeline.")
                    .font(.system(size: 16))
                    .foregroundColor(.warmWhite.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
                    .padding(.horizontal, 40)
                
                Button(action: onARToggle) {
                    HStack(spacing: 12) {
                        if isARActive {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.warmWhite)
                        } else {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.warmWhite)
                        }
                        
                        Text(isARActive ? "Exit AR" : "Start AR Session")
                            .font(.system(size: 16, weight: .semibold))
                        
                        if isARActive {
                            Image(systemName: "arrow.down.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.warmWhite)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [Color.electricCyan, Color.cyan.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                    .foregroundColor(.warmWhite)
                    .shadow(color: Color.electricCyan.opacity(0.4), radius: 8, x: 0, y: 4)
                }
                .disabled(isARActive) // Prevent multiple AR sessions
            }
            
            // Privacy Indicators
            HStack(spacing: 16) {
                PrivacyIndicator(
                    icon: "camera.fill",
                    label: "Camera Active",
                    color: .electricCyan,
                    isActive: isARActive
                )
                
                PrivacyIndicator(
                    icon: "mic.fill",
                    label: "Microphone Off",
                    color: .warmWhite.opacity(0.5),
                    isActive: false
                )
                
                PrivacyIndicator(
                    icon: "brain.head.profile",
                    label: "On-Device Processing",
                    color: .sageGrowth,
                    isActive: true
                )
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.clear)
                .background(TRACESColors.midnightToDawn)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.electricCyan.opacity(0.2), lineWidth: 1)
                )
        )
        .shadow(color: Color.black.opacity(0.2), radius: 12, x: 0, y: 6)
    }
}

struct PrivacyIndicator: View {
    let icon: String
    let label: String
    let color: Color
    let isActive: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)
                .scaleEffect(isActive ? 1.1 : 1.0)
                .animation(.spring(response: 0.3), value: isActive)
            
            Text(label)
                .font(.caption2)
                .foregroundColor(color)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: 60)
    }
}

struct LocationInsightsSection: View {
    let insights: [ARInsight]
    let onSelect: (ARInsight) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "location.north.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.electricCyan)
                
                Text("Current Location Insights")
                    .font(TRACTypography.heading3Utility)
                    .foregroundColor(.warmWhite)
                
                Spacer()
                
                Text("\(insights.count) found")
                    .font(.caption)
                    .foregroundColor(.warmWhite.opacity(0.6))
            }
            
            LazyVStack(spacing: 12) {
                ForEach(insights) { insight in
                    ARInsightCard(insight: insight, onSelect: onSelect)
                }
            }
        }
    }
}

struct ARInsightCard: View {
    let insight: ARInsight
    let onSelect: () -> Void
    @State private var isHovered = false
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 16) {
                // Insight Icon
                ZStack {
                    Circle()
                        .fill(insight.color.opacity(0.2))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: insight.icon)
                        .font(.system(size: 20))
                        .foregroundColor(insight.color)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(insight.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.warmWhite)
                        .lineLimit(1)
                    
                    Text(insight.description)
                        .font(.system(size: 14))
                        .foregroundColor(.warmWhite.opacity(0.8))
                        .lineLimit(2)
                    
                    HStack {
                        Text(insight.category)
                            .font(.caption)
                            .foregroundColor(insight.color)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(insight.color.opacity(0.1))
                            )
                        
                        Spacer()
                        
                        Text(insight.estimatedTime)
                            .font(.caption)
                            .foregroundColor(.warmWhite.opacity(0.6))
                    }
                }
                
                Spacer()
                
                // Action Indicator
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.electricCyan)
                    .scaleEffect(isHovered ? 1.2 : 1.0)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.warmWhite.opacity(0.02))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.electricCyan.opacity(0.1), lineWidth: 1)
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
}

struct DiscoverableHotspotsSection: View {
    let hotspots: [ARHotspot]
    let onSelect: (ARHotspot) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "map.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.electricCyan)
                
                Text("Nearby Hotspots")
                    .font(TRACTypography.heading3Utility)
                    .foregroundColor(.warmWhite)
                
                Spacer()
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 16) {
                    ForEach(hotspots) { hotspot in
                        HotspotCard(hotspot: hotspot, onSelect: onSelect)
                            .frame(width: 200)
                    }
                }
                .padding(.horizontal, 8)
            }
        }
    }
}

struct HotspotCard: View {
    let hotspot: ARHotspot
    let onSelect: () -> Void
    @State private var isHovered = false
    
    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 12) {
                // Hotspot Image
                ZStack {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 100)
                        .cornerRadius(12)
                        .overlay(
                            Image(systemName: hotspot.icon)
                                .font(.system(size: 32))
                                .foregroundColor(.warmWhite.opacity(0.4))
                        )
                    
                    // Distance badge
                    VStack {
                        HStack {
                            Spacer()
                            Text("\(hotspot.distance)m")
                                .font(.caption)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.black.opacity(0.6))
                                )
                        }
                        Spacer()
                    }
                }
                
                // Hotspot Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(hotspot.title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.warmWhite)
                        .lineLimit(1)
                    
                    Text(hotspot.description)
                        .font(.system(size: 12))
                        .foregroundColor(.warmWhite.opacity(0.8))
                        .lineLimit(2)
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.warmWhite.opacity(0.02))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.electricCyan.opacity(0.1), lineWidth: 1)
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
}

struct ARFeaturesOverview: View {
    let features: [(icon: String, title: String, description: String)] = [
        ("photo.fill", "Environmental Analysis", "AR Coach analyzes your surroundings to provide contextually relevant guidance."),
        ("lightbulb.fill", "Interactive Insights", "Tap floating orbs to discover wisdom tied to your current environment."),
        ("arrow.up.arrow.down", "Timeline Integration", "Seamlessly connect AR experiences to your decision timelines."),
        ("shield.fill", "Privacy First", "All processing happens on-device with clear privacy indicators.")
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("How AR Coach Works")
                .font(TRACTypography.heading3Utility)
                .foregroundColor(.warmWhite)
            
            ForEach(features.indices, id: \.self) { index in
                let feature = features[index]
                HStack(spacing: 16) {
                    Image(systemName: feature.icon)
                        .font(.system(size: 24))
                        .foregroundColor(.electricCyan)
                        .frame(width: 48)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(feature.title)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.warmWhite)
                        
                        Text(feature.description)
                            .font(.system(size: 13))
                            .foregroundColor(.warmWhite.opacity(0.8))
                            .lineLimit(2)
                    }
                    
                    Spacer()
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.warmWhite.opacity(0.02))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.electricCyan.opacity(0.1), lineWidth: 1)
                        )
                )
            }
        }
    }
}