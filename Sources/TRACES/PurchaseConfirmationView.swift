//
//  PurchaseConfirmationView.swift
//  TRACES
//
//  Created by TRACES Development Team on 12/15/2024.
//

import SwiftUI

struct PurchaseConfirmationView: View {
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
                
                // Wisdom Preview
                VStack(alignment: .leading, spacing: 12) {
                    Text("Wisdom Details")
                        .font(TRACTypography.heading3Utility)
                        .foregroundColor(.warmWhite)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(wisdom.title)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.warmWhite)
                        
                        HStack {
                            Text(wisdom.providerName)
                                .font(.system(size: 14))
                                .foregroundColor(.warmWhite.opacity(0.8))
                            
                            if wisdom.isVerified {
                                Image(systemName: "checkmark.seal.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(.sageGrowth)
                            }
                        }
                        
                        HStack(spacing: 8) {
                            ForEach(1...5, id: \.self) { star in
                                Image(systemName: star <= Int(wisdom.rating) ? "star.fill" : "star")
                                    .font(.system(size: 12))
                                    .foregroundColor(.sageGrowth)
                            }
                            
                            Text("(\(wisdom.reviewCount))")
                                .font(.caption)
                                .foregroundColor(.warmWhite.opacity(0.6))
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.warmWhite.opacity(0.05))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.electricCyan.opacity(0.2), lineWidth: 1)
                            )
                    )
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
                
                // Commission Notice
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.electricCyan)
                        
                        Text("TRACES Platform Fee")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.warmWhite)
                    }
                    
                    Text("30% of each purchase goes toward platform maintenance and community features.")
                        .font(.system(size: 11))
                        .foregroundColor(.warmWhite.opacity(0.7))
                        .lineSpacing(1)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.electricCyan.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.electricCyan.opacity(0.2), lineWidth: 1)
                        )
                )
                
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

#Preview {
    PurchaseConfirmationView(
        wisdom: WisdomItem(
            title: "Test Wisdom",
            providerName: "Test Provider",
            category: "Test",
            creditCost: 25,
            rating: 4.5,
            reviewCount: 100,
            relevanceScore: 0.8,
            isVerified: true,
            isVideo: false,
            providerAvatarColor: .electricCyan
        ),
        currentCredits: 247,
        onConfirm: {}
    )
}