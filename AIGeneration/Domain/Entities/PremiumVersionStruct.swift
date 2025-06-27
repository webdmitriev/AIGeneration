//
//  PremiumVersionStruct.swift
//  AIGeneration
//
//  Created by Олег Дмитриев on 27.06.2025.
//

import Foundation

struct PremiumVersionStruct: Hashable {
    let titleWhite: String
    let titleGradient: String
    let descr: String
    let items: [PremiumVersionItemStruct]
    
    static func mockData() -> PremiumVersionStruct {
        PremiumVersionStruct(titleWhite: "Try", titleGradient: "Premium version",
                             descr: "Video and photo generation, hot templates and more are already waiting for you!",
                             items: [
                                PremiumVersionItemStruct(title: "Weekly", descr: "Just $9.99 per month", price: "$9.99", when: "right now", isActive: true),
                                PremiumVersionItemStruct(title: "Yearly", descr: "Just $99.99 per year", price: "$8.33", when: "per month", isActive: false)
        ])
    }
}

struct PremiumVersionItemStruct: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let descr: String
    let price: String
    let when: String
    var isActive: Bool
}
