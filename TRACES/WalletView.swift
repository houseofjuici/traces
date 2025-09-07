//
//  WalletView.swift
//  TRACES
//
//  Created by TRACES Development Team on 12/15/2024.
//

import SwiftUI

struct WalletViewPure: View {
    // MARK: - Pure SwiftUI State
    @State private var selectedTab: WalletTab = .wallet
    @State private var showingPurchaseConfirm = false
    @State private var selectedWisdom: WisdomItem?
    @State private var credits: Int = 247
    @State private var searchText = ""
    @State private var selectedCategory: String = "All"
    @State private var sortOption: SortOption = .relevance
    
    // MARK: - Computed Properties (replacing ViewModel logic)
    private var transactions: [Transaction] {
        [
            Transaction(description: "Purchased 'Career Transition Wisdom'", type: .purchase, amount: -25, date: Date().addingTimeInterval(-3600)),
            Transaction(description: "Earned from wisdom sharing", type: .earning, amount: 15, date: Date().addingTimeInterval(-86400)),
            Transaction(description: "Platform commission payout", type: .earning, amount: 50, date: Date().addingTimeInterval(-86400 * 3)),
            Transaction(description: "Refund for unused credits", type: .refund, amount: 10, date: Date().addingTimeInterval(-86400 * 7))
        ]
    }
    
    private var wisdomItems: [WisdomItem] {
        [
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
            )
        ]
    }
    
    private var earningOpportunities: [EarningOpportunity] {
        [
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
    
    private var filteredWisdom: [WisdomItem] {
        wisdomItems
            .filter { item in
                if selectedCategory != "All" {
                    return item.category == selectedCategory
                }
                return true
            }
            .filter { item in
                if !searchText.isEmpty {
                    return item.title.localizedCaseInsensitiveContains(searchText) ||
                           item.providerName.localizedCaseInsensitiveContains(searchText)
                }
                return true
            }
            .sorted { item1, item2 in
                switch sortOption {
                case .relevance:
                    return item1.relevanceScore > item2.relevanceScore
                case .rating:
                    return item1.rating > item2.rating
                case .price:
                    return item1.creditCost < item2.creditCost
                }
            }
    }
    
    private var categories: [String] {
        ["All", "Career", "Relationships", "Health", "Finance", "Personal Growth"]
    }
    
    var body: some View {
        NavigationView {
            TabView(selection: $selectedTab) {
                // Wallet Balance Tab
                WalletBalanceViewPure(
                    credits: credits,
                    transactions: transactions
                )
                .tabItem {
                    Label("Wallet", systemImage: "creditcard.fill")
                }
                .tag(WalletTab.wallet)
                
                // Marketplace Tab
                MarketplaceViewPure(
                    wisdomItems: filteredWisdom,
                    searchText: $searchText,
                    selectedCategory: $selectedCategory,
                    sortOption: $sortOption,
                    categories: categories,
                    onPurchase: purchaseWisdom
                )
                .tabItem {
                    Label("Marketplace", systemImage: "store.fill")
                }
                .tag(WalletTab.marketplace)
                
                // Earnings Tab
                EarningsViewPure(
                    earningOpportunities: earningOpportunities
                )
                .tabItem {
                    Label("Earn", systemImage: "plus.circle.fill")
                }
                .tag(WalletTab.earnings)
            }
            .accentColor(.challengeRed)
            .navigationTitle("Wallet")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: TransactionHistoryViewPure()) {
                        Image(systemName: "list.bullet")
                            .foregroundColor(.warmWhite)
                    }
                }
            }
        }
        .background(Color.deepMidnightBlue.ignoresSafeArea())
        .sheet(isPresented: $showingPurchaseConfirm) {
            if let wisdom = selectedWisdom {
                PurchaseConfirmationViewPure(
                    wisdom: wisdom,
                    currentCredits: credits,
                    onConfirm: { confirmPurchase(wisdom) }
                )
            }
        }
    }
    
    // MARK: - Helper Methods
    private func purchaseWisdom(_ wisdom: WisdomItem) {
        selectedWisdom = wisdom
        showingPurchaseConfirm = true
    }
    
    private func confirmPurchase(_ wisdom: WisdomItem) {
        // Process purchase
        credits = max(0, credits - wisdom.creditCost)
        showingPurchaseConfirm = false
        selectedWisdom = nil
    }
}

