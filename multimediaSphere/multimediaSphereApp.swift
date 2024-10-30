//
//  multimediaSphereApp.swift
//  multimediaSphere
//
//  Created by Rahel Kempf on 11.10.2024.
//

import SwiftUI

@main
struct multimediaSphereApp: App {

    @State private var appModel = AppModel()

    var body: some Scene {
        WindowGroup {
            TerrainFaceView()
                .environment(appModel)
        }
        .windowStyle(.volumetric)
    }
}
