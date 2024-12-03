//
//  ImageEntity.swift
//  multimediaSphere
//
//  Created by Rahel Kempf on 09.11.2024.
//

import Foundation
import RealityFoundation
import RealityKitContent

enum positionIdentifier {
    case topright
    case topleft
    case bottomright
    case bottomleft
    
    case triangletop
    case trianglebottomright
    case trianglebottomleft
}

class ImageEntity: Entity {
    var modelEntity: ModelEntity?
    var meshResource: MeshResource?
    var vertexPositions: [SIMD3<Float>]
    var positionalIdentifier: positionIdentifier
    
    init(vertexPositions: [SIMD3<Float>], positionalIdentifier: positionIdentifier) async throws {
        self.vertexPositions = vertexPositions
        self.positionalIdentifier = positionalIdentifier
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
        var material = PhysicallyBasedMaterial()
        material.baseColor = PhysicallyBasedMaterial.BaseColor(tint:.gray)
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
    
    func transformTextureCoordinates(material: NamedMaterial) {
        var newMaterial = material.material
        
        switch positionalIdentifier {
        case .bottomright:
            newMaterial.textureCoordinateTransform = .init(
                offset: [0, 0],
                scale: [0.5, 0.5],
                rotation: 0
            )
        case .bottomleft:
            newMaterial.textureCoordinateTransform = .init(
                offset: [0.5, 0],      // Shift the coordinates, move the origin to the middle
                scale: [0.5, 0.5],       // Scale the texture coordinates, shrinking it to fit the new space
                rotation: 0              // No rotation, or apply the desired rotation in radians
            )
        case .topright:
            newMaterial.textureCoordinateTransform = .init(
                offset: [0, 0.5],      // Shift the coordinates, move the origin to the middle
                scale: [0.5, 0.5],       // Scale the texture coordinates, shrinking it to fit the new space
                rotation: 0              // No rotation, or apply the desired rotation in radians
            )
        case .topleft:
            newMaterial.textureCoordinateTransform = .init(
                offset: [0.5, 0.5],      // Shift the coordinates, move the origin to the middle
                scale: [0.5, 0.5],       // Scale the texture coordinates, shrinking it to fit the new space
                rotation: 0              // No rotation, or apply the desired rotation in radians
            )
        case .triangletop:
            newMaterial.textureCoordinateTransform = .init(
                offset: [0.5, 0.5],      // Shift the coordinates, move the origin to the middle
                scale: [0.5, 0.5],       // Scale the texture coordinates, shrinking it to fit the new space
                rotation: 0              // No rotation, or apply the desired rotation in radians
            )

        default: //TODO: handle triangles
            newMaterial.textureCoordinateTransform = .init(
                offset: [0, 0],      // Shift the coordinates, move the origin to the middle
                scale: [0.5, 0.5],       // Scale the texture coordinates, shrinking it to fit the new space
                rotation: 0              // No rotation, or apply the desired rotation in radians
            )
            break
        }
            self.name = material.name
            self.modelEntity?.model?.materials = [newMaterial]
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
        
        func updateTexture(material: PhysicallyBasedMaterial) {
            // Apply the material to the model of the entity.
            self.modelEntity!.model?.materials = [material]
        }
    }
