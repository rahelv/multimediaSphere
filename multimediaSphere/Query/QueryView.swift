//
//  QueryView.swift
//  multimediaSphere
//
//  Created by Rahel Kempf on 26.11.2024.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct QueryView: View { //TODO: make Window instead of Volumetric ... 
    @Environment(AppModel.self) private var appModel
    
    var body: some View {
        RealityView { content in
            // Add the initial RealityKit content
        }
        .toolbar {
            ToolbarItemGroup(placement: .bottomOrnament) {
                VStack (spacing: 12) {
                    QueryButton()
                }
            }
        }
    }
}

#Preview {
    QueryView()
}