// MARK: - Supporting Views
struct WalletBalanceViewPure: View {
    let credits: Int
    let transactions: [Transaction]
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 24) {
                // Hero Balance Card
                WalletBalanceCardPure(credits: credits)
                
                // Transaction History
                TransactionHistorySectionPure(transactions: transactions)
                
                // Quick Actions
                WalletQuickActionsPure()
                
                Spacer(minLength: 100)
            }
            .padding(.horizontal, TRACESLayout.heroMargin)
            .padding(.top, TRACESLayout.safeAreaTop)
        }
    }
}

struct WalletBalanceCardPure: View {
    let credits: Int
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Animated Credit Counter
            HStack {
                Image(systemName: "creditcard.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.challengeRed)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .animation(.spring(response: 1.0).repeatForever(autoreverses: true), value: isAnimating)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Available Credits")
                        .font(TRACTypography.bodyUtility)
                        .foregroundColor(.warmWhite.opacity(0.7))
                    
                    HStack(spacing: 4) {
                        Text("\(credits)")
                            .font(TRACTypography.heroTitle)
                            .foregroundColor(.warmWhite)
                            .monospacedDigit()
                        
                        Text("Credits")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.warmWhite)
                    }
                }
                
                Spacer()
                
                // Growth Indicator
                if credits > 200 {
                    VStack(spacing: 2) {
                        Text("+24%")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.sageGrowth)
                        
                        Text("This Month")
                            .font(.caption)
                            .foregroundColor(.warmWhite.opacity(0.6))
                    }
                }
            }
            .padding()
            
            // Action Buttons
            HStack(spacing: 12) {
                WalletActionButtonPure(
                    title: "Buy Credits",
                    subtitle: "Add more credits",
                    icon: "plus.circle.fill",
                    color: .challengeRed,
                    action: {}
                )
                
                WalletActionButtonPure(
                    title: "Withdraw",
                    subtitle: "Cash out earnings",
                    icon: "arrow.down.circle.fill",
                    color: .electricCyan,
                    action: {}
                )
            }
        }
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [Color.challengeRed.opacity(0.9), Color.red.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.challengeRed.opacity(0.3), lineWidth: 1)
                )
        )
        .shadow(color: Color.challengeRed.opacity(0.4), radius: 12, x: 0, y: 6)
        .onAppear {
            isAnimating = true
        }
    }
}

struct WalletActionButtonPure: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.warmWhite)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.warmWhite.opacity(0.8))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.clear)
                    .background(color.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(color.opacity(0.3), lineWidth: 1)
                    )
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct TransactionHistorySectionPure: View {
    let transactions: [Transaction]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent Transactions")
                    .font(TRACTypography.heading3Utility)
                    .foregroundColor(.warmWhite)
                
                Spacer()
                
                Text("\(transactions.count) total")
                    .font(.caption)
                    .foregroundColor(.warmWhite.opacity(0.6))
            }
            
            ForEach(transactions.prefix(5)) { transaction in
                TransactionRowPure(transaction: transaction)
            }
            
            if transactions.count > 5 {
                NavigationLink(destination: TransactionHistoryViewPure()) {
                    Text("View All Transactions")
                        .font(.system(size: 14))
                        .foregroundColor(.electricCyan)
                        .padding(.vertical, 8)
                }
            }
        }
    }
}

struct TransactionRowPure: View {
    let transaction: Transaction
    
    var body: some View {
        HStack(spacing: 16) {
            // Transaction Icon
            Image(systemName: transaction.icon)
                .font(.system(size: 16))
                .foregroundColor(transactionColor(for: transaction.type))
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.description)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.warmWhite)
                
                Text(transaction.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.warmWhite.opacity(0.6))
            }
            
            Spacer()
            
            // Amount
            HStack(spacing: 4) {
                Image(systemName: "creditcard")
                    .font(.caption)
                
                Text("\(transaction.amount > 0 ? "+" : "")\(transaction.amount)")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(transaction.amount >= 0 ? .sageGrowth : .challengeRed)
                    .monospacedDigit()
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.warmWhite.opacity(0.02))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.warmWhite.opacity(0.05), lineWidth: 1)
                )
        )
    }
    
    private func transactionColor(for type: TransactionType) -> Color {
        switch type {
        case .purchase: return .challengeRed
        case .earning: return .sageGrowth
        case .withdrawal: return .electricCyan
        case .refund: return .warmWhite
        }
    }
}

