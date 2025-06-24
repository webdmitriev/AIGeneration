//
//  OnboardingViewModel.swift
//  AIGeneration
//
//  Created by Олег Дмитриев on 24.06.2025.
//

import SwiftUI
import Combine

final class OnboardingViewModel: ObservableObject {
    @Published var currentPageIndex: Int = 0
    @Published var isLastPage: Bool = false
    @Published private(set) var items: [OnboardingStruct] = OnboardingStruct.mockData()
    
    private var cancellables = Set<AnyCancellable>()
    
    var currentPage: OnboardingStruct {
        items[currentPageIndex]
    }
    
    var progress: CGFloat {
        CGFloat(currentPageIndex + 1) / CGFloat(items.count)
    }
    
    init() {
        setupBinding()
    }
    
    func next() {
        guard currentPageIndex < items.count - 1 else { return }
        currentPageIndex += 1
    }
    
    func skip() {
        currentPageIndex = items.count - 1
    }
    
    private func setupBinding() {
        $currentPageIndex
            .map { $0 == self.items.count - 1 }
            .assign(to: \.isLastPage, on: self)
            .store(in: &cancellables)
    }
    
}
