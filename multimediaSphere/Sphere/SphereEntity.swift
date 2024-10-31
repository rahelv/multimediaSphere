//
//  SphereEntity.swift
//  multimediaSphere
//
//  Created by Rahel Kempf on 31.10.2024.
//

import RealityFoundation
import RealityKit

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
        let materials = ImageMaterialGenerator.generateMaterials() //TODO: don't repeat materials ...
        let materialsArray = Array(repeating: materials, count: 6).flatMap {$0}
        let modelEntity = ModelEntity(mesh: meshResource, materials: materialsArray)
        self.addChild(modelEntity)
        
        //TODO: position? 
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
        print(meshDescriptors[0])
        return try await MeshResource(from: meshDescriptors)
    }
}
