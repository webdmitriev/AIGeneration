//
//  StabilityAIResponse.swift
//  AIGeneration
//
//  Created by Олег Дмитриев on 28.06.2025.
//

import Foundation

struct GenerationRequest: Codable {
    struct TextPrompt: Codable {
        let text: String
        let weight: Float
    }
    
    let text_prompts: [TextPrompt]
    let cfg_scale: Int
    let height: Int
    let width: Int
    let steps: Int
}
