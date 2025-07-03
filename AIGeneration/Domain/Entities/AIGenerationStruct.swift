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
            AIGenerationItemStruct(title: "Harry Potter",
                                   descr: "Make a picture in the style of harry potter",
                                   image: "ai-generation-cat-01",
                                   category: ["Magic"]),
            AIGenerationItemStruct(title: "Samurai Style",
                                   descr: "Make a picture in samurai style",
                                   image: "ai-generation-cat-02",
                                   category: ["Samurai"]),
            AIGenerationItemStruct(title: "Anime and Magic",
                                   descr: "Make a picture in the style of magic and anime",
                                   image: "ai-generation-cat-03",
                                   category: ["Anime", "Magic"]),
            AIGenerationItemStruct(title: "Space",
                                   descr: "Make a picture in space style",
                                   image: "ai-generation-cat-04",
                                   category: ["Space"]),
            AIGenerationItemStruct(title: "Portrait",
                                   descr: "Make a picture in portrait style",
                                   image: "ai-generation-cat-05",
                                   category: ["Portrait"]),
            AIGenerationItemStruct(title: "AI Forest",
                                   descr: "Make a picture in the style of a forest",
                                   image: "ai-generation-cat-06",
                                   category: ["AI Forest"]),
            AIGenerationItemStruct(title: "Memes",
                                   descr: "Make a picture in memes style",
                                   image: "ai-generation-cat-07",
                                   category: ["Memes"])
        ]
    }
}

struct AIGenerationItemStruct: Hashable {
    let id = UUID().description
    let title: String
    let descr: String
    let image: String
    let category: [String]
}
