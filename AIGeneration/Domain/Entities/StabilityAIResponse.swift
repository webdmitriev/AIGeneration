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
    case invalidResponse
    case networkError
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Неверный URL запроса"
        case .missingInputImage: return "Загрузите изображение"
        case .emptyResponse: return "Пустой ответ от сервера"
        case .invalidImageData: return "Невозможно создать изображение"
        case .apiError(let message): return message
        case .unknownError: return "Неизвестная ошибка"
        case .invalidResponse: return "invalidResponse"
        case .networkError: return "networkError"
        case .unknown: return "unknown"
        }
    }
}

enum GenerationSurprice {
    case one
    case two
    case three
    case four
    case five
    case six
    case seven
    case eight
    case nine
    case ten
    
    var surpriceText: String {
        switch self {
        case .one:
            "A fluffy ginger cat napping in a hammock between palm trees on Boracay Beach, sunset sky, tropical watercolor style"
        case .two:
            "A striped grey cat sailing on a Philippine bangka boat, turquoise ocean, traditional Filipino woodcut art style"
        case .three:
            "A cat wearing a sarong hat sitting on a balcony in Manila, neon signs, rainy night, cyberpunk aesthetic"
        case .four:
            "A white cat meditating in front of Mayon Volcano’s perfect cone, pastel colors, Studio Ghibli-inspired"
        case .five:
            "A playful kitten hiding in a basket of mangoes and pineapples at a Filipino wet market, vibrant colors, detailed illustration"
        case .six:
            "A cat dressed as a Sinulog dancer with feathered costume, dynamic motion, festival lights, digital painting"
        case .seven:
            "A mermaid cat exploring Philippine coral reefs with parrotfish, fantasy realism, glowing scales"
        case .eight:
            "A black cat with lantern-like eyes in a lively Peryahan night market, atmospheric lighting, Ghibli-esque"
        case .nine:
            "A farmer cat resting on Banaue Rice Terraces, misty green hills, realistic watercolor texture"
        case .ten:
            "A cat transformed into the Filipino dragon Bakunawa, fiery tail, epic stormy sky, Warcraft-style digital art"
        }
    }
}

extension GenerationSurprice {
    static func random() -> GenerationSurprice {
        let allCases: [GenerationSurprice] = [.one, .two, .three, .four, .five,
                                            .six, .seven, .eight, .nine, .ten]
        return allCases.randomElement()!
    }
}
