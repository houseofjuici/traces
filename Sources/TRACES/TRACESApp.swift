//
//  TRACESApp.swift
//  TRACES
//
//  Created by TRACES Development Team on 12/15/2024.
//

import SwiftUI
import FirebaseCore
import CoreML
import AVFoundation
import UserNotifications
import CoreLocation

@main
struct TRACESApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var appState = AppState()
    @StateObject private var aiManager = AIModelManager.shared
    @StateObject private var firebaseManager = FirebaseManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(aiManager)
                .environmentObject(firebaseManager)
                .preferredColorScheme(.dark)
                .onAppear(perform: initializeApp)
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                    appState.handleAppForeground()
                }
                .alert("Error", isPresented: $appState.errorMessage.hasValue()) {
                    Button("OK") { appState.clearError() }
                } message: {
                    Text(appState.errorMessage ?? "")
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
        
        // Log app launch event
        Task {
            await firebaseManager.logEvent("app_launch", parameters: [
                "first_launch": appState.isFirstLaunch
            ])
        }
    }
    
    private func setupGlobalAppearance() {
        // Navigation bar styling
        UINavigationBar.appearance().barTintColor = UIColor(Color.deepMidnightBlue)
        UINavigationBar.appearance().titleTextAttributes = [
            .foregroundColor: UIColor(Color.warmWhite),
            .font: UIFont.systemFont(ofSize: 20, weight: .semibold)
        ]
        
        // Tab bar styling
        UITabBar.appearance().backgroundColor = UIColor(Color.deepMidnightBlue)
        UITabBar.appearance().unselectedItemTintColor = UIColor(Color.electricCyan.opacity(0.5))
        UITabBar.appearance().tintColor = UIColor(Color.challengeRed)
        
        // Scroll view styling
        UIScrollView.appearance().backgroundColor = UIColor.clear
        
        // Table view styling
        UITableView.appearance().backgroundColor = UIColor.clear
        UITableViewCell.appearance().backgroundColor = UIColor(Color.deepMidnightBlue)
        
        // Text field styling
        UITextField.appearance().textColor = UIColor(Color.warmWhite)
        UITextView.appearance().textColor = UIColor(Color.warmWhite)
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
            }
        }
        
        // Request location permission (if needed for location-based features)
        let locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Configure analytics and crash reporting
        #if DEBUG
        // Disable analytics in debug builds
        print("Running in DEBUG mode - analytics disabled")
        #else
        // Configure Firebase Analytics
        FirebaseApp.configure()
        #endif
        
        // Set up remote notifications
        UNUserNotificationCenter.current().delegate = self
        application.registerForRemoteNotifications()
        
        return true
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return .portrait // Lock to portrait for iPhone
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Save app state when entering background
        Task {
            // Save any pending data
            // Clean up resources
        }
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Refresh data when returning to foreground
        NotificationCenter.default.post(name: UIApplication.willEnterForegroundNotification, object: nil)
    }
}

// MARK: - Notification Center Delegate
extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, 
                              willPresent notification: UNNotification, 
                              withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show notifications when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, 
                              didReceive response: UNNotificationResponse, 
                              withCompletionHandler completionHandler: @escaping () -> Void) {
        // Handle notification taps
        let userInfo = response.notification.request.content.userInfo
        
        // Navigate to appropriate content based on notification
        if let timelineId = userInfo["timeline_id"] as? String {
            // Navigate to timeline detail
            NotificationCenter.default.post(name: Notification.Name("NavigateToTimeline"), object: timelineId)
        }
        
        completionHandler()
    }
}

// MARK: - Extensions
extension Optional where Wrapped == String {
    func hasValue() -> Bool {
        return self != nil && !self!.isEmpty
    }
}