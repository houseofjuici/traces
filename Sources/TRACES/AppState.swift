//
//  AppState.swift
//  TRACES
//
//  Created by TRACES Development Team on 12/15/2024.
//

import SwiftUI
import Firebase
import Combine
import AVFoundation
import CoreLocation
import UserNotifications

// MARK: - Main App State Manager
@MainActor
class AppState: ObservableObject {
    // MARK: - User Profile & Authentication
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var isFirstLaunch = true
    @Published var isOnboardingComplete = false
    
    // MARK: - Credits & Economy
    @Published var credits: Int = 247
    @Published var transactions: [Transaction] = []
    
    // MARK: - Navigation
    @Published var selectedTab: AppTab = .dashboard
    @Published var navigationPath = NavigationPath()
    
    // MARK: - Permissions
    @Published var cameraPermissionGranted = false
    @Published var notificationPermissionGranted = false
    @Published var locationPermissionGranted = false
    
    // MARK: - Content State
    @Published var timelines: [Timeline] = []
    @Published var wisdomItems: [WisdomItem] = []
    @Published var recentActivity: [ActivityItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - AI Model State
    @Published var aiModelsLoaded = false
    @Published var currentGenerationProgress: Double = 0.0
    @Published var isGeneratingTimeline = false
    
    // MARK: - AR State
    @Published var arSessionActive = false
    @Published var arCoachAvailable = false
    
    // MARK: - Services
    private let firebaseManager = FirebaseManager.shared
    private let aiModelManager = AIModelManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupSubscriptions()
        loadInitialState()
    }
    
    // MARK: - Setup
    private func setupSubscriptions() {
        // Listen for authentication changes
        firebaseManager.$currentUser
            .receive(on: RunLoop.main)
            .sink { [weak self] user in
                self?.currentUser = user
                self?.isAuthenticated = user != nil
                if user != nil {
                    self?.loadUserData()
                }
            }
            .store(in: &cancellables)
        
        // Listen for AI model loading
        aiModelManager.$modelsLoaded
            .receive(on: RunLoop.main)
            .sink { [weak self] loaded in
                self?.aiModelsLoaded = loaded
            }
            .store(in: &cancellables)
    }
    
    private func loadInitialState() {
        loadUserPreferences()
        checkPermissions()
        loadMockData()
    }
    
    // MARK: - User Preferences
    func loadUserPreferences() {
        let defaults = UserDefaults.standard
        
        isFirstLaunch = !defaults.bool(forKey: "hasLaunchedBefore")
        isOnboardingComplete = defaults.bool(forKey: "onboardingComplete")
        credits = defaults.integer(forKey: "credits")
        
        if isFirstLaunch {
            defaults.set(true, forKey: "hasLaunchedBefore")
        }
    }
    
    func saveUserPreferences() {
        let defaults = UserDefaults.standard
        defaults.set(isOnboardingComplete, forKey: "onboardingComplete")
        defaults.set(credits, forKey: "credits")
    }
    
    // MARK: - Permission Management
    func checkPermissions() {
        checkCameraPermission()
        checkNotificationPermission()
        checkLocationPermission()
    }
    
