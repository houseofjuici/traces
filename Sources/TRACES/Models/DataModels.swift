//
//  DataModels.swift
//  TRACES
//
//  Created by TRACES Development Team on 12/15/2024.
//

import Foundation

// MARK: - Core Data Models

struct Timeline: Identifiable, Codable, Equatable {
    let id: UUID
    let title: String
    let decision: String
    let createdDate: Date
    let videoURL: URL?
    let thumbnailURL: URL?
    let style: VideoStyle
    let paths: [DecisionPath]
    let emotionalTone: EmotionalTone
    let duration: Double
    var isSequelAvailable: Bool = false
    
    // Coding keys for Codable conformance
    enum CodingKeys: String, CodingKey {
        case id, title, decision, createdDate, videoURL, thumbnailURL, style, paths, emotionalTone, duration, isSequelAvailable
    }
    
    // Initialize with default values
    init(id: UUID = UUID(), title: String, decision: String, createdDate: Date = Date(), videoURL: URL? = nil, thumbnailURL: URL? = nil, style: VideoStyle, paths: [DecisionPath], emotionalTone: EmotionalTone, duration: Double = 3.0, isSequelAvailable: Bool = false) {
        self.id = id
        self.title = title
        self.decision = decision
        self.createdDate = createdDate
        self.videoURL = videoURL
        self.thumbnailURL = thumbnailURL
        self.style = style
        self.paths = paths
        self.emotionalTone = emotionalTone
        self.duration = duration
        self.isSequelAvailable = isSequelAvailable
    }
    
    // Codable implementation
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        decision = try container.decode(String.self, forKey: .decision)
        createdDate = try container.decode(Date.self, forKey: .createdDate)
        videoURL = try container.decode(URL?.self, forKey: .videoURL)
        thumbnailURL = try container.decode(URL?.self, forKey: .thumbnailURL)
        style = try container.decode(VideoStyle.self, forKey: .style)
        paths = try container.decode([DecisionPath].self, forKey: .paths)
        emotionalTone = try container.decode(EmotionalTone.self, forKey: .emotionalTone)
        duration = try container.decode(Double.self, forKey: .duration)
        isSequelAvailable = try container.decode(Bool.self, forKey: .isSequelAvailable)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(decision, forKey: .decision)
        try container.encode(createdDate, forKey: .createdDate)
        try container.encode(videoURL, forKey: .videoURL)
        try container.encode(thumbnailURL, forKey: .thumbnailURL)
        try container.encode(style, forKey: .style)
        try container.encode(paths, forKey: .paths)
        try container.encode(emotionalTone, forKey: .emotionalTone)
        try container.encode(duration, forKey: .duration)
        try container.encode(isSequelAvailable, forKey: .isSequelAvailable)
    }
}

struct DecisionPath: Identifiable, Codable, Equatable {
    let id: UUID
    let title: String
    let probability: Double // 0.0 - 1.0
    let outcomeDescription: String
    let emotionalIndicator: EmotionalIndicator
    let keyMoments: [String]
    
    // Coding keys for Codable conformance
    enum CodingKeys: String, CodingKey {
        case id, title, probability, outcomeDescription, emotionalIndicator, keyMoments
    }
    
    // Initialize with default values
    init(id: UUID = UUID(), title: String, probability: Double, outcomeDescription: String, emotionalIndicator: EmotionalIndicator, keyMoments: [String] = []) {
        self.id = id
        self.title = title
        self.probability = probability
        self.outcomeDescription = outcomeDescription
        self.emotionalIndicator = emotionalIndicator
        self.keyMoments = keyMoments
    }
    
    // Codable implementation
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        probability = try container.decode(Double.self, forKey: .probability)
        outcomeDescription = try container.decode(String.self, forKey: .outcomeDescription)
        emotionalIndicator = try container.decode(EmotionalIndicator.self, forKey: .emotionalIndicator)
        keyMoments = try container.decode([String].self, forKey: .keyMoments)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(probability, forKey: .probability)
        try container.encode(outcomeDescription, forKey: .outcomeDescription)
        try container.encode(emotionalIndicator, forKey: .emotionalIndicator)
        try container.encode(keyMoments, forKey: .keyMoments)
    }
}

