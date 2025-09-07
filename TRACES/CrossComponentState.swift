//
//  CrossComponentState.swift
//  TRACES
//
//  Created by TRACES Development Team on 12/15/2024.
//

import SwiftUI
import Combine

// MARK: - Cross-Component State Manager
@MainActor
class CrossComponentState: ObservableObject {
    // MARK: - Published Properties
    @Published var appState: AppStateData
    @Published var uiState: UIStateData
    @Published var sessionState: SessionStateData
    @Published var featureFlags: FeatureFlagData
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private var stateListeners: [String: AnyCancellable] = [:]
    
    // MARK: - Initialization
    init() {
        self.appState = AppStateData()
        self.uiState = UIStateData()
        self.sessionState = SessionStateData()
        self.featureFlags = FeatureFlagData()
        
        setupStateListeners()
        loadPersistedState()
    }
    
    // MARK: - State Accessors
    func getAppState<T>(_ keyPath: WritableKeyPath<AppStateData, T>) -> T {
        return appState[keyPath: keyPath]
    }
    
    func setAppState<T>(_ keyPath: WritableKeyPath<AppStateData, T>, value: T) {
        appState[keyPath: keyPath] = value
        persistState()
    }
    
    func getUIState<T>(_ keyPath: WritableKeyPath<UIStateData, T>) -> T {
        return uiState[keyPath: keyPath]
    }
    
    func setUIState<T>(_ keyPath: WritableKeyPath<UIStateData, T>, value: T) {
        uiState[keyPath: keyPath] = value
        persistState()
    }
    
    func getSessionState<T>(_ keyPath: WritableKeyPath<SessionStateData, T>) -> T {
        return sessionState[keyPath: keyPath]
    }
    
    func setSessionState<T>(_ keyPath: WritableKeyPath<SessionStateData, T>, value: T) {
        sessionState[keyPath: keyPath] = value
        persistState()
    }
    
    // MARK: - State Subscriptions
    func subscribeToAppState<T>(_ keyPath: KeyPath<AppStateData, T>, handler: @escaping (T) -> Void) -> String {
        let subscriptionId = UUID().uuidString
        
        stateListeners[subscriptionId] = $appState
            .map { $0[keyPath: keyPath] }
            .removeDuplicates()
            .sink { value in
                handler(value)
            }
        
        return subscriptionId
    }
    
    func subscribeToUIState<T>(_ keyPath: KeyPath<UIStateData, T>, handler: @escaping (T) -> Void) -> String {
        let subscriptionId = UUID().uuidString
        
        stateListeners[subscriptionId] = $uiState
            .map { $0[keyPath: keyPath] }
            .removeDuplicates()
            .sink { value in
                handler(value)
            }
        
        return subscriptionId
    }
    
    func unsubscribe(_ subscriptionId: String) {
        stateListeners[subscriptionId]?.cancel()
        stateListeners.removeValue(forKey: subscriptionId)
    }
    
    // MARK: - State Actions
    func updateTheme(_ theme: AppTheme) {
        uiState.currentTheme = theme
        persistState()
    }
    
    func toggleFeature(_ feature: FeatureFlag) {
        featureFlags.toggle(feature)
        persistState()
    }
    
    func setNetworkStatus(_ status: NetworkStatus) {
        appState.networkStatus = status
        persistState()
    }
    
    func setUserSession(_ session: UserSession?) {
        sessionState.currentSession = session
        appState.isAuthenticated = session != nil
        persistState()
    }
    
    func addTimeline(_ timeline: Timeline) {
        appState.timelines.insert(timeline, at: 0)
        sessionState.recentActivity.insert(
            ActivityItem(
                title: "Timeline created: \(timeline.title)",
                type: .timelineCreated,
                date: Date(),
                isUnread: true
            ),
            at: 0
        )
        persistState()
    }
    
    func updateCredits(_ amount: Int) {
        appState.credits = amount
        sessionState.currentSession?.credits = amount
        persistState()
    }
    
