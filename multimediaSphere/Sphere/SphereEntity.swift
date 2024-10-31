//
//  SphereEntity.swift
//  multimediaSphere
//
//  Created by Rahel Kempf on 31.10.2024.
//

import RealityFoundation
import RealityKit
import RealityKitContent

@MainActor
class SphereEntity: Entity {
    
    var resolution: Int
    
    init(resolution: Int = 10) async throws {
        self.resolution = resolution
        super.init()
        try await self.initialize()
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
    
    private func initialize() async throws {
        let meshResource = try await self.createMeshResource(resolution: self.resolution)
        let materials = ImageMaterialGenerator.generateMaterials(count: pow(Double(resolution - 1), 2) * 6)
        let modelEntity = ModelEntity(mesh: meshResource, materials: materials)
//        self.addGestures()
        self.addChild(modelEntity)
    }
    
    private func createMeshResource(resolution: Int) async throws -> MeshResource {
        let directions: [SIMD3<Float>] = [
            SIMD3<Float>(0, 1, 0),   // up
            SIMD3<Float>(0, -1, 0),  // down
            SIMD3<Float>(-1, 0, 0),  // left
            SIMD3<Float>(1, 0, 0),   // right
            SIMD3<Float>(0, 0, 1),   // forward
            SIMD3<Float>(0, 0, -1)   // back
        ]
        
        let meshDescriptors = directions.map({ SphereFace.constructSphereFaceMesh(resolution: resolution, localUp: $0) })
        return try await MeshResource(from: meshDescriptors) //TODO: materials are not applied correctly
    }
    
    func addGestures() {
        // Enable the entity for input.
        self.components.set(InputTargetComponent())
        
        // Create a collision component with an empty group and mask. https://developer.apple.com/documentation/realitykit/inputtargetcomponent
        var collision = CollisionComponent(shapes: [.generateSphere(radius: 0.4)])
        collision.filter = CollisionFilter(group: [], mask: [])
        self.components.set(collision)
        
        var component = GestureComponent()
        component.canDrag = true
        component.canScale = false
        component.canRotate = true
        self.components.set(component)
    }
}