struct ActivityItem: Identifiable, Codable, Equatable {
    let id: UUID
    let title: String
    let type: ActivityType
    let date: Date
    var isUnread: Bool
    
    // Coding keys for Codable conformance
    enum CodingKeys: String, CodingKey {
        case id, title, type, date, isUnread
    }
    
    // Initialize with default values
    init(id: UUID = UUID(), title: String, type: ActivityType, date: Date = Date(), isUnread: Bool = true) {
        self.id = id
        self.title = title
        self.type = type
        self.date = date
        self.isUnread = isUnread
    }
    
    // Codable implementation
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        type = try container.decode(ActivityType.self, forKey: .type)
        date = try container.decode(Date.self, forKey: .date)
        isUnread = try container.decode(Bool.self, forKey: .isUnread)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(type, forKey: .type)
        try container.encode(date, forKey: .date)
        try container.encode(isUnread, forKey: .isUnread)
    }
}

struct WisdomItem: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let description: String
    let price: Int
    let category: WisdomCategory
    let author: String
    let rating: Double
    let purchaseCount: Int
    
    // Coding keys for Codable conformance
    enum CodingKeys: String, CodingKey {
        case id, title, description, price, category, author, rating, purchaseCount
    }
    
    // Initialize with default values
    init(id: String, title: String, description: String, price: Int, category: WisdomCategory, author: String = "TRACES AI", rating: Double = 0.0, purchaseCount: Int = 0) {
        self.id = id
        self.title = title
        self.description = description
        self.price = price
        self.category = category
        self.author = author
        self.rating = rating
        self.purchaseCount = purchaseCount
    }
    
    // Codable implementation
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decode(String.self, forKey: .description)
        price = try container.decode(Int.self, forKey: .price)
        category = try container.decode(WisdomCategory.self, forKey: .category)
        author = try container.decode(String.self, forKey: .author)
        rating = try container.decode(Double.self, forKey: .rating)
        purchaseCount = try container.decode(Int.self, forKey: .purchaseCount)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(description, forKey: .description)
        try container.encode(price, forKey: .price)
        try container.encode(category, forKey: .category)
        try container.encode(author, forKey: .author)
        try container.encode(rating, forKey: .rating)
        try container.encode(purchaseCount, forKey: .purchaseCount)
    }
}

struct User: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let email: String
    let avatarURL: URL?
    let joinedDate: Date
    let totalCreditsEarned: Int
    let timelinesCreated: Int
    let wisdomShared: Int
    
    // Coding keys for Codable conformance
    enum CodingKeys: String, CodingKey {
        case id, name, email, avatarURL, joinedDate, totalCreditsEarned, timelinesCreated, wisdomShared
    }
    
    // Initialize with default values
    init(id: String, name: String, email: String, avatarURL: URL? = nil, joinedDate: Date = Date(), totalCreditsEarned: Int = 0, timelinesCreated: Int = 0, wisdomShared: Int = 0) {
        self.id = id
        self.name = name
        self.email = email
        self.avatarURL = avatarURL
        self.joinedDate = joinedDate
        self.totalCreditsEarned = totalCreditsEarned
        self.timelinesCreated = timelinesCreated
        self.wisdomShared = wisdomShared
    }
    
    // Codable implementation
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        email = try container.decode(String.self, forKey: .email)
        avatarURL = try container.decode(URL?.self, forKey: .avatarURL)
        joinedDate = try container.decode(Date.self, forKey: .joinedDate)
        totalCreditsEarned = try container.decode(Int.self, forKey: .totalCreditsEarned)
        timelinesCreated = try container.decode(Int.self, forKey: .timelinesCreated)
        wisdomShared = try container.decode(Int.self, forKey: .wisdomShared)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(email, forKey: .email)
        try container.encode(avatarURL, forKey: .avatarURL)
        try container.encode(joinedDate, forKey: .joinedDate)
        try container.encode(totalCreditsEarned, forKey: .totalCreditsEarned)
        try container.encode(timelinesCreated, forKey: .timelinesCreated)
        try container.encode(wisdomShared, forKey: .wisdomShared)
    }
}

