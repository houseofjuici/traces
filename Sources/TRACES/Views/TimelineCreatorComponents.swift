//
//  TimelineCreatorComponents.swift
//  TRACES
//
//  Created by TRACES Development Team on 12/15/2024.
//

import SwiftUI

struct SuggestionButton: View {
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

struct StyleCard: View {
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

struct ParameterSlider<Output>: View {
    let title: String
    @Binding var value: Output
    let range: ClosedRange<Output>
    let unit: String
    let icon: String
    let formatter: (Output) -> String
    let outputConverter: (Double) -> Output
    
    init(title: String, value: Binding<Double>, range: ClosedRange<Double>, unit: String, icon: String, formatter: @escaping (Double) -> String = { String(format: "%.0f", $0) }) where Output == Double {
        self.title = title
        self._value = value
        self.range = range as! ClosedRange<Output>
        self.unit = unit
        self.icon = icon
        self.formatter = formatter as! (Output) -> String
        self.outputConverter = { $0 as! Output }
    }
    
    init(title: String, value: Binding<EmotionalTone>, range: ClosedRange<Double>, unit: String, icon: String, converter: @escaping (Double) -> EmotionalTone) where Output == EmotionalTone {
        self.title = title
        self._value = Binding<Double>(
            get: { Double(converter.inverse($0) ?? 1) },
            set: { value.wrappedValue = converter($0) }
        ) as! Binding<Output>
        self.range = 0...2 as! ClosedRange<Output>
        self.unit = unit
        self.icon = icon
        self.formatter = { _ in "" }
        self.outputConverter = { _ in converter(1) as! Output }
    }
    
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
                    Text(formatter(value))
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.warmWhite)
                    
                    Text(unit)
                        .font(.system(size: 14))
                        .foregroundColor(.warmWhite.opacity(0.7))
                }
                
                Slider(value: Binding(
                    get: { Double(value as! Double) ?? 1.0 },
                    set: { value = outputConverter($0) as! Output }
                ), in: 0...1) {
                    Text(title)
                } minimumValueLabel: {
                    Text(formatter(range.lowerBound as! Output))
                        .font(.caption)
                        .foregroundColor(.warmWhite.opacity(0.6))
                } maximumValueLabel: {
                    Text(formatter(range.upperBound as! Output))
                        .font(.caption)
                        .foregroundColor(.warmWhite.opacity(0.6))
                } onEditingChanged: { editing in
                    // Handle slider interaction
                }
                .accentColor(.electricCyan)
                .scaleEffect(0.9)
                
                HStack {
                    Text(formatter(range.lowerBound as! Output))
                        .font(.caption)
                        .foregroundColor(.warmWhite.opacity(0.6))
                    Spacer()
                    Text(formatter(range.upperBound as! Output))
                        .font(.caption)
                        .foregroundColor(.warmWhite.opacity(0.6))
                }
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

struct StepperControl: View {
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

struct EmotionalToneSelector: View {
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

struct TimelineParameterTag: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundColor(.warmWhite.opacity(0.8))
            
            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(color.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct PathPreviewCard: View {
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

struct EmotionalRatingSlider: View {
    @State private var rating: Double = 3.0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Emotional Response")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.warmWhite)
            
            HStack(spacing: 8) {
                ForEach(1...5, id: \.self) { star in
                    Image(systemName: star <= Int(rating) ? "star.fill" : "star")
                        .font(.system(size: 24))
                        .foregroundColor(rating >= Double(star) ? .sageGrowth : .warmWhite.opacity(0.3))
                        .scaleEffect(rating >= Double(star) ? 1.1 : 1.0)
                        .onTapGesture {
                            withAnimation(.spring()) {
                                rating = Double(star)
                            }
                        }
                }
            }
            
            Text("How did this timeline make you feel?")
                .font(.caption)
                .foregroundColor(.warmWhite.opacity(0.7))
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