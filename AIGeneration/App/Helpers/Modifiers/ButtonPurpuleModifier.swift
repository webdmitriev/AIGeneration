//
//  ButtonPurpuleModifier.swift
//  AIGeneration
//
//  Created by Олег Дмитриев on 24.06.2025.
//

import SwiftUI

struct ButtonPurpuleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .urbanist(.urbanistMedium, 16)
            .frame(maxWidth: .infinity, minHeight: 62)
            .foregroundColor(.appWhite)
            .background(.appPurpule)
            .clipShape(RoundedRectangle(cornerRadius: 31))
    }
}
