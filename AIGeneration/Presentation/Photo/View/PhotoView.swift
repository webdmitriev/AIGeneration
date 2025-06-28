//
//  PhotoView.swift
//  AIGeneration
//
//  Created by Олег Дмитриев on 27.06.2025.
//

import SwiftUI
import PhotosUI

struct PhotoView: View {
    @State private var showSubscribeView: Bool = false
    @State private var withoutPhoto: Bool = true
    @State private var usePhoto: Bool = false
    
    @State private var selectedImageData: Data? = nil
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    
    private let widthScreen: CGFloat = UIScreen.main.bounds.width

    var body: some View {
        NavigationStack {
            VStack(spacing: 22) {
                CustomTopBar(title: "AI Photo") {
                    showSubscribeView = true
                }
                .frame(height: 40)
                .clipped()
                
                toogleBar
                
                EnterPromptView()
                
                getLibraryPicture

                Button {
                    print("Generate")
                } label: {
                    if selectedImageData == nil {
                        Text("Create")
                            .modifier(ButtonBlackModifier())
                    } else {
                        Text("Generate")
                            .modifier(ButtonPurpuleModifier())
                    }
                }
                .padding(.horizontal, 16)
                
                Spacer()
            }
            .navigationDestination(isPresented: $showSubscribeView) {
                SubscribeView()
            }
            .onChange(of: selectedPhotoItem) { oldValue, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        selectedImageData = data
                    }
                }
            }
            .frame(maxHeight: .infinity)
            .padding(.bottom, 60)
            .background(.appBg)
            .navigationBarHidden(true)
        }
    }
    
    private var toogleBar: some View {
        HStack {
            Button {
                withoutPhoto = true
                usePhoto = false
                
                selectedImageData = nil
                selectedPhotoItem = nil
            } label: {
                Text("Without Photo")
                    .frame(maxWidth: widthScreen / 2, maxHeight: 32, alignment: .center)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(withoutPhoto ? .appBlack : .appWhite)
                    .background(withoutPhoto ? .appWhite : .clear)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            Button {
                withoutPhoto = false
                usePhoto = true
            } label: {
                Text("Use Photo")
                    .frame(maxWidth: widthScreen / 2, maxHeight: 32, alignment: .center)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(usePhoto ? .appBlack : .appWhite)
                    .background(usePhoto ? .appWhite : .clear)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .frame(maxWidth: .infinity)
        .background(.appWhite.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
        .clipped()
    }
    
    private var getLibraryPicture: some View {
        VStack {
            if usePhoto {
                GetLibraryPicture(imageData: $selectedImageData, photoItem: $selectedPhotoItem)
            }
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, minHeight: 212, maxHeight: 212)
    }
}

#Preview {
    let appState = AppState()
    return PhotoView()
        .environmentObject(appState)
}
