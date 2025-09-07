//
//  DesignSystem.swift
//  TRACES
//
//  Created by TRACES Development Team on 12/15/2024.
//

import SwiftUI

// MARK: - Color System
extension Color {
    // Primary Colors
    static let deepMidnightBlue = Color(red: 0.04, green: 0.05, blue: 0.15) // #0A0E27
    static let challengeRed = Color(red: 1.0, green: 0.34, blue: 0.13)       // #FF5722
    static let warmWhite = Color(red: 0.98, green: 0.98, blue: 0.99)         // #FAFBFC
    static let electricCyan = Color(red: 0.0, green: 0.9, blue: 1.0)         // #00E5FF
    static let sageGrowth = Color(red: 0.29, green: 0.69, blue: 0.31)        // #4CAF50
    static let softGray = Color(red: 0.95, green: 0.95, blue: 0.96)          // #F2F2F2
    
    // TRACES Brand Colors
    static let tracesBlue = Color(red: 0.0, green: 0.48, blue: 1.0)          // #007AFF
    static let tracesPurple = Color(red: 0.58, green: 0.31, blue: 0.92)      // #944FFF
    static let tracesGreen = Color(red: 0.2, green: 0.8, blue: 0.4)          // #33CC66
    static let tracesOrange = Color(red: 1.0, green: 0.58, blue: 0.0)        // #FF9500
    
    // Semantic Colors
    static let backgroundPrimary = Color.deepMidnightBlue
    static let backgroundSecondary = Color.softGray.opacity(0.05)
    static let textPrimary = Color.warmWhite
    static let textSecondary = Color.warmWhite.opacity(0.7)
    static let accentPrimary = Color.challengeRed
    static let accentSecondary = Color.electricCyan
    static let success = Color.sageGrowth
    static let warning = Color.orange
    static let error = Color.red
}

struct TRACESColors {
    // Gradient Definitions
    static let etherealClarityFlow = LinearGradient(
        colors: [Color.deepMidnightBlue, Color.electricCyan.opacity(0.3)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let emotionalSpectrum = LinearGradient(
        colors: [Color.challengeRed, Color.sageGrowth, Color.electricCyan],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    static let midnightToDawn = LinearGradient(
        colors: [Color.deepMidnightBlue, Color(red: 0.1, green: 0.12, blue: 0.24), Color(red: 0.16, green: 0.18, blue: 0.36)],
        startPoint: .top,
        endPoint: .bottom
    )
    
    // Emotional Overlays
    static let challengeOverlay = Color.challengeRed.opacity(0.2)
    static let growthOverlay = Color.sageGrowth.opacity(0.15)
    static let calmOverlay = Color.electricCyan.opacity(0.1)
}

// MARK: - Typography System
struct TRACTypography {
    // Utility Typography (Korean-inspired: compact, high density)
    static let heading1Utility = Font.system(size: 32, weight: .bold, design: .default)
    static let heading2Utility = Font.system(size: 24, weight: .semibold, design: .default)
    static let heading3Utility = Font.system(size: 20, weight: .semibold, design: .default)
    static let bodyUtility = Font.system(size: 16, weight: .regular, design: .default)
    static let captionUtility = Font.system(size: 12, weight: .regular, design: .default)
    
    // Hero/Narrative Typography (European-inspired: spacious, premium)
    static let heroTitle = Font.custom("PlayfairDisplay-Bold", size: 36)
    static let sectionTitle = Font.custom("PlayfairDisplay-Semibold", size: 28)
    static let narrativeBody = Font.custom("SFProText-Regular", size: 18).leading(1.6)
    
    // Korean tight kerning for utility
    static let utilityTight: Font.TextStyle = .body
    static let utilityTightKerning: CGFloat = -0.02
    
    // European loose leading for narrative
    static let narrativeLooseLeading: CGFloat = 1.6
}

// MARK: - Font Extensions
extension Font {
    static let tracesHeroTitle = Font.system(size: 36, weight: .bold, design: .default)
    static let tracesSubheadline = Font.system(size: 16, weight: .semibold, design: .default)
    static let tracesBody = Font.system(size: 16, weight: .regular, design: .default)
    static let tracesCaption = Font.system(size: 12, weight: .regular, design: .default)
}

// MARK: - Layout System
struct TRACESLayout {
    // Korean Density: Compact utility grids
    static let utilityGridColumns = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8)
    ]
    static let utilityCardHeight: CGFloat = 100
    static let utilitySpacing: CGFloat = 8
    static let utilityPadding: CGFloat = 12
    
    // European Spaciousness: Hero single-columns
    static let heroMargin: CGFloat = 24
    static let heroCardMinHeight: CGFloat = 200
    static let heroSpacing: CGFloat = 24
    static let heroPadding: CGFloat = 24
    
    // Baseline grid and modular scale
    static let baselineGrid: CGFloat = 16
    static let modularScale: [CGFloat] = [4, 8, 16, 24, 32, 48, 64]
    
    // Safe area handling
    static let safeAreaTop: CGFloat = 44 // Status bar + navigation
    static let safeAreaBottom: CGFloat = 34 // Tab bar
}

// MARK: - Button Styles
struct TracesPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, 16)
            .padding(.horizontal, 24)
            .background(Color.tracesBlue)
            .foregroundColor(.white)
            .font(.system(size: 16, weight: .semibold))
            .cornerRadius(12)
            .shadow(color: Color.tracesBlue.opacity(0.3), radius: 4, x: 0, y: 2)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct TracesSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, 12)
            .padding(.horizontal, 20)
            .background(Color.tracesBlue.opacity(0.1))
            .foregroundColor(.tracesBlue)
            .font(.system(size: 14, weight: .medium))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.tracesBlue, lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Component Modifiers