    // MARK: - State Persistence
    private func persistState() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            
            do {
                let stateData = StateData(
                    appState: self.appState,
                    uiState: self.uiState,
                    sessionState: self.sessionState,
                    featureFlags: self.featureFlags
                )
                
                let data = try JSONEncoder().encode(stateData)
                UserDefaults.standard.set(data, forKey: "cross_component_state")
            } catch {
                print("Failed to persist state: \(error)")
            }
        }
    }
    
    private func loadPersistedState() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            
            do {
                guard let data = UserDefaults.standard.data(forKey: "cross_component_state") else { return }
                
                let stateData = try JSONDecoder().decode(StateData.self, from: data)
                
                DispatchQueue.main.async {
                    self.appState = stateData.appState
                    self.uiState = stateData.uiState
                    self.sessionState = stateData.sessionState
                    self.featureFlags = stateData.featureFlags
                }
            } catch {
                print("Failed to load persisted state: \(error)")
            }
        }
    }
    
    // MARK: - State Listeners Setup
    private func setupStateListeners() {
        // Listen to app state changes
        $appState
            .dropFirst()
            .sink { [weak self] _ in
                self?.persistState()
            }
            .store(in: &cancellables)
        
        // Listen to UI state changes
        $uiState
            .dropFirst()
            .sink { [weak self] _ in
                self?.persistState()
            }
            .store(in: &cancellables)
        
        // Listen to session state changes
        $sessionState
            .dropFirst()
            .sink { [weak self] _ in
                self?.persistState()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - State Reset
    func resetState() {
        appState = AppStateData()
        uiState = UIStateData()
        sessionState = SessionStateData()
        featureFlags = FeatureFlagData()
        
        // Clear persisted state
        UserDefaults.standard.removeObject(forKey: "cross_component_state")
    }
    
    func resetSessionState() {
        sessionState = SessionStateData()
        appState.isAuthenticated = false
        appState.currentUser = nil
        persistState()
    }
}

// MARK: - State Data Structures
struct AppStateData: Codable {
    var isAuthenticated: Bool = false
    var currentUser: User?
    var credits: Int = 247
    var timelines: [Timeline] = []
    var networkStatus: NetworkStatus = .connected
    var isOnline: Bool = true
    var lastSyncDate: Date?
    var deviceInfo: DeviceInfo = DeviceInfo()
    
    enum NetworkStatus: String, Codable {
        case connected
        case disconnected
        case connecting
        case poorConnection
    }
}

struct UIStateData: Codable {
    var currentTheme: AppTheme = .dark
    var selectedTab: AppTab = .dashboard
    var isSidebarVisible: Bool = false
    var isSearchActive: Bool = false
    var searchText: String = ""
    var filterOptions: FilterOptions = FilterOptions()
    var sortOrder: SortOrder = .newestFirst
    var viewMode: ViewMode = .grid
    var accessibilitySettings: AccessibilitySettings = AccessibilitySettings()
    
    enum AppTheme: String, Codable {
        case light
        case dark
        case system
    }
    
    enum AppTab: Int, Codable {
        case dashboard = 0
        case create = 1
        case library = 2
        case wallet = 3
        case ar = 4
        case profile = 5
    }
    
    enum SortOrder: String, Codable {
        case newestFirst
        case oldestFirst
        case alphabetical
        case byDuration
    }
    
    enum ViewMode: String, Codable {
        case grid
        case list
        case compact
    }
}

struct SessionStateData: Codable {
    var currentSession: UserSession?
    var recentActivity: [ActivityItem] = []
    var activeGenerations: [String] = []
    var pendingActions: [PendingAction] = []
    var userPreferences: UserPreferences = UserPreferences()
    var navigationHistory: [NavigationItem] = []
    var lastActiveDate: Date = Date()
}

struct FeatureFlagData: Codable {
    var enableNewAIModel: Bool = false
    var enableOfflineMode: Bool = true
    var enableDarkMode: Bool = true
    var enableBetaFeatures: Bool = false
    var enableAdvancedAnalytics: Bool = false
    var enableSocialFeatures: Bool = false
    
    func isFeatureEnabled(_ feature: FeatureFlag) -> Bool {
        switch feature {
        case .newAIModel: return enableNewAIModel
        case .offlineMode: return enableOfflineMode
        case .darkMode: return enableDarkMode
        case .betaFeatures: return enableBetaFeatures
        case .advancedAnalytics: return enableAdvancedAnalytics
        case .socialFeatures: return enableSocialFeatures
        }
    }
    
    mutating func toggle(_ feature: FeatureFlag) {
        switch feature {
        case .newAIModel: enableNewAIModel.toggle()
        case .offlineMode: enableOfflineMode.toggle()
        case .darkMode: enableDarkMode.toggle()
        case .betaFeatures: enableBetaFeatures.toggle()
        case .advancedAnalytics: enableAdvancedAnalytics.toggle()
        case .socialFeatures: enableSocialFeatures.toggle()
        }
    }
}

// MARK: - Supporting Types
struct StateData: Codable {
    let appState: AppStateData
    let uiState: UIStateData
    let sessionState: SessionStateData
    let featureFlags: FeatureFlagData
}

struct UserSession: Codable {
    let userId: String
    let email: String
    let displayName: String
    var credits: Int
    let sessionToken: String
    let expiresAt: Date
    let createdAt: Date
}

struct DeviceInfo: Codable {
    let deviceModel: String = UIDevice.current.model
    let systemVersion: String = UIDevice.current.systemVersion
    let appVersion: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    let isSimulator: Bool = TARGET_OS_SIMULATOR != 0
}

struct FilterOptions: Codable {
    var styleFilter: VideoStyle? = nil
    var dateRange: DateRange? = nil
    var emotionFilter: EmotionalIndicator? = nil
    var durationRange: ClosedRange<Double>? = nil
    var searchText: String = ""
}

struct DateRange: Codable {
    let startDate: Date
    let endDate: Date
}

struct AccessibilitySettings: Codable {
    var reduceMotion: Bool = false
    var voiceOverEnabled: Bool = false
    var largeTextEnabled: Bool = false
    var highContrastEnabled: Bool = false
    var customFontSize: Double = 1.0
}

struct UserPreferences: Codable {
    var preferredStyle: VideoStyle = .realistic
    var defaultDuration: Double = 3.0
    var enableNotifications: Bool = true
    var autoSaveTimelines: Bool = true
    var shareAnalytics: Bool = false
    var language: String = "en"
}

struct PendingAction: Codable {
    let id: String
    let type: ActionType
    let data: [String: Any]
    let createdAt: Date
    
    enum ActionType: String, Codable {
        case saveTimeline
        case shareTimeline
        case deleteTimeline
        case purchaseWisdom
        case updateProfile
    }
}

struct NavigationItem: Codable {
    let screen: String
    let parameters: [String: String]
    let timestamp: Date
}

enum FeatureFlag: String, CaseIterable {
    case newAIModel = "new_ai_model"
    case offlineMode = "offline_mode"
    case darkMode = "dark_mode"
    case betaFeatures = "beta_features"
    case advancedAnalytics = "advanced_analytics"
    case socialFeatures = "social_features"
}

// MARK: - SwiftUI State Binding Extensions
extension CrossComponentState {
    func binding<T>(for keyPath: WritableKeyPath<AppStateData, T>) -> Binding<T> {
        return Binding(
            get: { self.appState[keyPath: keyPath] },
            set: { self.appState[keyPath: keyPath] = $0 }
        )
    }
    
    func binding<T>(for keyPath: WritableKeyPath<UIStateData, T>) -> Binding<T> {
        return Binding(
            get: { self.uiState[keyPath: keyPath] },
            set: { self.uiState[keyPath: keyPath] = $0 }
        )
    }
    
    func binding<T>(for keyPath: WritableKeyPath<SessionStateData, T>) -> Binding<T> {
        return Binding(
            get: { self.sessionState[keyPath: keyPath] },
            set: { self.sessionState[keyPath: keyPath] = $0 }
        )
    }
}

// MARK: - Environment Key
struct CrossComponentStateKey: EnvironmentKey {
    static let defaultValue = CrossComponentState()
}

extension EnvironmentValues {
    var crossComponentState: CrossComponentState {
        get { self[CrossComponentStateKey.self] }
        set { self[CrossComponentStateKey.self] = newValue }
    }
}

// MARK: - State-aware View Modifier
struct StateAwareViewModifier: ViewModifier {
    @Environment(\.crossComponentState) private var stateManager
    let stateKey: String
    let action: (CrossComponentState) -> Void
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                action(stateManager)
            }
            .onChange(of: stateManager.appState) { _ in
                action(stateManager)
            }
            .onChange(of: stateManager.uiState) { _ in
                action(stateManager)
            }
            .onChange(of: stateManager.sessionState) { _ in
                action(stateManager)
            }
    }
}

