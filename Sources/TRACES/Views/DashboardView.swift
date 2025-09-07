//
//  DashboardView.swift
//  TRACES
//
//  Created by TRACES Development Team on 12/15/2024.
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var aiModelManager: AIModelManager
    @State private var showingNotifications = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 24) {
                    HeroCreditSection()
                        .environmentObject(appState)
                    
                    QuickActionsGrid()
                        .environmentObject(appState)
                        .environmentObject(aiModelManager)
                    
                    RecentTimelinesSection()
                        .environmentObject(appState)
                    
                    RecentActivitySection()
                        .environmentObject(appState)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
            }
            .navigationTitle("TRACES")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingNotifications = true
                    }) {
                        Image(systemName: "bell")
                            .foregroundColor(.tracesBlue)
                    }
                }
            }
        }
        .sheet(isPresented: $showingNotifications) {
            NotificationsView()
        }
    }
}

struct HeroCreditSection: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Available Credits")
                        .font(.tracesCaption)
                        .foregroundColor(.secondary)
                    
                    Text("\(appState.credits)")
                        .font(.tracesHeroTitle)
                        .foregroundColor(.tracesBlue)
                }
                
                Spacer()
                
                Button("Get More") {
                    // Navigate to credit purchase
                }
                .buttonStyle(.tracesSecondary)
            }
            
            if appState.credits < 10 {
                HStack {
                    Image(systemName: "info.circle")
                        .foregroundColor(.orange)
                    Text("Low credits - consider purchasing more to continue creating timelines")
                        .font(.tracesCaption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(8)
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

struct QuickActionsGrid: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var aiModelManager: AIModelManager
    
    let actions = [
        QuickAction(title: "New Timeline", icon: "plus.circle", color: .tracesBlue),
        QuickAction(title: "Voice Input", icon: "mic.circle", color: .tracesPurple),
        QuickAction(title: "Wisdom Share", icon: "heart.circle", color: .tracesGreen),
        QuickAction(title: "AI Insights", icon: "brain", color: .tracesOrange)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Actions")
                .font(.tracesSubheadline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                ForEach(actions, id: \.title) { action in
                    QuickActionCard(action: action)
                        .environmentObject(appState)
                        .environmentObject(aiModelManager)
                }
            }
        }
    }
}

struct QuickAction {
    let title: String
    let icon: String
    let color: Color
}

struct QuickActionCard: View {
    let action: QuickAction
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var aiModelManager: AIModelManager
    
    var body: some View {
        Button(action: {
            handleAction()
        }) {
            VStack(spacing: 12) {
                Image(systemName: action.icon)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(action.color)
                
                Text(action.title)
                    .font(.tracesCaption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 80)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func handleAction() {
        switch action.title {
        case "New Timeline":
            appState.selectedTab = .create
        case "Voice Input":
            // Handle voice input
            break
        case "Wisdom Share":
            // Handle wisdom sharing
            break
        case "AI Insights":
            // Handle AI insights
            break
        default:
            break
        }
    }
}

struct RecentTimelinesSection: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent Timelines")
                    .font(.tracesSubheadline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                NavigationLink("See All") {
                    TimelineLibraryView()
                        .environmentObject(appState)
                }
                .font(.tracesCaption)
                .foregroundColor(.tracesBlue)
            }
            
            if appState.timelines.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "timeline.selection")
                        .font(.system(size: 32))
                        .foregroundColor(.secondary)
                    
                    Text("No timelines yet")
                        .font(.tracesBody)
                        .foregroundColor(.secondary)
                    
                    Text("Create your first timeline to see your decision paths")
                        .font(.tracesCaption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 16) {
                        ForEach(Array(appState.timelines.prefix(5)), id: \.id) { timeline in
                            TimelineCard(timeline: timeline, isCompact: true)
                                .frame(width: 280)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.horizontal, -20)
            }
        }
    }
}

struct RecentActivitySection: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent Activity")
                    .font(.tracesSubheadline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                NavigationLink("View All") {
                    ActivityHistoryView()
                }
                .font(.tracesCaption)
                .foregroundColor(.tracesBlue)
            }
            
            VStack(spacing: 12) {
                ForEach(Array(appState.recentActivity.prefix(3)), id: \.id) { activity in
                    ActivityRow(activity: activity)
                }
            }
        }
    }
}

struct ActivityRow: View {
    let activity: ActivityItem
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(activity.isUnread ? Color.tracesBlue : Color.secondary)
                .frame(width: 8, height: 8)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(activity.title)
                    .font(.tracesBody)
                    .foregroundColor(.primary)
                
                Text(activity.date.formatted(.relative(presentation: .named)))
                    .font(.tracesCaption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: activity.type.iconName)
                .font(.system(size: 16))
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
}

struct ActivityHistoryView: View {
    var body: some View {
        Text("Activity History")
            .navigationTitle("Activity")
    }
}