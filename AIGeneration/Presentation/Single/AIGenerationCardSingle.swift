//
//  AIGenerationCardSingle.swift
//  AIGeneration
//
//  Created by Олег Дмитриев on 27.06.2025.
//

import SwiftUI
import PhotosUI

struct AIGenerationCardSingle: View {
    @EnvironmentObject var appState: AppState

    @Environment(\.dismiss) var dismiss
    
    @State private var selectedImageData: Data? = nil
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    
    let item: AIGenerationItemStruct
    private let heightImage: CGFloat = UIScreen.main.bounds.width
    
    var body: some View {
        VStack(spacing: 14) {
            Image(item.image)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: heightImage)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .clipped()
            
            VStack {
                if let imageData = selectedImageData, let uiImage = UIImage(data: imageData) {
                    ZStack(alignment: .topTrailing) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .clipped()

                        Button {
                            selectedImageData = nil
                            selectedPhotoItem = nil
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
                        selection: $selectedPhotoItem,
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

            Button {
                print("Generate")
            } label: {
                if selectedImageData == nil {
                    Text("Add a Photo")
                        .modifier(ButtonBlackModifier())
                } else {
                    Text("Generate")
                        .modifier(ButtonPurpuleModifier())
                }
            }
        }
        .onAppear {
            withAnimation {
                appState.isTabBarVisible = false
            }
        }
        .onDisappear {
            withAnimation(.easeInOut(duration: 0.2)) {
                appState.isTabBarVisible = true
            }
        }
        .onChange(of: selectedPhotoItem) { oldValue, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    selectedImageData = data
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 16)
        .background(.appBg)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(item.title)
                    .foregroundColor(.appWhite)
                    .font(.system(size: 22, weight: .bold))
            }
            
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .bold))
                    }
                    .foregroundColor(.appWhite)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}
