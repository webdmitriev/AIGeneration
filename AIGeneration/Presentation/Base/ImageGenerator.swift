//
//  ImageGenerator.swift
//  AIGeneration
//
//  Created by Олег Дмитриев on 28.06.2025.
//

import UIKit
import SwiftUI
import AVKit

struct VideoGenerationResponse: Codable {
    let id: String?
    let status: String?
}

@MainActor
final class ImageGenerator: ObservableObject {
    // MARK: - Публичные свойства
    @Published var generatedImage: UIImage?
    @Published var isLoading = false
    @Published var error: String?
    @Published var inputImage: UIImage?
    
    // MARK: - For video
    @Published var generatedVideoURL: URL?
    @Published var isVideoGenerating = false
    @Published var videoPlayer: AVPlayer?
    
    // MARK: - Приватные свойства
    private var checkStatusTask: Task<Void, Error>?
    private let env = Env()
    private var defaultHeaders: [String: String] {
        [
            "Accept": "application/json",
            "Authorization": "Bearer \(env.get("API_KEY") ?? "NO_KEY")"
        ]
    }
    
    // MARK: - Основной метод генерации
    func generate(prompt: String, mode: GenerationMode) async {
        await resetState()
        await setLoading(true)
        
        do {
            switch mode {
            case .textOnly:
                try await generateFromText(prompt)
            case .imageOnly:
                try await generateFromImage()
            case .textAndImage:
                try await generateFromTextAndImage(prompt)
            }
        } catch {
            await handleError(error)
        }
        
        await setLoading(false)
    }
    
    // MARK: - Video Generation
    func generateVideo(from image: UIImage, prompt: String) async {
        guard let apiKey = env.get("API_KEY"), apiKey != "NO_KEY" else {
            await updateError("API Key not found")
            return
        }
        
        // 1. Жёсткий ресайз без сохранения пропорций
        guard let resizedImage = prepareStrictSizeImage(image) else {
            await updateError("Image processing failed")
            return
        }
        
        // 2. Проверка перед отправкой (критически важно)
        print("Final image size: \(resizedImage.size)")
        assert(
            resizedImage.size == CGSize(width: 1024, height: 576) ||
            resizedImage.size == CGSize(width: 576, height: 1024) ||
            resizedImage.size == CGSize(width: 768, height: 768),
            "Invalid image dimensions after resizing"
        )
        
        await setVideoGenerating(true)
        await resetVideoState()

        do {
            // 3. Создание запроса
            let boundary = UUID().uuidString
            var request = URLRequest(url: URL(string: "https://api.stability.ai/v2beta/image-to-video")!)
            request.httpMethod = "POST"
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
            
            // 4. Подготовка тела запроса
            var body = Data()
            
            // Добавляем изображение
            if let imageData = resizedImage.jpegData(compressionQuality: 0.85) {
                body.append("--\(boundary)\r\n".data(using: .utf8)!)
                body.append("Content-Disposition: form-data; name=\"image\"; filename=\"input.jpg\"\r\n".data(using: .utf8)!)
                body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
                body.append(imageData)
                body.append("\r\n".data(using: .utf8)!)
            }
            
            // Добавляем промпт
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"prompt\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(prompt)\r\n".data(using: .utf8)!)
            
            body.append("--\(boundary)--\r\n".data(using: .utf8)!)
            request.httpBody = body
            
            // 5. Отправка запроса
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw GenerationError.invalidResponse
            }
            
            print("Status code: \(httpResponse.statusCode)")
            let responseString = String(data: data, encoding: .utf8) ?? "Empty response"
            print("Response: \(responseString)")
            
            guard httpResponse.statusCode == 200 else {
                throw GenerationError.apiError(message: httpResponse.statusCode.description)
            }
            
            let decodedResponse = try JSONDecoder().decode(VideoGenerationResponse.self, from: data)
            guard let generationId = decodedResponse.id else {
                throw GenerationError.apiError(message: "No generation ID in response")
            }
            
            try await checkVideoGenerationStatus(id: generationId)
            
        } catch {
            await handleError(error)
            print("Video generation failed: \(error)")
        }
        
        await setVideoGenerating(false)
    }

