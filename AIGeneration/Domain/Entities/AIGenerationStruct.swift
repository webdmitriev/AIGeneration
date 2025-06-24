//
//  AIGenerationStruct.swift
//  AIGeneration
//
//  Created by Олег Дмитриев on 24.06.2025.
//

import Foundation

struct AIGenerationStruct: Hashable {
    let id = UUID().description
    let aIGenerationItemStruct: [AIGenerationItemStruct]
    
    static func mockData() -> [AIGenerationItemStruct] {
        [
            AIGenerationItemStruct(title: "Magic",
                                   image: "ai-generation-item-image-01",
                                   category: ["Magic"]),
            AIGenerationItemStruct(title: "Fun-tastic Mermaid",
                                   image: "ai-generation-item-image-01",
                                   category: ["Fun-tastic Mermaid"]),
            AIGenerationItemStruct(title: "Space",
                                   image: "ai-generation-item-image-01",
                                   category: ["Space"]),
            AIGenerationItemStruct(title: "Cartoon",
                                   image: "ai-generation-item-image-01",
                                   category: ["Cartoon"]),
            AIGenerationItemStruct(title: "Space",
                                   image: "ai-generation-item-image-01",
                                   category: ["Space"]),
            AIGenerationItemStruct(title: "Anime",
                                   image: "ai-generation-item-image-01",
                                   category: ["Anime"]),
            AIGenerationItemStruct(title: "Voxel art",
                                   image: "ai-generation-item-image-01",
                                   category: ["Voxel art"])
        ]
    }
}

struct AIGenerationItemStruct: Hashable {
    let id = UUID().description
    let title: String
    let image: String
    let category: [String]
}
