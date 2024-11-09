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
    @State private var sphereEntities: [SphereEntity] = []
    
    var body: some View {
        RealityView  { content in
            root.scale = .init(x: 0.4, y: 0.4, z: 0.4) //TODO: enlarge (Volume Size)
            
            do {
                let sphereEntity = try await SphereEntity(resolution: 9) //TODO: change resolution
                await sphereEntity.addHoverToChildEntities() //has to be called here!
                self.sphereEntities.append(sphereEntity)
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
                        Task {
                            let newSphere = try await SphereEntity(resolution: 9) //TODO: change resolution
                            await newSphere.addHoverToChildEntities() //has to be called here!
                            newSphere.updateTextures()
                            sphereEntities.append(newSphere)
                            //TODO: make copying more performant. place sphere in empty space
                            root.addChild(newSphere)
                        }
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
