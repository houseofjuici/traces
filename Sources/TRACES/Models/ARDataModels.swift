//
//  ARDataModels.swift
//  TRACES
//
//  Created by TRACES Development Team on 12/15/2024.
//

import SwiftUI
import CoreLocation

// MARK: - Data Models for AR
struct ARInsight: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let category: String
    let icon: String
    let color: Color
    let estimatedTime: String
    let relevanceScore: Double
    let isInteractive: Bool
    
    var formattedRelevance: String {
        "\(Int(relevanceScore * 100))%"
    }
}

struct ARHotspot: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
    let distance: Double
    let category: String
    let coordinate: CLLocationCoordinate2D
}