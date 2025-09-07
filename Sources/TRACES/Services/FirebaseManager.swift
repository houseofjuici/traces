//
//  FirebaseManager.swift
//  TRACES
//
//  Created by TRACES Development Team on 12/15/2024.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import FirebaseAnalytics
import Combine
import UIKit

// MARK: - Firebase Manager
class FirebaseManager: ObservableObject {
    static let shared = FirebaseManager()
    
    // MARK: - Published Properties
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Firebase Services
    private let auth = Auth.auth()
    private let firestore = Firestore.firestore()
    private let storage = Storage.storage()
    
    // MARK: - Collections
    private let usersCollection = "users"
    private let timelinesCollection = "timelines"
    private let wisdomCollection = "wisdom"
    private let transactionsCollection = "transactions"
    private let activityCollection = "activity"
    
    // MARK: - Cache
    private var userCache: [String: User] = [:]
    
    private init() {
        setupFirebase()
        listenForAuthChanges()
    }
    
    // MARK: - Setup
    private func setupFirebase() {
        // Configure Firestore settings
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        firestore.settings = settings
        
        // Configure Firebase Storage
        let storageSettings = StorageSettings()
        storage.maxOperationRetryTime = 30
        storage.maxUploadRetryTime = 30
        storage.maxDownloadRetryTime = 30
    }
    
    private func listenForAuthChanges() {
        auth.addStateDidChangeListener { [weak self] _, user in
            if let user = user {
                self?.fetchUser(uid: user.uid)
            } else {
                self?.currentUser = nil
                self?.userCache.removeAll()
            }
        }
    }
    
    // MARK: - Authentication
    func signUp(email: String, password: String, name: String) async throws -> User {
        isLoading = true
        errorMessage = nil
        
        defer {
            isLoading = false
        }
        
        do {
            let authResult = try await auth.createUser(withEmail: email, password: password)
            
            let user = User(
                id: authResult.user.uid,
                name: name,
                email: email,
                avatarURL: nil,
                joinedDate: Date(),
                totalCreditsEarned: 247, // Starting credits
                timelinesCreated: 0,
                wisdomShared: 0
            )
            
            // Save user to Firestore
            try await saveUser(user)
            
            // Send verification email
            try await authResult.user.sendEmailVerification()
            
            // Log analytics event
            await logEvent("user_signed_up", parameters: [
                "user_id": user.id,
                "email": email
            ])
            
            return user
        } catch {
            errorMessage = "Sign up failed: \(error.localizedDescription)"
            await logError(error)
            throw error
        }
    }
    
