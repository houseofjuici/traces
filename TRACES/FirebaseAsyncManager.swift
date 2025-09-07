//
//  FirebaseAsyncManager.swift
//  TRACES
//
//  Created by TRACES Development Team on 12/15/2024.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseAuth
import Combine

// MARK: - Firebase Async Manager
@MainActor
class FirebaseAsyncManager: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var lastError: Error?
    @Published var networkStatus: NetworkStatus = .connected
    
    private var cancellables = Set<AnyCancellable>()
    private let firestore = Firestore.firestore()
    private let auth = Auth.auth()
    
    enum NetworkStatus {
        case connected
        case disconnected
        case connecting
    }
    
    // MARK: - Authentication Async Operations
    func signInWithEmail(email: String, password: String) async throws -> User {
        isLoading = true
        lastError = nil
        
        defer {
            isLoading = false
        }
        
        do {
            let result = try await auth.signIn(withEmail: email, password: password)
            return result.user
        } catch {
            lastError = error
            throw error
        }
    }
    
    func signUpWithEmail(email: String, password: String, displayName: String) async throws -> User {
        isLoading = true
        lastError = nil
        
        defer {
            isLoading = false
        }
        
        do {
            let result = try await auth.createUser(withEmail: email, password: password)
            
            // Update user profile
            let changeRequest = result.user.createProfileChangeRequest()
            changeRequest.displayName = displayName
            try await changeRequest.commitChanges()
            
            // Create user document
            try await createUserDocument(for: result.user, displayName: displayName)
            
            return result.user
        } catch {
            lastError = error
            throw error
        }
    }
    
    func signOut() async throws {
        do {
            try auth.signOut()
        } catch {
            lastError = error
            throw error
        }
    }
    
    // MARK: - User Data Operations
    func fetchUserData(userId: String) async throws -> [String: Any] {
        isLoading = true
        lastError = nil
        
        defer {
            isLoading = false
        }
        
        do {
            let document = try await firestore.collection("users").document(userId).getDocument()
            guard let data = document.data() else {
                throw NSError(domain: "FirebaseAsyncManager", code: 404, userInfo: [NSLocalizedDescriptionKey: "User data not found"])
            }
            return data
        } catch {
            lastError = error
            throw error
        }
    }
    
    func updateUserData(userId: String, data: [String: Any]) async throws {
        isLoading = true
        lastError = nil
        
        defer {
            isLoading = false
        }
        
        do {
            try await firestore.collection("users").document(userId).updateData(data)
        } catch {
            lastError = error
            throw error
        }
    }
    
    // MARK: - Timeline Operations
    func fetchTimelines(userId: String) async throws -> [Timeline] {
        isLoading = true
        lastError = nil
        
        defer {
            isLoading = false
        }
        
        do {
            let snapshot = try await firestore.collection("users")
                .document(userId)
                .collection("timelines")
                .order(by: "createdAt", descending: true)
                .getDocuments()
            
            let timelines = snapshot.documents.compactMap { document -> Timeline? in
                try? Timeline(from: document.data())
            }
            
            return timelines
        } catch {
            lastError = error
            throw error
        }
    }
    
    func saveTimeline(userId: String, timeline: Timeline) async throws -> String {
        isLoading = true
        lastError = nil
        
        defer {
            isLoading = false
        }
        
        do {
            let documentRef = firestore.collection("users")
                .document(userId)
                .collection("timelines")
                .document()
            
            let timelineData = try timeline.toDictionary()
            try await documentRef.setData(timelineData)
            
            return documentRef.documentID
        } catch {
            lastError = error
            throw error
        }
    }
    
    func deleteTimeline(userId: String, timelineId: String) async throws {
        isLoading = true
        lastError = nil
        
        defer {
            isLoading = false
        }
        
        do {
            try await firestore.collection("users")
                .document(userId)
                .collection("timelines")
                .document(timelineId)
                .delete()
        } catch {
            lastError = error
            throw error
        }
    }
    
    // MARK: - Real-time Listeners
    func listenToTimelines(userId: String) -> AnyPublisher<[Timeline], Error> {
        return firestore.collection("users")
            .document(userId)
            .collection("timelines")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener()
            .map { snapshot in
                snapshot.documents.compactMap { document -> Timeline? in
                    try? Timeline(from: document.data())
                }
            }
            .eraseToAnyPublisher()
    }
    
    func listenToUserData(userId: String) -> AnyPublisher<[String: Any], Error> {
        return firestore.collection("users")
            .document(userId)
            .addSnapshotListener()
            .map { document in
                guard let data = document.data() else {
                    throw NSError(domain: "FirebaseAsyncManager", code: 404, userInfo: [NSLocalizedDescriptionKey: "User data not found"])
                }
                return data
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - File Storage Operations
    func uploadImage(userId: String, image: UIImage, path: String) async throws -> URL {
        isLoading = true
        lastError = nil
        
        defer {
            isLoading = false
        }
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw NSError(domain: "FirebaseAsyncManager", code: 400, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to data"])
        }
        
        do {
            let storage = Storage.storage()
            let storageRef = storage.reference().child("\(userId)/\(path)")
            
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            
            let _ = try await storageRef.putDataAsync(imageData, metadata: metadata)
            let downloadURL = try await storageRef.downloadURL()
            
            return downloadURL
        } catch {
            lastError = error
            throw error
        }
    }
    
    // MARK: - Error Handling
    func clearError() {
        lastError = nil
    }
    
    // MARK: - Network Monitoring
    func startNetworkMonitoring() {
        // This would use Network.framework to monitor network status
        // For now, we'll use a simple implementation
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            Task {
                await self.checkNetworkStatus()
            }
        }
    }
    
    private func checkNetworkStatus() async {
        do {
            let _ = try await firestore.collection("users").limit(to: 1).getDocuments()
            networkStatus = .connected
        } catch {
            networkStatus = .disconnected
        }
    }
    
    // MARK: - Private Methods
    private func createUserDocument(for user: User, displayName: String) async throws {
        let userData: [String: Any] = [
            "userId": user.uid,
            "email": user.email ?? "",
            "displayName": displayName,
            "createdAt": FieldValue.serverTimestamp(),
            "credits": 247,
            "timelinesCreated": 0,
            "wisdomShared": 0
        ]
        
        try await firestore.collection("users").document(user.uid).setData(userData)
    }
}

