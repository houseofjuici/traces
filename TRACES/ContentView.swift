//
//  ContentView.swift
//  TRACES
//
//  Created by TRACES Development Team on 12/15/2024.
//

import SwiftUI
import Firebase

struct ContentView: View {
    // MARK: - Pure SwiftUI State
    @State private var isFirstLaunch = true
    @State private var isOnboardingComplete = false
    @State private var selectedTab: AppTab = .dashboard
    @State private var credits: Int = 247
    @State private var cameraPermissionGranted = false
    @State private var notificationPermissionGranted = false
    @State private var locationPermissionGranted = false
    @State private var timelines: [Timeline] = []
    @State private var wisdomItems: [WisdomItem] = []
    @State private var recentActivity: [ActivityItem] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var currentUser: User?
    @State private var isAuthenticated = false
    @State private var aiModelsLoaded = false
    @State private var currentGenerationProgress: Double = 0.0
    @State private var isGeneratingTimeline = false
    @State private var arSessionActive = false
    @State private var arCoachAvailable = false
    @State private var transactions: [Transaction] = []
    
    // MARK: - Computed Properties (replacing ViewModel logic)
    private var userProfile: UserProfile {
        UserProfile(credits: credits)
    }
    
    private var hasLowCredits: Bool {
        credits < 10
    }
    
    private var hasUnreadActivity: Bool {
        recentActivity.contains { $0.isUnread }
    }
    
    var body: some View {
        Group {
            if isFirstLaunch {
                OnboardingViewPure(
                    isComplete: $isOnboardingComplete,
                    cameraPermissionGranted: $cameraPermissionGranted
                )
            } else {
                MainTabViewPure(
                    selectedTab: $selectedTab,
                    credits: credits,
                    hasLowCredits: hasLowCredits,
                    timelines: timelines,
                    recentActivity: recentActivity,
                    onTabChange: { newTab in
                        selectedTab = newTab
                    }
                )
            }
        }
        .onAppear {
            checkFirstLaunch()
            loadInitialState()
        }
    }
    
    // MARK: - Helper Methods
    private func checkFirstLaunch() {
        let hasLaunchedBefore = UserDefaults.standard.bool(forKey: "hasLaunchedBefore")
        if !hasLaunchedBefore {
            isFirstLaunch = true
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
        } else {
            isFirstLaunch = false
        }
    }
    
    private func loadInitialState() {
        loadUserPreferences()
        checkPermissions()
        loadMockData()
    }
    
    private func loadUserPreferences() {
        let defaults = UserDefaults.standard
        
        isFirstLaunch = !defaults.bool(forKey: "hasLaunchedBefore")
        isOnboardingComplete = defaults.bool(forKey: "onboardingComplete")
        credits = defaults.integer(forKey: "credits")
        
        if isFirstLaunch {
            defaults.set(true, forKey: "hasLaunchedBefore")
        }
    }
    
    private func checkPermissions() {
        checkCameraPermission()
        checkNotificationPermission()
        checkLocationPermission()
    }
    
    private func checkCameraPermission() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        cameraPermissionGranted = status == .authorized
    }
    
    private func checkNotificationPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.notificationPermissionGranted = settings.authorizationStatus == .authorized
            }
        }
    }
    
    private func checkLocationPermission() {
        let status = CLLocationManager.authorizationStatus()
        locationPermissionGranted = status == .authorizedWhenInUse || status == .authorizedAlways
    }
    
    private func loadMockData() {
        if timelines.isEmpty && !isAuthenticated {
            timelines = MockData.timelines
            recentActivity = MockData.activity
        }
    }
}

// MARK: - Supporting Views
struct MainTabViewPure: View {
    @Binding var selectedTab: AppTab
    let credits: Int
    let hasLowCredits: Bool
    let timelines: [Timeline]
    let recentActivity: [ActivityItem]
    let onTabChange: (AppTab) -> Void
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardViewPure(
                credits: credits,
                hasLowCredits: hasLowCredits,
                timelines: timelines,
                recentActivity: recentActivity
            )
            .tabItem {
                Image(systemName: "house.fill")
                Text("Home")
            }
            .tag(AppTab.dashboard)
            
