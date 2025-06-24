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
            .frame(maxWidth: .infinity)
            .padding(.bottom, 36)
            .font(.system(size: 16, weight: .medium))
            .multilineTextAlignment(.center)
            .foregroundColor(.appWhite)
    }
}
