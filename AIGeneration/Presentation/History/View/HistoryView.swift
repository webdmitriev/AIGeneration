//
//  HistoryView.swift
//  AIGeneration
//
//  Created by Олег Дмитриев on 28.06.2025.
//

import SwiftUI

struct HistoryView: View {
    @Binding var selection: Int
    
    @State private var showSubscribeView = false
    
    @StateObject private var viewModel = HistoryViewModel()
    
    // заглушка
    private let listVideos: [String] = []
    
    private let widthScreen: CGFloat = UIScreen.main.bounds.width
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 22) {
                CustomTopBar(title: "History") {
                    showSubscribeView = true
                }
                .frame(height: 40)
                .clipped()
                
                tabPhotosView
            }
            .navigationDestination(isPresented: $showSubscribeView) {
                SubscribeView()
            }
            .frame(maxHeight: .infinity)
            .padding(.bottom, 60)
            .background(.appBg)
            .navigationBarHidden(true)
        }
    }
    
    private var tabPhotosView: some View {
        Group {
            if viewModel.items.count > 0 {
                contentCardsView
            } else {
                isEmptyView
            }
        }
    }
    
    private var isEmptyView: some View {
        VStack(spacing: 18) {
            Spacer()

            Text("Empty")
                .urbanist(.montserratBold, 24)
                .frame(maxWidth: .infinity, alignment: .center)
                .foregroundStyle(.appWhite)
            
            Text("Start generating right now")
                .urbanist(.montserratMedium, 16)
                .frame(maxWidth: .infinity, alignment: .center)
                .foregroundStyle(.appWhite.opacity(0.6))
            
            Button {
                withAnimation(.spring()) {
                    selection = 0
                }
            } label: {
                Text("View Templates")
                    .modifier(ButtonPurpuleModifier())
            }

            Spacer()
        }
        .padding(.horizontal, 16)
    }
    
    private var contentCardsView: some View {
        ScrollView {
            LazyVGrid(
                columns: [
                    GridItem(.adaptive(minimum: 216, maximum: 216),
                             spacing: 6, alignment: .top),
                    GridItem(.adaptive(minimum: 216, maximum: 216),
                             spacing: 6, alignment: .top)
                ],
                spacing: 6
            ) {
                ForEach(viewModel.items, id: \.id) { item in
                    NavigationLink(destination: AIGenerationCardSingle(item: item)) {
                        AIGenerationCard(item: item)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}
