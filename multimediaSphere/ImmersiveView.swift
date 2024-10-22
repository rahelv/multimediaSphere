//
//  ImmersiveView.swift
//  multimediaSphere
//
//  Created by Rahel Kempf on 11.10.2024.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ImmersiveView: View {
    
//    @StateObject var model = SphereModel()
    
    private var contentEntity = Entity()
    private var location: CGPoint = .zero
    private var location3D: Point3D = .zero

    var body: some View {
        RealityView { content in
//            content.add(model.setupContentEntity())
//            model.addCube()
        }
        .gesture(
            SpatialTapGesture()
                .targetedToAnyEntity()
                .onEnded { value in
                    print(value)
                }
        )
    }
}

#Preview(immersionStyle: .mixed) {
    ImmersiveView()
        .environment(AppModel())
}
