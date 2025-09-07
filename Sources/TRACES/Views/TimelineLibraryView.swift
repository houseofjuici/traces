//
//  TimelineLibraryView.swift
//  TRACES
//
//  Created by TRACES Development Team on 12/15/2024.
//

import SwiftUI

struct TimelineLibraryView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 16) {
                    if appState.timelines.isEmpty {
                        EmptyStateView()
                    } else {
                        ForEach(appState.timelines) { timeline in
                            TimelineCard(timeline: timeline, isCompact: false)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
            }
            .navigationTitle("Timeline Library")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "folder.badge.questionmark")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("No Timelines Yet")
                .font(.tracesSubheadline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text("Your created timelines will appear here. Start by creating your first timeline!")
                .font(.tracesBody)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button("Create Timeline") {
                // Navigate to timeline creator
            }
            .buttonStyle(.tracesPrimary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}