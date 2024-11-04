//
//  TerrainFaceView.swift
//  multimediaSphere
//
//  Created by Rahel Kempf on 17.10.2024.
//

import Foundation
import SwiftUI
import RealityKit
import RealityKitContent

struct SphereView: View {
    @State var root = Entity()
    
    var body: some View {
        RealityView  { content in
            root.scale = .init(x: 0.4, y: 0.4, z: 0.4) //TODO: enlarge (Volume Size)
            
            do {
                let sphereEntity = try await SphereEntity(resolution: 9)
                await sphereEntity.addHoverToChildEntities() //has to be called here!
//                sphereEntity.addGestures()
                root.addChild(sphereEntity)
            } catch {
                print("Failed to create SphereEntity: \(error)")
            }
            
            content.add(root)
        }
        .installGestures()
    }
}

#Preview(windowStyle: .plain) {
    SphereView()
}
