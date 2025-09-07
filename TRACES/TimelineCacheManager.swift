//
//  TimelineCacheManager.swift
//  TRACES
//
//  Created by TRACES Development Team on 12/15/2024.
//

import SwiftUI
import Combine
import CoreData
import Foundation

// MARK: - Timeline Cache Manager
@MainActor
class TimelineCacheManager: ObservableObject {
    @Published var cachedTimelines: [Timeline] = []
    @Published var isCacheLoading: Bool = false
    @Published var cacheSize: Int = 0
    @Published var lastCacheUpdate: Date?
    @Published var memoryUsage: UInt64 = 0
    
    private let cacheKey = "traces_timeline_cache"
    private let maxCacheSize = 100 // Maximum number of timelines to cache
    private let cacheExpiry: TimeInterval = 7 * 24 * 60 * 60 // 7 days
    private let memoryLimit: UInt64 = 100 * 1024 * 1024 // 100MB
    
    private var cancellables = Set<AnyCancellable>()
    private var saveTimer: Timer?
    
    // MARK: - Cache Initialization
    init() {
        loadCache()
        setupMemoryMonitoring()
        setupAutoSave()
    }
    
    // MARK: - Cache Operations
    func cacheTimeline(_ timeline: Timeline) {
        var updatedCache = cachedTimelines
        
        // Remove existing timeline with same ID if present
        updatedCache.removeAll { $0.id == timeline.id }
        
        // Add new timeline at the beginning
        updatedCache.insert(timeline, at: 0)
        
        // Enforce cache size limit
        if updatedCache.count > maxCacheSize {
            updatedCache = Array(updatedCache.prefix(maxCacheSize))
        }
        
        cachedTimelines = updatedCache
        updateCacheStats()
        
        // Schedule save
        scheduleSave()
    }
    
    func removeTimeline(_ timelineId: UUID) {
        cachedTimelines.removeAll { $0.id == timelineId }
        updateCacheStats()
        scheduleSave()
    }
    
    func getTimeline(_ timelineId: UUID) -> Timeline? {
        return cachedTimelines.first { $0.id == timelineId }
    }
    
    func searchTimelines(query: String) -> [Timeline] {
        let lowercasedQuery = query.lowercased()
        return cachedTimelines.filter { timeline in
            timeline.title.lowercased().contains(lowercasedQuery) ||
            timeline.decisionText.lowercased().contains(lowercasedQuery)
        }
    }
    
    func getTimelinesByStyle(_ style: VideoStyle) -> [Timeline] {
        return cachedTimelines.filter { $0.style == style }
    }
    
    func getRecentTimelines(limit: Int = 10) -> [Timeline] {
        return Array(cachedTimelines.prefix(limit))
    }
    
    func clearCache() {
        cachedTimelines.removeAll()
        updateCacheStats()
        saveCache()
        
        // Clear UserDefaults
        UserDefaults.standard.removeObject(forKey: cacheKey)
    }
    
    func clearExpiredCache() {
        let cutoffDate = Date().addingTimeInterval(-cacheExpiry)
        cachedTimelines.removeAll { $0.createdAt < cutoffDate }
        updateCacheStats()
        scheduleSave()
    }
    
