//
//  SingleImageView.swift
//  multimediaSphere
//
//

import SwiftUI

struct SingleImageView: View {
    var imageName: String
    
    var body: some View {
        Image(imageName)
            .resizable()             // Makes the image resizable
            .aspectRatio(contentMode: .fit)  // Preserves aspect ratio
            .padding()               // Adds padding around the image
    }
}

#Preview {
    SingleImageView(imageName: "image_00356")
}