struct MarketplaceViewPure: View {
    let wisdomItems: [WisdomItem]
    @Binding var searchText: String
    @Binding var selectedCategory: String
    @Binding var sortOption: SortOption
    let categories: [String]
    let onPurchase: (WisdomItem) -> Void
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 24) {
                // Search and Filters
                MarketplaceFiltersPure(
                    searchText: $searchText,
                    selectedCategory: $selectedCategory,
                    sortOption: $sortOption,
                    categories: categories
                )
                
                // Category Chips
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 12) {
                        ForEach(categories, id: \.self) { category in
                            CategoryChipPure(
                                title: category,
                                isSelected: selectedCategory == category
                            ) {
                                selectedCategory = category
                            }
                        }
                    }
                    .padding(.horizontal, 8)
                }
                
                // Wisdom Items Grid
                if wisdomItems.isEmpty {
                    EmptyMarketplaceStatePure()
                } else {
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ], spacing: 16) {
                        ForEach(wisdomItems) { wisdom in
                            WisdomCardPure(
                                wisdom: wisdom,
                                onPurchase: { onPurchase(wisdom) }
                            )
                        }
                    }
                }
                
                Spacer(minLength: 100)
            }
            .padding(.horizontal, TRACESLayout.utilitySpacing)
            .padding(.top, TRACESLayout.safeAreaTop)
        }
        .background(Color.clear)
    }
}

struct MarketplaceFiltersPure: View {
    @Binding var searchText: String
    @Binding var selectedCategory: String
    @Binding var sortOption: SortOption
    let categories: [String]
    
    var body: some View {
        VStack(spacing: 16) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.electricCyan)
                
                TextField("Search wisdom...", text: $searchText)
                    .font(.system(size: 16))
                    .foregroundColor(.warmWhite)
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.warmWhite.opacity(0.5))
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.warmWhite.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.electricCyan.opacity(0.2), lineWidth: 1)
                    )
            )
            
            // Sort and Filter Controls
            HStack {
                // Sort Dropdown
                Menu {
                    ForEach(SortOption.allCases, id: \.self) { option in
                        Button(option.title) {
                            sortOption = option
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "arrow.up.arrow.down")
                            .foregroundColor(.electricCyan)
                        
                        Text(sortOption.title)
                            .font(.system(size: 14))
                            .foregroundColor(.warmWhite)
                        
                        Image(systemName: "chevron.down")
                            .foregroundColor(.warmWhite.opacity(0.5))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.warmWhite.opacity(0.05))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.electricCyan.opacity(0.2), lineWidth: 1)
                            )
                    )
                }
                
                Spacer()
                
                // Filter Button
                Button(action: { /* Show filters */ }) {
                    HStack {
                        Image(systemName: "slider.horizontal.3")
                            .foregroundColor(.electricCyan)
                        
                        Text("Filters")
                            .font(.system(size: 14))
                            .foregroundColor(.warmWhite)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.warmWhite.opacity(0.05))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.electricCyan.opacity(0.2), lineWidth: 1)
                            )
                    )
                }
            }
        }
    }
}

struct CategoryChipPure: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isSelected ? Color.electricCyan.opacity(0.2) : Color.warmWhite.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(isSelected ? Color.electricCyan : Color.warmWhite.opacity(0.2), lineWidth: 1)
                        )
                )
                .foregroundColor(isSelected ? .electricCyan : .warmWhite)
        }
    }
}

