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
//            await createTerrainFace(resolution: 10, localUp: .init(x: 0, y: 1, z: 0)) //up
//            await createTerrainFace(resolution: 10, localUp: .init(x: 0, y: -1, z: 0)) //down
//            await createTerrainFace(resolution: 10, localUp: .init(x: 1, y: 0, z: 0)) //right
//            await createTerrainFace(resolution: 10, localUp: .init(x: -1, y: 0, z: 0)) //left
            await createTerrainFace(resolution: 3, localUp: .init(x: 0, y: 0, z: 1)) //front
//            await createTerrainFace(resolution: 10, localUp: .init(x: 0, y: 0, z: -1)) //back
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
        
        var vertices = [SIMD3<Float>](repeating: .zero, count: resolution * resolution) //vertex for each "edge" on the sphere
        var quads = [UInt32](repeating: 0, count: (resolution - 1) * (resolution - 1) * 4) //faces
        var textureCoordinates = [SIMD2<Float>](repeating: .zero, count: (resolution - 1) * (resolution - 1) * 4) //texture coordinates corresponding to faces

        var quadIndex = 0
        
        for y in 0..<resolution { //row
            for x in 0..<resolution { //column
                let i = x + y * resolution //index to store 2d array in linear order. row-major order
                let percent = SIMD2<Float>(Float(x), Float(y)) / Float(resolution - 1) //TODO
//                print("index \(i)")
//                print("print \(percent)")

                let normalizedCoordinateX = (percent.x - 0.5) * 2
                let normalizedCoordinateY = (percent.y - 0.5) * 2
                
                let tangentAOffset = normalizedCoordinateX * axisA
                let tangentBOffset = normalizedCoordinateY * axisB
                
                let pointOnUnitCube = localUp + tangentAOffset + tangentBOffset
                addSphere(position: pointOnUnitCube, color: .blue)

                let pointOnUnitSphere = simd_normalize(pointOnUnitCube)
                addSphere(position: pointOnUnitSphere, color: .red)
                
//                vertices[i] = pointOnUnitSphere
                vertices[i] = pointOnUnitCube

                guard (x != resolution - 1 && y != resolution - 1) else { continue }
//                if (x == 0 && y == 0) {
                    quads[quadIndex] = UInt32(i)
                    quads[quadIndex + 1] = UInt32(i + 1)
                    quads[quadIndex + 2] = UInt32(i + resolution + 1)
                    quads[quadIndex + 3] = UInt32(i + resolution)
                    print("next\n")
                    print("quads \(quads)")
                    print("next\n")

                    textureCoordinates[quadIndex] = [0, 0]
                    textureCoordinates[quadIndex + 1] = [1, 0]
                    textureCoordinates[quadIndex + 2] = [1, 1]
                    textureCoordinates[quadIndex + 3] = [0, 1]
                    print("textureCoords \(textureCoordinates)")
                    quadIndex += 4
//                }
            }
        }
        print("next\n")
        print("vertices \(vertices)")
        print("textureCoords COUNT \(textureCoordinates.count)")
        print("vertices COUNT \(vertices.count)")

        let size = (resolution - 1) * (resolution - 1)
        var descriptor = MeshDescriptor(name: "face")
        descriptor.positions = MeshBuffers.Positions(vertices)
        descriptor.primitives = .polygons(Array(repeating: 4, count: size), quads) //TODO: ist das sinnvoll? (triangles and quads maybe??)
        print("primitives \(descriptor.primitives)")
//        descriptor.textureCoordinates = MeshBuffer.init(textureCoordinates)
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
