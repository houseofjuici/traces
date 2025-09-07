//
//  ARCoachView.swift
//  TRACES
//
//  Created by TRACES Development Team on 12/15/2024.
//

import SwiftUI
import ARKit
import RealityKit
import AVFoundation
import CoreLocation

struct ARCoachView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var arViewModel = ARCoachViewModel()
    @State private var isARActive = false
    @State private var showingARView = false
    @State private var selectedInsight: ARInsight?
    @State private var currentLocationInsights: [ARInsight] = []
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // AR Coach Hero Section
                ARCoachHeroSection(isARActive: $isARActive, onARToggle: toggleAR)
                
                // Current Location Insights
                if !currentLocationInsights.isEmpty {
                    LocationInsightsSection(insights: currentLocationInsights, onSelect: selectInsight)
                }
                
                // Discoverable Hotspots
                DiscoverableHotspotsSection(hotspots: arViewModel.hotspots, onSelect: selectHotspot)
                
                // AR Features Overview
                ARFeaturesOverview()
                
                Spacer(minLength: 100)
            }
            .padding(.horizontal, TRACESLayout.heroMargin)
            .padding(.top, TRACESLayout.safeAreaTop)
            .navigationTitle("AR Life Coach")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { arViewModel.refreshLocation() }) {
                        Image(systemName: "location.fill")
                            .foregroundColor(.electricCyan)
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    if showingARView {
                        Button("Close AR") {
                            showingARView = false
                            isARActive = false
                        }
                        .foregroundColor(.warmWhite)
                    }
                }
            }
            .sheet(isPresented: $showingARView) {
                ARViewContainer(
                    isActive: $isARActive,
                    insights: currentLocationInsights,
                    onInsightSelected: { insight in
                        selectedInsight = insight
                    }
                )
            }
            .alert(item: $selectedInsight) { insight in
                ARInsightDetailView(insight: insight)
            }
            .onAppear {
                arViewModel.requestLocationPermission()
                arViewModel.refreshLocation()
            }
        }
        .background(TRACESColors.etherealClarityFlow.ignoresSafeArea())
    }
    
    private func toggleAR() {
        if !appState.cameraPermissionGranted {
            // Request camera permission
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    appState.cameraPermissionGranted = granted
                    if granted {
                        showingARView = true
                    }
                }
            }
        } else {
            showingARView = true
        }
    }
    
    private func selectInsight(_ insight: ARInsight) {
        selectedInsight = insight
    }
    
    private func selectHotspot(_ hotspot: ARHotspot) {
        // Navigate to hotspot location or show details
        print("Selected hotspot: \(hotspot.title)")
    }
}

// MARK: - AR Coach Previews
struct ARCoachView_Previews: PreviewProvider {
    static var previews: some View {
        ARCoachView()
            .environmentObject(AppState())
    }
}