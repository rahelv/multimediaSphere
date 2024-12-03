//
//  UVSphere.swift
//  multimediaSphere
//
//  Created by Rahel Kempf on 14.11.2024.
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
    var latitudes: Int = 15
    var longitudes: Int = 15
    var vertices: [SIMD3<Float>] = [] //vertexPositions
    var faces: [[SIMD3<Float>]] = [] //the vertices of all triangles and quads
    
    private init() { //TODO: change resolution
        self.calculateVertices(latitudes: latitudes, longitudes: longitudes);
    }
    
    private func calculateVertices(latitudes: Int, longitudes: Int) {
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
        
        // add top / bottom triangles
        for i in 0..<longitudes {
            var i0 = i + 1;
            var i1 = (i + 1) % longitudes + 1;
            faces.append([SIMD3(topVertex), vertices[i1], vertices[i0]]) //TODO: heeee
            i0 = i + longitudes * (latitudes - 2) + 1;
            i1 = (i + 1) % longitudes + longitudes * (latitudes - 2) + 1;
            faces.append([SIMD3(bottomVertex), vertices[i0], vertices[i1]])
        }
        
        // add quads per stack / slice
        for j in 0..<latitudes-2 {
            let j0 = j * longitudes + 1;
            let j1 = (j + 1) * longitudes + 1;
            for i in 0..<longitudes {
                let i0 = j0 + i;
                let i1 = j0 + (i + 1) % longitudes;
                let i2 = j1 + (i + 1) % longitudes;
                let i3 = j1 + i;
                faces.append([vertices[i0], vertices[i1], vertices[i2], vertices[i3]])
            }
        }
    }
}