    func signIn(email: String, password: String) async throws -> User {
        isLoading = true
        errorMessage = nil
        
        defer {
            isLoading = false
        }
        
        do {
            let authResult = try await auth.signIn(withEmail: email, password: password)
            
            guard let user = await fetchUser(uid: authResult.user.uid) else {
                throw NSError(domain: "FirebaseManager", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found"])
            }
            
            // Log analytics event
            await logEvent("user_signed_in", parameters: [
                "user_id": user.id,
                "email": email
            ])
            
            return user
        } catch {
            errorMessage = "Sign in failed: \(error.localizedDescription)"
            await logError(error)
            throw error
        }
    }
    
    func signOut() async throws {
        do {
            try auth.signOut()
            currentUser = nil
            userCache.removeAll()
            
            // Log analytics event
            await logEvent("user_signed_out", parameters: [:])
        } catch {
            errorMessage = "Sign out failed: \(error.localizedDescription)"
            await logError(error)
            throw error
        }
    }
    
    func resetPassword(email: String) async throws {
        isLoading = true
        errorMessage = nil
        
        defer {
            isLoading = false
        }
        
        do {
            try await auth.sendPasswordReset(withEmail: email)
            
            // Log analytics event
            await logEvent("password_reset_requested", parameters: [
                "email": email
            ])
        } catch {
            errorMessage = "Password reset failed: \(error.localizedDescription)"
            await logError(error)
            throw error
        }
    }
    
    // MARK: - User Management
    func fetchUser(uid: String) async -> User? {
        // Check cache first
        if let cachedUser = userCache[uid] {
            return cachedUser
        }
        
        do {
            let document = try await firestore.collection(usersCollection).document(uid).getDocument()
            
            guard let data = document.data() else { return nil }
            
            let user = User(
                id: uid,
                name: data["name"] as? String ?? "",
                email: data["email"] as? String ?? "",
                avatarURL: data["avatarURL"] as? String.flatMap { URL(string: $0) },
                joinedDate: (data["joinedDate"] as? Timestamp)?.dateValue() ?? Date(),
                totalCreditsEarned: data["totalCreditsEarned"] as? Int ?? 0,
                timelinesCreated: data["timelinesCreated"] as? Int ?? 0,
                wisdomShared: data["wisdomShared"] as? Int ?? 0
            )
            
            // Cache user
            userCache[uid] = user
            currentUser = user
            
            return user
        } catch {
            print("Error fetching user: \(error)")
            await logError(error)
            return nil
        }
    }
    
    func saveUser(_ user: User) async throws {
        let userData: [String: Any] = [
            "name": user.name,
            "email": user.email,
            "avatarURL": user.avatarURL?.absoluteString ?? NSNull(),
            "joinedDate": Timestamp(date: user.joinedDate),
            "totalCreditsEarned": user.totalCreditsEarned,
            "timelinesCreated": user.timelinesCreated,
            "wisdomShared": user.wisdomShared,
            "updatedAt": Timestamp(date: Date())
        ]
        
        try await firestore.collection(usersCollection).document(user.id).setData(userData)
        
        // Update cache
        userCache[user.id] = user
        currentUser = user
    }
    
    func updateUserProfile(name: String? = nil, avatarURL: URL? = nil) async throws {
        guard let currentUser = currentUser else { return }
        
        var updatedUser = currentUser
        if let name = name { updatedUser.name = name }
        if let avatarURL = avatarURL { updatedUser.avatarURL = avatarURL }
        
        try await saveUser(updatedUser)
        
        // Log analytics event
        await logEvent("user_profile_updated", parameters: [
            "user_id": currentUser.id,
            "name_updated": name != nil,
            "avatar_updated": avatarURL != nil
        ])
    }
    
    func updateUserCredits(_ credits: Int) async {
        guard let currentUser = currentUser else { return }
        
        let updatedUser = User(
            id: currentUser.id,
            name: currentUser.name,
            email: currentUser.email,
            avatarURL: currentUser.avatarURL,
            joinedDate: currentUser.joinedDate,
            totalCreditsEarned: max(currentUser.totalCreditsEarned, credits),
            timelinesCreated: currentUser.timelinesCreated,
            wisdomShared: currentUser.wisdomShared
        )
        
        try? await saveUser(updatedUser)
        
        // Log analytics event
        await logEvent("user_credits_updated", parameters: [
            "user_id": currentUser.id,
            "new_credits": credits,
            "previous_credits": currentUser.totalCreditsEarned
        ])
    }
    
    // MARK: - Timeline Management
    func saveTimeline(_ timeline: Timeline) async throws {
        guard let currentUser = currentUser else { throw NSError(domain: "FirebaseManager", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]) }
        
        let timelineData: [String: Any] = [
            "userId": currentUser.id,
            "title": timeline.title,
            "decision": timeline.decision,
            "createdDate": Timestamp(date: timeline.createdDate),
            "style": timeline.style.rawValue,
            "paths": timeline.paths.map { path in
                [
                    "id": path.id.uuidString,
                    "title": path.title,
                    "probability": path.probability,
                    "outcomeDescription": path.outcomeDescription,
                    "emotionalIndicator": path.emotionalIndicator.rawValue,
                    "keyMoments": path.keyMoments
                ]
            },
            "emotionalTone": timeline.emotionalTone.rawValue,
            "duration": timeline.duration,
            "isSequelAvailable": timeline.isSequelAvailable,
            "updatedAt": Timestamp(date: Date())
        ]
        
        let documentRef = firestore.collection(timelinesCollection).document(timeline.id.uuidString)
        try await documentRef.setData(timelineData)
        
        // Upload video if exists
        if let videoURL = timeline.videoURL {
            try await uploadTimelineVideo(videoURL, timelineId: timeline.id.uuidString)
        }
        
        // Upload thumbnail if exists
        if let thumbnailURL = timeline.thumbnailURL {
            try await uploadTimelineThumbnail(thumbnailURL, timelineId: timeline.id.uuidString)
        }
        
        // Update user stats
        let updatedUser = User(
            id: currentUser.id,
            name: currentUser.name,
            email: currentUser.email,
            avatarURL: currentUser.avatarURL,
            joinedDate: currentUser.joinedDate,
            totalCreditsEarned: currentUser.totalCreditsEarned,
            timelinesCreated: currentUser.timelinesCreated + 1,
            wisdomShared: currentUser.wisdomShared
        )
        try await saveUser(updatedUser)
        
        // Log activity
        let activity = ActivityItem(
            title: "Timeline '\(timeline.title)' created",
            type: .timelineCreated,
            date: Date(),
            isUnread: true
        )
        try await logActivity(activity)
        
        // Log analytics event
        await logEvent("timeline_created", parameters: [
            "user_id": currentUser.id,
            "timeline_id": timeline.id.uuidString,
            "style": timeline.style.rawValue,
            "emotional_tone": timeline.emotionalTone.rawValue
        ])
    }
    
