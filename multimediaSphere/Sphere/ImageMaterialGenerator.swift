//
//  ImageMaterialGenerator.swift
//  multimediaSphere
//
//  Created by Rahel Kempf on 30.10.2024.
//

import Foundation
import RealityFoundation
import UIKit

struct ImageMaterialGenerator {
    // TODO: load materials from web
    static func generateMaterials(count: Double) -> [SimpleMaterial] {
    //  var textures: [TextureResource] = [] //TODO: why differentiate between materials and textures?
        var materials: [SimpleMaterial] = []
        
        // Loop to load textures dynamically
        for i in 1 ... Int(count) {
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
    
    func loadImageFromURL(_ url: URL, completion: @escaping (UIImage?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }

            DispatchQueue.main.async {
                let image = UIImage(data: data)
                completion(image)
            }
        }.resume()
    }
    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//             detail = indexPath.item + 1
//             //let imageUrlString = "http://10.34.58.149/Data/CLS-LOC/train/n03832673/n03832673_17810.JPEG"
//             if let results = results, indexPath.item < results.count {
//                 var imageUrlString : String = ""
//                 if (results[indexPath.item].starts(with: "[")){
//                     let path = results[indexPath.item].dropFirst()
//                     imageUrlString = endpoint + path.dropFirst().dropLast()
//                 } else {
//                     imageUrlString = endpoint + results[indexPath.item].dropFirst().dropLast()
//                 }
//                 if let imageUrl = URL(string: imageUrlString) {
//                     loadImageFromURL(imageUrl) { [weak self] image in
//                         self?.detailImageView.image = image
//                         self?.toggleDetailVisibility()
//                     }
//                 }
//             }
//         }
}