struct Transaction: Identifiable, Codable, Equatable {
    let id: UUID
    let type: TransactionType
    let amount: Int
    let description: String
    let date: Date
    
    // Coding keys for Codable conformance
    enum CodingKeys: String, CodingKey {
        case id, type, amount, description, date
    }
    
    // Initialize with default values
    init(id: UUID = UUID(), type: TransactionType, amount: Int, description: String, date: Date = Date()) {
        self.id = id
        self.type = type
        self.amount = amount
        self.description = description
        self.date = date
    }
    
    // Codable implementation
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        type = try container.decode(TransactionType.self, forKey: .type)
        amount = try container.decode(Int.self, forKey: .amount)
        description = try container.decode(String.self, forKey: .description)
        date = try container.decode(Date.self, forKey: .date)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(type, forKey: .type)
        try container.encode(amount, forKey: .amount)
        try container.encode(description, forKey: .description)
        try container.encode(date, forKey: .date)
    }
}

// MARK: - Enum Definitions

enum VideoStyle: String, CaseIterable, Codable {
    case realistic = "Realistic"
    case anime = "Anime" 
    case watercolor = "Watercolor"
    case sketch = "Sketch"
}

enum EmotionalTone: String, CaseIterable, Codable {
    case optimistic = "Optimistic"
    case realistic = "Realistic"
    case challenging = "Challenging"
    case balanced = "Balanced"
}

enum EmotionalIndicator: String, CaseIterable, Codable {
    case success = "Success"
    case challenge = "Challenge"
    case neutral = "Neutral"
    case growth = "Growth"
}

enum ActivityType: String, CaseIterable, Codable {
    case timelineCreated = "Timeline Created"
    case sequelReady = "Sequel Ready"
    case wisdomPurchased = "Wisdom Purchased"
    case wisdomShared = "Wisdom Shared"
    case creditsEarned = "Credits Earned"
    
    var iconName: String {
        switch self {
        case .timelineCreated:
            return "plus.circle"
        case .sequelReady:
            return "arrow.right.circle"
        case .wisdomPurchased:
            return "bag.fill"
        case .wisdomShared:
            return "heart.circle"
        case .creditsEarned:
            return "star.circle"
        }
    }
}

enum WisdomCategory: String, CaseIterable, Codable {
    case career = "Career"
    case relationships = "Relationships"
    case personal = "Personal Growth"
    case financial = "Financial"
    case health = "Health"
    case spiritual = "Spiritual"
}

enum TransactionType: String, CaseIterable, Codable {
    case earn = "Earn"
    case spend = "Spend"
    case adjustment = "Adjustment"
    
    var iconName: String {
        switch self {
        case .earn: return "plus.circle"
        case .spend: return "minus.circle"
        case .adjustment: return "arrow.triangle.2.circlepath"
        }
    }
}

enum AppTab: Int, CaseIterable, Codable {
    case dashboard = 0
    case create = 1
    case library = 2
    case wallet = 3
    case ar = 4
    case profile = 5
    
    var iconName: String {
        switch self {
        case .dashboard: return "house"
        case .create: return "plus.circle"
        case .library: return "book"
        case .wallet: return "creditcard"
        case .ar: return "arkit"
        case .profile: return "person"
        }
    }
    
    var title: String {
        switch self {
        case .dashboard: return "Dashboard"
        case .create: return "Create"
        case .library: return "Library"
        case .wallet: return "Wallet"
        case .ar: return "AR Coach"
        case .profile: return "Profile"
        }
    }
}

