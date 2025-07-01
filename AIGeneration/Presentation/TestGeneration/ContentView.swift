//
//  ContentView.swift
//  AIGeneration
//
//  Created by Олег Дмитриев on 28.06.2025.
//

import SwiftUI
import PhotosUI

struct ContentView: View {
    @StateObject private var generator = ImageGenerator()
    @State private var prompt: String = ""
    @State private var mode: GenerationMode = .imageOnly
    @State private var showImagePicker = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Шапка с выбором режима
                modePickerSection
                
                // Поле ввода текста (скрыто в режиме imageOnly)
                if mode != .imageOnly {
                    textInputSection
                }
                
                // Кнопка генерации
                generateButton
                
                // Результат или состояние загрузки
                resultSection
                
                Spacer()
            }
            .padding()
            .navigationTitle("AI Генератор")
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $generator.inputImage)
            }
        }
    }
    
    // MARK: - Компоненты интерфейса
    private var modePickerSection: some View {
        Picker("Режим генерации", selection: $mode) {
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
        .disabled(generator.isLoading || (mode != .imageOnly && generator.inputImage == nil))
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