struct GlassmorphismEffect: ViewModifier {
    let blurRadius: CGFloat
    let opacity: CGFloat
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.clear)
                    .background(
                        Color.white.opacity(opacity)
                            .blur(radius: blurRadius)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
    }
}

extension View {
    func glassmorphism(blurRadius: CGFloat = 10, opacity: CGFloat = 0.1) -> some View {
        modifier(GlassmorphismEffect(blurRadius: blurRadius, opacity: opacity))
    }
    
    func heroCardStyle() -> some View {
        self
            .padding(TRACESLayout.heroPadding)
            .frame(minHeight: TRACESLayout.heroCardMinHeight)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.clear)
                    .background(TRACESColors.midnightToDawn)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.warmWhite.opacity(0.1), lineWidth: 1)
                    )
            )
            .shadow(color: Color.black.opacity(0.2), radius: 12, x: 0, y: 4)
    }
    
    func utilityCardStyle() -> some View {
        self
            .frame(height: TRACESLayout.utilityCardHeight)
            .padding(TRACESLayout.utilityPadding)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.clear)
                    .background(Color.warmWhite.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.warmWhite.opacity(0.1), lineWidth: 1)
                    )
            )
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    func ctaButtonStyle() -> some View {
        self
            .padding(.vertical, 16)
            .padding(.horizontal, 24)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [Color.challengeRed, Color.red.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            )
            .foregroundColor(.warmWhite)
            .font(.system(size: 16, weight: .semibold))
            .shadow(color: Color.challengeRed.opacity(0.3), radius: 4, x: 0, y: 2)
    }
    
    // Animation utilities
    func koreanSpringAnimation() -> some View {
        self
            .animation(.spring(response: 0.15, dampingFraction: 0.8), value: UUID())
    }
    
    func europeanFlowAnimation() -> some View {
        self
            .animation(.easeInOut(duration: 0.4), value: UUID())
    }
    
    // Accessibility utilities
    func tracesAccessible() -> some View {
        self
            .dynamicTypeSize(.small...DynamicTypeSize.large)
            .minimumScaleFactor(0.5)
    }
}

// MARK: - Button Style Extensions
extension ButtonStyle where Self == TracesPrimaryButtonStyle {
    static var tracesPrimary: TracesPrimaryButtonStyle { TracesPrimaryButtonStyle() }
}

extension ButtonStyle where Self == TracesSecondaryButtonStyle {
    static var tracesSecondary: TracesSecondaryButtonStyle { TracesSecondaryButtonStyle() }
}

// MARK: - Shimmer Effect for Loading States
struct ShimmerEffect: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    colors: [
                        Color.clear,
                        Color.white.opacity(0.1),
                        Color.clear
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .offset(x: phase * 400)
                .onAppear {
                    withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                        phase = 1
                    }
                }
            )
    }
}

extension View {
    func shimmerEffect() -> some View {
        modifier(ShimmerEffect())
    }
}

// MARK: - High Contrast Modifier
struct HighContrastModifier: ViewModifier {
    @Environment(\.accessibilityEnabled) var accessibilityEnabled
    
    func body(content: Content) -> some View {
        content
            .font(accessibilityEnabled ? .system(size: 18, weight: .bold) : .system(size: 16))
            .foregroundColor(accessibilityEnabled ? .primary : .warmWhite)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(accessibilityEnabled ? Color.primary : Color.clear, lineWidth: 2)
            )
    }
}

extension View {
    func highContrast() -> some View {
        modifier(HighContrastModifier())
    }
}