// MARK: - Error Types

enum TimelineError: LocalizedError, Codable {
    case insufficientCredits
    case generationFailed
    case invalidInput
    
    var errorDescription: String? {
        switch self {
        case .insufficientCredits:
            return "Insufficient credits to create timeline"
        case .generationFailed:
            return "Failed to generate timeline"
        case .invalidInput:
            return "Invalid input for timeline creation"
        }
    }
}

enum WisdomError: LocalizedError, Codable {
    case insufficientCredits
    case alreadyOwned
    case notAvailable
    
    var errorDescription: String? {
        switch self {
        case .insufficientCredits:
            return "Insufficient credits to purchase wisdom"
        case .alreadyOwned:
            return "You already own this wisdom item"
        case .notAvailable:
            return "This wisdom item is not available"
        }
    }
}

// MARK: - Mock Data

struct MockData {
    static let timelines = [
        Timeline(
            title: "Career Change",
            decision: "Should I switch to a tech career?",
            createdDate: Date().addingTimeInterval(-3600),
            videoURL: nil,
            thumbnailURL: nil,
            style: .realistic,
            paths: [
                DecisionPath(title: "Success", probability: 0.7, outcomeDescription: "Thriving in new role", emotionalIndicator: .success),
                DecisionPath(title: "Growth", probability: 0.2, outcomeDescription: "Learning curve challenges", emotionalIndicator: .growth),
                DecisionPath(title: "Struggle", probability: 0.1, outcomeDescription: "Difficulty adapting", emotionalIndicator: .challenge)
            ],
            emotionalTone: .optimistic
        ),
        Timeline(
            title: "Business Venture",
            decision: "Should I quit my job and start my own business?",
            createdDate: Date().addingTimeInterval(-86400 * 3),
            videoURL: nil,
            thumbnailURL: nil,
            style: .realistic,
            paths: [
                DecisionPath(title: "Success", probability: 0.4, outcomeDescription: "Your business thrives", emotionalIndicator: .success),
                DecisionPath(title: "Challenges", probability: 0.5, outcomeDescription: "Initial struggles but growth", emotionalIndicator: .challenge),
                DecisionPath(title: "Balanced", probability: 0.1, outcomeDescription: "Steady progress", emotionalIndicator: .neutral)
            ],
            emotionalTone: .challenging
        )
    ]
    
    static let activity = [
        ActivityItem(
            title: "Career Change timeline created",
            type: .timelineCreated,
            date: Date().addingTimeInterval(-3600),
            isUnread: true
        ),
        ActivityItem(
            title: "Earned 25 credits from wisdom sharing",
            type: .creditsEarned,
            date: Date().addingTimeInterval(-86400),
            isUnread: false
        ),
        ActivityItem(
            title: "Sequel ready for Relationship Decision",
            type: .sequelReady,
            date: Date().addingTimeInterval(-86400 * 2),
            isUnread: true
        )
    ]
    
    static let wisdomItems = [
        WisdomItem(
            id: "wisdom_001",
            title: "The Art of Decision Making",
            description: "Learn how to make better decisions under uncertainty and pressure.",
            price: 50,
            category: .personal,
            author: "TRACES AI",
            rating: 4.8,
            purchaseCount: 1247
        ),
        WisdomItem(
            id: "wisdom_002",
            title: "Career Transition Mastery",
            description: "Navigate career changes with confidence and strategic planning.",
            price: 75,
            category: .career,
            author: "TRACES AI",
            rating: 4.6,
            purchaseCount: 892
        ),
        WisdomItem(
            id: "wisdom_003",
            title: "Relationship Intelligence",
            description: "Understanding patterns in relationships and emotional dynamics.",
            price: 60,
            category: .relationships,
            author: "TRACES AI",
            rating: 4.7,
            purchaseCount: 1056
        )
    ]
}