// MARK: - Async/Await Extensions for Firebase
extension StorageReference {
    func putDataAsync(_ data: Data, metadata: StorageMetadata? = nil) async throws -> StorageMetadata {
        return try await withCheckedThrowingContinuation { continuation in
            self.putData(data, metadata: metadata) { metadata, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: metadata ?? StorageMetadata())
                }
            }
        }
    }
    
    func downloadURLAsync() async throws -> URL {
        return try await withCheckedThrowingContinuation { continuation in
            self.downloadURL { url, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let url = url {
                    continuation.resume(returning: url)
                } else {
                    continuation.resume(throwing: NSError(domain: "Storage", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown error"]))
                }
            }
        }
    }
}

// MARK: - Timeline Codable Support
extension Timeline {
    init(from dictionary: [String: Any]) throws {
        // Implementation for converting Firestore document to Timeline
        // This would need to match your Timeline model structure
        self.init(
            id: UUID(),
            title: dictionary["title"] as? String ?? "",
            decisionText: dictionary["decisionText"] as? String ?? "",
            style: .realistic, // Parse from dictionary
            duration: dictionary["duration"] as? Double ?? 3.0,
            paths: [], // Parse from dictionary
            createdAt: Date(), // Parse from dictionary
            videoURL: URL(string: dictionary["videoURL"] as? String ?? "")
        )
    }
    
    func toDictionary() throws -> [String: Any] {
        // Implementation for converting Timeline to Firestore document
        return [
            "title": title,
            "decisionText": decisionText,
            "style": style.rawValue,
            "duration": duration,
            "createdAt": FieldValue.serverTimestamp(),
            "videoURL": videoURL?.absoluteString ?? ""
        ]
    }
}

// MARK: - SwiftUI Async Task Wrapper
struct AsyncTaskView<Content: View>: View {
    @StateObject private var firebaseManager = FirebaseAsyncManager()
    let task: () async throws -> Void
    let content: (FirebaseAsyncManager) -> Content
    let onSuccess: () -> Void
    let onError: (Error) -> Void
    
    init(
        task: @escaping () async throws -> Void,
        onSuccess: @escaping () -> Void = {},
        onError: @escaping (Error) -> Void = { _ in },
        @ViewBuilder content: @escaping (FirebaseAsyncManager) -> Content
    ) {
        self.task = task
        self.content = content
        self.onSuccess = onSuccess
        self.onError = onError
    }
    
    var body: some View {
        content(firebaseManager)
            .task {
                do {
                    try await task()
                    onSuccess()
                } catch {
                    onError(error)
                }
            }
    }
}

// MARK: - Usage Example
struct FirebaseAsyncExample: View {
    @State private var timelines: [Timeline] = []
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            VStack {
                if timelines.isEmpty {
                    Text("No timelines yet")
                        .foregroundColor(.secondary)
                } else {
                    List(timelines, id: \.id) { timeline in
                        Text(timeline.title)
                    }
                }
                
                Button("Load Timelines") {
                    showAlert = true
                }
                .padding()
            }
            .navigationTitle("Firebase Async Demo")
            .alert("Error", isPresented: $showAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
        .task {
            do {
                let manager = FirebaseAsyncManager()
                timelines = try await manager.fetchTimelines(userId: "currentUserId")
            } catch {
                alertMessage = error.localizedDescription
                showAlert = true
            }
        }
    }
}