//
//  WalletDataModels.swift
//  TRACES
//
//  Created by TRACES Development Team on 12/15/2024.
//

import SwiftUI

// MARK: - Data Models for Wallet System
struct WisdomItem: Identifiable {
    let id = UUID()
    let title: String
    let providerName: String
    let category: String
    let creditCost: Int
    let rating: Double
    let reviewCount: Int
    let relevanceScore: Double
    let isVerified: Bool
    let isVideo: Bool
    let providerAvatarColor: Color
    
    var formattedRating: String {
        String(format: "%.1f", rating)
    }
}

struct Transaction: Identifiable {
    let id = UUID()
    let description: String
    let type: TransactionType
    let amount: Int
    let date: Date
    
    var icon: String {
        switch type {
        case .purchase: return "cart.fill"
        case .earning: return "plus.circle.fill"
        case .withdrawal: return "arrow.down.circle.fill"
        case .refund: return "arrow.up.circle.fill"
        }
    }
}

enum TransactionType {
    case purchase, earning, withdrawal, refund
}

struct EarningOpportunity: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let description: String
    let icon: String
    let color: Color
    let rewards: [String]
    let ctaText: String
}

enum EarningTips: String, CaseIterable {
    case qualityContent = "Provide high-quality, specific advice based on your experiences"
    case engagement = "Respond to comments and questions to build trust with the community"
    case consistency = "Regularly share new wisdom to maintain visibility"
    case verification = "Get verified by completing your profile and providing credentials"
}

// MARK: - Mock Data for Wallet
class WalletViewModel: ObservableObject {
    @Published var transactions: [Transaction] = []
    @Published var wisdomItems: [WisdomItem] = []
    @Published var earningOpportunities: [EarningOpportunity] = []
    
    func loadData() {
        loadTransactions()
        loadWisdomItems()
        loadEarningOpportunities()
    }
    
    private func loadTransactions() {
        transactions = [
            Transaction(description: "Purchased 'Career Transition Wisdom'", type: .purchase, amount: -25, date: Date().addingTimeInterval(-3600)),
            Transaction(description: "Earned from wisdom sharing", type: .earning, amount: 15, date: Date().addingTimeInterval(-86400)),
            Transaction(description: "Platform commission payout", type: .earning, amount: 50, date: Date().addingTimeInterval(-86400 * 3)),
            Transaction(description: "Refund for unused credits", type: .refund, amount: 10, date: Date().addingTimeInterval(-86400 * 7))
        ]
    }
    
    private func loadWisdomItems() {
        wisdomItems = [
            WisdomItem(
                title: "Navigating career transitions at 30+",
                providerName: "Sarah Chen",
                category: "Career",
                creditCost: 25,
                rating: 4.8,
                reviewCount: 247,
                relevanceScore: 0.92,
                isVerified: true,
                isVideo: true,
                providerAvatarColor: .challengeRed
            ),
            WisdomItem(
                title: "Building healthy relationship boundaries",
                providerName: "Dr. Michael Rivera",
                category: "Relationships",
                creditCost: 35,
                rating: 4.9,
                reviewCount: 156,
                relevanceScore: 0.87,
                isVerified: true,
                isVideo: false,
                providerAvatarColor: .electricCyan
            ),
            WisdomItem(
                title: "Financial planning for entrepreneurs",
                providerName: "Priya Patel",
                category: "Finance",
                creditCost: 20,
                rating: 4.6,
                reviewCount: 89,
                relevanceScore: 0.78,
                isVerified: false,
                isVideo: true,
                providerAvatarColor: .sageGrowth
            ),
            WisdomItem(
                title: "Mindfulness techniques for stress reduction",
                providerName: "Alex Thompson",
                category: "Health",
                creditCost: 15,
                rating: 4.7,
                reviewCount: 134,
                relevanceScore: 0.85,
                isVerified: true,
                isVideo: true,
                providerAvatarColor: .electricCyan
            ),
            WisdomItem(
                title: "Effective communication in remote teams",
                providerName: "Maria Rodriguez",
                category: "Career",
                creditCost: 30,
                rating: 4.5,
                reviewCount: 92,
                relevanceScore: 0.81,
                isVerified: false,
                isVideo: false,
                providerAvatarColor: .challengeRed
            ),
            WisdomItem(
                title: "Investment strategies for beginners",
                providerName: "James Wilson",
                category: "Finance",
                creditCost: 40,
                rating: 4.9,
                reviewCount: 218,
                relevanceScore: 0.93,
                isVerified: true,
                isVideo: true,
                providerAvatarColor: .sageGrowth
            ),
            WisdomItem(
                title: "Building self-confidence and self-esteem",
                providerName: "Dr. Emma Johnson",
                category: "Personal Growth",
                creditCost: 25,
                rating: 4.8,
                reviewCount: 176,
                relevanceScore: 0.89,
                isVerified: true,
                isVideo: false,
                providerAvatarColor: .electricCyan
            ),
            WisdomItem(
                title: "Time management for work-life balance",
                providerName: "David Kim",
                category: "Personal Growth",
                creditCost: 20,
                rating: 4.4,
                reviewCount: 68,
                relevanceScore: 0.76,
                isVerified: false,
                isVideo: true,
                providerAvatarColor: .challengeRed
            )
        ]
    }
    
    private func loadEarningOpportunities() {
        earningOpportunities = [
            EarningOpportunity(
                title: "Share Your Wisdom",
                subtitle: "Create wisdom cards based on your experiences",
                description: "Share your life lessons and decision-making strategies with the TRACES community. Earn credits for every purchase of your wisdom.",
                icon: "lightbulb.fill",
                color: .electricCyan,
                rewards: ["5-50 credits per sale", "30% commission", "Rating bonuses"],
                ctaText: "Create Wisdom"
            ),
            EarningOpportunity(
                title: "Answer Questions",
                subtitle: "Help others with their specific situations",
                description: "Respond to community questions in your area of expertise. Get paid per helpful answer and build your reputation.",
                icon: "chat.bubble.fill",
                color: .sageGrowth,
                rewards: ["2-10 credits per answer", "Bonus for verified experts", "Reputation points"],
                ctaText: "Browse Questions"
            ),
            EarningOpportunity(
                title: "Live Consultations",
                subtitle: "Offer premium 1-on-1 sessions",
                description: "Provide personalized guidance through video or chat consultations. Set your own rates and schedule.",
                icon: "video.fill",
                color: .challengeRed,
                rewards: ["50-200 credits per session", "Calendar integration", "Payment processing"],
                ctaText: "Set Up Consultations"
            )
        ]
    }
}