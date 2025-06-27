//
//  SubscribeViewModel.swift
//  AIGeneration
//
//  Created by Олег Дмитриев on 27.06.2025.
//

import SwiftUI

final class SubscribeViewModel: ObservableObject {
    @Published var premiumItems: PremiumVersionStruct = PremiumVersionStruct.mockData()
    @Published var selectedItemId: UUID?

    init() {
        if let first = premiumItems.items.first {
            selectedItemId = first.id
        }
    }
    
}