struct WisdomCardPure: View {
    let wisdom: WisdomItem
    let onPurchase: () -> Void
    @State private var isHovered = false
    @State private var showPreview = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Preview Image/Video
            ZStack {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 120)
                    .cornerRadius(8)
                    .overlay(
                        Image(systemName: wisdom.isVideo ? "play.circle.fill" : "doc.text.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.warmWhite.opacity(0.4))
                    )
                
                if showPreview {
                    // Mock preview overlay
                    VStack {
                        Text(wisdom.title)
                            .font(.caption)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        Spacer()
                        Text("Tap to Preview")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding()
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(8)
                }
            }
            .scaleEffect(isHovered ? 1.02 : 1.0)
            .onTapGesture {
                showPreview.toggle()
            }
            
            // Content
            VStack(alignment: .leading, spacing: 6) {
                // Title
                Text(wisdom.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.warmWhite)
                    .lineLimit(2)
                
                // Provider Info
                HStack(spacing: 8) {
                    // Provider Avatar
                    Circle()
                        .fill(wisdom.providerAvatarColor)
                        .frame(width: 24, height: 24)
                        .overlay(
                            Text(String(wisdom.providerName.prefix(1).uppercased()))
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.warmWhite)
                        )
                    
                    Text(wisdom.providerName)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.warmWhite)
                    
                    if wisdom.isVerified {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.sageGrowth)
                    }
                }
                
                // Rating
                HStack(spacing: 4) {
                    ForEach(1...5, id: \.self) { star in
                        Image(systemName: star <= Int(wisdom.rating) ? "star.fill" : "star")
                            .font(.system(size: 12))
                            .foregroundColor(.sageGrowth)
                    }
                    
                    Text("(\(wisdom.reviewCount))")
                        .font(.caption)
                        .foregroundColor(.warmWhite.opacity(0.6))
                }
                
                // Category Tag
                Text(wisdom.category)
                    .font(.caption)
                    .foregroundColor(.electricCyan)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.electricCyan.opacity(0.1))
                    )
                
                // Price and Relevance
                HStack {
                    // Price
                    HStack(spacing: 4) {
                        Image(systemName: "creditcard")
                            .font(.caption)
                        
                        Text("\(wisdom.creditCost)")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.challengeRed)
                            .monospacedDigit()
                        
                        Text("Credits")
                            .font(.caption)
                            .foregroundColor(.warmWhite.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    // Relevance Score
                    if wisdom.relevanceScore > 0 {
                        VStack(spacing: 2) {
                            Text("\(Int(wisdom.relevanceScore * 100))%")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.sageGrowth)
                            
                            Text("Match")
                                .font(.caption2)
                                .foregroundColor(.warmWhite.opacity(0.6))
                        }
                    }
                }
            }
            
            // Purchase Button
            Button(action: onPurchase) {
                Text("Apply Wisdom")
                    .font(.system(size: 12, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        LinearGradient(
                            colors: [Color.challengeRed, Color.red.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(8)
                    .foregroundColor(.warmWhite)
                    .shadow(color: Color.challengeRed.opacity(0.3), radius: 2, x: 0, y: 1)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.warmWhite.opacity(0.02))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.warmWhite.opacity(0.1), lineWidth: 1)
                )
        )
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        .onHover { hovering in
            withAnimation(.spring(response: 0.2)) {
                isHovered = hovering
            }
        }
    }
}

struct EarningsViewPure: View {
    let earningOpportunities: [EarningOpportunity]
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 24) {
                // Earnings Header
                VStack(alignment: .leading, spacing: 16) {
                    Text("Earn Credits")
                        .font(TRACTypography.sectionTitle)
                        .foregroundColor(.warmWhite)
                    
                    Text("Share your wisdom and experiences to earn credits that can be used in the marketplace or withdrawn as cash.")
                        .font(.system(size: 14))
                        .foregroundColor(.warmWhite.opacity(0.8))
                        .lineSpacing(2)
                }
                
                // Earning Opportunities Grid
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 16),
                    GridItem(.flexible(), spacing: 16)
                ], spacing: 16) {
                    ForEach(earningOpportunities) { opportunity in
                        EarningOpportunityCardPure(opportunity: opportunity)
                    }
                }
                
                // Earnings Tips
                VStack(alignment: .leading, spacing: 12) {
                    Text("Tips for Success")
                        .font(TRACTypography.heading3Utility)
                        .foregroundColor(.warmWhite)
                    
                    ForEach(EarningTips.allCases, id: \.self) { tip in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "lightbulb.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.sageGrowth)
                                .frame(width: 16, alignment: .top)
                            
                            Text(tip.rawValue)
                                .font(.system(size: 13))
                                .foregroundColor(.warmWhite.opacity(0.9))
                        }
                    }
                }
                
                Spacer(minLength: 100)
            }
            .padding(.horizontal, TRACESLayout.heroMargin)
            .padding(.top, TRACESLayout.safeAreaTop)
        }
    }
}

