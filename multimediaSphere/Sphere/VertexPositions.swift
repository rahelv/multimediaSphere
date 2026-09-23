//
//  VertexPositions.swift
//  multimediaSphere
//
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
    var vertexPositions: [[[SIMD3<Float>]]] = [] //vertexPositions for all 6 faces
    var faces: [[[[SIMD3<Float>]]]] = [] //the vertices of all quads

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
            vertexPositions.append(verticesOfFace) //TODO: does orientation make sense?
            let facesOfSphereFace = self.calculateFaces(directionIndex: i) //returns array of array of edges
            faces.append(facesOfSphereFace)
            i+=1
        }
    }
    
    private func calculateVerticesForSphereFace(localUp: SIMD3<Float>) -> [[SIMD3<Float>]] {
        let axisA: SIMD3<Float> = SIMD3<Float>(localUp.y, localUp.z, localUp.x)
        let axisB: SIMD3<Float> = simd_cross(localUp, axisA)
        
        var vertexPositions: [[SIMD3<Float>]] = Array(repeating: [], count: resolution)
        
        for y in 0..<self.resolution {
            for x in 0..<self.resolution {
                let percent = SIMD2<Float>(Float(x), Float(y)) / Float(self.resolution - 1)
                
                let normalizedCoordinateX = (percent.x - 0.5) * 2
                let normalizedCoordinateY = (percent.y - 0.5) * 2
                
                let tangentAOffset = normalizedCoordinateX * axisA
                let tangentBOffset = normalizedCoordinateY * axisB
                
                let pointOnUnitCube = localUp + tangentAOffset + tangentBOffset
                let pointOnUnitSphere = simd_normalize(pointOnUnitCube)
                
                vertexPositions[y].append(pointOnUnitSphere)
            }
        }
        return vertexPositions
    }
    
    private func calculateFaces(directionIndex: Int) -> [[[SIMD3<Float>]]] {
        var faces: [[[SIMD3<Float>]]] = Array(repeating: [], count: resolution-1)
        
        for x in 0..<resolution { //row
            for y in 0..<resolution { //column
                guard (x != resolution - 1 && y != resolution - 1) else { continue }
                     
                let edges: [SIMD3<Float>] = [
                    vertexPositions[directionIndex][x][y],
                    vertexPositions[directionIndex][x][y+1],
                    vertexPositions[directionIndex][x+1][y+1],
                    vertexPositions[directionIndex][x+1][y]
                ]
                faces[x].append(edges)
            }
        }
        return faces
        
    }
}
