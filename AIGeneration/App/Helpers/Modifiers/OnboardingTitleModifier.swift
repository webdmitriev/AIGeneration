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
            .frame(maxWidth: .infinity)
            .padding(.bottom, 18)
            .font(.system(size: 30, weight: .bold))
            .multilineTextAlignment(.center)
            .foregroundColor(.appWhite)
    }
}
