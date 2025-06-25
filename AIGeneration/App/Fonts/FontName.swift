//
//  FontName.swift
//  AIGeneration
//
//  Created by Олег Дмитриев on 25.06.2025.
//

import SwiftUI

enum FontName: String {
    case urbanistRegular = "Urbanist-Regular"
    case urbanistMedium = "Urbanist-Medium"
    case urbanistBold = "Urbanist-Bold"
    case urbanistBlack = "Urbanist-Black"
}

extension View {
    func urbanist(_ fontName: FontName, _ size: CGFloat = 14) -> some View {
        font(Font.custom(fontName.rawValue, size: size))
    }
}
