//
//  TimelineCard.swift
//  TRACES
//
//  Created by TRACES Development Team on 12/15/2024.
//

import SwiftUI

struct TimelineCard: View {
    let timeline: Timeline
    let isCompact: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: isCompact ? 12 : 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(timeline.title)
                        .font(isCompact ? .tracesSubheadline : .tracesBody)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    Text(timeline.decision)
                        .font(isCompact ? .tracesCaption : .tracesBody)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                }
                
                Spacer()
                
                // Style Badge
                VStack(spacing: 4) {
                    Image(systemName: styleIcon)
                        .font(.system(size: isCompact ? 16 : 20))
                        .foregroundColor(styleColor)
                    
                    Text(timeline.style.rawValue)
                        .font(isCompact ? .system(size: 10) : .tracesCaption)
                        .foregroundColor(styleColor)
                }
            }
            
            // Emotional Tone
            if !isCompact {
                HStack {
                    Image(systemName: emotionalIcon)
                        .font(.system(size: 14))
                        .foregroundColor(emotionalColor)
                    
                    Text(timeline.emotionalTone.rawValue)
                        .font(.tracesCaption)
                        .foregroundColor(emotionalColor)
                    
                    Spacer()
                    
                    Text(timeline.createdDate.formatted(.relative(presentation: .named)))
                        .font(.tracesCaption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Decision Paths
            VStack(alignment: .leading, spacing: 8) {
                Text("Possible Outcomes")
                    .font(isCompact ? .system(size: 12, weight: .medium) : .tracesCaption)
                    .foregroundColor(.secondary)
                
                VStack(spacing: 6) {
                    ForEach(Array(timeline.paths.prefix(isCompact ? 2 : 3)), id: \.id) { path in
                        PathRow(path: path, isCompact: isCompact)
                    }
                    
                    if timeline.paths.count > (isCompact ? 2 : 3) {
                        Text("+\(timeline.paths.count - (isCompact ? 2 : 3)) more")
                            .font(.tracesCaption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Actions
            if !isCompact {
                HStack(spacing: 12) {
                    Button(action: {
                        // Play timeline
                    }) {
                        HStack {
                            Image(systemName: "play.circle.fill")
                                .font(.system(size: 16))
                            Text("Play")
                        }
                    }
                    .buttonStyle(.tracesSecondary)
                    
                    if timeline.isSequelAvailable {
                        Button(action: {
                            // View sequel
                        }) {
                            HStack {
                                Image(systemName: "arrow.right.circle.fill")
                                    .font(.system(size: 16))
                                Text("Sequel")
                            }
                        }
                        .buttonStyle(.tracesPrimary)
                    }
                    
                    Spacer()
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private var styleIcon: String {
        switch timeline.style {
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
    
    private var styleColor: Color {
        switch timeline.style {
        case .realistic:
            return .tracesBlue
        case .anime:
            return .tracesPurple
        case .watercolor:
            return .tracesGreen
        case .sketch:
            return .tracesOrange
        }
    }
    
    private var emotionalIcon: String {
        switch timeline.emotionalTone {
        case .optimistic:
            return "sun.max.fill"
        case .realistic:
            return "eye.fill"
        case .challenging:
            return "bolt.fill"
        }
    }
    
    private var emotionalColor: Color {
        switch timeline.emotionalTone {
        case .optimistic:
            return .tracesGreen
        case .realistic:
            return .tracesBlue
        case .challenging:
            return .tracesOrange
        }
    }
}

struct PathRow: View {
    let path: DecisionPath
    let isCompact: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(indicatorColor)
                .frame(width: isCompact ? 6 : 8, height: isCompact ? 6 : 8)
            
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(path.title)
                        .font(isCompact ? .system(size: 11, weight: .medium) : .tracesCaption)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text("\(Int(path.probability * 100))%")
                        .font(isCompact ? .system(size: 10) : .tracesCaption)
                        .foregroundColor(.secondary)
                }
                
                if !isCompact {
                    Text(path.outcomeDescription)
                        .font(.tracesCaption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                }
            }
        }
        .padding(.horizontal, isCompact ? 8 : 12)
        .padding(.vertical, isCompact ? 4 : 6)
        .background(indicatorColor.opacity(0.1))
        .cornerRadius(8)
    }
    
    private var indicatorColor: Color {
        switch path.emotionalIndicator {
        case .success:
            return .tracesGreen
        case .challenge:
            return .tracesOrange
        case .neutral:
            return .tracesBlue
        case .growth:
            return .tracesPurple
        }
    }
}