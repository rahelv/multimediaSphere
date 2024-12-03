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
    let position: positionIdentifier
}

//Singleton for VertexPositions
class VertexPositions {
    static let shared: VertexPositions = {
        let instance = VertexPositions()
        // setup code
        return instance
    }()
    var latitudes: Int = 30
    var longitudes: Int = 30
    var vertices: [SIMD3<Float>] = [] //vertexPositions
    var faces: [Face] = [] //the vertices of all triangles and quads
//    var zoomFaces: [[SIMD3<Float>]] = [] //vertices of all triangles and quads once zoomed in
    
    private init() {
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
            faces.append(Face(vertices: [SIMD3(topVertex), vertices[i1], vertices[i0]], position: .triangletop)) //TODO: heeee
            i0 = i + longitudes * (latitudes - 2) + 1;
            i1 = (i + 1) % longitudes + longitudes * (latitudes - 2) + 1;
            faces.append(Face(vertices: [SIMD3(bottomVertex), vertices[i0], vertices[i1]], position: .triangletop))
        }
       
        // add quads per stack / slice
        for j in 0..<longitudes-2 {
            let j0 = j * latitudes + 1;
            let j1 = (j + 1) * latitudes + 1;
            for i in 0..<latitudes {
                let i0 = j0 + i;
                let i1 = j0 + (i + 1) % latitudes;
                let i2 = j1 + (i + 1) % latitudes;
                let i3 = j1 + i;
                
                //position:
                var position: positionIdentifier
                if (j == 0) {
                    if (i % 2 == 0) {
//                        position = .trianglebottomleft
                        position = .bottomleft
                    } else {
//                     position = .trianglebottomright
                        position = .bottomright
                    }
                }
                else if (j % 2 == 0) { //top or bottom, based on longitude
                    if (i % 2 == 0) {
                        position = .topleft
                    } else {
                        position = .topright
                    }
                } else {
                    if (i % 2 == 0) {
                        position = .bottomleft
                    } else {
                        position = .bottomright
                    }
                }
                faces.append(Face(vertices: [vertices[i0], vertices[i1], vertices[i2], vertices[i3]], position: position))
            }
        }
    }
}
