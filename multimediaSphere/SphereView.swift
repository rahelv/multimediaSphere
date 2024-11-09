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
    @State private var sphereEntity: SphereEntity?
    
    var body: some View {
        RealityView  { content in
            root.scale = .init(x: 0.4, y: 0.4, z: 0.4) //TODO: enlarge (Volume Size)
            
            do {
                let sphereEntity = try await SphereEntity(resolution: 9) //TODO: change resolution
                await sphereEntity.addHoverToChildEntities() //has to be called here!
                sphereEntity.addGestures() //TODO: test
                self.sphereEntity = sphereEntity
                root.addChild(sphereEntity)
            } catch {
                print("Failed to create SphereEntity: \(error)")
            }
            
            content.add(root)
        }
        .installGestures()
        .toolbar {
            ToolbarItemGroup(placement: .bottomOrnament) {
                VStack (spacing: 12) {
                    Button {
                        sphereEntity!.updateTextures()
                    } label: {
                        Text("QUERY SIMULATION")
                    }
                    .animation(.none, value: 0)
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

#Preview(windowStyle: .plain) {
    SphereView()
}