extension View {
    func onStateChange(_ stateKey: String, action: @escaping (CrossComponentState) -> Void) -> some View {
        self.modifier(StateAwareViewModifier(stateKey: stateKey, action: action))
    }
}

// MARK: - Usage Examples
struct CrossComponentStateExample: View {
    @Environment(\.crossComponentState) private var stateManager
    
    var body: some View {
        VStack {
            // Access state directly
            Text("Credits: \(stateManager.getAppState(\.credits))")
            
            // Use state binding
            Toggle("Dark Mode", isOn: stateManager.binding(for: \.uiState.currentTheme == .dark))
            
            // Subscribe to state changes
            TimelineListView()
                .onStateChange("timeline_updates") { state in
                    print("Timelines updated: \(state.getAppState(\.timelines).count)")
                }
        }
    }
}

struct TimelineListView: View {
    @Environment(\.crossComponentState) private var stateManager
    @State private var subscriptionId: String?
    
    var body: some View {
        List(stateManager.getAppState(\.timelines), id: \.id) { timeline in
            TimelineRow(timeline: timeline)
        }
        .onAppear {
            // Subscribe to timeline changes
            subscriptionId = stateManager.subscribeToAppState(\.timelines) { timelines in
                print("Timeline count changed: \(timelines.count)")
            }
        }
        .onDisappear {
            if let subscriptionId = subscriptionId {
                stateManager.unsubscribe(subscriptionId)
            }
        }
    }
}

