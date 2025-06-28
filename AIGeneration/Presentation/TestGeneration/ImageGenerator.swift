//
//  ImageGenerator.swift
//  AIGeneration
//
//  Created by Олег Дмитриев on 28.06.2025.
//

import UIKit
import SwiftUI

@MainActor
final class ImageGenerator: ObservableObject {
    // MARK: - Публичные свойства
    @Published var generatedImage: UIImage?
    @Published var isLoading = false
    @Published var error: String?
    @Published var inputImage: UIImage?
    
    // MARK: - Приватные свойства
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
            if let generationError = error as? GenerationError {
                self.error = generationError.localizedDescription
            } else {
                self.error = error.localizedDescription
            }
            print("Generation failed: \(error)")
        }
    }
}

// MARK: - Модели данных
struct StabilityAIResponse: Codable {
    struct Artifact: Codable {
        let base64: String?
    }
    let artifacts: [Artifact]?
}

struct StabilityAPIError: Codable {
    let message: String
}

enum GenerationMode {
    case textOnly
    case imageOnly
    case textAndImage
}

enum GenerationError: LocalizedError {
    case invalidURL
    case missingInputImage
    case emptyResponse
    case invalidImageData
    case apiError(message: String)
    case unknownError
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Неверный URL запроса"
        case .missingInputImage: return "Загрузите изображение"
        case .emptyResponse: return "Пустой ответ от сервера"
        case .invalidImageData: return "Невозможно создать изображение"
        case .apiError(let message): return message
        case .unknownError: return "Неизвестная ошибка"
        }
    }
}
