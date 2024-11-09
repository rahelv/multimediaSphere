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
        let baseURL = self.generatebaseURL()
        
        // Loop to load textures dynamically
        for i in 1 ... Int(count) {
            let textureURL = URL(string: baseURL + String(format: "%d.jpg", i))
            //TODO: what if theres not enough pictures in chosen folder?? catch error message
//            let texture = createTextureFromURL(url: textureURL!) //TODO: unwrap ...
            createTextureAsync(textureURL!) { texture in
                if let texture = texture {
                    var material = SimpleMaterial()
                    material.color = .init(texture: .init(texture)) //TODO: unwrap ...
                    materials.append(material)
                } else {
                    print("Failed to load texture.")
                    let material = SimpleMaterial(color: .gray, isMetallic: false)
                    materials.append(material)
                }
            }
        }
        print(materials)
        return materials
    }
    
    // select random folder from repo
    private static func generatebaseURL() -> String {
        let baseURL = "https://v3c.xreco-retrieval.ch/v3c/thumbnails/"
        let randomFolderNumber = Int.random(in: 1...17235)
        let randomFolder = String(format: "v_%05d", randomFolderNumber) // "v_00001" to "v_17235"
        return baseURL + randomFolder + "/" + randomFolder + "_"
    }
    
    // from https://forums.developer.apple.com/forums/thread/664280?answerId=641793022#641793022
    static func createTextureFromURL(url: URL) -> TextureResource? {
        // Create a temporary file URL to store the image at the remote URL.
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        // Download contents of imageURL as Data.  Use a URLSession if you want to do this asynchronously.
        let data = try! Data(contentsOf: url)
        
        // Write the image Data to the file URL.
        try! data.write(to: fileURL)
        do {
            // Create a TextureResource by loading the contents of the file URL.
            print("returning")
            return try TextureResource.load(contentsOf: fileURL)
        } catch {
            print(error.localizedDescription)
        }
        return nil //TODO: error handling
    }
    
    static func createTextureAsync(_ url: URL, completion: @escaping (TextureResource?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }

            DispatchQueue.main.async {
                let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
                // Write the image Data to the file URL.
                try! data.write(to: fileURL)
                do {
                    // Create a TextureResource by loading the contents of the file URL.
                    let texture = try TextureResource.load(contentsOf: fileURL)
                    completion(texture)
                } catch {
                    print(error.localizedDescription)
                }
            }
        }.resume()
    }
}
