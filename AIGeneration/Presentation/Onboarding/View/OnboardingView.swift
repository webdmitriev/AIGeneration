//
//  OnboardingView.swift
//  AIGeneration
//
//  Created by Олег Дмитриев on 24.06.2025.
//

import SwiftUI

struct OnboardingView: View {
    @StateObject var appState = AppState()
    @StateObject private var viewModel = OnboardingViewModel()

    @State private var showHomeView = false
    @State private var currentOpacity: Double = 1
    
    var body: some View {
        Group {
            if showHomeView {
                CustomTabBar()
                    .environmentObject(appState)
            } else {
                content
            }
        }
    }
    
    private var content: some View {
        TabView(selection: $viewModel.currentPageIndex) {
            ForEach(Array(viewModel.items.enumerated()), id: \.element.id) { idx, item in
                ZStack(alignment: .bottom) {
                    Image(item.image)
                        .resizable()
                        .edgesIgnoringSafeArea(.all)
                        .scaledToFill()
                        .frame(width: UIScreen.main.bounds.width)
                    
                    VStack {
                        Text(item.title)
                            .modifier(OnboardingTitleModifier())
                        
                        Text(item.descr)
                            .modifier(OnboardingDescrModifier())
                        
                        if !viewModel.isLastPage {
                            Button(viewModel.isLastPage ? "Get Started" : "Next") {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    currentOpacity = 0.0
                                    viewModel.next()
                                    currentOpacity = 1.0
                                }
                            }
                            .modifier(ButtonPurpuleModifier())
                        } else {
                            Button("Get Started") {
                                withAnimation {
                                    UserDefaults.standard.set(true,
                                                              forKey: "hasCompletedOnboarding")
                                    showHomeView = true
                                }
                            }
                            .modifier(ButtonPurpuleModifier())
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 28)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 51)
                    .background(.appBlack)
                    .clipShape(
                        .rect(
                            topLeadingRadius: 20,
                            bottomLeadingRadius: 0,
                            bottomTrailingRadius: 0,
                            topTrailingRadius: 20
                        )
                    )
                }
                .tag(idx)
                .opacity(currentOpacity)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .edgesIgnoringSafeArea(.all)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.appBlack)
    }
}

#Preview {
    OnboardingView()
}
