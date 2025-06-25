//
//  HomeViewModel.swift
//  AIGeneration
//
//  Created by Олег Дмитриев on 24.06.2025.
//

import SwiftUI

final class HomeViewModel: ObservableObject {
    @Published var selectedCategory: String?
    @Published private(set) var items = AIGenerationStruct.mockData()
    
    var categories: [String] {
        Array(Set(items.flatMap { $0.category })).sorted()
    }
    
    var filteredItems: [AIGenerationItemStruct] {
        if let selectedCategory {
            return items.filter { $0.category.contains(selectedCategory) }
        }
        
        return items
    }
    
    func selectCategory(_ category: String) {
        withAnimation {
            selectedCategory = (selectedCategory == category) ? nil : category
        }
    }
    
}
