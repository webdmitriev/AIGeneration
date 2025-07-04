//
//  HomeView.swift
//  AIGeneration
//
//  Created by Олег Дмитриев on 24.06.2025.
//

import SwiftUI

struct HomeView: View {
    @StateObject var generator: ImageGenerator
    @StateObject private var viewModel = HomeViewModel()
    
    @State private var scrollOffset: CGFloat = 0
    @State private var isTopBarVisible: Bool = true
    @State private var showSubscribeView = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                CustomTopBar(title: "Main") {
                    showSubscribeView = true
                }
                .frame(height: isTopBarVisible ? 40 : 0)
                .clipped()
                .opacity(isTopBarVisible ? 1 : 0)
                .animation(.easeInOut(duration: 0.3), value: isTopBarVisible)
                
                categoryScrollView
                    .animation(.easeInOut(duration: 0.3), value: isTopBarVisible)
                
                contentCardsView
            }
            .navigationDestination(isPresented: $showSubscribeView) {
                SubscribeView()
            }
            .frame(maxHeight: .infinity)
            .padding(.bottom, 60)
            .background(.appBg)
            .navigationBarHidden(true)
            .animation(.easeInOut(duration: 0.3), value: isTopBarVisible)
        }
    }
    
    private var categoryScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(viewModel.categories, id: \.self) { category in
                    CategoryButton(
                        title: category,
                        isSelected: viewModel.selectedCategory == category
                    ) {
                        viewModel.selectCategory(category)
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }
    
    private var contentCardsView: some View {
        ScrollView {
            VStack(spacing: 6) {
                ScrollViewOffsetReader { offset in
                    scrollOffset = offset

                    withAnimation(.easeInOut(duration: 0.3)) {
                        if offset < -40 {
                            isTopBarVisible = false
                        } else if offset < 10 {
                            isTopBarVisible = true
                        }
                    }
                }
                .frame(height: 0)

                LazyVGrid(
                    columns: [
                        GridItem(.adaptive(minimum: 216, maximum: 216),
                                 spacing: 6, alignment: .top),
                        GridItem(.adaptive(minimum: 216, maximum: 216),
                                 spacing: 6, alignment: .top)
                    ],
                    spacing: 6
                ) {
                    ForEach(viewModel.filteredItems, id: \.id) { item in
                        NavigationLink(destination: AIGenerationCardSingle(generator: generator, item: item)) {
                            AIGenerationCard(item: item)
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
        .coordinateSpace(name: "scroll")
    }
}

// MARK: CategoryButton
struct CategoryButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .modifier(CategoryButtonModifier())
                .kerning(0.4)
                .foregroundColor(isSelected ? .white : .primary)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isSelected ? Color.appPurpule : Color.gray.opacity(0.1))
                )
        }
    }
}

// MARK: ScrollOffsetPreferenceKey
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: ScrollViewOffsetReader
struct ScrollViewOffsetReader: View {
    var onOffsetChange: (CGFloat) -> Void

    var body: some View {
        GeometryReader { geometry in
            Color.clear
                .preference(key: ScrollOffsetPreferenceKey.self,
                            value: geometry.frame(in: .named("scroll")).minY)
        }
        .onPreferenceChange(ScrollOffsetPreferenceKey.self, perform: onOffsetChange)
    }
}


#Preview {
    let appState = AppState()
    return CustomTabBar()
        .environmentObject(appState)
}
