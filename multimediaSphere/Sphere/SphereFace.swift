//
//  SphereFace.swift
//  multimediaSphere
//
//  Created by Rahel Kempf on 30.10.2024.
//

import Foundation
import RealityFoundation

struct SphereFace {
    static func constructSphereFaceMesh(resolution: Int, localUp: SIMD3<Float>) async -> [MeshResource] { //returns a MeshResource for each picture on the sphere
//        var meshDescriptors: [MeshDescriptor] = []
        var meshResources: [MeshResource] = []
        let axisA: SIMD3<Float> = SIMD3<Float>(localUp.y, localUp.z, localUp.x) //cyclic permutation (rechtwinklig zu localUp)
        let axisB: SIMD3<Float> = simd_cross(localUp, axisA) //senkrecht auf localUp and axisA
        
        var vertexPositions = [SIMD3<Float>](repeating: .zero, count: resolution * resolution) //vertex for each "edge" on the sphere
        
        for y in 0..<resolution { //row
            for x in 0..<resolution { //column
                let i = x + y * resolution //index to store 2d array in linear order. row-major order
                let percent = SIMD2<Float>(Float(x), Float(y)) / Float(resolution - 1) //TODO
                
                let normalizedCoordinateX = (percent.x - 0.5) * 2
                let normalizedCoordinateY = (percent.y - 0.5) * 2
                
                let tangentAOffset = normalizedCoordinateX * axisA
                let tangentBOffset = normalizedCoordinateY * axisB
                
                let pointOnUnitCube = localUp + tangentAOffset + tangentBOffset
                let pointOnUnitSphere = simd_normalize(pointOnUnitCube)
                
                vertexPositions[i] = pointOnUnitSphere
            }
        }
//        print("vertexpositions: \(vertexPositions)")
            
            for y in 0..<resolution { //row
                for x in 0..<resolution { //column
//                    if (x % 2 == 0 && y % 2 == 0) { //TODO: remove 
                        let i = x + y * resolution //index to store 2d array in linear order. row-major order
                        guard (x != resolution - 1 && y != resolution - 1) else { continue }
                        
                        let edges: [SIMD3<Float>] = [
                            vertexPositions[i],
                            vertexPositions[i + 1],
                            vertexPositions[i + resolution + 1],
                            vertexPositions[i + resolution]
                        ]
                        do {
                            
                            let meshDescriptor: MeshDescriptor = createSingleFaceMesh(vertexPositions: edges, name: "face\(x)\(y)")
                            let meshResource = try await MeshResource.generate(from: [meshDescriptor]) //TODO: why using array
                            meshResources.append(meshResource)
                        } catch {
                            print("Failed to create mesh resource: \(error.localizedDescription)") //TODO: evtl. better error handling
                        }
                    }
//                }
        }
        return meshResources
    }
    
    static func createSingleFaceMesh(vertexPositions: [SIMD3<Float>], name: String) -> MeshDescriptor {
        //check that vertexPositions has 4 edges
//        if vertexPositions.count != 4 { return nil }
        var textureCoordinates = [SIMD2<Float>]() //texture coordinates for a single face

        textureCoordinates.append([0, 0])
        textureCoordinates.append([1, 0])
        textureCoordinates.append([1, 1])
        textureCoordinates.append([0, 1])
        
        var descriptor = MeshDescriptor(name: name)
        descriptor.positions = MeshBuffers.Positions(vertexPositions)
        descriptor.primitives = .polygons([4], [0, 1, 2, 3])
        descriptor.textureCoordinates = MeshBuffer.init(textureCoordinates)
//        descriptor.materials = .perFace(materialsArray)
        return descriptor
    }
}