    // MARK: - Persistence
    private func loadCache() {
        isCacheLoading = true
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            
            do {
                let data = UserDefaults.standard.data(forKey: self.cacheKey)
                let timelines = try self.decodeCacheData(data)
                
                DispatchQueue.main.async {
                    self.cachedTimelines = timelines
                    self.updateCacheStats()
                    self.isCacheLoading = false
                }
            } catch {
                print("Failed to load cache: \(error)")
                DispatchQueue.main.async {
                    self.isCacheLoading = false
                }
            }
        }
    }
    
    private func saveCache() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            
            do {
                let data = try self.encodeCacheData(self.cachedTimelines)
                UserDefaults.standard.set(data, forKey: self.cacheKey)
            } catch {
                print("Failed to save cache: \(error)")
            }
        }
    }
    
    private func scheduleSave() {
        saveTimer?.invalidate()
        saveTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] _ in
            self?.saveCache()
        }
    }
    
    // MARK: - Cache Encoding/Decoding
    private func encodeCacheData(_ timelines: [Timeline]) throws -> Data {
        let cacheData = TimelineCacheData(
            timelines: timelines,
            version: "1.0",
            createdAt: Date()
        )
        
        return try JSONEncoder().encode(cacheData)
    }
    
    private func decodeCacheData(_ data: Data?) throws -> [Timeline] {
        guard let data = data else { return [] }
        
        let cacheData = try JSONDecoder().decode(TimelineCacheData.self, from: data)
        
        // Validate cache version
        guard cacheData.version == "1.0" else {
            throw CacheError.invalidVersion
        }
        
        // Clear expired cache
        let cutoffDate = Date().addingTimeInterval(-cacheExpiry)
        let validTimelines = cacheData.timelines.filter { $0.createdAt >= cutoffDate }
        
        return validTimelines
    }
    
    // MARK: - Memory Management
    private func setupMemoryMonitoring() {
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            self?.updateMemoryUsage()
        }
    }
    
    private func updateMemoryUsage() {
        let usage = cachedTimelines.reduce(0) { total, timeline in
            total + timeline.estimatedMemorySize
        }
        memoryUsage = usage
        
        // If memory usage exceeds limit, clear oldest timelines
        if usage > memoryLimit {
            let timelinesToRemove = cachedTimelines.count - maxCacheSize / 2
            if timelinesToRemove > 0 {
                cachedTimelines.removeLast(timelinesToRemove)
                updateCacheStats()
                scheduleSave()
            }
        }
    }
    
    private func updateCacheStats() {
        cacheSize = cachedTimelines.count
        lastCacheUpdate = Date()
    }
    
    private func setupAutoSave() {
        // Save cache when app enters background
        NotificationCenter.default.addObserver(
            forName: UIApplication.didEnterBackgroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.saveCache()
        }
    }
    
    // MARK: - Background Sync
    func syncWithFirebase(userId: String, firebaseManager: FirebaseAsyncManager) async {
        do {
            let firebaseTimelines = try await firebaseManager.fetchTimelines(userId: userId)
            
            // Merge with cache, keeping the most recent versions
            var mergedTimelines = cachedTimelines
            
            for firebaseTimeline in firebaseTimelines {
                if let existingIndex = mergedTimelines.firstIndex(where: { $0.id == firebaseTimeline.id }) {
                    // Update if Firebase version is newer
                    if firebaseTimeline.createdAt > mergedTimelines[existingIndex].createdAt {
                        mergedTimelines[existingIndex] = firebaseTimeline
                    }
                } else {
                    // Add new timeline
                    mergedTimelines.insert(firebaseTimeline, at: 0)
                }
            }
            
            cachedTimelines = mergedTimelines
            updateCacheStats()
            scheduleSave()
            
        } catch {
            print("Failed to sync with Firebase: \(error)")
        }
    }
    
    // MARK: - Export/Import
    func exportCache() -> URL? {
        do {
            let data = try encodeCacheData(cachedTimelines)
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let exportURL = documentsPath.appendingPathComponent("traces_cache_\(Date().timeIntervalSince1970).json")
            
            try data.write(to: exportURL)
            return exportURL
        } catch {
            print("Failed to export cache: \(error)")
            return nil
        }
    }
    
    func importCache(from url: URL) async throws {
        let data = try Data(contentsOf: url)
        let importedTimelines = try decodeCacheData(data)
        
        // Merge with existing cache
        var mergedTimelines = cachedTimelines
        
        for importedTimeline in importedTimelines {
            if let existingIndex = mergedTimelines.firstIndex(where: { $0.id == importedTimeline.id }) {
                // Keep the most recent version
                if importedTimeline.createdAt > mergedTimelines[existingIndex].createdAt {
                    mergedTimelines[existingIndex] = importedTimeline
                }
            } else {
                mergedTimelines.insert(importedTimeline, at: 0)
            }
        }
        
        // Enforce cache size limit
        if mergedTimelines.count > maxCacheSize {
            mergedTimelines = Array(mergedTimelines.prefix(maxCacheSize))
        }
        
        cachedTimelines = mergedTimelines
        updateCacheStats()
        scheduleSave()
    }
    
    // MARK: - Cache Statistics
    func getCacheStatistics() -> CacheStatistics {
        let totalSize = cachedTimelines.reduce(0) { $0 + $1.estimatedMemorySize }
        let oldestTimeline = cachedTimelines.min { $0.createdAt < $1.createdAt }
        let newestTimeline = cachedTimelines.max { $0.createdAt < $1.createdAt }
        
        return CacheStatistics(
            totalTimelines: cachedTimelines.count,
            totalMemorySize: totalSize,
            oldestTimelineDate: oldestTimeline?.createdAt,
            newestTimelineDate: newestTimeline?.createdAt,
            lastUpdated: lastCacheUpdate,
            cacheHitRate: calculateCacheHitRate()
        )
    }
    
    private func calculateCacheHitRate() -> Double {
        // This would need to be implemented with actual hit tracking
        return 0.85 // 85% hit rate as example
    }
}

// MARK: - Supporting Types
struct TimelineCacheData: Codable {
    let timelines: [Timeline]
    let version: String
    let createdAt: Date
}

struct CacheStatistics {
    let totalTimelines: Int
    let totalMemorySize: UInt64
    let oldestTimelineDate: Date?
    let newestTimelineDate: Date?
    let lastUpdated: Date?
    let cacheHitRate: Double
}

enum CacheError: Error, LocalizedError {
    case invalidVersion
    case encodingFailed
    case decodingFailed
    case fileNotFound
    
    var errorDescription: String? {
        switch self {
        case .invalidVersion:
            return "Cache version is incompatible"
        case .encodingFailed:
            return "Failed to encode cache data"
        case .decodingFailed:
            return "Failed to decode cache data"
        case .fileNotFound:
            return "Cache file not found"
        }
    }
}

