//
//  OnboardingTitleModifier.swift
//  AIGeneration
//
//  Created by Олег Дмитриев on 24.06.2025.
//

import SwiftUI

struct OnboardingTitleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .urbanist(.urbanistBlack, 30)
            .frame(maxWidth: .infinity)
            .padding(.bottom, 18)
            .multilineTextAlignment(.center)
            .foregroundColor(.appWhite)
    }
}
