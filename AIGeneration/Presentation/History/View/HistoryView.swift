//
//  HistoryView.swift
//  AIGeneration
//
//  Created by Олег Дмитриев on 28.06.2025.
//

import SwiftUI

struct HistoryView: View {
    @Binding var selection: Int
    
    @State private var showSettingsView: Bool = false
    @State private var tabToggle: Bool = true
    
    @StateObject private var viewModel = HistoryViewModel()
    
    // заглушка
    private let listVideos: [String] = []
    
    private let widthScreen: CGFloat = UIScreen.main.bounds.width
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 22) {
                CustomTopBar(title: "History", darkMode: true) {
                    showSettingsView = true
                }
                .frame(height: 40)
                .clipped()
                
                toogleBar
                
                if tabToggle {
                    tabPhotosView
                } else {
                    tabVideosView
                }
            }
            .navigationDestination(isPresented: $showSettingsView) {
                SettingsView()
            }
            .frame(maxHeight: .infinity)
            .padding(.bottom, 60)
            .background(.appBg)
            .navigationBarHidden(true)
        }
    }
    
    private var toogleBar: some View {
        HStack {
            Button {
                tabToggle.toggle()
            } label: {
                Text("Photo")
                    .frame(maxWidth: widthScreen / 2, maxHeight: 32, alignment: .center)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(tabToggle ? .appBlack : .appWhite)
                    .background(tabToggle ? .appWhite : .clear)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            Button {
                tabToggle.toggle()
            } label: {
                Text("Video")
                    .frame(maxWidth: widthScreen / 2, maxHeight: 32, alignment: .center)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(!tabToggle ? .appBlack : .appWhite)
                    .background(!tabToggle ? .appWhite : .clear)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .frame(maxWidth: .infinity)
        .background(.appWhite.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 16)
        .clipped()
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
    
    private var tabVideosView: some View {
        Group {
            if listVideos.count > 0 {
                Text("Videos")
                    .foregroundStyle(.appWhite)
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
