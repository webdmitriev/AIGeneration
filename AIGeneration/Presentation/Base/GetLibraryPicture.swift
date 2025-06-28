//
//  GetLibraryPicture.swift
//  AIGeneration
//
//  Created by Олег Дмитриев on 28.06.2025.
//

import SwiftUI
import PhotosUI

struct GetLibraryPicture: View {
    @Binding var imageData: Data?
    @Binding var photoItem: PhotosPickerItem?
    
    var body: some View {
        VStack {
            if let imageData = imageData, let uiImage = UIImage(data: imageData) {
                ZStack(alignment: .topTrailing) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .clipped()

                    Button {
                        self.imageData = nil
                        self.photoItem = nil
                    } label: {
                        Image("icon-close-black")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .scaledToFit()
                    }
                    .padding(.top, 28)
                    .padding(.trailing, 16)
                }
                .frame(height: 212)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .clipped()
            } else {
                PhotosPicker(
                    selection: $photoItem,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    Image(systemName: "photo.on.rectangle.angled.fill")
                        .resizable()
                        .frame(width: 71, height: 71)
                        .foregroundStyle(.appWhite.opacity(0.3))
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: 212)
        .background(.appWhite.opacity(0.03))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .clipped()
    }
}
