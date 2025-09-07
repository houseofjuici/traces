//
//  ARViewContainer.swift
//  TRACES
//
//  Created by TRACES Development Team on 12/15/2024.
//

import SwiftUI
import ARKit
import RealityKit

// MARK: - AR View Container
struct ARViewContainer: UIViewRepresentable {
    @Binding var isActive: Bool
    let insights: [ARInsight]
    let onInsightSelected: (ARInsight) -> Void
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        
        // Configure AR session
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        config.environmentTexturing = .automatic
        arView.session.run(config)
        
        // Setup AR content
        context.coordinator.setupARContent(in: arView)
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        if isActive {
            uiView.session.run(ARWorldTrackingConfiguration(), options: [.resetTracking, .removeExistingAnchors])
            context.coordinator.updateContent(for: uiView, insights: insights)
        } else {
            uiView.session.pause()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, ARSessionDelegate {
        let parent: ARViewContainer
        
        init(_ parent: ARViewContainer) {
            self.parent = parent
        }
        
        func setupARContent(in arView: ARView) {
            // Add floating orbs and AR content
            let anchor = AnchorEntity(.plane(.horizontal, classification: .any, minimumBounds: SIMD2<Float>(0.2, 0.2)))
            
            // Create insight orbs
            for insight in parent.insights {
                let orbEntity = createInsightOrb(for: insight)
                anchor.addChild(orbEntity)
            }
            
            arView.scene.addAnchor(anchor)
        }
        
        func updateContent(for arView: ARView, insights: [ARInsight]) {
            // Update AR content based on current insights
            arView.scene.anchors.removeAll()
            
            let anchor = AnchorEntity(.plane(.horizontal, classification: .any, minimumBounds: SIMD2<Float>(0.2, 0.2)))
            
            for insight in insights {
                let orbEntity = createInsightOrb(for: insight)
                anchor.addChild(orbEntity)
            }
            
            arView.scene.addAnchor(anchor)
        }
        
        private func createInsightOrb(for insight: ARInsight) -> ModelEntity {
            // Create glowing orb entity
            let orb = ModelEntity(mesh: .generateSphere(radius: 0.1))
            orb.model?.materials = [SimpleMaterial(
                color: insight.color,
                isMetallic: false
            )]
            
            // Add animation
            let pulseAnimation = FromToByAnimation<Float>(
                name: "pulse",
                from: 0.8,
                to: 1.2,
                duration: 2.0,
                timing: .easeInOut,
                bindTarget: .scale
            )
            orb.availableAnimations = [pulseAnimation]
            orb.playAnimation(pulseAnimation)
            
            // Add tap gesture
            orb.generateCollisionShapes(recursive: true)
            orb.components.set(InputTargetComponent())
            
            // Handle interaction
            orb.generateCollisionShapes(recursive: true)
            
            return orb
        }
        
        func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
            // Handle new AR anchors
        }
        
        func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
            // Handle anchor updates
        }
    }
}