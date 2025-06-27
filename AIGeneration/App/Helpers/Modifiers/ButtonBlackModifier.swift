//
//  ButtonBlackModifier.swift
//  AIGeneration
//
//  Created by Олег Дмитриев on 27.06.2025.
//

import SwiftUI

struct ButtonBlackModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .urbanist(.montserratMedium, 16)
            .frame(maxWidth: .infinity, minHeight: 62)
            .foregroundColor(.appWhite)
            .background(.appWhite.opacity(0.03))
            .clipShape(RoundedRectangle(cornerRadius: 31))
    }
}