//    private func checkVideoGenerationStatus(id: String) async throws {
//        guard let apiKey = env.get("API_KEY"), apiKey != "NO_KEY" else {
//            throw GenerationError.invalidResponse
//        }
//
//        let endpoint = "https://api.stability.ai/v2beta/image-to-video/result/\(id)"
//        var request = URLRequest(url: URL(string: endpoint)!)
//        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
//        request.setValue("video/*", forHTTPHeaderField: "Accept")
//
//        let (data, response) = try await URLSession.shared.data(for: request)
//
//        if let httpResponse = response as? HTTPURLResponse {
//            print("Status code: \(httpResponse.statusCode)")
//        }
//        print("Raw data length:", data.count)
//
//        // Сохраняем полученные бинарные данные как видеофайл
//        if let videoURL = saveVideoToTempFile(data) {
//            await MainActor.run {
//                self.generatedVideoURL = videoURL
//                self.videoPlayer = AVPlayer(url: videoURL)
//            }
//        } else {
//            await updateError("Failed to save video file")
//        }
//    }
    
    func checkVideoGenerationStatus(id: String) async throws {
        guard let apiKey = env.get("API_KEY"), apiKey != "NO_KEY" else {
            throw GenerationError.invalidResponse
        }
        let endpoint = "https://api.stability.ai/v2beta/image-to-video/result/\(id)"
        var request = URLRequest(url: URL(string: endpoint)!)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        // Отменяем предыдущую задачу проверки
        checkStatusTask?.cancel()
        
        checkStatusTask = Task {
            while !Task.isCancelled {
                let (data, response) = try await URLSession.shared.data(for: request)
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw GenerationError.invalidResponse
                }
                
                print("Status check: \(httpResponse.statusCode)")
                
                switch httpResponse.statusCode {
                case 200: // Видео готово
                    let tempURL = saveVideoToTempFile(data)
                    await MainActor.run {
                        self.generatedVideoURL = tempURL
                        self.videoPlayer = AVPlayer(url: tempURL!)
                    }
                    return
                    
                case 202: // Генерация еще в процессе
                    print("Video is being generated, waiting...")
                    try await Task.sleep(nanoseconds: 3_000_000_000) // Ждем 3 секунды
                    continue
                    
                default:
                    throw GenerationError.apiError(message: httpResponse.statusCode.description)
                }
            }
        }
        
        try await checkStatusTask?.value
    }
    
    private func saveVideoToTempFile(_ data: Data) -> URL? {
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent("generated-video-\(UUID().uuidString).mp4")
        
        do {
            try data.write(to: fileURL)
            return fileURL
        } catch {
            print("Failed to save video: \(error)")
            return nil
        }
    }
    
    @MainActor
    private func updateError(_ message: String) async {
        self.error = message
    }

    @MainActor
    private func setVideoGenerating(_ value: Bool) async {
        self.isVideoGenerating = value
    }

    @MainActor
    private func resetVideoState() async {
        self.generatedVideoURL = nil
        self.videoPlayer = nil
    }

    @MainActor
    private func setLoading(_ value: Bool) {
        self.isLoading = value
        if value {
            self.error = nil
        }
    }

    @MainActor
    private func resetState() {
        self.generatedImage = nil
        self.error = nil
        self.inputImage = nil
    }
    
    private func prepareStrictSizeImage(_ image: UIImage) -> UIImage? {
        // Жёсткое приведение к одному из допустимых размеров
        let targetSize: CGSize
        
        let aspectRatio = image.size.width / image.size.height
        if aspectRatio > 1.5 {
            targetSize = CGSize(width: 1024, height: 576) // Горизонтальное
        } else if aspectRatio < 0.67 {
            targetSize = CGSize(width: 576, height: 1024) // Вертикальное
        } else {
            targetSize = CGSize(width: 768, height: 768) // Квадратное
        }
        
        print("Original size: \(image.size) -> Converting to: \(targetSize)")
        
        UIGraphicsBeginImageContextWithOptions(targetSize, true, 1.0)
        image.draw(in: CGRect(origin: .zero, size: targetSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    deinit {
        checkStatusTask?.cancel()
    }
}

// MARK: - Режимы генерации
extension ImageGenerator {
    private func generateFromText(_ prompt: String) async throws {
        let endpoint = "https://api.stability.ai/v1/generation/stable-diffusion-v1-6/text-to-image"
        let body: [String: Any] = [
            "text_prompts": [["text": prompt, "weight": 1.0]],
            "cfg_scale": 7,
            "height": 512,
            "width": 512,
            "steps": 30,
            "samples": 1
        ]
        try await sendRequest(to: endpoint, body: body)
    }
    
    private func generateFromImage() async throws {
        guard let inputImage = inputImage else {
            throw GenerationError.missingInputImage
        }
        let endpoint = "https://api.stability.ai/v1/generation/stable-diffusion-v1-6/image-to-image"
        try await styleImage(inputImage, prompt: nil, endpoint: endpoint)
    }
    
    private func generateFromTextAndImage(_ prompt: String) async throws {
        guard let inputImage = inputImage else {
            throw GenerationError.missingInputImage
        }
        let endpoint = "https://api.stability.ai/v1/generation/stable-diffusion-v1-6/image-to-image"
        try await styleImage(inputImage, prompt: prompt, endpoint: endpoint)
    }
}

// MARK: - Сетевые запросы
extension ImageGenerator {
    private func sendRequest(to endpoint: String, body: [String: Any]) async throws {
        guard let url = URL(string: endpoint) else {
            throw GenerationError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = defaultHeaders
        
        // Кодируем тело запроса
        let jsonData = try JSONSerialization.data(withJSONObject: body, options: [])
        request.httpBody = jsonData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Отправка запроса
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Проверка статус-кода
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw try handleAPIError(data: data)
        }
        
        // Декодирование ответа
        let apiResponse = try JSONDecoder().decode(StabilityAIResponse.self, from: data)
        try await processAPIResponse(apiResponse)
    }
    
    private func styleImage(_ image: UIImage, prompt: String?, endpoint: String) async throws {
        guard let url = URL(string: endpoint) else {
            throw GenerationError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = defaultHeaders
        
        // Подготовка multipart/form-data
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        // Добавляем изображение
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"init_image\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: .utf8)!)
        }
        
        // Добавляем текстовый промпт (если есть)
        if let prompt = prompt {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"text_prompts[0][text]\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(prompt)\r\n".data(using: .utf8)!)
        }
        
        // Параметры стилизации
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image_strength\"\r\n\r\n".data(using: .utf8)!)
        body.append("0.35\r\n".data(using: .utf8)!) // Сила влияния исходного изображения
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body
        
        // Отправка запроса
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Проверка ответа
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw try handleAPIError(data: data)
        }
        
        // Декодирование ответа
        let apiResponse = try JSONDecoder().decode(StabilityAIResponse.self, from: data)
        try await processAPIResponse(apiResponse)
    }
}

