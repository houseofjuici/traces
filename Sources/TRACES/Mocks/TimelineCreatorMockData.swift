//
//  TimelineCreatorMockData.swift
//  TRACES
//
//  Created by TRACES Development Team on 12/15/2024.
//

import Foundation

// MARK: - Mock Data Generator
struct TimelineCreatorMockData {
    
    // MARK: - Psychology Facts
    static let psychologyFacts = [
        "Research shows that visualizing potential outcomes can reduce decision anxiety by up to 40%.",
        "The average person makes about 35,000 decisions per day, but only consciously considers about 70.",
        "Studies indicate that people who simulate future scenarios make 23% better long-term decisions.",
        "Neuroscience reveals that imagining future events activates the same brain regions as actual experiences.",
        "Decision fatigue affects the quality of choices - that's why TRACES helps automate the simulation process.",
        "People who use decision simulation tools report 31% higher satisfaction with their choices.",
        "Visualizing multiple futures can increase creativity and problem-solving abilities by 27%.",
        "The human brain can process visual information 60,000 times faster than text.",
        "Decision simulation activates the prefrontal cortex, enhancing executive function.",
        "Regular use of future visualization can improve emotional regulation by 35%."
    ]
    
    // MARK: - Decision Suggestions
    static let decisionSuggestions = [
        "Should I accept this job offer?",
        "Is it time to move to a new city?",
        "Should I start my own business?",
        "Is this relationship worth pursuing?",
        "Should I go back to school?",
        "Is it time to buy a house?",
        "Should I end this friendship?",
        "Is now the right time to have children?",
        "Should I invest in the stock market?",
        "Is it time to switch careers?",
        "Should I ask for a promotion?",
        "Is it time to end this relationship?",
        "Should I move back home?",
        "Is it time to get married?",
        "Should I adopt a pet?",
        "Is it time to start investing?",
        "Should I take this risk?",
        "Is it time to set boundaries?",
        "Should I pursue my passion?",
        "Is it time to forgive someone?"
    ]
    
    // MARK: - Mock Timeline Generator
    static func generateMockTimeline(
        decisionText: String,
        style: VideoStyle,
        emotionalTone: EmotionalTone,
        pathCount: Int
    ) -> Timeline {
        let paths = generateMockPaths(count: pathCount, emotionalTone: emotionalTone)
        
        return Timeline(
            id: UUID(),
            title: generateTimelineTitle(from: decisionText),
            decision: decisionText,
            createdDate: Date(),
            videoURL: generateMockVideoURL(style: style),
            thumbnailURL: generateMockThumbnailURL(style: style),
            style: style,
            paths: paths,
            emotionalTone: emotionalTone,
            isSequelAvailable: Bool.random()
        )
    }
    
    // MARK: - Mock Path Generator
    static func generateMockPaths(count: Int, emotionalTone: EmotionalTone) -> [DecisionPath] {
        let baseScenarios = getBaseScenarios(for: emotionalTone)
        var paths: [DecisionPath] = []
        
        for i in 0..<count {
            let scenario = baseScenarios[i % baseScenarios.count]
            let emotionalIndicator = determineEmotionalIndicator(for: i, total: count, tone: emotionalTone)
            let probability = calculateProbability(for: i, total: count, tone: emotionalTone)
            let keyMoments = generateKeyMoments(for: scenario.title)
            
            paths.append(DecisionPath(
                id: UUID(),
                title: scenario.title,
                probability: probability,
                outcomeDescription: scenario.description,
                emotionalIndicator: emotionalIndicator,
                keyMoments: keyMoments
            ))
        }
        
        // Normalize probabilities to sum to 1.0
        let totalProbability = paths.reduce(0) { $0 + $1.probability }
        return paths.map { path in
            DecisionPath(
                id: path.id,
                title: path.title,
                probability: path.probability / totalProbability,
                outcomeDescription: path.outcomeDescription,
                emotionalIndicator: path.emotionalIndicator,
                keyMoments: path.keyMoments
            )
        }
    }
    
    // MARK: - Helper Methods
    private static func generateTimelineTitle(from decisionText: String) -> String {
        let keywords = ["Career", "Life", "Love", "Future", "Journey", "Path", "Choice", "Decision"]
        let selectedKeyword = keywords.randomElement() ?? "Decision"
        return "\(selectedKeyword) Timeline"
    }
    
    private static func generateMockVideoURL(style: VideoStyle) -> URL? {
        let styleIdentifiers = [
            VideoStyle.realistic: "realistic",
            VideoStyle.anime: "anime",
            VideoStyle.watercolor: "watercolor",
            VideoStyle.sketch: "sketch"
        ]
        
        let identifier = styleIdentifiers[style] ?? "default"
        return URL(string: "https://example.com/timelines/\(identifier)_\(UUID().uuidString.prefix(8)).mp4")
    }
    
    private static func generateMockThumbnailURL(style: VideoStyle) -> URL? {
        let styleIdentifiers = [
            VideoStyle.realistic: "realistic",
            VideoStyle.anime: "anime",
            VideoStyle.watercolor: "watercolor",
            VideoStyle.sketch: "sketch"
        ]
        
        let identifier = styleIdentifiers[style] ?? "default"
        return URL(string: "https://example.com/thumbnails/\(identifier)_\(UUID().uuidString.prefix(8)).jpg")
    }
    
