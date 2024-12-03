//
//  ImageEntity.swift
//  multimediaSphere
//
//  Created by Rahel Kempf on 09.11.2024.
//

import Foundation
import RealityFoundation
import RealityKitContent

class ImageEntity: Entity {
    var modelEntity: ModelEntity?
    var meshResource: MeshResource?
    var vertexPositions: [SIMD3<Float>]
    
    init(vertexPositions: [SIMD3<Float>]) async throws {
        self.vertexPositions = vertexPositions
        super.init()
        try await self.initialize()
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
    
    private func initialize() async throws {
        var descriptor: MeshDescriptor
               if vertexPositions.count == 3 {
                   descriptor = self.createDescriptorTriangle(vertexPositions: vertexPositions)
               } else {
                   descriptor = self.createDescriptorQuad(vertexPositions: vertexPositions)
               }
        let meshResource = try MeshResource.generate(from: [descriptor])
        self.meshResource = meshResource
        let material = SimpleMaterial(color: .gray, isMetallic: false)
        let modelEntity = ModelEntity(mesh: meshResource, materials: [material])
        self.modelEntity = modelEntity
        self.addChild(modelEntity)
    }
    
    private func createDescriptorQuad(vertexPositions: [SIMD3<Float>]) -> MeshDescriptor {
        var textureCoordinates = [SIMD2<Float>]() //texture coordinates for a single face
        
        textureCoordinates.append([1, 1])
        textureCoordinates.append([0, 1])
        textureCoordinates.append([0, 0])
        textureCoordinates.append([1, 0])
        
        var descriptor = MeshDescriptor(name: "none")
        descriptor.positions = MeshBuffers.Positions(vertexPositions)
        descriptor.primitives = .polygons([4], [0, 1, 2, 3])
        descriptor.textureCoordinates = MeshBuffer.init(textureCoordinates)
        return descriptor
    }
    
    private func createDescriptorTriangle(vertexPositions: [SIMD3<Float>]) -> MeshDescriptor {
           var textureCoordinates = [SIMD2<Float>]() //texture coordinates for a single face
           
           textureCoordinates.append([0, 0])
           textureCoordinates.append([0, 1])
           textureCoordinates.append([1, 1])
           
           var descriptor = MeshDescriptor(name: name)
           descriptor.positions = MeshBuffers.Positions(vertexPositions)
           descriptor.primitives = .polygons([3], [0, 1, 2])
           descriptor.textureCoordinates = MeshBuffer.init(textureCoordinates)
           return descriptor
       }
    
    func addHover() async {
        self.components.set(InputTargetComponent())
        self.components.set(HoverEffectComponent())
        
        var collisionShape: ShapeResource //TODO: error is not catched ...
        collisionShape = try! await ShapeResource.generateStaticMesh(from: meshResource!)
        
        var collision = CollisionComponent(shapes: [collisionShape])
        collision.filter = CollisionFilter(group: [], mask: [])
        self.components.set(collision)
    }
    
    func addGestures() {
        var component = GestureComponent()
        component.canDrag = true
        component.canScale = false
        component.canRotate = true
        component.canTap = true
        self.components.set(component)
    }
    
    func updateTexture(material: SimpleMaterial) {
        // Apply the material to the model of the entity.
        self.modelEntity!.model?.materials = [material]
    }
}
