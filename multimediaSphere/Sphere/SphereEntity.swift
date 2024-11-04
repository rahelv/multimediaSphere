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
class SphereEntity: Entity { //TODO: create Entity for each Face
    
    var resolution: Int
    var sphereImageEntities: [ModelEntity] = []

    init(resolution: Int = 10) async throws {
        self.resolution = resolution
        super.init()
        try await self.initialize()
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
    
    private func initialize() async throws {
        let meshResources = try await self.createMeshResources(resolution: self.resolution)
        let materials = ImageMaterialGenerator.generateMaterials(count: pow(Double(resolution - 1), 2) * 6)
        var materialIndex = 0;
        for resource in meshResources {
            let modelEntity = ModelEntity(mesh: resource, materials: [materials[materialIndex]])
//            self.addHoverToEntity(entity: modelEntity)
            sphereImageEntities.append(modelEntity)
            self.addChild(modelEntity)
            materialIndex+=1
        }
    }
    
    // creates array of meshresources containing mesh for every face of the sphere
    private func createMeshResources(resolution: Int) async throws -> [MeshResource] {
        let directions: [SIMD3<Float>] = [
            SIMD3<Float>(0, 1, 0),   // up
            SIMD3<Float>(0, -1, 0),  // down
            SIMD3<Float>(-1, 0, 0),  // left
            SIMD3<Float>(1, 0, 0),   // right
            SIMD3<Float>(0, 0, 1),   // forward
            SIMD3<Float>(0, 0, -1)   // back
        ]
        
        var meshResources: [MeshResource] = []
        
        for direction in directions {
            let meshResource = await SphereFace.constructSphereFaceMesh(resolution: resolution, localUp: direction)
            meshResources.append(contentsOf: meshResource)
        }
        return meshResources
    }
    
    func addHoverToChildEntities() async {
        for entity in sphereImageEntities {
            entity.components.set(InputTargetComponent())
            entity.components.set(HoverEffectComponent())
//            print("mesh:\(entity.model!.mesh)")
            
            // Create a collision component with an empty group and mask. https://developer.apple.com/documentation/realitykit/inputtargetcomponent
           
            var collisionShape: ShapeResource //TODO: weiter hier
            do {
                collisionShape = try await ShapeResource.generateConvex(from: entity.model!.mesh)
            } catch {
                // Handle the error
                print("Failed to generate convex shape from mesh: \(error.localizedDescription)")
                collisionShape = ShapeResource.generateBox(width: 0.01, height: 0.01, depth: 0.01) //TODO: only happens for ex, when resolution = 10 
            }

            var collision = CollisionComponent(shapes: [collisionShape])
            collision.filter = CollisionFilter(group: [], mask: [])
            entity.components.set(collision)
        }
    }
    
    func addGestures() {
        // Enable the entity for input.
        self.components.set(InputTargetComponent())
        self.components.set(HoverEffectComponent())
        
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
