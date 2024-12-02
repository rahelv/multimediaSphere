//
//  multimediaSphereApp.swift
//  multimediaSphere
//
//  Created by Rahel Kempf on 11.10.2024.
//

import SwiftUI
import RealityKitContent

@main
struct multimediaSphereApp: App {
    
    init() {
        RealityKitContent.GestureComponent
            .registerComponent()
    }
    
    @State private var appModel = AppModel()

    var body: some Scene {
//        WindowGroup {
//            QueryView()
//                .environment(appModel)
//        }
//        .windowStyle(.volumetric)
        
        ImmersiveSpace(id: appModel.immersiveSpaceID) {
            SphereView()
                .environment(appModel)
                .onAppear {
                    appModel.immersiveSpaceState = .open
                }
                .onDisappear {
                    appModel.immersiveSpaceState = .closed
                }
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
    }
}
