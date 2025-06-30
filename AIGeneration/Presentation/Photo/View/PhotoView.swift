//
//  PhotoView.swift
//  AIGeneration
//
//  Created by Олег Дмитриев on 27.06.2025.
//

import SwiftUI
import PhotosUI

struct PhotoView: View {
    @StateObject private var generator = ImageGenerator()
    @State private var prompt: String = ""
    @State private var mode: GenerationMode = .textOnly
    @State private var showImagePicker = false
    
    @State private var showSubscribeView: Bool = false
    
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
                
                modePickerSection
                
                textInputSection
                
                imageUploadSection
                
                generateButton
                
                

                
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
    
    // MARK: - Компоненты интерфейса
    private var modePickerSection: some View {
        Picker("Режим генерации", selection: $mode) {
            Text("Текст").tag(GenerationMode.textOnly)
            Text("Картинка").tag(GenerationMode.imageOnly)
            Text("Текст + Картинка").tag(GenerationMode.textAndImage)
        }
        .pickerStyle(.segmented)
        .padding(.bottom, 10)
        .onChange(of: mode) { oldValue, _ in
            generator.generatedImage = nil
        }
    }
    
    private var textInputSection: some View {
        TextField("Опишите изображение...", text: $prompt, axis: .vertical)
            .textFieldStyle(.roundedBorder)
            .lineLimit(3...5)
    }
    
    private var imageUploadSection: some View {
        VStack {
            if let inputImage = generator.inputImage {
                Image(uiImage: inputImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150)
                    .cornerRadius(10)
                    .overlay(alignment: .topTrailing) {
                        Button {
                            generator.inputImage = nil
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                                .padding(5)
                        }
                    }
            } else {
                Button {
                    showImagePicker = true
                } label: {
                    Label("Загрузить изображение", systemImage: "photo")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
        }
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
                Text("Сгенерировать")
                    .frame(maxWidth: .infinity)
            }
        }
        .buttonStyle(.borderedProminent)
        .disabled(generator.isLoading || (mode != .textOnly && generator.inputImage == nil))
    }
    
    private var resultSection: some View {
        Group {
            if generator.isLoading {
                VStack {
                    ProgressView("Генерация...")
                    Text("Обычно занимает 10-30 секунд")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } else if let error = generator.error {
                errorView(error)
            } else if let image = generator.generatedImage {
                resultImageView(image)
            }
        }
        .frame(minHeight: 300)
    }
    
    private func errorView(_ message: String) -> some View {
        VStack {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(.red)
            Text(message)
                .foregroundColor(.red)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
    
    private func resultImageView(_ image: UIImage) -> some View {
        VStack {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .cornerRadius(12)
                .shadow(radius: 5)
            
            HStack {
                Button {
                    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                } label: {
                    Label("Сохранить", systemImage: "square.and.arrow.down")
                }
                
                ShareLink(item: Image(uiImage: image), preview: SharePreview("AI изображение", image: Image(uiImage: image))) {
                    Label("Поделиться", systemImage: "square.and.arrow.up")
                }
            }
            .buttonStyle(.bordered)
        }
    }
    
    
    
    
    
    private var getLibraryPicture: some View {
        VStack {
            GetLibraryPicture(imageData: $selectedImageData, photoItem: $selectedPhotoItem)
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, minHeight: 212, maxHeight: 212)
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

#Preview {
    let appState = AppState()
    return PhotoView()
        .environmentObject(appState)
}