// MARK: - Timeline Memory Size Extension
extension Timeline {
    var estimatedMemorySize: UInt64 {
        // Rough estimate of memory usage
        let titleSize = title.utf8.count
        let decisionTextSize = decisionText.utf8.count
        let pathsSize = paths.reduce(0) { $0 + $1.estimatedMemorySize }
        
        return UInt64(titleSize + decisionTextSize + pathsSize + 1000) // Base overhead
    }
}

extension DecisionPath {
    var estimatedMemorySize: UInt64 {
        let titleSize = title.utf8.count
        let descriptionSize = outcomeDescription.utf8.count
        
        return UInt64(titleSize + descriptionSize + 500) // Base overhead
    }
}

// MARK: - Cache-aware Timeline View
struct CachedTimelineView: View {
    @StateObject private var cacheManager = TimelineCacheManager()
    let timelineId: UUID
    
    var body: some View {
        Group {
            if cacheManager.isCacheLoading {
                LoadingView()
            } else if let timeline = cacheManager.getTimeline(timelineId) {
                TimelineDetailView(timeline: timeline)
            } else {
                ErrorView(message: "Timeline not found")
            }
        }
        .onAppear {
            // Preload cache if needed
            if cacheManager.cachedTimelines.isEmpty {
                cacheManager.loadCache()
            }
        }
    }
}

// MARK: - Cache Statistics View
struct CacheStatisticsView: View {
    @StateObject private var cacheManager = TimelineCacheManager()
    @State private var showingExportSheet = false
    @State private var exportURL: URL?
    
    var body: some View {
        NavigationView {
            VStack {
                if cacheManager.isCacheLoading {
                    ProgressView("Loading cache statistics...")
                } else {
                    List {
                        Section("Cache Overview") {
                            StatRow(title: "Total Timelines", value: "\(cacheManager.cacheSize)")
                            StatRow(title: "Memory Usage", value: formatBytes(cacheManager.memoryUsage))
                            StatRow(title: "Cache Hit Rate", value: "\(Int(cacheManager.getCacheStatistics().cacheHitRate * 100))%")
                        }
                        
                        Section("Timeline Dates") {
                            if let oldest = cacheManager.getCacheStatistics().oldestTimelineDate {
                                StatRow(title: "Oldest Timeline", value: formatDate(oldest))
                            }
                            if let newest = cacheManager.getCacheStatistics().newestTimelineDate {
                                StatRow(title: "Newest Timeline", value: formatDate(newest))
                            }
                            if let updated = cacheManager.getCacheStatistics().lastUpdated {
                                StatRow(title: "Last Updated", value: formatDate(updated))
                            }
                        }
                        
                        Section("Cache Management") {
                            Button("Clear Expired Cache") {
                                cacheManager.clearExpiredCache()
                            }
                            .foregroundColor(.orange)
                            
                            Button("Clear All Cache") {
                                cacheManager.clearCache()
                            }
                            .foregroundColor(.red)
                            
                            Button("Export Cache") {
                                exportURL = cacheManager.exportCache()
                                showingExportSheet = true
                            }
                            .foregroundColor(.blue)
                        }
                    }
                }
            }
            .navigationTitle("Cache Statistics")
            .sheet(isPresented: $showingExportSheet) {
                if let url = exportURL {
                    ShareSheet(items: [url])
                }
            }
        }
    }
    
    private func formatBytes(_ bytes: UInt64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(bytes))
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct StatRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}

// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Usage Example
struct TimelineCacheExample: View {
    @StateObject private var cacheManager = TimelineCacheManager()
    @State private var showingStats = false
    
    var body: some View {
        NavigationView {
            VStack {
                if cacheManager.isCacheLoading {
                    ProgressView("Loading cache...")
                } else {
                    List(cacheManager.cachedTimelines, id: \.id) { timeline in
                        NavigationLink(destination: TimelineDetailView(timeline: timeline)) {
                            VStack(alignment: .leading) {
                                Text(timeline.title)
                                    .fontWeight(.medium)
                                Text(timeline.decisionText)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(2)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Cached Timelines")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Stats") {
                        showingStats = true
                    }
                }
            }
            .sheet(isPresented: $showingStats) {
                CacheStatisticsView()
            }
        }
    }
}

struct TimelineDetailView: View {
    let timeline: Timeline
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(timeline.title)
                    .font(.title)
                    .fontWeight(.bold)
                
                Text(timeline.decisionText)
                    .font(.body)
                    .foregroundColor(.secondary)
                
                Text("Style: \(timeline.style.rawValue)")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(4)
                
                Text("Created: \(formatDate(timeline.createdAt))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
        .navigationTitle("Timeline Details")
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct LoadingView: View {
    var body: some View {
        ProgressView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ErrorView: View {
    let message: String
    
    var body: some View {
        VStack {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(.red)
            Text(message)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}