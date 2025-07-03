//
//  HistoryViewModel.swift
//  AIGeneration
//
//  Created by Олег Дмитриев on 28.06.2025.
//

import SwiftUI

final class HistoryViewModel: ObservableObject {
    @Published private(set) var items = AIGenerationStruct.mockData()
    
}

