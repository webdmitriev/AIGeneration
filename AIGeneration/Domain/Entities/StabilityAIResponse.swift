//
//  StabilityAIResponse.swift
//  AIGeneration
//
//  Created by Олег Дмитриев on 28.06.2025.
//

import Foundation

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
