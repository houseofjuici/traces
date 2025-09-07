//
//  TimelineCreatorExtensions.swift
//  TRACES
//
//  Created by TRACES Development Team on 12/15/2024.
//

import SwiftUI

// MARK: - VideoStyle Extensions
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

// MARK: - EmotionalTone Extensions
extension EmotionalTone {
    var icon: String {
        switch self {
        case .optimistic: return "sun.max.fill"
        case .realistic: return "eye.fill"
        case .challenging: return "shield.fill"
        case .balanced: return "balance.scale"
        }
    }
    
    // Add balanced case that was missing from the original enum
    static var allCases: [EmotionalTone] {
        [.optimistic, .realistic, .challenging, .balanced]
    }
}

// MARK: - Button Style Extensions
extension View {
    func secondaryButtonStyle() -> some View {
        self
            .padding(.vertical, 16)
            .padding(.horizontal, 24)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.warmWhite.opacity(0.3), lineWidth: 1)
                    )
            )
            .foregroundColor(.warmWhite)
            .font(.system(size: 16, weight: .medium))
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
}

// MARK: - EmotionalTone Converter Helper
extension EmotionalTone {
    static func fromDouble(_ value: Double) -> EmotionalTone {
        switch value {
        case 0.0...0.5: return .optimistic
        case 0.5...1.0: return .realistic
        case 1.0...1.5: return .challenging
        default: return .balanced
        }
    }
    
    func toDouble() -> Double {
        switch self {
        case .optimistic: return 0.25
        case .realistic: return 0.75
        case .challenging: return 1.25
        case .balanced: return 1.75
        }
    }
    
    static func inverse(_ tone: EmotionalTone) -> Double? {
        switch tone {
        case .optimistic: return 0.25
        case .realistic: return 0.75
        case .challenging: return 1.25
        case .balanced: return 1.75
        }
    }
}

// MARK: - Additional Extensions for UI Components
extension View {
    func shimmerEffect() -> some View {
        self.modifier(ShimmerEffect())
    }
}

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