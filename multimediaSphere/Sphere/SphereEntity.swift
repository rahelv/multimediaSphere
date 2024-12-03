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
        //        await self.updateTextures()
        await self.updateFlowerTextures()
    }
    
    // creates array of meshresources containing mesh for every face of the sphere
    private func generateSphereImageEntities(resolution: Int) async throws { //TODO: resolution should be the same everywhere ...
        for faces in vertexPositions.faces {
            do {
                let imageEntity: ImageEntity = try await ImageEntity.init(vertexPositions: faces)
                sphereImageEntities.append(imageEntity)
                self.addChild(imageEntity)
            } catch {
                print("Failed to create mesh resource: \(error.localizedDescription)") //TODO: evtl. better error handling + why are there empty arrays ???
            }
        }
    }
        
        func addHoverToChildEntities() async {
            for entity in sphereImageEntities {
                await entity.addHover()
                entity.addGestures()
            }
        }
        
        func updateTextures() async { //TODO: move function to ImageMaterialGenerator
            let imageGenerator = ImageMaterialGenerator()
            let baseURL = "https://v3c.xreco-retrieval.ch/v3c/thumbnails/"
            var randomFolder = imageGenerator.generateRandomFolder()
            var imageCount = await imageGenerator.countImagesInDirectory(url: URL(string: baseURL + randomFolder + "/")!)
            
            // Loop to load textures dynamically
            var counter: Int = 1
            for entity in sphereImageEntities {
                if (counter > imageCount) {
                    //get new random folder
                    randomFolder = imageGenerator.generateRandomFolder()
                    imageCount = await imageGenerator.countImagesInDirectory(url: URL(string: baseURL + randomFolder + "/")!)
                    counter = 1
                }
                let textureURL = URL(string: baseURL + randomFolder + "/" + randomFolder + String(format: "_%d.jpg", counter))
                counter+=1
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
        
        func updateFlowerTextures() async { //TODO: move function to ImageMaterialGenerator
            let imageGenerator = ImageMaterialGenerator()
            let materials = imageGenerator.generateFlowerMaterials(count: Double(sphereImageEntities.count))
            
            var index = 0
            // Loop to load textures dynamically
            for entity in sphereImageEntities {
                entity.updateTexture(material: materials[index].material)
                entity.name = materials[index].name
                index+=1
            }
        }
    }
