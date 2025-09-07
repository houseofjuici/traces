//
//  ARCoachViewModel.swift
//  TRACES
//
//  Created by TRACES Development Team on 12/15/2024.
//

import Foundation
import CoreLocation
import SwiftUI

// MARK: - AR Coach ViewModel
class ARCoachViewModel: ObservableObject {
    @Published var hotspots: [ARHotspot] = []
    @Published var locationPermission: CLAuthorizationStatus = .notDetermined
    
    private let locationManager = CLLocationManager()
    
    func requestLocationPermission() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    func refreshLocation() {
        guard locationPermission == .authorizedWhenInUse || locationPermission == .authorizedAlways else {
            requestLocationPermission()
            return
        }
        
        locationManager.requestLocation()
    }
    
    private func generateMockInsights() -> [ARInsight] {
        [
            ARInsight(
                title: "Workspace Analysis",
                description: "This looks like your workspace. Consider how your current environment influences your career decisions.",
                category: "Career",
                icon: "briefcase.fill",
                color: .electricCyan,
                estimatedTime: "30s",
                relevanceScore: 0.85,
                isInteractive: true
            ),
            ARInsight(
                title: "Relationship Context",
                description: "Family photos detected. Your home environment can provide insights into relationship dynamics.",
                category: "Relationships",
                icon: "heart.fill",
                color: .sageGrowth,
                estimatedTime: "45s",
                relevanceScore: 0.72,
                isInteractive: true
            ),
            ARInsight(
                title: "Health Environment",
                description: "Exercise equipment found. Your physical environment can influence your health decisions.",
                category: "Health",
                icon: "figure.walk",
                color: .challengeRed,
                estimatedTime: "20s",
                relevanceScore: 0.91,
                isInteractive: false
            )
        ]
    }
    
    private func generateMockHotspots() -> [ARHotspot] {
        [
            ARHotspot(
                title: "Career Networking Event",
                description: "Local business networking event happening nearby.",
                icon: "person.2.fill",
                distance: 1.2,
                category: "Career",
                coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
            ),
            ARHotspot(
                title: "Mindfulness Workshop",
                description: "Meditation and stress management session.",
                icon: "leaf.fill",
                distance: 0.8,
                category: "Health",
                coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
            ),
            ARHotspot(
                title: "Financial Planning Seminar",
                description: "Learn about investment strategies and budgeting.",
                icon: "dollarsign.circle.fill",
                distance: 2.5,
                category: "Finance",
                coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
            )
        ]
    }
}

extension ARCoachViewModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        // Generate insights based on location
        DispatchQueue.main.async {
            self.hotspots = self.generateMockHotspots()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        DispatchQueue.main.async {
            self.locationPermission = status
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error)")
    }
}