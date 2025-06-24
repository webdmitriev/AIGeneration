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
            .frame(maxWidth: .infinity, minHeight: 62)
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(.appWhite)
            .background(.appPurpule)
            .clipShape(RoundedRectangle(cornerRadius: 31))
    }
}