            TimelineCreatorViewPure()
            .tabItem {
                Image(systemName: "plus.circle.fill")
                Text("Create")
            }
            .tag(AppTab.create)
            
            TimelineLibraryViewPure(timelines: timelines)
            .tabItem {
                Image(systemName: "folder.fill")
                Text("Library")
            }
            .tag(AppTab.library)
            
            ProfileViewPure()
            .tabItem {
                Image(systemName: "person.fill")
                Text("Profile")
            }
            .tag(AppTab.profile)
        }
        .accentColor(.tracesBlue)
        .onChange(of: selectedTab) { newTab in
            onTabChange(newTab)
        }
    }
}

struct DashboardViewPure: View {
    let credits: Int
    let hasLowCredits: Bool
    let timelines: [Timeline]
    let recentActivity: [ActivityItem]
    @State private var showingNotifications = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 24) {
                    HeroCreditSectionPure(credits: credits, hasLowCredits: hasLowCredits)
                    
                    QuickActionsGridPure()
                    
                    RecentTimelinesSectionPure(timelines: timelines)
                    
                    RecentActivitySectionPure(recentActivity: recentActivity)
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
            NotificationsViewPure()
        }
    }
}

struct HeroCreditSectionPure: View {
    let credits: Int
    let hasLowCredits: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Available Credits")
                        .font(.tracesCaption)
                        .foregroundColor(.secondary)
                    
                    Text("\(credits)")
                        .font(.tracesHeroTitle)
                        .foregroundColor(.tracesBlue)
                }
                
                Spacer()
                
                Button("Get More") {
                    // Navigate to credit purchase
                }
                .buttonStyle(.tracesSecondary)
            }
            
            if hasLowCredits {
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

struct QuickActionsGridPure: View {
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
                    QuickActionCardPure(action: action)
                }
            }
        }
    }
}

struct QuickActionCardPure: View {
    let action: QuickAction
    
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
            // Handle new timeline
            break
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

struct RecentTimelinesSectionPure: View {
    let timelines: [Timeline]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent Timelines")
                    .font(.tracesSubheadline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                NavigationLink("See All") {
                    TimelineLibraryViewPure(timelines: timelines)
                }
                .font(.tracesCaption)
                .foregroundColor(.tracesBlue)
            }
            
            if timelines.isEmpty {
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
                        ForEach(Array(timelines.prefix(5)), id: \.id) { timeline in
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

struct RecentActivitySectionPure: View {
    let recentActivity: [ActivityItem]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent Activity")
                    .font(.tracesSubheadline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                NavigationLink("View All") {
                    ActivityHistoryViewPure()
                }
                .font(.tracesCaption)
                .foregroundColor(.tracesBlue)
            }
            
            VStack(spacing: 12) {
                ForEach(Array(recentActivity.prefix(3)), id: \.id) { activity in
                    ActivityRowPure(activity: activity)
                }
            }
        }
    }
}

struct ActivityRowPure: View {
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

// MARK: - Supporting Types
enum AppTab: Int {
    case dashboard = 0
    case create = 1
    case library = 2
    case profile = 3
}

struct UserProfile {
    let credits: Int
}

// MARK: - Placeholder Views
struct TimelineLibraryViewPure: View {
    let timelines: [Timeline]
    
    var body: some View {
        NavigationView {
            Text("Timeline Library")
                .navigationTitle("Library")
        }
    }
}

struct ProfileViewPure: View {
    var body: some View {
        NavigationView {
            Text("Profile")
                .navigationTitle("Profile")
        }
    }
}

struct NotificationsViewPure: View {
    var body: some View {
        NavigationView {
            Text("Notifications")
                .navigationTitle("Notifications")
        }
    }
}

struct ActivityHistoryViewPure: View {
    var body: some View {
        NavigationView {
            Text("Activity History")
                .navigationTitle("Activity")
        }
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}