// MARK: - Обработка ответов
extension ImageGenerator {
    private func processAPIResponse(_ response: StabilityAIResponse) async throws {
        guard let artifact = response.artifacts?.first else {
            throw GenerationError.emptyResponse
        }
        
        if let base64String = artifact.base64,
           let imageData = Data(base64Encoded: base64String),
           let image = UIImage(data: imageData) {
            await updateImage(image)
        } else {
            throw GenerationError.invalidImageData
        }
    }
    
    private func handleAPIError(data: Data) throws -> GenerationError {
        if let apiError = try? JSONDecoder().decode(StabilityAPIError.self, from: data) {
            return .apiError(message: apiError.message)
        }
        return .unknownError
    }
}

// MARK: - Вспомогательные методы
extension ImageGenerator {
    private func resetState() async {
        await MainActor.run {
            generatedImage = nil
            error = nil
        }
    }
    
    private func setLoading(_ value: Bool) async {
        await MainActor.run {
            isLoading = value
        }
    }
    
    private func updateImage(_ image: UIImage?) async {
        await MainActor.run {
            generatedImage = image
        }
    }
    
    private func handleError(_ error: Error) async {
        await MainActor.run {
            if let genError = error as? GenerationError {
                switch genError {
                case .invalidResponse:
                    self.error = "Invalid response from server."
                case .networkError:
                    self.error = "Network error. Please try again."
                case .unknown:
                    self.error = "Unknown error occurred."
                case .invalidURL:
                    self.error = "Invalid URL provided."
                case .missingInputImage:
                    self.error = "Missing input image."
                case .emptyResponse:
                    self.error = "Empty response from server."
                case .invalidImageData:
                    self.error = "Invalid image data returned."
                case .apiError(message: let message):
                    self.error = message
                case .unknownError:
                    self.error = "Unknown error occurred."
                }
            } else {
                self.error = error.localizedDescription
            }
            print("Generation failed: \(error)")
        }
    }
}

// MARK: - Изменяем размер изображения (для video)
extension ImageGenerator {
    private func prepareImageForVideo(_ image: UIImage) -> UIImage? {
        // 1. Определяем ориентацию изображения
        let isLandscape = image.size.width > image.size.height
        let isPortrait = image.size.height > image.size.width
        _ = image.size.width == image.size.height
        
        // 2. Выбираем целевой размер
        let targetSize: CGSize
        if isLandscape {
            targetSize = CGSize(width: 1024, height: 576)
        } else if isPortrait {
            targetSize = CGSize(width: 576, height: 1024)
        } else {
            targetSize = CGSize(width: 768, height: 768)
        }
        
        // 3. Масштабирование с сохранением пропорций
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        let resizedImage = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
        
        // 4. Проверка результата
        print("Resized to: \(resizedImage.size)") // Должно вывести 1024x576, 576x1024 или 768x768
        return resizedImage
    }
}
