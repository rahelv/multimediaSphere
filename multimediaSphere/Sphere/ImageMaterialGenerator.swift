//
//  ImageMaterialGenerator.swift
//  multimediaSphere
//
//  Created by Rahel Kempf on 30.10.2024.
//

import Foundation
import RealityFoundation

struct ImageMaterialGenerator {
    // TODO: load materials from web
    static func generateMaterials() -> [SimpleMaterial] {
    //  var textures: [TextureResource] = [] //TODO: why differentiate between materials and textures?
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
