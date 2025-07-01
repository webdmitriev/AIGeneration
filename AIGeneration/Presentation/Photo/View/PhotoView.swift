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
    private let placeholderString: String = "Type what should be shown in the sketch"

    var body: some View {
        NavigationStack {
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
                    
                // result
                resultSection
                
                Spacer()
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
            Text("Without Photo").tag(GenerationMode.textOnly)
            //Text("Картинка").tag(GenerationMode.imageOnly)
            Text("Use Photo").tag(GenerationMode.textAndImage)
        }
        .pickerStyle(.segmented)
        .background(
            RoundedRectangle(cornerRadius: 22) // Увеличиваем скругление
                .fill(Color.gray.opacity(0.2)) // Фон
        )
        .clipShape(RoundedRectangle(cornerRadius: 22)) // Обрезаем края
        .padding(.bottom, 18)
        .onChange(of: mode) { oldValue, _ in
            generator.generatedImage = nil
        }
    }
    
    private var textInputSection: some View {
        VStack {
            Text("Enter Promt")
                .urbanist(.montserratMedium, 19)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(.appWhite)
            
            ZStack {
                TextField("", text: $prompt,
                          prompt: Text(placeholderString).foregroundColor(.appWhite.opacity(0.2)),
                          axis: .vertical)
                .padding(12)
                .textFieldStyle(.plain)
                .foregroundStyle(.appWhite.opacity(0.8))
                .background(.appWhite.opacity(0.05))
                .lineLimit(8...10)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
    }
    
    private var imageUploadSection: some View {
        VStack {
            if let inputImage = generator.inputImage {
                Image(uiImage: inputImage)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: 212)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .clipped()
                    .overlay(alignment: .topTrailing) {
                        Button {
                            generator.inputImage = nil
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.appBlack)
                                .padding(8)
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
        .frame(maxWidth: .infinity, minHeight: 212, maxHeight: 212)
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
                Text("Сгенерировать")
                    .urbanist(.montserratMedium, 16)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                    .foregroundStyle(.appWhite)
                    .background(.appWhite.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            }
        }
        .disabled(generator.isLoading || prompt.isEmpty)
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
