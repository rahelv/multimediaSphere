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
        WindowGroup {
            SphereView()
                .environment(appModel)
        }
        .windowStyle(.volumetric)
    }
}
