//
//  ScreenTitle.swift
//  AIGeneration
//
//  Created by Олег Дмитриев on 24.06.2025.
//

import SwiftUI

struct ScreenTitle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .urbanist(.montserratBold, 24)
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundColor(.appWhite)
    }
}