struct TimelineRow: View {
    let timeline: Timeline
    @Environment(\.crossComponentState) private var stateManager
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(timeline.title)
                .font(.headline)
            Text(timeline.decisionText)
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack {
                Text(timeline.style.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(4)
                
                Spacer()
                
                Button("Delete") {
                    stateManager.setAppState(\.timelines, value: 
                        stateManager.getAppState(\.timelines).filter { $0.id != timeline.id }
                    )
                }
                .foregroundColor(.red)
            }
        }
    }
}

// MARK: - State Management View
struct StateManagementDebugView: View {
    @Environment(\.crossComponentState) private var stateManager
    @State private var showingStateDetails = false
    
    var body: some View {
        NavigationView {
            List {
                Section("App State") {
                    Text("Authenticated: \(stateManager.getAppState(\.isAuthenticated))")
                    Text("Credits: \(stateManager.getAppState(\.credits))")
                    Text("Network Status: \(stateManager.getAppState(\.networkStatus).rawValue)")
                    Text("Timeline Count: \(stateManager.getAppState(\.timelines).count)")
                }
                
                Section("UI State") {
                    Text("Current Theme: \(stateManager.getUIState(\.currentTheme).rawValue)")
                    Text("Selected Tab: \(stateManager.getUIState(\.selectedTab).rawValue)")
                    Text("Search Active: \(stateManager.getUIState(\.isSearchActive))")
                    Text("View Mode: \(stateManager.getUIState(\.viewMode).rawValue)")
                }
                
                Section("Session State") {
                    Text("Has Session: \(stateManager.getSessionState(\.currentSession) != nil)")
                    Text("Activity Count: \(stateManager.getSessionState(\.recentActivity).count)")
                    Text("Active Generations: \(stateManager.getSessionState(\.activeGenerations).count)")
                }
                
                Section("Feature Flags") {
                    ForEach(FeatureFlag.allCases, id: \.self) { flag in
                        Toggle(flag.rawValue, isOn: Binding(
                            get: { stateManager.featureFlags.isFeatureEnabled(flag) },
                            set: { _ in stateManager.toggleFeature(flag) }
                        ))
                    }
                }
                
                Section("Actions") {
                    Button("Reset State") {
                        stateManager.resetState()
                    }
                    .foregroundColor(.red)
                    
                    Button("Reset Session") {
                        stateManager.resetSessionState()
                    }
                    .foregroundColor(.orange)
                    
                    Button("Show State Details") {
                        showingStateDetails = true
                    }
                }
            }
            .navigationTitle("State Management")
            .sheet(isPresented: $showingStateDetails) {
                StateDetailsView()
            }
        }
    }
}

struct StateDetailsView: View {
    @Environment(\.crossComponentState) private var stateManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("App State")
                        .font(.headline)
                    Text(String(describing: stateManager.appState))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("UI State")
                        .font(.headline)
                    Text(String(describing: stateManager.uiState))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("Session State")
                        .font(.headline)
                    Text(String(describing: stateManager.sessionState))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("Feature Flags")
                        .font(.headline)
                    Text(String(describing: stateManager.featureFlags))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
            }
            .navigationTitle("State Details")
        }
    }
}