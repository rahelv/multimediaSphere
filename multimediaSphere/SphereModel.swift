//
//  SphereModel.swift
//  multimediaSphere
//
//  Created by Rahel Kempf on 11.10.2024.
//

import SwiftUI
import RealityKit

@MainActor class SphereModel: ObservableObject {

    private var contentEntity = Entity()

    func setupContentEntity() -> Entity {
        return contentEntity
    }

    func addCube() {
        var textures: [TextureResource] = []
        
        // Loop to load textures dynamically
        for i in 1...81 {
            let textureName = String(format: "image_%05d", i)
            guard let texture = try? TextureResource.load(named: textureName) else {
                fatalError("Unable to load texture \(textureName).")
            }
            textures.append(texture)
        }

        let entity = Entity()

        var materials: [SimpleMaterial] = []

        // Loop through the textures array (indexed 0-5)
        for texture in textures {
            var material = SimpleMaterial()
            material.color = .init(texture: .init(texture))
            materials.append(material)
        }
        
        var descriptor = MeshDescriptor(name: "triangle")
        descriptor.positions = MeshBuffers.Positions([
            [-1, -1, 0], [1, -1, 0], [0, 1, 0]
        ])
        descriptor.primitives = .triangles([0, 1, 2])

        // Ensure we assign exactly 6 materials to the cube
        entity.components.set(ModelComponent(
            mesh: .generateBox(width: 0.5, height: 0.5, depth: 0.5, splitFaces: true),
            materials: materials)
        )

        entity.position = SIMD3(x: 0, y: 1, z: -2)

        contentEntity.addChild(entity)
    }
}

#Preview {
    ImmersiveView()
}

