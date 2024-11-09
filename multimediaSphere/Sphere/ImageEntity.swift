//
//  ImageEntity.swift
//  multimediaSphere
//
//  Created by Rahel Kempf on 09.11.2024.
//

import Foundation
import RealityFoundation

class ImageEntity: Entity {
    var modelEntity: ModelEntity?
    var meshResource: MeshResource?
    var vertexPositions: [SIMD3<Float>]
    var entityName: String
    var localUp: SIMD3<Float>

    init(vertexPositions: [SIMD3<Float>], name: String, localUp: SIMD3<Float>) async throws {
        self.vertexPositions = vertexPositions
        self.entityName = name
        self.localUp = localUp
        super.init()
        try await self.initialize()
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
    
    private func initialize() async throws {
        let descriptor = self.createDescriptor(vertexPositions: vertexPositions, name: self.entityName, localUp: localUp)
        let meshResource = try MeshResource.generate(from: [descriptor])
        self.meshResource = meshResource
        let material = SimpleMaterial(color: .gray, isMetallic: false)
        let modelEntity = ModelEntity(mesh: meshResource, materials: [material])
        self.modelEntity = modelEntity
        self.addChild(modelEntity)
    }
    
    private func createDescriptor(vertexPositions: [SIMD3<Float>], name: String, localUp: SIMD3<Float>) -> MeshDescriptor {
        var textureCoordinates = [SIMD2<Float>]() //texture coordinates for a single face
        
        switch localUp {
        case _ where abs(localUp.x) == 1 : //left and right
            textureCoordinates.append([1, 1])
            textureCoordinates.append([0, 1])
            textureCoordinates.append([0, 0])
            textureCoordinates.append([1, 0])
        case _ where abs(localUp.y) == 1 : //up and down
            textureCoordinates.append([0, 0])
            textureCoordinates.append([1, 0])
            textureCoordinates.append([1, 1])
            textureCoordinates.append([0, 1])
        case _ where abs(localUp.z) == 1 : //forward and back
            textureCoordinates.append([0, 0])
            textureCoordinates.append([0, 1])
            textureCoordinates.append([1, 1])
            textureCoordinates.append([1, 0])
        default: //TODO: what default case?
            print("default")
            textureCoordinates.append([0, 0])
            textureCoordinates.append([1, 0])
            textureCoordinates.append([1, 1])
            textureCoordinates.append([0, 1])
        }

        var descriptor = MeshDescriptor(name: name)
        descriptor.positions = MeshBuffers.Positions(vertexPositions)
        descriptor.primitives = .polygons([4], [0, 1, 2, 3])
        descriptor.textureCoordinates = MeshBuffer.init(textureCoordinates)
    //  descriptor.materials = .perFace(materialsArray)
        return descriptor
    }
        
    func addHover() { //TODO: maybe function needs to be called after instantiation ...
        self.components.set(InputTargetComponent())
        self.components.set(HoverEffectComponent())
           
        var collisionShape: ShapeResource //TODO: error is not catched ...
        collisionShape = ShapeResource.generateConvex(from: meshResource!)

        var collision = CollisionComponent(shapes: [collisionShape])
        collision.filter = CollisionFilter(group: [], mask: [])
        self.components.set(collision)
    }
    
    func updateTexture(material: SimpleMaterial) {
        // Apply the material to the model of the entity.
        self.modelEntity!.model?.materials = [material]
    }
}
