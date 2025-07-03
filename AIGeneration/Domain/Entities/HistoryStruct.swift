//
//  HistoryStruct.swift
//  AIGeneration
//
//  Created by Олег Дмитриев on 03.07.2025.
//

import Foundation

struct HistoryItem: Identifiable, Codable {
    let id: UUID
    let date: Date
    let prompt: String?
    let imageData: Data
}