    func fetchTimelines() async throws -> [Timeline] {
        guard let currentUser = currentUser else { return [] }
        
        let query = firestore.collection(timelinesCollection)
            .whereField("userId", isEqualTo: currentUser.id)
            .order(by: "createdDate", descending: true)
        
        let snapshot = try await query.getDocuments()
        
        var timelines: [Timeline] = []
        for document in snapshot.documents {
            if let timeline = timelineFromDocument(document) {
                timelines.append(timeline)
            }
        }
        
        return timelines
    }
    
    private func timelineFromDocument(_ document: QueryDocumentSnapshot) -> Timeline? {
        let data = document.data()
        
        guard let title = data["title"] as? String,
              let decision = data["decision"] as? String,
              let createdDate = (data["createdDate"] as? Timestamp)?.dateValue(),
              let styleString = data["style"] as? String,
              let style = VideoStyle(rawValue: styleString),
              let emotionalToneString = data["emotionalTone"] as? String,
              let emotionalTone = EmotionalTone(rawValue: emotionalToneString) else {
            return nil
        }
        
        let pathsData = data["paths"] as? [[String: Any]] ?? []
        let paths = pathsData.compactMap { pathData -> DecisionPath? in
            guard let idString = pathData["id"] as? String,
                  let id = UUID(uuidString: idString),
                  let title = pathData["title"] as? String,
                  let probability = pathData["probability"] as? Double,
                  let outcomeDescription = pathData["outcomeDescription"] as? String,
                  let emotionalIndicatorString = pathData["emotionalIndicator"] as? String,
                  let emotionalIndicator = EmotionalIndicator(rawValue: emotionalIndicatorString) else {
                return nil
            }
            let keyMoments = pathData["keyMoments"] as? [String] ?? []
            return DecisionPath(
                id: id,
                title: title,
                probability: probability,
                outcomeDescription: outcomeDescription,
                emotionalIndicator: emotionalIndicator,
                keyMoments: keyMoments
            )
        }
        
        let videoURL = data["videoURL"] as? String.flatMap { URL(string: $0) }
        let thumbnailURL = data["thumbnailURL"] as? String.flatMap { URL(string: $0) }
        
        return Timeline(
            id: UUID(uuidString: document.documentID) ?? UUID(),
            title: title,
            decision: decision,
            createdDate: createdDate,
            videoURL: videoURL,
            thumbnailURL: thumbnailURL,
            style: style,
            paths: paths,
            emotionalTone: emotionalTone,
            duration: data["duration"] as? Double ?? 3.0,
            isSequelAvailable: data["isSequelAvailable"] as? Bool ?? false
        )
    }
    
    // MARK: - Timeline Media Upload
    private func uploadTimelineVideo(_ videoURL: URL, timelineId: String) async throws {
        let storageRef = storage.reference().child("timelines/\(timelineId)/video.mp4")
        
        let metadata = StorageMetadata()
        metadata.contentType = "video/mp4"
        
        _ = try await storageRef.putFile(from: videoURL, metadata: metadata)
        
        let downloadURL = try await storageRef.downloadURL()
        
        // Update timeline document with video URL
        try await firestore.collection(timelinesCollection).document(timelineId).updateData([
            "videoURL": downloadURL.absoluteString
        ])
    }
    
