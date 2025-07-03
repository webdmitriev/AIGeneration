//
//  PhotoView.swift
//  AIGeneration
//
//  Created by Олег Дмитриев on 27.06.2025.
//

import SwiftUI
import PhotosUI

struct PhotoView: View {
    @StateObject var generator: ImageGenerator

    @State private var prompt: String = ""
    @State private var mode: GenerationMode = .textOnly
    @State private var showImagePicker: Bool = false
    
    @State private var showSubscribeView: Bool = false
    
    @State private var selectedImageData: Data? = nil
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    
    private let widthScreen: CGFloat = UIScreen.main.bounds.width
    private let placeholderString: String = "Type what should be shown in the sketch"
    
    var body: some View {
        NavigationStack {
            ScrollView {
                ZStack {
                    VStack(spacing: 22) {
                        CustomTopBar(title: "AI Photo") {
                            showSubscribeView = true
                        }
                        .frame(height: 40)
                        .clipped()
                        
                        VStack(spacing: 12) {
                            modePickerSection
                            
                            textInputSection
                            
                            imageUploadSection
                            
                            generateButton
                        }
                        .padding(.horizontal, 16)
                    }
                    .opacity(generator.isLoading ? 0.05 : 1)
                    
                    resultSection
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(.appBlack.opacity(0.9))
                }
            }
            .navigationDestination(isPresented: $showSubscribeView) {
                SubscribeView()
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $generator.inputImage)
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
    
    // MARK: - Компоненты интерфейса
    private var modePickerSection: some View {
        Picker("", selection: $mode) {
            Text("Without Photo")
                .tag(GenerationMode.textOnly)
                .foregroundStyle(mode == .textOnly ? .appBlack : .appWhite)
            //Text("Картинка").tag(GenerationMode.imageOnly)
            Text("Use Photo")
                .tag(GenerationMode.textAndImage)
                .foregroundStyle(mode == .textAndImage ? .appBlack : .appWhite)
        }
        .pickerStyle(.segmented)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Color.gray.opacity(0.2))
        )
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .padding(.bottom, 18)
        .onChange(of: mode) { oldValue, _ in
            generator.generatedImage = nil
        }
    }
    
    private var textInputSection: some View {
        VStack {
            Text("Enter Promt")
                .urbanist(.montserratMedium, 21)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(.appWhite)
            
            ZStack(alignment: .bottomTrailing) {
                TextField("", text: $prompt,
                          prompt: Text(placeholderString).foregroundColor(.appWhite.opacity(0.2)),
                          axis: .vertical)
                    .padding(12)
                    .textFieldStyle(.plain)
                    .foregroundStyle(.appWhite.opacity(0.8))
                    .background(.appWhite.opacity(0.05))
                    .lineLimit(8...10)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                
                Button {
                    let randomSurprise = GenerationSurprice.random()
                    prompt = randomSurprise.surpriceText
                } label: {
                    HStack(spacing: 4) {
                        Image("icon-starts-white")
                            .resizable()
                            .frame(width: 16, height: 16)
                            .scaledToFit()
                        
                        Text("Surprise me!")
                            .urbanist(.montserratMedium, 14)
                            .foregroundStyle(.appWhite)
                    }
                }
                .padding(.vertical, 6)
                .padding(.horizontal, 10)
                .background(.appBg)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .padding(.trailing, 12)
                .padding(.bottom, 12)
            }
        }
    }
    
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
                .opacity(mode == .textOnly ? 0 : 1)
            }
        }
        .frame(minHeight: 212, maxHeight: 212)
        .background(.appWhite.opacity(mode == .textOnly ? 0 : 0.05))
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
                if prompt.isEmpty {
                    Text("Create")
                        .modifier(ButtonBlackModifier())
                } else {
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
                
                ShareLink(item: Image(uiImage: image), preview: SharePreview("AI изображение", image: Image(uiImage: image))) {
                    Label("Поделиться", systemImage: "square.and.arrow.up")
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

// MARK: - ImagePicker для загрузки фото
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            parent.dismiss()
        }
    }
}

