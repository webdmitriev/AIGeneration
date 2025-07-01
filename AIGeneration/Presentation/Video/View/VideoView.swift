//
//  VideoView.swift
//  AIGeneration
//
//  Created by Олег Дмитриев on 28.06.2025.
//

import SwiftUI
import AVKit
import PhotosUI

struct VideoView: View {
    @ObservedObject var generator: ImageGenerator
    @EnvironmentObject var appState: AppState

    @State private var prompt: String = ""
    @State private var selectedItem: PhotosPickerItem?
    @State private var showingErrorAlert = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Image to Video")
                        .font(.title)
                        .bold()

                    // MARK: - Image Picker
                    PhotosPicker(
                        selection: $selectedItem,
                        matching: .images,
                        photoLibrary: .shared()) {
                        HStack {
                            Image(systemName: "photo.on.rectangle.angled")
                            Text(generator.inputImage == nil ? "Select Image" : "Change Image")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .onChange(of: selectedItem) { oldValue, newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self),
                               let uiImage = UIImage(data: data) {
                                await MainActor.run {
                                    generator.inputImage = uiImage
                                }
                            }
                        }
                    }

                    // MARK: - Selected Image Preview
                    if let inputImage = generator.inputImage {
                        Image(uiImage: inputImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .cornerRadius(12)
                            .shadow(radius: 4)
                            .padding(.horizontal)
                    }

                    // MARK: - Prompt Input
                    TextField("Enter prompt...", text: $prompt)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)

                    // MARK: - Generate Button
                    Button(action: {
                        Task {
                            await generateVideo()
                        }
                    }) {
                        if generator.isVideoGenerating {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .padding()
                        } else {
                            Text("Generate Video")
                                .fontWeight(.semibold)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                    .disabled(generator.isVideoGenerating || generator.inputImage == nil || prompt.isEmpty)
                    .padding(.horizontal)

                    // MARK: - Result Video Player
                    if generator.generatedVideoURL != nil {
                        Text("Generated Video")
                            .font(.headline)
                            .padding(.top)

                        VideoPlayer(player: generator.videoPlayer)
                            .frame(height: 300)
                            .cornerRadius(12)
                            .padding()
                    }

                    Spacer()
                    
                    // MARK: - Status Information
                    if generator.isVideoGenerating {
                        VStack {
                            ProgressView("Generating video...")
                                .padding(.bottom, 4)
                            
                            Text("This may take 1-2 minutes")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // MARK: - Result Video Player
                    if let player = generator.videoPlayer {
                        Text("Generated Video")
                            .font(.headline)
                            .padding(.top)
                        
                        VideoPlayer(player: player)
                            .frame(height: 300)
                            .cornerRadius(12)
                            .padding()
                            .onAppear {
                                player.play()
                            }
                        
                        Button(action: saveVideoToGallery) {
                            Label("Save to Photos", systemImage: "square.and.arrow.down")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .padding(.horizontal)
                    }
                }
                .padding()
            }
            .alert(isPresented: $showingErrorAlert) {
                Alert(title: Text("Error"),
                      message: Text(generator.error ?? "Unknown error"),
                      dismissButton: .default(Text("OK")))
            }
            .onReceive(generator.$error) { newError in
                if newError != nil {
                    showingErrorAlert = true
                }
            }
        }
    }

    private func generateVideo() async {
        guard let inputImage = generator.inputImage else {
            generator.error = "Please select an image first."
            return
        }
        
        guard !prompt.isEmpty else {
            generator.error = "Please enter a prompt."
            return
        }
        
        await generator.generateVideo(from: inputImage, prompt: prompt)
        
        // Автоматическое воспроизведение после генерации
        if let player = generator.videoPlayer {
            player.play()
        }
    }
    
    private func saveVideoToGallery() {
        guard let url = generator.generatedVideoURL else { return }
        
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
        }) { success, error in
            DispatchQueue.main.async {
                if success {
                    generator.error = "Video saved to Photos!"
                } else {
                    generator.error = error?.localizedDescription ?? "Failed to save video"
                }
            }
        }
    }
}
