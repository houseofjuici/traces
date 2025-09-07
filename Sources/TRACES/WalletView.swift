//
//  WalletView.swift
//  TRACES
//
//  Created by TRACES Development Team on 12/15/2024.
//

import SwiftUI

struct WalletView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = WalletViewModel()
    @State private var selectedTab: WalletTab = .wallet
    @State private var showingPurchaseConfirm = false
    @State private var selectedWisdom: WisdomItem?
    
    enum WalletTab {
        case wallet, marketplace, earnings
    }
    
    var body: some View {
        NavigationView {
            TabView(selection: $selectedTab) {
                // Wallet Balance Tab
                WalletBalanceView(credits: appState.credits, transactions: viewModel.transactions)
                    .tabItem {
                        Label("Wallet", systemImage: "creditcard.fill")
                    }
                    .tag(WalletTab.wallet)
                
                // Marketplace Tab
                MarketplaceView(wisdomItems: viewModel.wisdomItems, onPurchase: purchaseWisdom)
                    .tabItem {
                        Label("Marketplace", systemImage: "store.fill")
                    }
                    .tag(WalletTab.marketplace)
                
                // Earnings Tab
                EarningsView(earningOpportunities: viewModel.earningOpportunities)
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
                    NavigationLink(destination: TransactionHistoryView()) {
                        Image(systemName: "list.bullet")
                            .foregroundColor(.warmWhite)
                    }
                }
            }
        }
        .background(Color.deepMidnightBlue.ignoresSafeArea())
        .sheet(isPresented: $showingPurchaseConfirm) {
            if let wisdom = selectedWisdom {
                PurchaseConfirmationView(
                    wisdom: wisdom,
                    currentCredits: appState.credits,
                    onConfirm: { confirmPurchase(wisdom) }
                )
            }
        }
        .onAppear {
            viewModel.loadData()
        }
    }
    
    private func purchaseWisdom(_ wisdom: WisdomItem) {
        selectedWisdom = wisdom
        showingPurchaseConfirm = true
    }
    
    private func confirmPurchase(_ wisdom: WisdomItem) {
        // TODO: Process with Stripe
        appState.updateCredits(appState.credits - wisdom.creditCost)
        showingPurchaseConfirm = false
        selectedWisdom = nil
        // TODO: Add to purchased wisdom
    }
}

struct WalletBalanceView: View {
    let credits: Int
    let transactions: [Transaction]
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 24) {
                // Hero Balance Card
                WalletBalanceCard(credits: credits)
                
                // Transaction History
                TransactionHistorySection(transactions: transactions)
                
                // Quick Actions
                WalletQuickActions()
                
                Spacer(minLength: 100)
            }
            .padding(.horizontal, TRACESLayout.heroMargin)
            .padding(.top, TRACESLayout.safeAreaTop)
        }
    }
}

struct WalletBalanceCard: View {
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
                WalletActionButton(
                    title: "Buy Credits",
                    subtitle: "Add more credits",
                    icon: "plus.circle.fill",
                    color: .challengeRed,
                    action: {}
                )
                
                WalletActionButton(
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

struct WalletActionButton: View {
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

struct TransactionHistorySection: View {
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
                TransactionRow(transaction: transaction)
            }
            
            if transactions.count > 5 {
                NavigationLink(destination: TransactionHistoryView()) {
                    Text("View All Transactions")
                        .font(.system(size: 14))
                        .foregroundColor(.electricCyan)
                        .padding(.vertical, 8)
                }
            }
        }
    }
}

struct TransactionRow: View {
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

struct MarketplaceView: View {
    let wisdomItems: [WisdomItem]
    let onPurchase: (WisdomItem) -> Void
    @State private var searchText = ""
    @State private var selectedCategory: String = "All"
    @State private var sortOption: SortOption = .relevance
    
    enum SortOption {
        case relevance, rating, price
    }
    
    let categories = ["All", "Career", "Relationships", "Health", "Finance", "Personal Growth"]
    
    var filteredWisdom: [WisdomItem] {
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
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 24) {
                // Search and Filters
                MarketplaceFilters(
                    searchText: $searchText,
                    selectedCategory: $selectedCategory,
                    sortOption: $sortOption,
                    categories: categories
                )
                
                // Category Chips
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 12) {
                        ForEach(categories, id: \.self) { category in
                            CategoryChip(
                                title: category,
                                isSelected: selectedCategory == category
                            ) {
                                selectedCategory = category
                            }
                        }
                    }
                    .padding(.horizontal, 8)
                }
                
                // Wisdom Items Grid (Korean Density)
                if filteredWisdom.isEmpty {
                    EmptyMarketplaceState()
                } else {
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ], spacing: 16) {
                        ForEach(filteredWisdom) { wisdom in
                            WisdomCard(
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

struct MarketplaceFilters: View {
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

extension SortOption: CaseIterable {
    var title: String {
        switch self {
        case .relevance: return "Relevance"
        case .rating: return "Rating"
        case .price: return "Price"
        }
    }
}

struct CategoryChip: View {
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

struct WisdomCard: View {
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

struct EmptyMarketplaceState: View {
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

struct EarningsView: View {
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
                        EarningOpportunityCard(opportunity: opportunity)
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

struct EarningOpportunityCard: View {
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

// MARK: - WalletView Previews
struct WalletView_Previews: PreviewProvider {
    static var previews: some View {
        WalletView()
            .environmentObject(AppState())
    }
}