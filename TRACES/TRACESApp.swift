//
//  TRACESApp.swift
//  TRACES
//
//  Created by TRACES Development Team on 12/15/2024.
//

import SwiftUI
import FirebaseCore
import CoreML
import Combine

@main
struct TRACESApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var appState = AppState()
    @StateObject private var aiManager = AIModelManager()
    @StateObject private var authManager = AuthenticationManager()
    @StateObject private var navigationManager = NavigationManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(aiManager)
                .environmentObject(authManager)
                .environmentObject(navigationManager)
                .preferredColorScheme(.dark)
                .onAppear(perform: initializeApp)
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                    appState.handleAppForeground()
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
                    appState.handleAppBackground()
                }
        }
    }
    
    private func initializeApp() {
        // Configure Firebase
        FirebaseApp.configure()
        
        // Setup global appearance
        setupGlobalAppearance()
        
        // Preload AI models in background
        DispatchQueue.global(qos: .background).async {
            aiManager.preloadModels()
        }
        
        // Initialize user defaults
        appState.loadUserPreferences()
        
        // Request permissions
        requestNecessaryPermissions()
        
        // Setup crash reporting and analytics
        setupAnalytics()
    }
    
    private func setupGlobalAppearance() {
        // Navigation bar styling
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.deepMidnightBlue)
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor(Color.warmWhite),
            .font: UIFont.systemFont(ofSize: 20, weight: .semibold)
        ]
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor(Color.warmWhite),
            .font: UIFont.systemFont(ofSize: 32, weight: .bold)
        ]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        
        // Tab bar styling
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor(Color.deepMidnightBlue)
        
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        UITabBar.appearance().unselectedItemTintColor = UIColor(Color.electricCyan.opacity(0.6))
        UITabBar.appearance().tintColor = UIColor(Color.challengeRed)
        
        // Scroll view styling
        UIScrollView.appearance().backgroundColor = UIColor.clear
        
        // Table view styling
        UITableView.appearance().backgroundColor = UIColor.clear
        UITableViewCell.appearance().backgroundColor = UIColor(Color.deepMidnightBlue)
    }
    
    private func requestNecessaryPermissions() {
        // Request camera permission for AR and photo upload
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                appState.cameraPermissionGranted = granted
            }
        }
        
        // Request notification permission for sequel reminders
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                appState.notificationPermissionGranted = granted
                if granted {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
        
        // Request photo library access for timeline generation
        PHPhotoLibrary.requestAuthorization { status in
            DispatchQueue.main.async {
                appState.photoLibraryPermissionGranted = status == .authorized || status == .limited
            }
        }
    }
    
    private func setupAnalytics() {
        // Configure analytics and crash reporting
        #if !DEBUG
        // Production analytics setup would go here
        #endif
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Configure remote notifications
        UNUserNotificationCenter.current().delegate = self
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Handle device token for push notifications
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("Device Token: \(tokenString)")
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Save app state when entering background
        // This would be used to save any unsaved data
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, 
                              willPresent notification: UNNotification, 
                              withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Handle notification when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, 
                              didReceive response: UNNotificationResponse, 
                              withCompletionHandler completionHandler: @escaping () -> Void) {
        // Handle notification response when user taps on notification
        let userInfo = response.notification.request.content.userInfo
        
        // Navigate to appropriate screen based on notification
        if let timelineId = userInfo["timelineId"] as? String {
            // Navigate to timeline detail
        }
        
        completionHandler()
    }
}