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
    
    @StateObject var generator: ImageGenerator

    @State private var mode: GenerationMode = .textAndImage
    @State private var showImagePicker: Bool = false
    @State private var showSubscribeView: Bool = false
    @State private var selectedImageData: Data? = nil
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    
    let item: AIGenerationItemStruct
    private let widthScreen: CGFloat = UIScreen.main.bounds.width
    private let heightImage: CGFloat = UIScreen.main.bounds.width
    var prompt: String {
        return item.descr
    }
    
    var body: some View {
        ScrollView {
            ZStack {
                VStack(spacing: 12) {
                    Image(item.image)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity, maxHeight: heightImage)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .clipped()
                    
                    imageUploadSection
                    
                    generateButton
                }
                .opacity(generator.isLoading ? 0.05 : 1)
                
                resultSection
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.appBlack.opacity(0.9))
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
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $generator.inputImage)
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
    
    // MARK: - Компоненты интерфейса
    private var imageUploadSection: some View {
        VStack {
            if let inputImage = generator.inputImage {
                Image(uiImage: inputImage)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: widthScreen - 32, minHeight: 212, maxHeight: 212)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .clipped()
                    .overlay(alignment: .topTrailing) {
                        Button {
                            generator.inputImage = nil
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 17, weight: .medium))
                                .foregroundColor(.appBlack)
                                .padding(14)
                        }
                    }
            } else {
                VStack(spacing: 8) {
                    Button {
                        showImagePicker = true
                    } label: {
                        Image("tab-photo-active")
                            .resizable()
                            .frame(width: 58, height: 58)
                            .scaledToFit()
                    }
                    
                    Text("Tap here to add a photo")
                        .urbanist(.montserratMedium, 16)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .foregroundStyle(.appWhite.opacity(0.2))
                }
            }
        }
        .frame(minHeight: 212, maxHeight: 212)
        .background(.appWhite.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var generateButton: some View {
        Button {
            Task {
                await generator.generate(prompt: prompt, mode: mode)
            }
        } label: {
            if generator.isLoading {
                ProgressView()
                    .tint(.white)
            } else {
                if (generator.inputImage != nil) {
                    Text("Create")
                        .modifier(ButtonPurpuleModifier())
                }
            }
        }
        .disabled(generator.isLoading || prompt.isEmpty)
        
    }
    
    private var resultSection: some View {
        Group {
            if generator.isLoading {
                VStack(spacing: 4) {
                    ProgressView("Генерация...")
                        .tint(.appWhite)

                    Text("Обычно занимает 10-30 секунд")
                        .urbanist(.montserratMedium, 16)
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.appWhite)
                }
            } else if let error = generator.error {
                errorView(error)
            } else if let image = generator.generatedImage {
                resultImageView(image)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 300, maxHeight: 460)
    }
    
    private func errorView(_ message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(.appWhite)

            Text(message)
                .urbanist(.montserratMedium, 14)
                .frame(maxWidth: .infinity)
                .foregroundColor(.appWhite)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
    
    private func resultImageView(_ image: UIImage) -> some View {
        VStack(spacing: 12) {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: 420)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .clipped()
            
            HStack {
                Button {
                    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                } label: {
                    Label("Сохранить", systemImage: "square.and.arrow.down")
                }
                
                Button {
                    generator.isLoading = false
                    selectedImageData = nil
                    selectedPhotoItem = nil
                    
                    generator.generatedImage = nil
                } label: {
                    Image(systemName: "xmark")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .scaledToFit()
                }
            }
            .buttonStyle(.bordered)
        }
        .padding(.horizontal, 16)
    }
}
