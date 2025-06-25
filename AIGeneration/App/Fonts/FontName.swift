//
//  FontName.swift
//  AIGeneration
//
//  Created by Олег Дмитриев on 25.06.2025.
//

import SwiftUI

enum FontName: String {
    case urbanistMedium = "Urbanist-Medium"
    case montserratMedium = "Montserrat-Medium"
    case montserratBold = "Montserrat-Bold"
    
}

extension View {
    func urbanist(_ fontName: FontName, _ size: CGFloat = 14) -> some View {
        font(Font.custom(fontName.rawValue, size: size))
    }
}
