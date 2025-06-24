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
            .frame(minHeight: 28)
            .padding(.horizontal, 18)
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(.appWhite)
            .background(.appWhite.opacity(0.3))
            .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
