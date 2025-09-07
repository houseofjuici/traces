//
//  NotificationsView.swift
//  TRACES
//
//  Created by TRACES Development Team on 12/15/2024.
//

import SwiftUI

struct NotificationsView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 16) {
                    if appState.recentActivity.isEmpty {
                        EmptyNotificationsView()
                    } else {
                        ForEach(appState.recentActivity) { activity in
                            NotificationCard(activity: activity)
                                .environmentObject(appState)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Mark All Read") {
                        markAllAsRead()
                    }
                    .disabled(appState.recentActivity.allSatisfy { !$0.isUnread })
                }
            }
        }
    }
    
    private func markAllAsRead() {
        for i in appState.recentActivity.indices {
            appState.recentActivity[i].isUnread = false
        }
    }
}

struct EmptyNotificationsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "bell.slash")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("No Notifications")
                .font(.tracesSubheadline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text("You're all caught up! New activity will appear here.")
                .font(.tracesBody)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

struct NotificationCard: View {
    let activity: ActivityItem
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Circle()
                .fill(activity.isUnread ? Color.tracesBlue : Color.secondary)
                .frame(width: 8, height: 8)
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(activity.title)
                    .font(.tracesBody)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                
                HStack {
                    Text(activity.date.formatted(.relative(presentation: .named)))
                        .font(.tracesCaption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    if activity.isUnread {
                        Button("Mark Read") {
                            appState.markActivityAsRead(activity.id)
                        }
                        .font(.tracesCaption)
                        .foregroundColor(.tracesBlue)
                    }
                }
            }
            
            Spacer()
            
            // Type Icon
            Image(systemName: activity.type.iconName)
                .font(.system(size: 16))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 1)
    }
}