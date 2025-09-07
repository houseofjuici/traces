//
//  WalletQuickActions.swift
//  TRACES
//
//  Created by TRACES Development Team on 12/15/2024.
//

import SwiftUI

struct WalletQuickActions: View {
    @EnvironmentObject var appState: AppState
    @State private var isAnimating = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Actions")
                .font(TRACTypography.heading3Utility)
                .foregroundColor(.warmWhite)
            
            HStack(spacing: 12) {
                // Buy Credits Action
                QuickActionButton(
                    title: "Buy Credits",
                    subtitle: "Add credits to wallet",
                    icon: "plus.circle.fill",
                    color: .challengeRed,
                    action: {
                        // Navigate to credits purchase flow
                        print("Buy credits tapped")
                    }
                )
                
                // Withdraw Earnings Action
                QuickActionButton(
                    title: "Withdraw",
                    subtitle: "Cash out earnings",
                    icon: "arrow.down.circle.fill",
                    color: .electricCyan,
                    action: {
                        // Navigate to withdrawal flow
                        print("Withdraw tapped")
                    }
                )
                
                // Share Wisdom Action
                QuickActionButton(
                    title: "Share Wisdom",
                    subtitle: "Earn credits by sharing",
                    icon: "lightbulb.fill",
                    color: .sageGrowth,
                    action: {
                        // Navigate to wisdom sharing flow
                        print("Share wisdom tapped")
                    }
                )
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

struct QuickActionButton: View {
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
                    .font(.system(size: 12, weight: .semibold))
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

#Preview {
    WalletQuickActions()
        .environmentObject(AppState())
        .background(Color.deepMidnightBlue)
}