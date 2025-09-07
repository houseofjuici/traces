//
//  TransactionHistoryView.swift
//  TRACES
//
//  Created by TRACES Development Team on 12/15/2024.
//

import SwiftUI

struct TransactionHistoryView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = WalletViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 16) {
                    // Summary Cards
                    TransactionSummaryView(transactions: viewModel.transactions)
                    
                    // Filter Options
                    TransactionFilters()
                    
                    // Transaction List
                    ForEach(viewModel.transactions) { transaction in
                        TransactionDetailRow(transaction: transaction)
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, TRACESLayout.heroMargin)
                .padding(.top, TRACESLayout.safeAreaTop)
            }
            .navigationTitle("Transaction History")
            .navigationBarTitleDisplayMode(.large)
            .background(Color.deepMidnightBlue.ignoresSafeArea())
            .onAppear {
                viewModel.loadData()
            }
        }
    }
}

struct TransactionSummaryView: View {
    let transactions: [Transaction]
    
    var totalSpent: Int {
        transactions.filter { $0.amount < 0 }.reduce(0) { $0 + abs($1.amount) }
    }
    
    var totalEarned: Int {
        transactions.filter { $0.amount > 0 }.reduce(0, +)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Summary")
                .font(TRACTypography.heading3Utility)
                .foregroundColor(.warmWhite)
            
            HStack(spacing: 12) {
                // Total Spent
                SummaryCard(
                    title: "Total Spent",
                    amount: totalSpent,
                    color: .challengeRed,
                    icon: "cart.fill"
                )
                
                // Total Earned
                SummaryCard(
                    title: "Total Earned",
                    amount: totalEarned,
                    color: .sageGrowth,
                    icon: "plus.circle.fill"
                )
                
                // Net Balance
                SummaryCard(
                    title: "Net Balance",
                    amount: totalEarned - totalSpent,
                    color: totalEarned >= totalSpent ? .sageGrowth : .challengeRed,
                    icon: "equal.circle.fill"
                )
            }
        }
    }
}

struct SummaryCard: View {
    let title: String
    let amount: Int
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.warmWhite.opacity(0.8))
            
            Text("\(amount)")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(color)
                .monospacedDigit()
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.warmWhite.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct TransactionFilters: View {
    @State private var selectedFilter: TransactionFilter = .all
    @State private var dateRange: DateRange = .last30Days
    
    enum TransactionFilter {
        case all, purchases, earnings, refunds, withdrawals
    }
    
    enum DateRange {
        case last7Days, last30Days, last90Days, allTime
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Type Filters
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach([TransactionFilter.all, .purchases, .earnings, .refunds, .withdrawals], id: \.self) { filter in
                        FilterChip(
                            title: filterTitle(for: filter),
                            isSelected: selectedFilter == filter
                        ) {
                            selectedFilter = filter
                        }
                    }
                }
                .padding(.horizontal, 8)
            }
            
            // Date Range Filters
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach([DateRange.last7Days, .last30Days, .last90Days, .allTime], id: \.self) { range in
                        FilterChip(
                            title: dateRangeTitle(for: range),
                            isSelected: dateRange == range
                        ) {
                            dateRange = range
                        }
                    }
                }
                .padding(.horizontal, 8)
            }
        }
    }
    
    private func filterTitle(for filter: TransactionFilter) -> String {
        switch filter {
        case .all: return "All"
        case .purchases: return "Purchases"
        case .earnings: return "Earnings"
        case .refunds: return "Refunds"
        case .withdrawals: return "Withdrawals"
        }
    }
    
    private func dateRangeTitle(for range: DateRange) -> String {
        switch range {
        case .last7Days: return "Last 7 Days"
        case .last30Days: return "Last 30 Days"
        case .last90Days: return "Last 90 Days"
        case .allTime: return "All Time"
        }
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? Color.electricCyan.opacity(0.2) : Color.warmWhite.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(isSelected ? Color.electricCyan : Color.warmWhite.opacity(0.2), lineWidth: 1)
                        )
                )
                .foregroundColor(isSelected ? .electricCyan : .warmWhite)
        }
    }
}

struct TransactionDetailRow: View {
    let transaction: Transaction
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 16) {
                // Transaction Icon
                Image(systemName: transaction.icon)
                    .font(.system(size: 20))
                    .foregroundColor(transactionColor(for: transaction.type))
                    .frame(width: 32, height: 32)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(transaction.description)
                        .font(.system(size: 16, weight: .semibold))
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
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(transaction.amount >= 0 ? .sageGrowth : .challengeRed)
                        .monospacedDigit()
                }
            }
            
            // Additional Details
            HStack {
                Text(transactionTypeTitle(for: transaction.type))
                    .font(.caption)
                    .foregroundColor(.warmWhite.opacity(0.6))
                
                Spacer()
                
                Text(transaction.date, style: .time)
                    .font(.caption)
                    .foregroundColor(.warmWhite.opacity(0.6))
            }
        }
        .padding()
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
    
    private func transactionTypeTitle(for type: TransactionType) -> String {
        switch type {
        case .purchase: return "Purchase"
        case .earning: return "Earning"
        case .withdrawal: return "Withdrawal"
        case .refund: return "Refund"
        }
    }
}

#Preview {
    TransactionHistoryView()
        .environmentObject(AppState())
}