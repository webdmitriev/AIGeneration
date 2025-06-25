//
//  OnboardingDescrModifier.swift
//  AIGeneration
//
//  Created by Олег Дмитриев on 24.06.2025.
//

import SwiftUI

struct OnboardingDescrModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .urbanist(.montserratMedium, 16)
            .frame(maxWidth: .infinity)
            .padding(.bottom, 36)
            .multilineTextAlignment(.center)
            .foregroundColor(.appWhite)
    }
}
