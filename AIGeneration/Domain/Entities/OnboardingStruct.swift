//
//  OnboardingStruct.swift
//  AIGeneration
//
//  Created by Олег Дмитриев on 24.06.2025.
//

import Foundation

struct OnboardingStruct: Hashable {
    let id = UUID().description
    let title: String
    let descr: String
    let image: String
    
    static func mockData() -> [OnboardingStruct] {
        [
            OnboardingStruct(title: "Create with AI",
                             descr: "Generate with text promts, photo and video uploads",
                             image: "onboarding-01.1"),
            OnboardingStruct(title: "Have fun",
                             descr: "Make funny videos and share with your friends.",
                             image: "onboarding-02"),
            OnboardingStruct(title: "Be on Trend",
                             descr: "Lots of trending templates for your social networks",
                             image: "onboarding-03")
        ]
    }
}
