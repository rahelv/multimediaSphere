//
//  VertexPositions.swift
//  multimediaSphere
//
//  Created by Rahel Kempf on 30.10.2024.
//

import Foundation
import RealityFoundation

//Singleton for VertexPositions
class VertexPositions {
    static let shared: VertexPositions = {
        let instance = VertexPositions()
           // setup code
           return instance
       }()
    var resolution: Int = 9 //TODO: change resolution
    var vertexPositions: [[SIMD3<Float>]] = [] //vertexPositions for all 6 faces
    var edges: [[[SIMD3<Float>]]] = [] //the vertices of all quads

    let directions: [SIMD3<Float>] = [
        SIMD3<Float>(0, 1, 0),   // up
        SIMD3<Float>(0, -1, 0),  // down
        SIMD3<Float>(-1, 0, 0),  // left
        SIMD3<Float>(1, 0, 0),   // right
        SIMD3<Float>(0, 0, 1),   // forward
        SIMD3<Float>(0, 0, -1)   // back
    ]
    
    private init(resolution: Int = 9) { //TODO: change resolution 
        var i: Int = 0; //to know which direction
        for direction in directions {
            let verticesOfFace = self.calculateVerticesForSphereFace(localUp: direction)
            vertexPositions.append(verticesOfFace)
            let edgesOfFace = self.calculateEdges(directionIndex: i) //returns array of array of edges
            edges.append(edgesOfFace)
            i+=1
        }
    }
    
    private func calculateVerticesForSphereFace(localUp: SIMD3<Float>) -> [SIMD3<Float>] { //returns a MeshResource for each Image on the sphere
        let axisA: SIMD3<Float> = SIMD3<Float>(localUp.y, localUp.z, localUp.x) //cyclic permutation (rechtwinklig zu localUp)
        let axisB: SIMD3<Float> = simd_cross(localUp, axisA) //senkrecht auf localUp and axisA
        
        var vertexPositions = [SIMD3<Float>](repeating: .zero, count: self.resolution * self.resolution) //vertex for each "edge" on the sphere
        
        for y in 0..<self.resolution { //row
            for x in 0..<self.resolution { //column
                let i = x + y * self.resolution //index to store 2d array in linear order. row-major order
                let percent = SIMD2<Float>(Float(x), Float(y)) / Float(self.resolution - 1) //TODO
                
                let normalizedCoordinateX = (percent.x - 0.5) * 2
                let normalizedCoordinateY = (percent.y - 0.5) * 2
                
                let tangentAOffset = normalizedCoordinateX * axisA
                let tangentBOffset = normalizedCoordinateY * axisB
                
                let pointOnUnitCube = localUp + tangentAOffset + tangentBOffset
                let pointOnUnitSphere = simd_normalize(pointOnUnitCube)
                
                vertexPositions[i] = pointOnUnitSphere
            }
        }
        return vertexPositions
    }
    
    private func calculateEdges(directionIndex: Int) -> [[SIMD3<Float>]] {
        var edgesOfFace: [[SIMD3<Float>]] = []
        for y in 0..<resolution { //row
            for x in 0..<resolution { //column
                let i = x + y * resolution //index to store 2d array in linear order. row-major order
                guard (x != resolution - 1 && y != resolution - 1) else { continue }
                     
                let edges: [SIMD3<Float>] = [
                    vertexPositions[directionIndex][i],
                    vertexPositions[directionIndex][i + 1],
                    vertexPositions[directionIndex][i + resolution + 1],
                    vertexPositions[directionIndex][i + resolution]
                ]
                edgesOfFace.append(edges)
            }
        }
        return edgesOfFace
    }
}