    private static func getBaseScenarios(for tone: EmotionalTone) -> [(title: String, description: String)] {
        switch tone {
        case .optimistic:
            return [
                ("Success Path", "You achieve your goals with enthusiasm and support from others."),
                ("Growth Path", "Challenges lead to valuable learning and personal development."),
                ("Opportunity Path", "New doors open, bringing unexpected positive outcomes.")
            ]
        case .realistic:
            return [
                ("Balanced Path", "Steady progress with manageable challenges and rewards."),
                ("Practical Path", "Realistic outcomes that require consistent effort."),
                ("Measured Path", "Careful planning leads to predictable results.")
            ]
        case .challenging:
            return [
                ("Challenge Path", "Significant obstacles test your resolve and adaptability."),
                ("Struggle Path", "Initial difficulties that require perseverance and growth."),
                ("Test Path", "Situations that challenge your current capabilities and beliefs.")
            ]
        case .balanced:
            return [
                ("Harmony Path", "A balanced approach that considers multiple factors."),
                ("Integrated Path", "Combining different aspects leads to wholeness."),
                ("Centered Path", "Finding balance between extremes brings stability.")
            ]
        }
    }
    
    private static func determineEmotionalIndicator(for index: Int, total: Int, tone: EmotionalTone) -> EmotionalIndicator {
        let indicators = EmotionalIndicator.allCases
        
        switch tone {
        case .optimistic:
            return index == 0 ? .success : (index == total - 1 ? .growth : .neutral)
        case .realistic:
            return indicators[index % indicators.count]
        case .challenging:
            return index == 0 ? .challenge : (index == total - 1 ? .growth : .neutral)
        case .balanced:
            return .neutral
        }
    }
    
    private static func calculateProbability(for index: Int, total: Int, tone: EmotionalTone) -> Double {
        switch tone {
        case .optimistic:
            return Double(total - index) * 0.3 + 0.2
        case .realistic:
            return 1.0 / Double(total)
        case .challenging:
            return Double(index + 1) * 0.2 + 0.1
        case .balanced:
            return 1.0 / Double(total)
        }
    }
    
    private static func generateKeyMoments(for pathTitle: String) -> [String] {
        let baseMoments = [
            "Initial decision point",
            "First significant challenge",
            "Major turning point",
            "Critical moment of choice",
            "Final outcome realization"
        ]
        
        return baseMoments.map { moment in
            "\(moment) on the \(pathTitle.lowercased())"
        }
    }
    
    // MARK: - Mock User Data
    static func generateMockUser() -> User {
        return User(
            id: "user_\(UUID().uuidString)",
            name: "Alex Johnson",
            email: "alex.johnson@example.com",
            avatarURL: URL(string: "https://example.com/avatars/alex.jpg"),
            joinedDate: Date().addingTimeInterval(-86400 * 30), // 30 days ago
            totalCreditsEarned: 250,
            timelinesCreated: 12,
            wisdomShared: 5
        )
    }
    
    // MARK: - Mock Activity Data
    static func generateMockActivity() -> [ActivityItem] {
        return [
            ActivityItem(
                title: "New timeline created: Career Decision",
                type: .timelineCreated,
                date: Date().addingTimeInterval(-3600),
                isUnread: true
            ),
            ActivityItem(
                title: "Sequel ready for Life Path timeline",
                type: .sequelReady,
                date: Date().addingTimeInterval(-86400),
                isUnread: true
            ),
            ActivityItem(
                title: "Earned 25 credits from wisdom sharing",
                type: .creditsEarned,
                date: Date().addingTimeInterval(-86400 * 2),
                isUnread: false
            ),
            ActivityItem(
                title: "Purchased: Career Navigation Mastery",
                type: .wisdomPurchased,
                date: Date().addingTimeInterval(-86400 * 3),
                isUnread: false
            )
        ]
    }
    
    // MARK: - Mock Wisdom Data
    static func generateMockWisdom() -> [WisdomItem] {
        return [
            WisdomItem(
                id: "wisdom_career_001",
                title: "Career Navigation Mastery",
                description: "Learn to make strategic career decisions with confidence and clarity.",
                price: 75,
                category: .career,
                author: "TRACES AI",
                rating: 4.8,
                purchaseCount: 1247
            ),
            WisdomItem(
                id: "wisdom_relationships_001",
                title: "Relationship Intelligence",
                description: "Understanding patterns in relationships and emotional dynamics.",
                price: 60,
                category: .relationships,
                author: "TRACES AI",
                rating: 4.7,
                purchaseCount: 1056
            ),
            WisdomItem(
                id: "wisdom_personal_001",
                title: "Personal Growth Framework",
                description: "Develop a structured approach to personal development and self-improvement.",
                price: 50,
                category: .personal,
                author: "TRACES AI",
                rating: 4.6,
                purchaseCount: 892
            )
        ]
    }
}