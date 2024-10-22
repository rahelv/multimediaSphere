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
            addSphere(position: .zero, color: .black)
            await createTerrainFace(resolution: 10, localUp: .init(x: 0, y: 1, z: 0))
            await createTerrainFace(resolution: 10, localUp: .init(x: 0, y: -1, z: 0))
            await createTerrainFace(resolution: 10, localUp: .init(x: 1, y: 0, z: 0))
            await createTerrainFace(resolution: 10, localUp: .init(x: -1, y: 0, z: 0))
            await createTerrainFace(resolution: 10, localUp: .init(x: 0, y: 0, z: 1)) //Front facing
            await createTerrainFace(resolution: 10, localUp: .init(x: 0, y: 0, z: -1))
        }
    }
    
    @MainActor
    func addSphere(position: SIMD3<Float>, color: SimpleMaterial.Color) {
        let sphereEntity = ModelEntity(
            mesh: .generateSphere(radius: 0.01),
            materials: [SimpleMaterial(color: color, isMetallic: false)]
        )
        sphereEntity.position = position
        root.addChild(sphereEntity)
    }
    
    func createTerrainFace(resolution: Int, localUp: SIMD3<Float>) async {
        let descriptor = constructTerrainFaceMesh(resolution: resolution, localUp: localUp)
        let mesh = try! await MeshResource(from: [descriptor])
        let face = ModelEntity(mesh: mesh, materials: generateMaterials())
        root.addChild(face)
    }
    
    func constructTerrainFaceMesh(resolution: Int, localUp: SIMD3<Float>) -> MeshDescriptor {
        let axisA: SIMD3<Float> = SIMD3<Float>(localUp.y, localUp.z, localUp.x)
        let axisB: SIMD3<Float> = simd_cross(localUp, axisA)
        
        var vertices = [SIMD3<Float>](repeating: .zero, count: resolution * resolution)
        var quads = [UInt32](repeating: 0, count: (resolution - 1) * (resolution - 1) * 4)

        var quadIndex = 0
        
        for y in 0..<resolution {
            for x in 0..<resolution {
                let i = x + y * resolution
                let percent = SIMD2<Float>(Float(x), Float(y)) / Float(resolution - 1)
                
                let normalizedCoordinateX = (percent.x - 0.5) * 2
                let normalizedCoordinateY = (percent.y - 0.5) * 2
                
                let tangentAOffset = normalizedCoordinateX * axisA
                let tangentBOffset = normalizedCoordinateY * axisB
                
                let pointOnUnitCube = localUp + tangentAOffset + tangentBOffset
                
                let pointOnUnitSphere = simd_normalize(pointOnUnitCube)
                addSphere(position: pointOnUnitSphere, color: .red)
                
                vertices[i] = pointOnUnitSphere
                
                guard (x != resolution - 1 && y != resolution - 1) else { continue }
//                if (x % 2 == 0 && y % 2 == 0) {
                    quads[quadIndex] = UInt32(i) //x
                    quads[quadIndex + 2] = UInt32(i) + UInt32(resolution) + UInt32(1) //x + resolution + 1
                    quads[quadIndex + 1] = UInt32(i) + UInt32(1) // x + 1
                    quads[quadIndex + 3] = UInt32(i) + UInt32(resolution) // x + resolution
                    quadIndex += 4
//                }
            }
        }
        
        let size = (resolution - 1) * (resolution - 1)
        var descriptor = MeshDescriptor(name: "face")
        descriptor.positions = MeshBuffers.Positions(vertices)
        descriptor.primitives = .polygons(Array(repeating: 4, count: size), quads) //TODO: ist das sinnvoll? (triangles and quads maybe??)
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
            guard let texture = try? TextureResource.load(named: textureName) else {
                fatalError("Unable to load texture \(textureName).")
            }
            var material = SimpleMaterial()
            material.color = .init(texture: .init(texture))
            materials.append(material)
            
//            let material = SimpleMaterial(color: .random(), isMetallic: false)
//            materials.append(material)
        }
        
        return materials
    }
    
}

extension UIColor {
    static func random() -> UIColor {
        let red = CGFloat.random(in: 0...1)
        let green = CGFloat.random(in: 0...1)
        let blue = CGFloat.random(in: 0...1)
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
}

#Preview(windowStyle: .plain) {
    TerrainFaceView()
}
