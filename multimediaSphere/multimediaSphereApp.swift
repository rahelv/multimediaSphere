//
//  multimediaSphereApp.swift
//  multimediaSphere
//
//  Created by Rahel Kempf on 11.10.2024.
//

import SwiftUI

@main
struct multimediaSphereApp: App {
    
    init() {
        GestureComponent
            .registerComponent()
    }
    
    @State private var appModel = AppModel()

    var body: some Scene {
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