    private func uploadTimelineThumbnail(_ thumbnailURL: URL, timelineId: String) async throws {
        let storageRef = storage.reference().child("timelines/\(timelineId)/thumbnail.jpg")
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        _ = try await storageRef.putFile(from: thumbnailURL, metadata: metadata)
        
        let downloadURL = try await storageRef.downloadURL()
        
        // Update timeline document with thumbnail URL
        try await firestore.collection(timelinesCollection).document(timelineId).updateData([
            "thumbnailURL": downloadURL.absoluteString
        ])
    }
    
    // MARK: - Wisdom Management
    func getWisdomItems() async throws -> [WisdomItem] {
        let snapshot = try await firestore.collection(wisdomCollection).getDocuments()
        
        var wisdomItems: [WisdomItem] = []
        for document in snapshot.documents {
            if let wisdomItem = wisdomItemFromDocument(document) {
                wisdomItems.append(wisdomItem)
            }
        }
        
        return wisdomItems
    }
    
    func saveWisdomPurchase(_ wisdomItem: WisdomItem) async throws {
        guard let currentUser = currentUser else { throw NSError(domain: "FirebaseManager", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]) }
        
        let purchaseData: [String: Any] = [
            "userId": currentUser.id,
            "wisdomId": wisdomItem.id,
            "title": wisdomItem.title,
            "price": wisdomItem.price,
            "purchasedAt": Timestamp(date: Date())
        ]
        
        try await firestore.collection("wisdom_purchases").addDocument(data: purchaseData)
        
        // Log activity
        let activity = ActivityItem(
            title: "Wisdom '\(wisdomItem.title)' purchased",
            type: .wisdomPurchased,
            date: Date(),
            isUnread: true
        )
        try await logActivity(activity)
        
        // Log analytics event
        await logEvent("wisdom_purchased", parameters: [
            "user_id": currentUser.id,
            "wisdom_id": wisdomItem.id,
            "price": wisdomItem.price,
            "category": wisdomItem.category.rawValue
        ])
    }
    
    private func wisdomItemFromDocument(_ document: QueryDocumentSnapshot) -> WisdomItem? {
        let data = document.data()
        
        guard let title = data["title"] as? String,
              let description = data["description"] as? String,
              let price = data["price"] as? Int,
              let categoryString = data["category"] as? String,
              let category = WisdomCategory(rawValue: categoryString) else {
            return nil
        }
        
        let author = data["author"] as? String ?? "TRACES AI"
        let rating = data["rating"] as? Double ?? 0.0
        let purchaseCount = data["purchaseCount"] as? Int ?? 0
        
        return WisdomItem(
            id: document.documentID,
            title: title,
            description: description,
            price: price,
            category: category,
            author: author,
            rating: rating,
            purchaseCount: purchaseCount
        )
    }
    
    // MARK: - Activity & Transactions
    func logActivity(_ activity: ActivityItem) async throws {
        guard let currentUser = currentUser else { return }
        
        let activityData: [String: Any] = [
            "userId": currentUser.id,
            "title": activity.title,
            "type": activity.type.rawValue,
            "date": Timestamp(date: activity.date),
            "isUnread": activity.isUnread
        ]
        
        try await firestore.collection(activityCollection).addDocument(data: activityData)
    }
    
    func logTransaction(_ transaction: Transaction) async throws {
        guard let currentUser = currentUser else { return }
        
        let transactionData: [String: Any] = [
            "userId": currentUser.id,
            "type": transaction.type.rawValue,
            "amount": transaction.amount,
            "description": transaction.description,
            "date": Timestamp(date: transaction.date)
        ]
        
        try await firestore.collection(transactionsCollection).addDocument(data: transactionData)
    }
    
    // MARK: - Error Logging
    func logError(_ error: Error) async {
        guard let currentUser = currentUser else { return }
        
        let errorData: [String: Any] = [
            "userId": currentUser.id,
            "error": error.localizedDescription,
            "timestamp": Timestamp(date: Date()),
            "deviceInfo": [
                "systemVersion": UIDevice.current.systemVersion,
                "model": UIDevice.current.model,
                "appVersion": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
            ]
        ]
        
        try? await firestore.collection("errors").addDocument(data: errorData)
    }
    
    // MARK: - Analytics
    func logEvent(_ eventName: String, parameters: [String: Any]? = nil) async {
        Analytics.logEvent(eventName, parameters: parameters)
    }
    
    func setUserProperty(_ value: String?, forName name: String) async {
        Analytics.setUserProperty(value, forName: name)
    }
}