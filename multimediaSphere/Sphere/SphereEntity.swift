//
//  SphereEntity.swift
//  multimediaSphere
//
//  Created by Rahel Kempf on 31.10.2024.
//

import RealityFoundation
import RealityKit
import RealityKitContent
import Foundation

@MainActor
class SphereEntity: Entity {
    var resolution: Int
    let vertexPositions = VertexPositions.shared
    var sphereImageEntities: [ImageEntity] = [] //entity for each image on the sphere

    init(resolution: Int = 9) async throws { //TODO: change resolution 
        self.resolution = resolution
        super.init()
        try await self.initialize()
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
    
    private func initialize() async throws {
        try await self.generateSphereImageEntities(resolution: self.resolution)
        self.updateTextures(count: pow(Double(resolution - 1), 2) * 6)
    }
    
    // creates array of meshresources containing mesh for every face of the sphere
    private func generateSphereImageEntities(resolution: Int) async throws { //TODO: resolution should be the same everywhere ...
        var directionIndex: Int = 0
        for direction in vertexPositions.edges {
            for edges in direction {
                do {
                    let imageEntity: ImageEntity = try await ImageEntity.init(vertexPositions: edges, name: "face", localUp: vertexPositions.directions[directionIndex])
                    sphereImageEntities.append(imageEntity)
                    self.addChild(imageEntity)
                } catch {
                    print("Failed to create mesh resource: \(error.localizedDescription)") //TODO: evtl. better error handling + why are there empty arrays ???
                }
            }
            directionIndex+=1
        }
    }
    
    func addHoverToChildEntities() async {
        for entity in sphereImageEntities {
            entity.addHover()
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
    
    func updateTextures(count: Double) {
        let imageGenerator = ImageMaterialGenerator()
        let baseURL = "https://v3c.xreco-retrieval.ch/v3c/thumbnails/"
        var randomFolder = imageGenerator.generateRandomFolder()
        var imageCount = imageGenerator.countImagesInDirectory(url: URL(string: baseURL + randomFolder + "/")!)
        
        // Loop to load textures dynamically
        var counter: Int = 1
        for entity in sphereImageEntities {
            if (counter > imageCount) {
                //get new random folder
                randomFolder = imageGenerator.generateRandomFolder()
                imageCount = imageGenerator.countImagesInDirectory(url: URL(string: baseURL + randomFolder + "/")!)
                counter = 1
            }
            let textureURL = URL(string: baseURL + randomFolder + "/" + randomFolder + String(format: "_%d.jpg", counter))
            counter+=1
            //TODO: what if theres not enough pictures in chosen folder?? catch error message
            imageGenerator.createMaterialAsync(textureURL!) { material in
                if let material = material {
                    //change texture of entity
                    entity.updateTexture(material: material)
                } else {
                    print("Failed to load texture.")
                }
            }
        }
    }
}
