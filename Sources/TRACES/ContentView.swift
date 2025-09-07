//
//  ContentView.swift
//  TRACES
//
//  Created by TRACES Development Team on 12/15/2024.
//

import SwiftUI
import Firebase

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var aiModelManager: AIModelManager
    @State private var showingOnboarding = false
    
    var body: some View {
        Group {
            if appState.isFirstLaunch {
                OnboardingView()
                    .environmentObject(appState)
            } else {
                MainTabView()
                    .environmentObject(appState)
                    .environmentObject(aiModelManager)
            }
        }
        .onAppear {
            checkFirstLaunch()
        }
    }
    
    private func checkFirstLaunch() {
        let hasLaunchedBefore = UserDefaults.standard.bool(forKey: "hasLaunchedBefore")
        if !hasLaunchedBefore {
            appState.isFirstLaunch = true
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
        }
    }
}

struct MainTabView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var aiModelManager: AIModelManager
    
    var body: some View {
        TabView(selection: $appState.selectedTab) {
            DashboardView()
                .environmentObject(appState)
                .environmentObject(aiModelManager)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0)
            
            TimelineCreatorView()
                .environmentObject(appState)
                .environmentObject(aiModelManager)
                .tabItem {
                    Image(systemName: "plus.circle.fill")
                    Text("Create")
                }
                .tag(1)
            
            TimelineLibraryView()
                .environmentObject(appState)
                .tabItem {
                    Image(systemName: "folder.fill")
                    Text("Library")
                }
                .tag(2)
            
            ProfileView()
                .environmentObject(appState)
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
                .tag(3)
        }
        .accentColor(.tracesBlue)
        .onAppear {
            setupTabBarAppearance()
        }
    }
    
    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.95)
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AppState())
            .environmentObject(AIModelManager())
            .preferredColorScheme(.dark)
    }
}