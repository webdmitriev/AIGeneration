//
//  CategoryButtonModifier.swift
//  AIGeneration
//
//  Created by Олег Дмитриев on 24.06.2025.
//

import SwiftUI

struct CategoryButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .urbanist(.urbanistMedium, 14)
            .frame(minHeight: 28)
            .padding(.horizontal, 18)
            .foregroundColor(.appWhite)
            .background(.appWhite.opacity(0.3))
            .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