struct EarningOpportunityCardPure: View {
    let opportunity: EarningOpportunity
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack(spacing: 12) {
                Image(systemName: opportunity.icon)
                    .font(.system(size: 20))
                    .foregroundColor(opportunity.color)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(opportunity.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.warmWhite)
                    
                    Text(opportunity.subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(.warmWhite.opacity(0.7))
                }
                
                Spacer()
                
                Button(action: { isExpanded.toggle() }) {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14))
                        .foregroundColor(.electricCyan)
                }
            }
            
            // Content (expandable)
            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    Text(opportunity.description)
                        .font(.system(size: 13))
                        .foregroundColor(.warmWhite.opacity(0.9))
                        .lineSpacing(1)
                    
                    // Rewards
                    HStack(spacing: 8) {
                        Text("Potential Earnings:")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.warmWhite)
                        
                        ForEach(opportunity.rewards, id: \.self) { reward in
                            Text(reward)
                                .font(.system(size: 12))
                                .foregroundColor(.sageGrowth)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color.sageGrowth.opacity(0.1))
                                )
                        }
                    }
                    
                    // CTA
                    Button(opportunity.ctaText) {
                        // Handle opportunity selection
                        print("Selected opportunity: \(opportunity.title)")
                    }
                    .font(.system(size: 12, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.clear)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(opportunity.color.opacity(0.3), lineWidth: 1)
                            )
                    )
                    .foregroundColor(opportunity.color)
                }
                .padding(.top, 8)
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.warmWhite.opacity(0.02))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.warmWhite.opacity(0.1), lineWidth: 1)
                )
        )
        .animation(.spring(response: 0.3), value: isExpanded)
    }
}

struct PurchaseConfirmationViewPure: View {
    let wisdom: WisdomItem
    let currentCredits: Int
    let onConfirm: () -> Void
    @Environment(\.presentationMode) var presentationMode
    @State private var isProcessing = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Confirmation Header
                VStack(spacing: 16) {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.electricCyan)
                    
                    Text("Purchase Confirmation")
                        .font(TRACTypography.sectionTitle)
                        .foregroundColor(.warmWhite)
                    
                    Text("You're about to acquire this wisdom for your decision-making.")
                        .font(.system(size: 14))
                        .foregroundColor(.warmWhite.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                
                // Cost Breakdown
                VStack(alignment: .leading, spacing: 16) {
                    Text("Cost Breakdown")
                        .font(TRACTypography.heading3Utility)
                        .foregroundColor(.warmWhite)
                    
                    VStack(spacing: 12) {
                        // Current Balance
                        HStack {
                            Text("Current Balance")
                                .font(.system(size: 14))
                                .foregroundColor(.warmWhite)
                            
                            Spacer()
                            
                            HStack(spacing: 4) {
                                Image(systemName: "creditcard")
                                    .font(.caption)
                                
                                Text("\(currentCredits)")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(currentCredits >= wisdom.creditCost ? .sageGrowth : .challengeRed)
                                    .monospacedDigit()
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(currentCredits >= wisdom.creditCost ? Color.sageGrowth.opacity(0.1) : Color.challengeRed.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(currentCredits >= wisdom.creditCost ? Color.sageGrowth.opacity(0.3) : Color.challengeRed.opacity(0.3), lineWidth: 1)
                                )
                        )
                        
                        // Purchase Cost
                        HStack {
                            Text("Wisdom Cost")
                                .font(.system(size: 14))
                                .foregroundColor(.warmWhite)
                            
                            Spacer()
                            
                            HStack(spacing: 4) {
                                Image(systemName: "creditcard")
                                    .font(.caption)
                                
                                Text("\(wisdom.creditCost)")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.challengeRed)
                                    .monospacedDigit()
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.challengeRed.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.challengeRed.opacity(0.3), lineWidth: 1)
                                )
                        )
                        
                        // Remaining Balance
                        let remaining = currentCredits - wisdom.creditCost
                        HStack {
                            Text("After Purchase")
                                .font(.system(size: 14))
                                .foregroundColor(.warmWhite)
                            
                            Spacer()
                            
                            HStack(spacing: 4) {
                                Image(systemName: "creditcard")
                                    .font(.caption)
                                
                                Text("\(remaining)")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(remaining >= 0 ? .warmWhite : .challengeRed)
                                    .monospacedDigit()
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(remaining >= 0 ? Color.warmWhite.opacity(0.05) : Color.challengeRed.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(remaining >= 0 ? Color.warmWhite.opacity(0.1) : Color.challengeRed.opacity(0.3), lineWidth: 1)
                                )
                        )
                    }
                }
                
                // Action Buttons
                HStack(spacing: 12) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Cancel")
                            .font(.system(size: 14, weight: .medium))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.clear)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.warmWhite.opacity(0.3), lineWidth: 1)
                                    )
                            )
                            .foregroundColor(.warmWhite.opacity(0.7))
                    }
                    
                    Button(action: {
                        isProcessing = true
                        onConfirm()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            isProcessing = false
                            presentationMode.wrappedValue.dismiss()
                        }
                    }) {
                        if isProcessing {
                            HStack(spacing: 8) {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .warmWhite))
                                    .scaleEffect(0.8)
                                
                                Text("Processing...")
                                    .font(.system(size: 14, weight: .medium))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                LinearGradient(
                                    colors: [Color.challengeRed, Color.red.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(8)
                            .foregroundColor(.warmWhite)
                        } else {
                            Text("Confirm Purchase")
                                .font(.system(size: 14, weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(
                                    LinearGradient(
                                        colors: [Color.challengeRed, Color.red.opacity(0.8)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(8)
                                .foregroundColor(.warmWhite)
                                .shadow(color: Color.challengeRed.opacity(0.3), radius: 4, x: 0, y: 2)
                        }
                    }
                    .disabled(isProcessing || currentCredits < wisdom.creditCost)
                }
            }
            .padding()
            .navigationTitle("Confirm Purchase")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.warmWhite)
                }
            }
            .background(Color.deepMidnightBlue.ignoresSafeArea())
        }
    }
}

