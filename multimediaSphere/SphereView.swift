import Foundation
import SwiftUI
import RealityKit
import RealityKitContent
import ARKit

struct SphereView: View {
    @State private var root: Entity = Entity()
    @State private var selectedImageName: String? // Holds the selected image name
    @State private var isSelectingImage: Bool = false
    @ObservedObject private var state = EntityGestureState.shared
    
    let session = ARKitSession()
    let worldTracking = WorldTrackingProvider()
    
    var body: some View {
        ZStack {
            RealityView { content, attachments in
                Task {
                    try? await session.run([worldTracking])
                }
                
                do {
                    let sphereEntity = try await SphereEntity(resolution: 9) // Customize resolution
                    await sphereEntity.addHoverToChildEntities()
                    sphereEntity.position = [0, 1.5, -3.0] // centered in front of the user at eye level
                    root.addChild(sphereEntity)
                    content.add(root)
                } catch {
                    print("Failed to create SphereEntity: \(error)")
                }
            } update: { content, attachments in
                let sphereEntity = root.children[0]
                guard let attachmentEntity = attachments.entity(for: "singleImageAttachment") else { return }
                sphereEntity.addChild(attachmentEntity)
                
                guard let deviceAnchor = worldTracking.queryDeviceAnchor(atTimestamp: CACurrentMediaTime()) else { return }
                let deviceOrigin = deviceAnchor.originFromAnchorTransform.columns.3
                let devicePositionInEntitySpace = sphereEntity.convert(position: SIMD3(deviceOrigin.x, deviceOrigin.y, deviceOrigin.z), from: nil ) //device position relative to world coordinates
                print("Sphere Position: \(sphereEntity.position)")
//                let facingDirection = devicePosition - sphereEntity.position(relativeTo: nil) //relative to world
//                print("Facing Direction: \(facingDirection)")

//                let normalizedFacingDirection = normalize(devicePosition - sphereEntity.position(relativeTo: nil)) //unit vector from sphere to device
//                print("normalizedFacingDirection: \(normalizedFacingDirection)")
                
//                let localFacingDirection = devicePositionInEntitySpace - sphereEntity.position
//                sphereEntity.convert(direction: normalize(devicePosition - sphereEntity.position(relativeTo: nil)), from: nil)
//                print("localFacingDirection \(localFacingDirection)")

                // Position the attachmentEntity in front of the sphere relative to its local space
                let offsetDistance: Float = 1.1
                let localPosition = normalize(devicePositionInEntitySpace - sphereEntity.position) * offsetDistance

                // Set the new position of the attachmentEntity relative to the sphereEntity
                attachmentEntity.setPosition(localPosition, relativeTo: sphereEntity)
                print("------")
            }
            attachments: {
                Attachment(id: "singleImageAttachment") {
                    if isSelectingImage, let imageName = selectedImageName {
                        SingleImageView(imageName: imageName)
                            .cornerRadius(12)
                            .shadow(radius: 10)
                            .padding()
                            .overlay(
                                Button(action: {
                                    state.isSelectingImage = false
                                    isSelectingImage = false
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.white)
                                        .padding()
                                },
                                alignment: .topTrailing
                            )
                            .transition(.scale)
                    }
                }}
            .installGestures()
            .gesture(
                SpatialTapGesture()
                    .targetedToAnyEntity()
                    .onEnded { value in
                        selectedImageName = value.entity.name
                        state.isSelectingImage = true
                        isSelectingImage = true
                    }
            )
        }
    }
}

#Preview(immersionStyle: .mixed) {
    SphereView().environment(AppModel())
}