    private func checkCameraPermission() {
        // Check camera permission status
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
    
    func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                self.cameraPermissionGranted = granted
            }
        }
    }
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                self.notificationPermissionGranted = granted
            }
        }
    }
    
    // MARK: - Credits & Economy
    func updateCredits(_ newCredits: Int) {
        credits = max(0, newCredits)
        saveUserPreferences()
        
        // Add transaction record
        let transaction = Transaction(
            type: .adjustment,
            amount: newCredits - credits,
            description: "Credit adjustment",
            date: Date()
        )
        transactions.insert(transaction, at: 0)
        
        // Sync with Firebase if authenticated
        if isAuthenticated {
            Task {
                await firebaseManager.updateUserCredits(credits)
            }
        }
    }
    
    func spendCredits(_ amount: Int) -> Bool {
        guard credits >= amount else { return false }
        
        updateCredits(credits - amount)
        
        let transaction = Transaction(
            type: .spend,
            amount: -amount,
            description: "Credits spent",
            date: Date()
        )
        transactions.insert(transaction, at: 0)
        
        return true
    }
    
    func earnCredits(_ amount: Int, description: String = "Credits earned") {
        updateCredits(credits + amount)
        
        let transaction = Transaction(
            type: .earn,
            amount: amount,
            description: description,
            date: Date()
        )
        transactions.insert(transaction, at: 0)
        
        // Add activity item
        let activity = ActivityItem(
            title: description,
            type: .creditsEarned,
            date: Date(),
            isUnread: true
        )
        recentActivity.insert(activity, at: 0)
    }
    
    // MARK: - Timeline Management
    func createTimeline(decision: String, style: VideoStyle) async throws -> Timeline {
        isLoading = true
        isGeneratingTimeline = true
        errorMessage = nil
        
        defer {
            isLoading = false
            isGeneratingTimeline = false
        }
        
        // Spend credits for timeline creation
        guard spendCredits(25) else {
            throw TimelineError.insufficientCredits
        }
        
        // Generate timeline using AI
        guard let timeline = await aiModelManager.generateTimeline(
            decision: decision,
            style: style,
            progressHandler: { progress in
                DispatchQueue.main.async {
                    self.currentGenerationProgress = progress
                }
            }
        ) else {
            throw TimelineError.generationFailed
        }
        
        // Add to timelines array
        timelines.insert(timeline, at: 0)
        
        // Add activity item
        let activity = ActivityItem(
            title: "Timeline created: \(timeline.title)",
            type: .timelineCreated,
            date: Date(),
            isUnread: true
        )
        recentActivity.insert(activity, at: 0)
        
        // Save to Firebase if authenticated
        if isAuthenticated {
            try await firebaseManager.saveTimeline(timeline)
        }
        
        return timeline
    }
    
    func loadTimelines() async {
        guard isAuthenticated else { return }
        
        isLoading = true
        errorMessage = nil
        
        defer {
            isLoading = false
        }
        
        do {
            timelines = try await firebaseManager.fetchTimelines()
        } catch {
            errorMessage = "Failed to load timelines: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Wisdom Management
    func purchaseWisdom(_ wisdomItem: WisdomItem) async throws {
        guard spendCredits(wisdomItem.price) else {
            throw WisdomError.insufficientCredits
        }
        
        // Add to user's wisdom collection
        wisdomItems.append(wisdomItem)
        
        // Add activity item
        let activity = ActivityItem(
            title: "Purchased wisdom: \(wisdomItem.title)",
            type: .wisdomPurchased,
            date: Date(),
            isUnread: true
        )
        recentActivity.insert(activity, at: 0)
        
        // Save to Firebase if authenticated
        if isAuthenticated {
            try await firebaseManager.saveWisdomPurchase(wisdomItem)
        }
    }
    
    func shareWisdom(_ wisdomItem: WisdomItem) async throws {
        // Earn credits for sharing wisdom
        earnCredits(10, description: "Wisdom shared: \(wisdomItem.title)")
        
        // Add activity item
        let activity = ActivityItem(
            title: "Shared wisdom: \(wisdomItem.title)",
            type: .wisdomShared,
            date: Date(),
            isUnread: true
        )
        recentActivity.insert(activity, at: 0)
    }
    
    // MARK: - AR Management
    func startARSession() {
        guard arCoachAvailable else { return }
        
        arSessionActive = true
        // AR session will be managed by ARCoachView
    }
    
    func stopARSession() {
        arSessionActive = false
    }
    
    // MARK: - Activity Management
    func markActivityAsRead(_ activityId: UUID) {
        if let index = recentActivity.firstIndex(where: { $0.id == activityId }) {
            recentActivity[index].isUnread = false
        }
    }
    
    func clearAllActivity() {
        recentActivity.removeAll()
    }
    
    // MARK: - Error Handling
    func handleError(_ error: Error) {
        errorMessage = error.localizedDescription
        
        // Log error to Firebase if authenticated
        if isAuthenticated {
            Task {
                await firebaseManager.logError(error)
            }
        }
    }
    
    func clearError() {
        errorMessage = nil
    }
    
    // MARK: - App Lifecycle
    func handleAppForeground() {
        checkPermissions()
        refreshData()
    }
    
    private func refreshData() {
        Task {
            if isAuthenticated {
                await loadTimelines()
                // Load other user data as needed
            }
        }
    }
    
    // MARK: - Mock Data (for development)
    private func loadMockData() {
        // Load mock timelines if none exist
        if timelines.isEmpty && !isAuthenticated {
            timelines = MockData.timelines
            recentActivity = MockData.activity
            wisdomItems = MockData.wisdomItems
        }
    }
    
    // MARK: - User Data Loading
    private func loadUserData() {
        guard let currentUser = currentUser else { return }
        
        Task {
            await loadTimelines()
            // Load other user-specific data
        }
    }
}