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
    let vertexPositions = VertexPositions.shared
    var sphereImageEntities: [[ImageEntity]] = Array(repeating: [], count: 28) //entity for each image on the sphere
    var materials: [NamedMaterial] = []
    
    init(param: Int) async throws {
        super.init()
        try await self.initialize()
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
    
    private func initialize() async throws {
        try await self.generateSphereImageEntities()
        //        await self.updateTextures()
        await self.generateFlowerTextures()
        self.updateFlowerTextures()
    }
    
    // creates array of meshresources containing mesh for every face of the sphere
    private func generateSphereImageEntities() async throws {
        for (index, row) in vertexPositions.faces.enumerated() {
            for face in row {
                do {
                    let imageEntity: ImageEntity = try await ImageEntity.init(vertexPositions: face.vertices, positionalIdentifier: face.position)
                    sphereImageEntities[index].append(imageEntity)
                    self.addChild(imageEntity)
                } catch {
                    print("Failed to create mesh resource: \(error.localizedDescription)") //TODO: evtl. better error handling + why are there empty arrays ???
                }

            }
        }
    }
        
        func addHoverToChildEntities() async {
            for row in sphereImageEntities {
                for entity in row {
                    await entity.addHover()
                    entity.addGestures()
                }
            }
        }
        
        func updateTextures() async { //TODO: move function to ImageMaterialGenerator
            let imageGenerator = ImageMaterialGenerator()
            let baseURL = "https://v3c.xreco-retrieval.ch/v3c/thumbnails/"
            var randomFolder = imageGenerator.generateRandomFolder()
            var imageCount = await imageGenerator.countImagesInDirectory(url: URL(string: baseURL + randomFolder + "/")!)
            
            // Loop to load textures dynamically
            var counter: Int = 1
            for row in sphereImageEntities {
                for entity in row {
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
        }
        
        func generateFlowerTextures() async { //TODO: move function to ImageMaterialGenerator
            let imageGenerator = ImageMaterialGenerator()
            materials = imageGenerator.generateFlowerMaterials(count: Double(sphereImageEntities.count*sphereImageEntities.count))
        }
    
        func updateFlowerTextures() {
            var index = 0
            // Loop to load textures dynamically
            for row in sphereImageEntities {
                for entity in row {
                    entity.updateTexture(material: materials[index].material)
                    entity.name = materials[index].name
                    index+=1
                }
            }
        }
    
    func updateFlowerTexturesForZoom(zoomLevel: Int) {
        var materialCount = 1;
        if (zoomLevel == 0) {
            for row in stride(from: 3, through: vertexPositions.resolution-1, by: 2) {
                for col in stride(from: 0, to: vertexPositions.resolution, by: 2) {
                    let material = materials[materialCount]
                    sphereImageEntities[row][col].transformTextureCoordinates(material: material, zoomLevel: zoomLevel)
                    sphereImageEntities[row][col+1].transformTextureCoordinates(material: material, zoomLevel: zoomLevel)
                    sphereImageEntities[row-1][col].transformTextureCoordinates(material: material, zoomLevel: zoomLevel)
                    sphereImageEntities[row-1][col+1].transformTextureCoordinates(material: material, zoomLevel: zoomLevel)
                    materialCount = materialCount + 1
                }
            }
        } else if (zoomLevel == 1) {
            for row in stride(from: 3, through: vertexPositions.resolution-1, by: 4) {
                for col in stride(from: 0, to: vertexPositions.resolution, by: 4) {
                    let material =  materials[materialCount]
                    sphereImageEntities[row][col].transformTextureCoordinates(material: material, zoomLevel: zoomLevel)
                    sphereImageEntities[row][col+1].transformTextureCoordinates(material: material, zoomLevel: zoomLevel)
                    sphereImageEntities[row][col+2].transformTextureCoordinates(material: material, zoomLevel: zoomLevel)
                    sphereImageEntities[row][col+3].transformTextureCoordinates(material: material, zoomLevel: zoomLevel)
                    
                    sphereImageEntities[row-1][col].transformTextureCoordinates(material: material, zoomLevel: zoomLevel)
                    sphereImageEntities[row-1][col+1].transformTextureCoordinates(material: material, zoomLevel: zoomLevel)
                    sphereImageEntities[row-1][col+2].transformTextureCoordinates(material: material, zoomLevel: zoomLevel)
                    sphereImageEntities[row-1][col+3].transformTextureCoordinates(material: material, zoomLevel: zoomLevel)
                    
                    sphereImageEntities[row-2][col].transformTextureCoordinates(material: material, zoomLevel: zoomLevel)
                    sphereImageEntities[row-2][col+1].transformTextureCoordinates(material: material, zoomLevel: zoomLevel)
                    sphereImageEntities[row-2][col+2].transformTextureCoordinates(material: material, zoomLevel: zoomLevel)
                    sphereImageEntities[row-2][col+3].transformTextureCoordinates(material: material, zoomLevel: zoomLevel)
                    
                    sphereImageEntities[row-3][col].transformTextureCoordinates(material: material, zoomLevel: zoomLevel)
                    sphereImageEntities[row-3][col+1].transformTextureCoordinates(material: material, zoomLevel: zoomLevel)
                    sphereImageEntities[row-3][col+2].transformTextureCoordinates(material: material, zoomLevel: zoomLevel)
                    sphereImageEntities[row-3][col+3].transformTextureCoordinates(material: material, zoomLevel: zoomLevel)
                    materialCount = materialCount + 1
                }
            }
        }
    }
}
