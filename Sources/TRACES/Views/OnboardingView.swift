//
//  OnboardingView.swift
//  TRACES
//
//  Created by TRACES Development Team on 12/15/2024.
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var appState: AppState
    @State private var currentPage = 0
    @State private var isAnimating = false
    
    let pages = [
        OnboardingPage(
            title: "Welcome to TRACES",
            subtitle: "Explore your future decision paths",
            imageName: "sparkles",
            description: "TRACES helps you visualize different outcomes of your life decisions through AI-generated timeline videos."
        ),
        OnboardingPage(
            title: "Create Timelines",
            subtitle: "See what could happen",
            imageName: "timeline.selection",
            description: "Input any life decision and watch as AI creates multiple possible future scenarios for you."
        ),
        OnboardingPage(
            title: "Share Wisdom",
            subtitle: "Help others on their journey",
            imageName: "heart.circle",
            description: "Share your experiences and insights to earn credits and help the community grow together."
        ),
        OnboardingPage(
            title: "Get Started",
            subtitle: "Your journey begins now",
            imageName: "arrow.right.circle",
            description: "You're ready to explore your future! Let's begin creating your first timeline."
        )
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color.tracesBlue, Color.tracesPurple],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Skip button
                    if currentPage < pages.count - 1 {
                        HStack {
                            Spacer()
                            Button("Skip") {
                                completeOnboarding()
                            }
                            .padding(.trailing, 20)
                            .padding(.top, 10)
                        }
                    }
                    
                    Spacer()
                    
                    // Page content
                    TabView(selection: $currentPage) {
                        ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                            OnboardingPageView(page: page, geometry: geometry)
                                .tag(index)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle())
                    .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                    
                    Spacer()
                    
                    // Navigation buttons
                    VStack(spacing: 16) {
                        if currentPage == pages.count - 1 {
                            Button("Get Started") {
                                completeOnboarding()
                            }
                            .buttonStyle(.tracesPrimary)
                            .padding(.horizontal, 40)
                        } else {
                            Button("Next") {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    currentPage += 1
                                }
                            }
                            .buttonStyle(.tracesPrimary)
                            .padding(.horizontal, 40)
                        }
                        
                        // Page indicators
                        HStack(spacing: 8) {
                            ForEach(0..<pages.count, id: \.self) { index in
                                Circle()
                                    .fill(index == currentPage ? Color.white : Color.white.opacity(0.3))
                                    .frame(width: 8, height: 8)
                                    .scaleEffect(index == currentPage ? 1.2 : 1.0)
                                    .animation(.easeInOut(duration: 0.3), value: currentPage)
                            }
                        }
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
    
    private func completeOnboarding() {
        appState.isFirstLaunch = false
        appState.isOnboardingComplete = true
        UserDefaults.standard.set(true, forKey: "onboardingComplete")
    }
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    let geometry: GeometryProxy
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 24) {
            // Icon
            Image(systemName: page.imageName)
                .font(.system(size: 80))
                .foregroundColor(.white)
                .scaleEffect(isAnimating ? 1.0 : 0.8)
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isAnimating)
            
            // Content
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.tracesHeroTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text(page.subtitle)
                    .font(.tracesSubheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                
                Text(page.description)
                    .font(.tracesBody)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            .opacity(isAnimating ? 1.0 : 0.0)
            .animation(.easeInOut(duration: 0.5), value: isAnimating)
        }
        .frame(width: geometry.size.width * 0.9)
        .onAppear {
            isAnimating = true
        }
    }
}

struct OnboardingPage {
    let title: String
    let subtitle: String
    let imageName: String
    let description: String
}