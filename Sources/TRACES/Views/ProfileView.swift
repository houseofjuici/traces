//
//  ProfileView.swift
//  TRACES
//
//  Created by TRACES Development Team on 12/15/2024.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 24) {
                    // Profile Header
                    ProfileHeaderView()
                        .environmentObject(appState)
                    
                    // Stats Section
                    StatsSection()
                        .environmentObject(appState)
                    
                    // Settings Section
                    SettingsSection()
                        .environmentObject(appState)
                    
                    // Actions Section
                    ActionsSection()
                        .environmentObject(appState)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct ProfileHeaderView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(spacing: 16) {
            // Avatar
            Circle()
                .fill(Color.tracesBlue.opacity(0.2))
                .frame(width: 80, height: 80)
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.tracesBlue)
                )
            
            // User Info
            VStack(spacing: 4) {
                Text(appState.currentUser?.name ?? "Guest User")
                    .font(.tracesSubheadline)
                    .fontWeight(.semibold)
                
                if let email = appState.currentUser?.email {
                    Text(email)
                        .font(.tracesCaption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Credits Display
            HStack(spacing: 8) {
                Image(systemName: "star.fill")
                    .foregroundColor(.tracesOrange)
                    .font(.system(size: 16))
                
                Text("\(appState.credits) Credits")
                    .font(.tracesBody)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.tracesOrange.opacity(0.1))
            .cornerRadius(20)
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

struct StatsSection: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Statistics")
                .font(.tracesSubheadline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                StatCard(title: "Timelines", value: "\(appState.timelines.count)", icon: "timeline.selection")
                StatCard(title: "Wisdom", value: "\(appState.wisdomItems.count)", icon: "lightbulb.fill")
                StatCard(title: "Activity", value: "\(appState.recentActivity.count)", icon: "bell.fill")
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.tracesBlue)
            
            Text(value)
                .font(.tracesSubheadline)
                .fontWeight(.semibold)
            
            Text(title)
                .font(.tracesCaption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 80)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 1)
    }
}

struct SettingsSection: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Settings")
                .font(.tracesSubheadline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                SettingsRow(title: "Notifications", icon: "bell", isToggle: true, isOn: $appState.notificationPermissionGranted)
                SettingsRow(title: "Camera", icon: "camera", isToggle: true, isOn: $appState.cameraPermissionGranted)
                SettingsRow(title: "Privacy", icon: "lock.shield")
                SettingsRow(title: "About", icon: "info.circle")
            }
        }
    }
}

struct SettingsRow: View {
    let title: String
    let icon: String
    var isToggle: Bool = false
    @Binding var isOn: Bool
    
    init(title: String, icon: String, isToggle: Bool = false, isOn: Binding<Bool> = .constant(false)) {
        self.title = title
        self.icon = icon
        self.isToggle = isToggle
        self._isOn = isOn
    }
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(.tracesBlue)
                .frame(width: 24)
            
            Text(title)
                .font(.tracesBody)
            
            Spacer()
            
            if isToggle {
                Toggle("", isOn: $isOn)
                    .labelsHidden()
            } else {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 1)
    }
}

struct ActionsSection: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Actions")
                .font(.tracesSubheadline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                Button(action: {
                    // Handle sign out
                }) {
                    HStack {
                        Image(systemName: "arrow.right.square")
                            .font(.system(size: 18))
                            .foregroundColor(.red)
                        
                        Text("Sign Out")
                            .font(.tracesBody)
                            .foregroundColor(.red)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 1)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}