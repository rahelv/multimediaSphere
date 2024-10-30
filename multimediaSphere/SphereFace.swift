//
//  SphereFace.swift
//  multimediaSphere
//
//  Created by Rahel Kempf on 30.10.2024.
//

import Foundation
import RealityFoundation

struct SphereFace {
    
    //TODO: -- build sphere entity from sphere faces
    //TODO: -- add all faces and then return
    
        static func constructSphereFaceMesh(resolution: Int, localUp: SIMD3<Float>) -> MeshDescriptor {
        let axisA: SIMD3<Float> = SIMD3<Float>(localUp.y, localUp.z, localUp.x) //cyclic permutation (rechtwinklig zu localUp)
        let axisB: SIMD3<Float> = simd_cross(localUp, axisA) //senkrecht auf localUp and axisA
        
        var vertexPositions = [SIMD3<Float>](repeating: .zero, count: resolution * resolution)//vertex for each "edge" on the sphere
        var vertexIndices = [UInt32]()
        var textureCoordinates = [SIMD2<Float>]() //texture coordinates corresponding to faces
        
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
//                addSphere(position: pointOnUnitSphere, color: .red)
                
                vertexPositions[i] = pointOnUnitSphere
//                vertexPositions[i] = pointOnUnitCube
                
                guard (x != resolution - 1 && y != resolution - 1) else { continue }
 //                if (x == 0 && y == 0) {
                //first add new vertices (with duplicates)
                vertexIndices.append(UInt32(i))
                vertexIndices.append(UInt32(i + 1))
                vertexIndices.append(UInt32(i + resolution + 1))
                vertexIndices.append(UInt32(i + resolution))
                
                textureCoordinates.append([0, 0])
                textureCoordinates.append([1, 0])
                textureCoordinates.append([1, 1])
                textureCoordinates.append([0, 1])
            }
        }
        let quads = [UInt32](0..<UInt32(vertexIndices.count))
        let orderedVertexPositions: [SIMD3<Float>] = vertexIndices.map { vertexPositions[Int($0)] }
            
        let size = (resolution - 1) * (resolution - 1)
        var descriptor = MeshDescriptor(name: "face")
        descriptor.positions = MeshBuffers.Positions(orderedVertexPositions)
        descriptor.primitives = .polygons(Array(repeating: 4, count: size), quads) //TODO: ist das sinnvoll? (triangles and quads maybe??)
        descriptor.textureCoordinates = MeshBuffer.init(textureCoordinates)
        let materialsArray: [UInt32] = Array(0..<size).map { UInt32($0) } //TODO
        descriptor.materials = .perFace(materialsArray)
        return descriptor
    }
}
