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
    // select random folder from repo
    func generateRandomFolder() -> String {
        let randomFolderNumber = Int.random(in: 1...17235)
        let randomFolder = String(format: "v_%05d", randomFolderNumber) // "v_00001" to "v_17235"
        return randomFolder
    }
    
    func createMaterialAsync(_ url: URL, completion: @escaping (SimpleMaterial?) -> Void) {
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
                    var material = SimpleMaterial()
                    material.color = .init(texture: .init(texture))
                    completion(material)
                } catch {
                    print("there was an error loading the data: \(error.localizedDescription)")
                    // Create a TextureResource by loading the contents of the file URL.
                    //TODO: load texture from new url
                    completion(nil)
                }
            }
        }.resume()
    }
    
    func countImagesInDirectory(url: URL) async -> Int {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            guard let htmlString = String(data: data, encoding: .utf8) else {
                   return 0
            }
            let lines = htmlString.split { $0.isNewline }  // Split by newlines
            return lines.count - 10 //TODO: maybe there's a better way, is it always 10 lines exactly which are not li elements ?
            
        } catch {
            print("error: \(error)")
            return 0
        }
    }
    
    func generateFlowerMaterials(count: Double) -> [NamedMaterial] {
        var materials: [NamedMaterial] = []
              
              // Loop to load textures dynamically
              for i in 1 ... Int(count) {
                  let textureName = String(format: "image_%05d", i)
                  do {
                      let texture = try TextureResource.load(named: textureName)
                      var material = SimpleMaterial()
                      material.color = .init(texture: .init(texture))
                      materials.append(NamedMaterial(name: textureName, material: material))
                  } catch {
                      print("Unable to load texture \(textureName).")
                      // Fallback material
                      let material = SimpleMaterial(color: .gray, isMetallic: false)
                      materials.append(NamedMaterial(name: "fallbackMaterial", material: material))
                  }
              }
              return materials
          }
}


