//
//  UVSphere.swift
//  multimediaSphere
//
//  Created by Rahel Kempf on 14.11.2024.
//

import Foundation
import RealityFoundation

struct Face {
    let vertices: [SIMD3<Float>]
    var position: PositionIdentifier
}

//Singleton for VertexPositions
class VertexPositions {
    static let shared: VertexPositions = {
        let instance = VertexPositions()
        // setup code
        return instance
    }()
    var latitudes: Int = 28
    var longitudes: Int = 28
    var resolution: Int = 28
    var vertices: [SIMD3<Float>] = [] //vertices stored in row-major order
    var faces: [[Face]] = Array(repeating: [], count: 28)
 //the vertices of all triangles and quads
    
    private init() {
        self.calculateVertices(latitudes: latitudes, longitudes: longitudes);
    }
    
    private func calculateVertices(latitudes: Int, longitudes: Int) {
        // MARK: vertices
        
        //add top vertex
        let topVertex = SIMD3<Float>(0, 1, 0)
        vertices.append(topVertex)
       
        for i in 0..<latitudes-1 {
            let phi = Float.pi * Float(i + 1) / Float(latitudes)
            for j in 0..<longitudes {
                let theta = 2.0 * Float.pi * Float(j) / Float(longitudes);
            
                let x = sin(phi) * cos(theta)
                let y = cos(phi)
                let z = sin(phi) * sin(theta)
                vertices.append(SIMD3(x, y, z))
            }
        }
        
        // add bottom vertex
        let bottomVertex = SIMD3<Float>(0, -1, 0)
        vertices.append(bottomVertex)
        
        // MARK: faces
        
        // add top / bottom triangles
        for i in 0..<longitudes {
            var i0 = i + 1;
            var i1 = (i + 1) % longitudes + 1;
            faces[0].append(Face(vertices: [SIMD3(topVertex), vertices[i1], vertices[i0]], position: .triangletop)) //all top triangles stored in faces[0]
            i0 = i + longitudes * (latitudes - 2) + 1;
            i1 = (i + 1) % longitudes + longitudes * (latitudes - 2) + 1;
            faces[latitudes-1].append(Face(vertices: [SIMD3(bottomVertex), vertices[i0], vertices[i1]], position: .triangletop)) //all bottom triangles stored in the last row
        }
       
        // add quads per stack / slice
        for j in 0..<longitudes-2 { //-2 because top and bottom triangles have already been added.
            let j0 = j * latitudes + 1;
            let j1 = (j + 1) * latitudes + 1;
            for i in 0..<latitudes {
                let i0 = j0 + i;
                let i1 = j0 + (i + 1) % latitudes;
                let i2 = j1 + (i + 1) % latitudes;
                let i3 = j1 + i;
                
                faces[j+1].append(Face(vertices: [vertices[i0], vertices[i1], vertices[i2], vertices[i3]], position: .undefined))
            }
        }
       
        // assign positions
        for row in stride(from: 3, through: resolution-1, by: 4) {
            for col in stride(from: 0, to: resolution, by: 4) { //TODO: check if correct
                faces[row][col].position = .bottomright_bottomright
                faces[row][col+1].position = .bottomright_bottomleft
                faces[row][col+2].position = .bottomleft_bottomright
                faces[row][col+3].position = .bottomleft_bottomleft
                
                faces[row-1][col].position = .bottomright_topright
                faces[row-1][col+1].position = .bottomright_topleft
                faces[row-1][col+2].position = .bottomleft_topright
                faces[row-1][col+3].position = .bottomleft_topleft
                
                faces[row-2][col].position = .topright_bottomright
                faces[row-2][col+1].position = .topright_bottomleft
                faces[row-2][col+2].position = .topleft_bottomright
                faces[row-2][col+3].position = .topleft_bottomleft
                
                faces[row-3][col].position = .topright_topright
                faces[row-3][col+1].position = .topright_topleft
                faces[row-3][col+2].position = .topleft_topright
                faces[row-3][col+3].position = .topleft_topleft
            }

        }
    }
}
