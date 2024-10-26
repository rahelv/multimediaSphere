//
//  TerrainFaceView.swift
//  multimediaSphere
//
//  Created by Rahel Kempf on 17.10.2024.
//

import Foundation
import SwiftUI
import RealityKit
import UIKit

struct TerrainFaceView: View {
    @State var root = Entity()
    
    var body: some View {
        RealityView  { content in
            root.scale = .init(x: 0.4, y: 0.4, z: 0.4) //TODO: enlarge (Volume Size)
            content.add(root)
        }
        .task {
            //TODO: create richtungen und dann createTerrainFace pro Richtung
            await createTerrainFace(resolution: 10, localUp: .init(x: 0, y: 1, z: 0)) //up
            await createTerrainFace(resolution: 10, localUp: .init(x: 0, y: -1, z: 0)) //down
            await createTerrainFace(resolution: 10, localUp: .init(x: 1, y: 0, z: 0)) //right
            await createTerrainFace(resolution: 10, localUp: .init(x: -1, y: 0, z: 0)) //left
            await createTerrainFace(resolution: 10, localUp: .init(x: 0, y: 0, z: 1)) //front
            await createTerrainFace(resolution: 10, localUp: .init(x: 0, y: 0, z: -1)) //back
        }
    }
    
    // Helper Function
    @MainActor //ensure UI is always updated on the main thread
    func addSphere(position: SIMD3<Float>, color: SimpleMaterial.Color) {
        let sphereEntity = ModelEntity(
            mesh: .generateSphere(radius: 0.01),
            materials: [SimpleMaterial(color: color, isMetallic: false)]
        )
        sphereEntity.position = position
        root.addChild(sphereEntity)
    }
    
    func createTerrainFace(resolution: Int, localUp: SIMD3<Float>) async { //
        let descriptor = constructTerrainFaceMesh(resolution: resolution, localUp: localUp)
        do {
            let mesh = try await MeshResource(from: [descriptor])
            let face = ModelEntity(mesh: mesh, materials: generateMaterials())
            root.addChild(face)
        } catch {
            print("Failed to create mesh resource: \(error)")
            //TODO: better error handling
        }

    }
    
    func constructTerrainFaceMesh(resolution: Int, localUp: SIMD3<Float>) -> MeshDescriptor {
        let axisA: SIMD3<Float> = SIMD3<Float>(localUp.y, localUp.z, localUp.x) //cyclic permutation (rechtwinklig zu localUp)
        let axisB: SIMD3<Float> = simd_cross(localUp, axisA) //senkrecht auf localUp and axisA
        
        var vertexPositions = [SIMD3<Float>](repeating: .zero, count: resolution * resolution)//vertex for each "edge" on the sphere

        var verticesWithDuplicates = [SIMD3<Float>]() //vertex for each "edge" on the sphere
        var quads = [UInt32]() //faces
        var textureCoordinates = [SIMD2<Float>]() //texture coordinates corresponding to faces
        
        var vertex_index = 0

        for y in 0..<resolution { //row
            for x in 0..<resolution { //column
                let i = x + y * resolution //index to store 2d array in linear order. row-major order
                let percent = SIMD2<Float>(Float(x), Float(y)) / Float(resolution - 1) //TODO
                
                let normalizedCoordinateX = (percent.x - 0.5) * 2
                let normalizedCoordinateY = (percent.y - 0.5) * 2
                
                let tangentAOffset = normalizedCoordinateX * axisA
                let tangentBOffset = normalizedCoordinateY * axisB
                
                //TODO: remove
                let pointOnUnitCube = localUp + tangentAOffset + tangentBOffset
//                addSphere(position: pointOnUnitCube, color: .blue)
                
                let pointOnUnitSphere = simd_normalize(pointOnUnitCube)
                addSphere(position: pointOnUnitSphere, color: .red)
                
                vertexPositions[i] = pointOnUnitSphere
//                vertexPositions[i] = pointOnUnitCube
            }
        }
        
        for y in 0..<resolution { //row
            for x in 0..<resolution { //column
                let i = x + y * resolution //index to store 2d array in linear order. row-major order
                guard (x != resolution - 1 && y != resolution - 1) else { continue }
 //                if (x == 0 && y == 0) {
                //first add new vertices (with duplicates)
                //TODO: there has to be a much more efficient way ...
                verticesWithDuplicates.append(vertexPositions[i])
                verticesWithDuplicates.append(vertexPositions[i + 1])
                verticesWithDuplicates.append(vertexPositions[i + resolution + 1])
                verticesWithDuplicates.append(vertexPositions[i + resolution])
                
                //then add faces
                quads.append(UInt32(vertex_index))
                quads.append(UInt32(vertex_index + 1))
                quads.append(UInt32(vertex_index + 2))
                quads.append(UInt32(vertex_index + 3))
                
                vertex_index += 4

                textureCoordinates.append([0, 0])
                textureCoordinates.append([1, 0])
                textureCoordinates.append([1, 1])
                textureCoordinates.append([0, 1])
//              print("textureCoords \(textureCoordinates)")
//                }
            }
        }

        let size = (resolution - 1) * (resolution - 1)
        var descriptor = MeshDescriptor(name: "face")
        descriptor.positions = MeshBuffers.Positions(verticesWithDuplicates)
        descriptor.primitives = .polygons(Array(repeating: 4, count: size), quads) //TODO: ist das sinnvoll? (triangles and quads maybe??)
        descriptor.textureCoordinates = MeshBuffer.init(textureCoordinates)
        let materialsArray: [UInt32] = Array(0..<size).map { UInt32($0) } //TODO
        descriptor.materials = .perFace(materialsArray)
        return descriptor
    }
    
    func generateMaterials() -> [SimpleMaterial] {
//        var textures: [TextureResource] = [] //TODO: why differentiate between materials and textures?
        var materials: [SimpleMaterial] = []
        
        // Loop to load textures dynamically
        for i in 1 ... 81 {
            let textureName = String(format: "image_%05d", i)
            do {
                let texture = try TextureResource.load(named: textureName)
                var material = SimpleMaterial()
                material.color = .init(texture: .init(texture))
                materials.append(material)
            } catch {
                print("Unable to load texture \(textureName).")
                // Fallback material
                let material = SimpleMaterial(color: .gray, isMetallic: false)
                materials.append(material)
            }
        }
        
        return materials
    }
    
}

#Preview(windowStyle: .plain) {
    TerrainFaceView()
}
