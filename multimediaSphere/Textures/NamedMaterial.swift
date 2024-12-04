//
//  NamedMaterial.swift
//  multimediaSphere
//
//  Created by Rahel Kempf on 26.11.2024.
//

import Foundation
import RealityFoundation

struct NamedMaterial {
    let name: String
    var material: PhysicallyBasedMaterial
    
    mutating func zoomTexture(inputOffset: SIMD2<Float>, inputScale: SIMD2<Float>) {
        material.textureCoordinateTransform = .init(
            offset: inputOffset,
            scale: inputScale,
            rotation: 0
        )
    }
}