// MARK: - Supporting Types
enum WalletTab {
    case wallet, marketplace, earnings
}

enum SortOption: CaseIterable {
    case relevance, rating, price
    
    var title: String {
        switch self {
        case .relevance: return "Relevance"
        case .rating: return "Rating"
        case .price: return "Price"
        }
    }
}

enum TransactionType {
    case purchase, earning, withdrawal, refund
}

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

// MARK: - Placeholder Views
struct WalletQuickActionsPure: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Actions")
                .font(TRACTypography.heading3Utility)
                .foregroundColor(.warmWhite)
            
            HStack(spacing: 12) {
                Button(action: {}) {
                    VStack(spacing: 8) {
                        Image(systemName: "gift.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.electricCyan)
                        
                        Text("Redeem Code")
                            .font(.system(size: 12))
                            .foregroundColor(.warmWhite)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.warmWhite.opacity(0.05))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.electricCyan.opacity(0.2), lineWidth: 1)
                            )
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: {}) {
                    VStack(spacing: 8) {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.system(size: 24))
                            .foregroundColor(.sageGrowth)
                        
                        Text("View Stats")
                            .font(.system(size: 12))
                            .foregroundColor(.warmWhite)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.warmWhite.opacity(0.05))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.sageGrowth.opacity(0.2), lineWidth: 1)
                            )
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}

struct EmptyMarketplaceStatePure: View {
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "store.slash")
                .font(.system(size: 64))
                .foregroundColor(.warmWhite.opacity(0.3))
            
            Text("No wisdom found")
                .font(TRACTypography.heading2Utility)
                .foregroundColor(.warmWhite)
            
            Text("Try adjusting your search or filters to find relevant wisdom.")
                .font(.system(size: 14))
                .foregroundColor(.warmWhite.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button(action: {}) {
                Text("Browse Popular Wisdom")
                    .font(.system(size: 14, weight: .semibold))
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.electricCyan.opacity(0.2))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.electricCyan, lineWidth: 1)
                            )
                    )
                    .foregroundColor(.electricCyan)
            }
        }
        .frame(maxHeight: .infinity)
        .padding(.top, 100)
    }
}

struct TransactionHistoryViewPure: View {
    var body: some View {
        List {
            Text("Full Transaction History")
        }
        .navigationTitle("Transaction History")
    }
}

// MARK: - Preview
struct WalletViewPure_Previews: PreviewProvider {
    static var previews: some View {
        WalletViewPure()
    }
}