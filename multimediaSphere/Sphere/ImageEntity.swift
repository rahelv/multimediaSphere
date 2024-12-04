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
    var positionalIdentifier: PositionIdentifier
    
    init(vertexPositions: [SIMD3<Float>], positionalIdentifier: PositionIdentifier) async throws {
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
    
    func transformTextureCoordinates(material: NamedMaterial, zoomLevel: Int) {
        var newMaterial = material
        
        if (zoomLevel == 0) {
            switch positionalIdentifier {
                case .bottomleft_topleft, .bottomright_topleft, .topleft_topleft, .topright_topleft:
                    newMaterial.zoomTexture(inputOffset: [0, 0], inputScale: [0.5, 0.5])
                case .bottomleft_topright, .bottomright_topright, .topleft_topright, .topright_topright:
                    newMaterial.zoomTexture(inputOffset: [0.5, 0], inputScale: [0.5, 0.5])
                case  .bottomleft_bottomleft, .bottomright_bottomleft, .topleft_bottomleft, .topright_bottomleft:
                    newMaterial.zoomTexture(inputOffset: [0, 0.5], inputScale: [0.5, 0.5])
                case .bottomleft_bottomright, .bottomright_bottomright, .topleft_bottomright, .topright_bottomright:
                    newMaterial.zoomTexture(inputOffset: [0.5, 0.5], inputScale: [0.5, 0.5])
                case .triangletop:
                    newMaterial.zoomTexture(inputOffset: [0.5, 0.5], inputScale: [0.5, 0.5])
                default: //TODO: handle triangles
                    newMaterial.zoomTexture(inputOffset: [0, 0], inputScale: [0.5, 0.5])
                    break
            }
        }
        if (zoomLevel == 1) {
            switch positionalIdentifier {
                
            case .topleft_topleft:
                newMaterial.zoomTexture(inputOffset: [0, 0], inputScale: [0.25, 0.25])
            case .topleft_topright:
                newMaterial.zoomTexture(inputOffset: [0.25, 0], inputScale: [0.25, 0.25])
            case .topright_topleft:
                newMaterial.zoomTexture(inputOffset: [0.5, 0], inputScale: [0.25, 0.25])
            case .topright_topright:
                newMaterial.zoomTexture(inputOffset: [0.75, 0], inputScale: [0.25, 0.25])
               
            case .topleft_bottomleft:
                newMaterial.zoomTexture(inputOffset: [0, 0.25], inputScale: [0.25, 0.25])
            case .topleft_bottomright:
                newMaterial.zoomTexture(inputOffset: [0.25, 0.25], inputScale: [0.25, 0.25])
            case .topright_bottomleft:
                newMaterial.zoomTexture(inputOffset: [0.5, 0.25], inputScale: [0.25, 0.25])
            case .topright_bottomright:
                newMaterial.zoomTexture(inputOffset: [0.75, 0.25], inputScale: [0.25, 0.25])
                
            case .bottomleft_topleft:
                newMaterial.zoomTexture(inputOffset: [0, 0.5], inputScale: [0.25, 0.25])
            case .bottomleft_topright:
                newMaterial.zoomTexture(inputOffset: [0.25, 0.5], inputScale: [0.25, 0.25])
            case .bottomright_topleft:
                newMaterial.zoomTexture(inputOffset: [0.5, 0.5], inputScale: [0.25, 0.25])
            case .bottomright_topright:
                newMaterial.zoomTexture(inputOffset: [0.75, 0.5], inputScale: [0.25, 0.25])
                
            case .bottomleft_bottomleft:
                newMaterial.zoomTexture(inputOffset: [0, 0.75], inputScale: [0.25, 0.25])
            case .bottomleft_bottomright:
                newMaterial.zoomTexture(inputOffset: [0.25, 0.75], inputScale: [0.25, 0.25])
            case .bottomright_bottomleft:
                newMaterial.zoomTexture(inputOffset: [0.5, 0.75], inputScale: [0.25, 0.25])
            case .bottomright_bottomright:
                newMaterial.zoomTexture(inputOffset: [0.75, 0.75], inputScale: [0.25, 0.25])
                
            case .triangletop:
                newMaterial.zoomTexture(inputOffset: [0.5, 0.5], inputScale: [0.25, 0.25])
            default:
                // TODO: Handle triangles or other custom cases
                newMaterial.zoomTexture(inputOffset: [0, 0], inputScale: [0.25, 0.25])
                break
            }
        }
        
        self.name = material.name
        self.modelEntity?.model?.materials = [newMaterial.material]
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
    
        func getMaterial() -> NamedMaterial {
            let namedMaterial = NamedMaterial(name: self.name, material: self.modelEntity!.model?.materials[0] as! PhysicallyBasedMaterial)
            return namedMaterial
        }
    }
